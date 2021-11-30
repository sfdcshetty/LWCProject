/*
    Name : CheckOpenNCNM
    TestClassName : CheckOpenNCNM_Test
    ScheduleClassName : CheckOpenNCNM_Scheduler
    Developer Name: Troy Solland
    Reviewed by : Troy Solland
    Description : Send Chatter post to household owner's CS Chatter Group
					for any open NCNM Opportunties related to a household with a New Money blot
*/

global class CheckOpenNCNM implements Database.Batchable<SObject>, Database.Stateful {
    
    global Iterable<sObject> start(Database.BatchableContext ctx){
        
        List<Opportunity> opptys = [SELECT Id, Household__c
                                   FROM Opportunity
                                   WHERE IsClosed = false
                                   AND Type = 'NCNM'
                                   AND Household__c != null];
        return opptys;

    }                
    
    global void execute(Database.BatchableContext ctx, List<Opportunity> scope) {
        
        try {
            
            // gather the account ids associated to the opportunities
            Set<Id> accountIds = new Set<Id>();
            for (Opportunity oppty : scope) {
                accountIds.add(oppty.Household__c);
            }
            
            // get the accounts and any New Money blots they may have
            Map<Id, Account> accts = new Map<Id, Account>([
                SELECT Id, OwnerId, Owner.CSChatterGroup__c
                , (SELECT Id FROM Blots__r WHERE WEGP1_BlotType__c = 'New Money')
                FROM Account
                WHERE Id IN :accountIds]);
            
            // list of batch inputs
            List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
            
            for (Opportunity oppty : scope) {
                
                // get the account associated with the oppty
                Account acct = accts.get(oppty.Household__c);
                
                // if the account was found and has New Money blots...
                if (acct != null && !acct.Blots__r.isEmpty()) {
                    
                    // construct the body
                    ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
                    body.messageSegments = new List <ConnectApi.MessageSegmentInput>();
                    
                    // add the mention to the post
                    //ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
                    //mentionSegment.Id = acct.OwnerId;
                    //body.messageSegments.add (mentionSegment);
                    
                    ConnectApi.TextSegmentInput textSegment1 = new ConnectApi.TextSegmentInput();
                    textSegment1.text = 'The following opportunity ';
                    body.messageSegments.add(textSegment1);
                    
                    ConnectApi.EntityLinkSegmentInput entityLinkSegmentInputOpportunity = new ConnectApi.EntityLinkSegmentInput();
                    entityLinkSegmentInputOpportunity.entityId = oppty.Id;
                    body.messageSegments.add(entityLinkSegmentInputOpportunity);
                    
                    ConnectApi.TextSegmentInput textSegment2 = new ConnectApi.TextSegmentInput();
                    textSegment2.text = ' is not closed. However, there is a New Money blot associated to the household. Please address this opportunity.';
                    textSegment2.text += ' This is a notification, please don’t respond to this notification. If you have questions, please reach out to ! ATO Support.';
                    body.messageSegments.add(textSegment2);
                    
                    // build the feed item input
                    ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
                    input.SubjectId = acct.Owner.CSChatterGroup__c;
                    input.Body = body;
                    ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
                    
                    // add the FeedItemInput instances to a list
                	batchInputs.add(batchInput);
                }
            }
            
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
            
        } catch(Exception e) {
            
        }
    }
    
    global void finish(Database.BatchableContext ctx){
    
    }
}