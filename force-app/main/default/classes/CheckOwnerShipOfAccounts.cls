/*
    Name : CheckOwnerShipOfAccounts
    TestClassName : CheckOwnerShipOfAccounts_TC
    ScheduleClassName : AccountOwnership_Scheduler
    Developer Name: K P Sai Sampath
    Reviewed by : Srikanth Valluri
    Description : Send Chatter post to record owner if owner profile is not Advisor
                  and  if the recortypes are Business,Household and Trust.
*/

global class CheckOwnerShipOfAccounts implements Database.Batchable<SObject>, Database.Stateful{
    Map <String, RecordType__mdt> recordTypeMetadata;
    
    global CheckOwnerShipOfAccounts () {
        recordTypeMetadata = new Map<String, RecordType__mdt>();
    }
    
    global Database.queryLocator start(Database.BatchableContext ctx){
        
        Set<String> recordTypeNames = new Set<String>();
        Set<String> profileNames = new Set<String>();
        for (RecordType__mdt r : [Select Id, Name__c, Profile__c, Message__c from RecordType__mdt]) {
            recordTypeNames.add(r.Name__c);
            profileNames.add(r.Profile__c);
            recordTypeMetadata.put(r.Name__c, r);
        }
        System.Debug ('>>>> Record Type Names: ' + recordTypeNames);
        System.Debug ('>>>> Profile Names: ' + profileNames);
        
        if (!Test.isRunningTest())
        	profileNames.add ('System Administrator');
        
        List<String> userRoles = new List<String>();
        userRoles.add('Tax Group');
        
        String query = 'SELECT Name, OwnerId, Owner.Profile.Name, Owner.UserRole.Name, RecordType.Name'
            + ' FROM Account'
            + ' WHERE Owner.Profile.Name NOT IN :profileNames'
            + ' AND Recordtype.Name IN :recordTypeNames'
            + ' AND Owner.UserRole.Name NOT IN :userRoles';
        
        System.debug('::: QUERY :::::' + query);
        return Database.getQueryLocator(query);
    }                
    
    global void execute(Database.BatchableContext ctx, List<Account> scope){
        try{
            List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
            for (Account acc :scope) {
                ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
                input.subjectId = acc.Id;
                ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
                body.messageSegments = new List <ConnectApi.MessageSegmentInput>();
                
                // add the mention to the post
                ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
                mentionSegment.id = acc.OwnerId;
                body.messageSegments.add (mentionSegment);
                
                ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = ' '+recordTypeMetadata.get (acc.RecordType.Name).Message__c;
                body.messageSegments.add(textSegment);
                
                input.body = body;
                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
                
                // add the FeedItemInput instances to a list
                batchInputs.add(batchInput);
            }
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
        }Catch(exception e){}
    }
    
    global void finish(Database.BatchableContext ctx){
    
    }
}