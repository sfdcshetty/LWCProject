public class Quik_SendChatterNotification {
    public static void sendNotification(Set<Id> asQuikFormGrpsIDs) {
        for(AS_Quik_Forms_Group__c eachRec : [SELECT DocuSign_Envelope_Status__c, Account_Servicing__c, CreatedBy.Name, 
                                              Financial_Account_Servicing__c, CreatedBy.Profile.Name, CreatedById, 
                                              Docusign_Envelope_Id__c, Account_Servicing__r.Related_Account__c, 
                                              Account_Servicing__r.Related_Account__r.Owner.CSChatterGroup__c, 
                                              Account_Servicing__r.Related_Account__r.Name, Account_Servicing__r.Name, 
                                              Financial_Account_Servicing__r.Name 
                                              FROM AS_Quik_Forms_Group__c 
                                              WHERE Id IN: asQuikFormGrpsIDs]) 
        {
            
            AS_Quik_Forms_Group__c oldRec = (AS_Quik_Forms_Group__c)Trigger.oldMap.get(eachRec.Id);
            if(oldRec.DocuSign_Envelope_Status__c != 'Completed' && eachRec.DocuSign_Envelope_Status__c == 'Completed') {
                if(eachRec.Account_Servicing__c != null && eachRec.Financial_Account_Servicing__c == null) {
                    // AS Chatter Notification to User
                    if(eachRec.CreatedBy.Profile.Name != 'System Administrator') {
                        chatterPostCallout(eachRec.CreatedById, eachRec.CreatedBy.Name, eachRec.Docusign_Envelope_Id__c, 
                                           eachRec.Account_Servicing__r.Related_Account__r.Name, 
                                           eachRec.Account_Servicing__r.Id);
                    } else {
                        // AS Chatter Notification to Group
                        if(eachRec.Account_Servicing__r.Related_Account__r.Owner.CSChatterGroup__c != null) {
                            chatterPostCallout(eachRec.Account_Servicing__r.Related_Account__r.Owner.CSChatterGroup__c,
                                               eachRec.Account_Servicing__r.Related_Account__r.Owner.CSChatterGroup__c, 
                                               eachRec.Docusign_Envelope_Id__c, 
                                               eachRec.Account_Servicing__r.Related_Account__r.Name, 
                                               eachRec.Account_Servicing__r.Id);
                        }
                    }
                }
                if(eachRec.Account_Servicing__c != null && eachRec.Financial_Account_Servicing__c != null) {
                    // FAS Chatter Notification to User
                    if(eachRec.CreatedBy.Profile.Name != 'System Administrator') {
                        chatterPostCallout(eachRec.CreatedById, eachRec.CreatedBy.Name, eachRec.Docusign_Envelope_Id__c, 
                                           eachRec.Account_Servicing__r.Related_Account__r.Name, 
                                           eachRec.Financial_Account_Servicing__r.Id);
                    }else {
                        // FAS Chatter Notification to Group:
                        if(eachRec.Account_Servicing__r.Related_Account__r.Owner.CSChatterGroup__c != null) {
                            chatterPostCallout(eachRec.Account_Servicing__r.Related_Account__r.Owner.CSChatterGroup__c, 
                                               eachRec.Account_Servicing__r.Related_Account__r.Owner.CSChatterGroup__c, 
                                               eachRec.Docusign_Envelope_Id__c, 
                                               eachRec.Account_Servicing__r.Related_Account__r.Name, 
                                               eachRec.Financial_Account_Servicing__r.Id);
                        }
                    }
                }
            }   
        }
    }
    
    // Method to check of environement is Production ORG or not
    public static String IsProductionOrg() { 
        Organization org = [SELECT IsSandbox FROM Organization WHERE Id = :UserInfo.getOrganizationId()];
        return (org.IsSandbox == true) ? 'https://test.salesforce.com' : 'https://login.salesforce.com';
    }
    
    // Method to initiate the chatter post from site guest user 
    @future(Callout = true)
    public static void chatterPostCallout(String parentId, String userOrGroupId, String envelopeId, 
                                          String relatedAccount, String asFasId) 
    {
        //Quik_Chatter_Post_Settings__c settings = Quik_Chatter_Post_Settings__c.getInstance(UserInfo.getUserID());
        Quik_Chatter_Post__mdt settings = [SELECT SF_Client_ID__c, SF_Client_Secret__c, SF_User_Name__c, 
                                           SF_User_Password__c FROM Quik_Chatter_Post__mdt 
                                           WHERE Label = 'Post To Feed'];
        
        Http h = new Http();
        HttpResponse res = new HttpResponse();
        
        String loginURL = IsProductionOrg();
        HttpRequest session = new HttpRequest();
        session.setEndpoint(loginURL + '/services/oauth2/token?grant_type=password&client_id=' 
                            + settings.SF_Client_ID__c + '&client_secret=' + settings.SF_Client_Secret__c 
                            + '&username=' + settings.SF_User_Name__c + '&password=' + settings.SF_User_Password__c);
        session.setMethod('POST');
        if(!Test.isRunningTest()) {
            res = h.send(session);
        } else {
            res.setStatusCode(200);
            res.setBody ('{"access_token" : "test", "instance_url" : "https://test.com"}');
        }
        if(res.getStatusCode() == 200) {
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            String accessToken = String.valueOf(response.get('access_token'));
            String instanceURL = String.valueOf(response.get('instance_url'));
            res = new HTTPResponse ();
            
            String reqBody = '{"parentId" : "' + parentId + '", "userOrGroupId" : "' + userOrGroupId 
                + '", "envelopeId" : "' + envelopeId + '", "relatedAccount" : "' + relatedAccount 
                + '", "asFasId" : "' + asFasId + '"}';
            
            HttpRequest req = new HTTPRequest ();
            req.setEndpoint(instanceURL + '/services/apexrest/quikChatterPost');        
            req.setBody(reqBody);
            req.setHeader('Authorization', 'OAuth ' + accesstoken);
            req.setHeader('Content-Type', 'application/json');
            req.setMethod('POST');
            req.setTimeOut(120000);
            if(!Test.isRunningTest()) {
                res = h.send(req);
            } else {
                RestRequest request = new RestRequest();
                request.requestUri ='https://test.salesforce.com/services/apexrest/quikChatterPost';
                request.httpMethod = 'POST';
                request.requestBody = Blob.valueof(reqBody);
                RestContext.request = request;
                Quik_ChatterPost.chatterPost();
            }
        }
    }
    
    public static void sendChatterFeed(String parentId, String userOrGroupId, String envelopeId, String relatedAccount, 
                                       String asFasId) 
    {
        String body1 = ', The Docusign Envelope Id: ' + envelopeId + ' for ' + relatedAccount + ' has been completed for ';
        
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();            
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();   
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.TextSegmentInput textSegmentInput1 = new ConnectApi.TextSegmentInput();
        
        textSegmentInput1.text = body1;   
        mentionSegmentInput.id = parentId; 
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        messageBodyInput.messageSegments.add(textSegmentInput1);
        
        ConnectApi.EntityLinkSegmentInput entityLinkSegmentInputAS = new ConnectApi.EntityLinkSegmentInput();
        
        entityLinkSegmentInputAS.entityId = asFasId;  
        messageBodyInput.messageSegments.add(entityLinkSegmentInputAS );        
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = asFasId; 
        
        if(!Test.isRunningTest()) {
            ConnectApi.FeedElement feedElement =
                ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
        }
    }
}