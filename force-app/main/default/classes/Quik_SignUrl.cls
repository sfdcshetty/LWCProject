//Test class - QuikFormHandler_TEST 
@RestResource(urlMapping='/quik_envelopeCallback')
global without sharing class Quik_SignUrl {   
    @HttpPost
    global static void doPost() {    
        RestRequest req1 = RestContext.request;
        RestResponse res1 = RestContext.response; 
        String reqBody1 = '';
        String uniqueId = '';
        if(!Test.isRunningTest())
        {
            reqBody1 = req1.requestBody.toString();
            uniqueId = req1.Params.get('id1');
        }
        if(Test.isRunningTest())
        {
            reqBody1 = ('{"ResultData":{"EnvelopeID":"b0368b9a-bf06-4306-ba37-ab9603f57c46","Uri":"/envelopes/b0368b9a-bf06-4306-ba37-' 
                        + 'ab9603f57c46","StatusDateTime":"2020-04-28T14:37:00.5470000Z","Status":"created"},"ErrorCode":0,"Message":' 
                        + '"","Errors":null}');
            uniqueId = '005R0000004zy6zIAA1588084474404';
        }
        Map<String, Object> fieldList = (Map<String, Object>)JSON.deserializeUntyped(reqBody1);
        Map<String, Object> items = (Map<String, Object>)fieldList.get('ResultData');
        
        String envelopeId = String.ValueOf(items.get('EnvelopeID'));
        Docusign_Credentails__mdt mdtSettings = [SELECT Endpoint__c, Integrator_Key__c, User_Name__c, Password__c 
                                                 FROM Docusign_Credentails__mdt WHERE DeveloperName = 'Receipients'];
        
        AS_Quik_Forms_Group__c formGroup = [SELECT Docusign_Envelope_Id__c, DocuSign_Envelope_Status__c, Recipients_Size__c 
                                            FROM AS_Quik_Forms_Group__c WHERE UniqueId__c = :uniqueId];
        formGroup.DocuSign_Envelope_Status__c = 'Draft';
        formGroup.Docusign_Envelope_Id__c = envelopeId;
        try {
            update formGroup;
        } catch(Exception exc) {
            QuikErrorLogGeneration.createErrorLog('', '', envelopeId, exc.getMessage(),'Quik_SignUrl','doPost',exc.getLineNumber());
        }
        String resBody = '{'
            +'"StatusCode": "0",'
            +'"Message" : "Your form has been uploaded for Signature.",'
            +'"StatusMessage": "Your form has been uploaded for Signature."'
            +'}';
        if(!Test.isRunningTest()) {
            RestResponse response = RestContext.response;
            response.addHeader('Content-Type', 'application/json');
            response.addHeader('Access-Control-Allow-Origin', '*');
            response.addHeader('Access-Control-Allow-Methods', 'GET, POST, PATCH, PUT, DELETE, OPTIONS');
            response.addHeader('Access-Control-Allow-Headers', 'Accept, Origin, Content-Type, Referer, User-Agent, X-Auth-Token');
            response.responseBody = Blob.valueOf(resBody);
            response.statusCode = 200;
        }
    }
    
    global static void updateReceipients(String envpId, List<Quik_SignUrl.receipients> signers, Docusign_Credentails__mdt mdtSettings, 
                                          String signType) 
    {
        String receipientEndpoint = mdtSettings.Endpoint__c + envpId + '/recipients';
        String  signerType = 'signers';
        if(signType == 'Carbon Copy') {
            signerType = 'carbonCopies';
        }
        String reqBody = formSignerJson(signers, signerType);
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
            if (!Test.isRunningTest()) {
                receipientResponse = http.send(receipientRequest);
            }
            if(receipientResponse.getStatusCode() != 200) {
                QuikErrorLogGeneration.createErrorLog(reqBody, receipientResponse.getBody(), envpId, '', 'Quik_SignUrl', 
                                                      'updateReceipients', null);
            }
        } catch(Exception exc) {
            QuikErrorLogGeneration.createErrorLog(reqBody, receipientResponse.getBody(), envpId, exc.getMessage(), 'Quik_SignUrl', 
                                                  'updateReceipients', exc.getLineNumber());
        }
    }
    
    global static void callDeleteRecipients(Map<String, List<String>> recptsToDeleted ) {
        Docusign_Credentails__mdt mdtSettings = [SELECT Endpoint__c, Integrator_Key__c, User_Name__c, Password__c 
                                                 FROM Docusign_Credentails__mdt
                                                 WHERE DeveloperName = 'Receipients'];
        for(String rec : recptsToDeleted.keySet()) {
            List<Receipients> recpToDel = new List<Receipients>();
            for(String recpId : recptsToDeleted.get(rec)) {
                Receipients recp = new Receipients();
                recp.receipientId = recpId;
                recpToDel.add(recp);
            }
            deleteReceipients (rec, recpToDel, mdtSettings);
        }
    }
    
    global static void deleteReceipients (String envpId, List<Receipients> signers, Docusign_Credentails__mdt mdtSettings) {
        String receipientEndpoint = mdtSettings.Endpoint__c + envpId + '/recipients';
        String reqBody = formSignerJson(signers, 'signers');
        HttpRequest receipientRequest = new HttpRequest();
        receipientRequest.setEndpoint(receipientEndpoint);
        receipientRequest.setHeader('X-DocuSign-Authentication', '{"IntegratorKey" : "' 
                                    + mdtSettings.Integrator_key__c + '", "Username" : "' 
                                    + mdtSettings.User_Name__c + '", "Password" : "' 
                                    + mdtSettings.Password__c + '"}');
        receipientRequest.setheader('Content-Type', 'application/json');
        receipientRequest.setMethod('DELETE');
        receipientRequest.setBody (reqBody);
        receipientRequest.setTimeout(120000);
        HTTP http = new HTTP();
        HttpResponse receipientResponse = new HttpResponse();
        try {
            if (!Test.isRunningTest()) {
                receipientResponse = http.send(receipientRequest);
            }
            if(receipientResponse.getStatusCode() != 200) {
                QuikErrorLogGeneration.createErrorLog(reqBody, receipientResponse.getBody(), envpId, '', 'Quik_SignUrl', 
                                                      'deleteReceipients', null);
            }
        } catch(Exception exc) {
            QuikErrorLogGeneration.createErrorLog(reqBody, receipientResponse.getBody(), envpId, exc.getMessage(), 'Quik_SignUrl', 
                                                  'deleteReceipients', exc.getLineNumber());
        }
    }
    
    @future(callout=true)
    global static void callAddccAddresses(Set<Id> asformIds) {
        Docusign_Credentails__mdt mdtSettings = [SELECT Endpoint__c, Integrator_Key__c, User_Name__c, Password__c 
                                                 FROM Docusign_Credentails__mdt WHERE DeveloperName = 'Receipients'];
        for(AS_Quik_Forms_Group__c asFormAndRecps : [SELECT Id, Docusign_Envelope_Id__c, UniqueId__c, 
                                                     Financial_Account_Servicing__r.WEG_Custodian_Info__c, 
                                                     (SELECT Id, Order__c FROM Recipients__r) 
                                                     FROM AS_Quik_Forms_Group__c WHERE Id IN :asformIds]) 
        {
            Integer routingOrderNum = 0;
            for(Recipients__c rec : asFormAndRecps.Recipients__r) {
                if(rec.Order__c > routingOrderNum) {
                    routingOrderNum = Integer.valueOf(rec.Order__c);
                }
            }
            sendEmail(asFormAndRecps.UniqueId__c, asFormAndRecps.Docusign_Envelope_Id__c, mdtSettings);
        }
    }
    
    global static void sendEmail(String uniqueId, String envelopeId, Docusign_Credentails__mdt mdtSettings) {
        String emailEndpoint = mdtSettings.Endpoint__c + envelopeId;   
        String emailRequestBody = '{"status": "sent", "useDisclosure": "true"}';  
        HttpRequest emailRequest = new HttpRequest();
        emailRequest.setEndpoint(emailEndpoint);
        emailRequest.setHeader('X-DocuSign-Authentication', '{"IntegratorKey" : "' + mdtSettings.Integrator_key__c 
                               + '", "Username" : "' + mdtSettings.User_Name__c 
                               + '", "Password" : "' + mdtSettings.Password__c + '"}');
        emailRequest.setheader('Content-Type', 'application/json');
        emailRequest.setMethod('PUT');
        emailRequest.setBody(emailRequestBody);
        emailRequest.setTimeout(120000);
        HTTP emailHttp = new HTTP();
        HttpResponse emailResponse = new HttpResponse();
        try {
            if(!Test.isRunningTest()) {
                emailResponse = emailHttp.send(emailRequest);
            }
            if(emailResponse.getStatusCode() != 200) {
                QuikErrorLogGeneration.createErrorLog(emailRequestBody, emailResponse.getBody(), envelopeId, '', 'Quik_SignUrl', 
                                                      'sendEmail', null);
            }
        } catch(Exception exc) {
            QuikErrorLogGeneration.createErrorLog(emailRequestBody, emailResponse.getBody(), envelopeId, exc.getMessage(), 'Quik_SignUrl', 
                                                  'sendEmail', exc.getLineNumber());
        }
        if(Test.isRunningTest()) {
            emailResponse.setBody('{"envelopeId" : "test", "Status" : "Sent", "url" : "test.com"}');
            emailResponse.setStatusCode(201);
        }
    }
    
    // Method to prepare the request body for the Docusign cc recipients
    public static String prepareReceipientsReqBody(String uniqueId, String envelopeId, Integer recpCount, Id custoInfId, Integer routingOrder) {
        String body = '';
        try {
            for (Custodian_Info__c ccAddresses : [SELECT Custodian_Email_1__c, Custodian_Email_2__c, Custodian_Phone__c, 
                                                  WEG_eSign_Authorization_Type__c 
                                                  FROM Custodian_Info__c WHERE Id = :custoInfId LIMIT 1]) 
            {
                Map<String, String> emailAndNames = new Map<String, String>();
                if(ccAddresses.Custodian_Email_1__c != null && ccAddresses.Custodian_Email_1__c != '') {
                    emailAndNames.put('CC1', ccAddresses.Custodian_Email_1__c);
                }
                if(ccAddresses.Custodian_Email_2__c != null && ccAddresses.Custodian_Email_2__c != '') {
                    emailAndNames.put('CC2', ccAddresses.Custodian_Email_2__c);  
                } 
                String replaceValueOfJson = '';
                body += '{"carbonCopies": [';
                Integer count = 1;
                count = count + recpCount;
                Integer routingCount = routingOrder + 1;
                for (String cus : emailAndNames.keySet()) {
                    body += '{"email": "' + emailAndNames.get(cus)
                        + '","name": "' + cus
                        + '","idCheckConfigurationName": "' + replaceValueOfJson
                        + '","routingOrder": "' + routingCount
                        + '","recipientId": "' + count + '"},';   
                    ++count;
                    ++routingCount;
                }
                body = body.removeEnd(',');
                body += ']}';
            }
        } catch (Exception e) {}
        return body;
    }
    
    global class receipients {
        global String receipientId;
        global String roleName;
        global String name;
        global String email;
        global String routingOrder;
        global String senderNumber;
        global String signType;
        global String signerType;
        global String idCheckConfigurationName;
    }
    
    public Static String formSignerJson(List<Quik_SignUrl.receipients> wrapList, String signType) {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();     
        gen.writeFieldName(signType);
        gen.writeStartArray();
        for(Receipients wc : wraplist) {
            String email = wc.email != null ? wc.email : '';
            String name = wc.name != null ? wc.name : '';
            String phone = wc.senderNumber != null ? wc.senderNumber : '';
            String recipientId = wc.receipientId != null ? wc.receipientId : '';
            String idCheckConfigNameReplace = '';
            if(wc.idCheckConfigurationName == 'SMS') {
                idCheckConfigNameReplace = 'SMS Auth $';
            } else if(wc.idCheckConfigurationName == 'KBA') {
                idCheckConfigNameReplace = 'ID Check $';
            }
            List<String> phoneNumbers = new List<String>();
            if(phone != '' && idCheckConfigNameReplace == 'SMS Auth $') {
                phoneNumbers.add(phone);
            }
            gen.writeStartObject();
            gen.writeStringField('email', email);
            gen.writeStringField('name', name);
            gen.writeStringField('recipientId', recipientId);
            gen.writeStringField('idCheckConfigurationName', idCheckConfigNameReplace);
            if(phoneNumbers.size() > 0) {
                gen.writeFieldName('smsAuthentication');
                gen.writeStartObject();
                gen.writeObjectField('senderProvidedNumbers', phoneNumbers);
                gen.writeEndObject();
            }
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();
        String jsonData = gen.getAsString();
        return jsonData;
    }
    
    // To get the signed copy and certificate copy as one PDF
    global static void getCombinedDocuments(String envpId, String recId) {
        AS_Quik_Forms_Group__c asQFGroup = [SELECT Account_Servicing__r.Related_Account__r.WEGP1_WEGID__c, 
                                            Account_Servicing__r.Related_Account__r.Name, Account_Servicing__r.Related_Account__r.CreatedDate 
                                            FROM AS_Quik_Forms_Group__c WHERE Docusign_Envelope_Id__c = :envpId];
        Docusign_Credentails__mdt mdtSettings = [SELECT Endpoint__c, Integrator_Key__c, User_Name__c, Password__c 
                                                 FROM Docusign_Credentails__mdt WHERE DeveloperName = 'Receipients'];
        String receipientEndpoint = mdtSettings.Endpoint__c + envpId + '/documents/combined';
        HttpRequest receipientRequest = new HttpRequest();
        receipientRequest.setEndpoint(receipientEndpoint);
        receipientRequest.setHeader('X-DocuSign-Authentication', '{"IntegratorKey" : "' 
                                    + mdtSettings.Integrator_key__c + '", "Username" : "' 
                                    + mdtSettings.User_Name__c + '", "Password" : "' 
                                    + mdtSettings.Password__c + '"}');
        receipientRequest.setheader('Content-Type', 'application/json');
        receipientRequest.setMethod('GET');
        receipientRequest.setTimeout(120000);
        HTTP http = new HTTP();
        HttpResponse receipientResponse = new HttpResponse();
        try {
            if (!Test.isRunningTest()) {
                receipientResponse = http.send(receipientRequest);
                //String attachmentName = System.Label.Cloud_File_Attachment_Name;
                String attachmentName = asQFGroup.Account_Servicing__r.Related_Account__r.WEGP1_WEGID__c + '_';
                attachmentName += asQFGroup.Account_Servicing__r.Related_Account__r.Name + '_';
                attachmentName += asQFGroup.Account_Servicing__r.Related_Account__r.CreatedDate + '.pdf';
                uploadFileAsCloudFile.createCloudFile(attachmentName, 'application/pdf', 10000, recId, receipientResponse.getBodyAsBlob());
            }
            if(receipientResponse.getStatusCode() != 200) {
                QuikErrorLogGeneration.createErrorLog('', receipientResponse.getBody(), envpId, '', 'Quik_SignUrl', 
                                                      'getReceipientsWrapper', null);
            }
        } catch(Exception exc) {
            QuikErrorLogGeneration.createErrorLog('', receipientResponse.getBody(), envpId, exc.getMessage(), 'Quik_SignUrl', 
                                                  'getReceipientsWrapper', exc.getLineNumber());
        }
    }
}