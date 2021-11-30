/*
 *  Schedule Class Name: Account_OwnerProfileRole_Scheduler
 *  Test Class Name: CheckAdvisorRoleOfIndividualAccounts_TC
*/
global class CheckAdvisorRoleOfIndividualAccounts implements Database.Batchable<SObject>{
    
    global Database.queryLocator start(Database.BatchableContext ctx){
        
        String recordType = System.label.Individual_RecordType;
        Set<String> profileNames = new Set<String>();
        for (RecordType__mdt r : [Select Id, Name__c, Profile__c, Message__c from RecordType__mdt]) {
            profileNames.add(r.Profile__c);
        }
        System.Debug ('>>>> Profile Names: ' + profileNames);
        
        if (!Test.isRunningTest())
        	profileNames.add ('System Administrator');
        
        List<String> userRoles = new List<String>();
        userRoles.add('Tax Group');
        
        String classification = 'Partner';
        
        String query = 'SELECT OwnerId, Owner.Profile.Name, RecordType.Name, WEGP1_Primary_Household__c, Owner.UserRole.Name,'
            + ' WEGP1_Primary_Household__r.ownerid, WEGP1_Primary_Household__r.Owner.Profile.Name'
            + ' FROM Account '
            + ' WHERE Recordtype.Name = :recordType'
            + ' AND Owner.Profile.Name NOT IN :profileNames'
            + ' AND Owner.UserRole.Name NOT IN :userRoles'
            + ' AND Type != :classification';
            
        System.debug('::: QUERY :::::' + query);
        return Database.getQueryLocator(query);
    }                
    
    global void execute(Database.BatchableContext ctx, List<Account> scope){
        List <ConnectApi.BatchInput> chatterPostList = new List <ConnectApi.BatchInput>();
        try {
            for (Account acc:scope) {
                ConnectApi.BatchInput chatterPostRec = chatterPost (acc);
                chatterPostList.add (chatterPostRec);
            }
            ConnectApi.ChatterFeeds.postFeedElementBatch (Network.getNetworkId(), chatterPostList);
        }
        catch (Exception e) {}
    }    
    global void finish(Database.BatchableContext ctx){
    }
    
    public ConnectApi.BatchInput chatterPost (Account acc) {
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        input.subjectId = acc.ID;
        ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
        body.messageSegments = new List <ConnectApi.MessageSegmentInput>();
        
        // add the mention to the post
        ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
        mentionSegment.id = acc.OwnerId;
        body.messageSegments.add (mentionSegment);
        
        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = ' '+Label.Individual_Owner_Message;
        body.messageSegments.add(textSegment);
        
        input.body = body;
        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
        return batchInput;
    }
}