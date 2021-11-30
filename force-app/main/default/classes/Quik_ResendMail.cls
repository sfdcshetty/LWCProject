/*
Created By: Bigworks
Created Date: 30/09/2020
Test Class: QuikFormHandler_TEST
Lightning Component: Quik_ResendMailComponent
Description: To resend the document to the particular recipient
*/
public class Quik_ResendMail {
    @AuraEnabled
    public static String resendEnvelope(String recId) {
        String status = '';
        
        Docusign_Credentails__mdt mdtSettings = [SELECT Endpoint__c, Integrator_Key__c, User_Name__c, Password__c 
                                                 FROM Docusign_Credentails__mdt
                                                 WHERE DeveloperName = 'Receipients'];
        
        Recipients__c recp = [SELECT Docusign_Recipient_Id__c, AS_Quik_Forms_Group__r.Docusign_Envelope_Id__c, Status__c 
                              FROM Recipients__c WHERE Id = :recId LIMIT 1];
        
        if(recp.Status__c == 'Sent') {
            String receipientEndpoint = mdtSettings.Endpoint__c + recp.AS_Quik_Forms_Group__r.Docusign_Envelope_Id__c 
                						+ '/recipients?resend_envelope=true';
            String reqBody = '{"signers" : [{ "recipientId" : "' + recp.Docusign_Recipient_Id__c + '" }] }';
            
            HttpRequest receipientRequest = new HttpRequest();
            receipientRequest.setEndpoint(receipientEndpoint);
            receipientRequest.setHeader('X-DocuSign-Authentication', '{"IntegratorKey" : "' 
                                        + mdtSettings.Integrator_key__c + '", "Username" : "' 
                                        + mdtSettings.User_Name__c + '", "Password" : "' 
                                        + mdtSettings.Password__c + '"}');
            receipientRequest.setheader('Content-Type', 'application/json');
            receipientRequest.setMethod('PUT');
            receipientRequest.setBody (reqBody);
            receipientRequest.setTimeout(120000);
            
            HTTP http = new HTTP();
            HttpResponse receipientResponse = new HttpResponse();
            try {
                if(!Test.isRunningTest()) {
                    receipientResponse = http.send(receipientRequest);
                }
                if(receipientResponse.getStatusCode() != 200) {
                    QuikErrorLogGeneration.createErrorLog(reqBody, receipientResponse.getBody(), 
                                                          recp.AS_Quik_Forms_Group__r.Docusign_Envelope_Id__c, '', 
                                                          'Quik_ResendMail', 'resendEnvelope', null);
                }
            } catch(Exception exc) {
                QuikErrorLogGeneration.createErrorLog(reqBody, receipientResponse.getBody(), 
                                                      recp.AS_Quik_Forms_Group__r.Docusign_Envelope_Id__c, exc.getMessage(), 
                                                      'Quik_ResendMail', 'resendEnvelope', exc.getLineNumber());
            }
        }
        return recp.Status__c;
    }
}