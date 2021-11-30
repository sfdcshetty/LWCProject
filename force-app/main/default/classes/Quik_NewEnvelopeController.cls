public class Quik_NewEnvelopeController {
    
    @AuraEnabled
    public Static List<Recipients__c> getSignerDetails(String accountServicingId) {
        List<Recipients__c> asSignerList = new List<Recipients__c>();
        List<Account_Servicing__c> accoutServicingDetails = [SELECT WEGP1_Primary_Individual__r.Account.Name, WEGP1_Primary_Individual__r.Email, 
                                                             WEGP1_Primary_Individual__r.MobilePhone, WEGP1_Secondary_Individual__r.Account.Name, 
                                                             WEGP1_Secondary_Individual__r.Email, 
                                                             WEGP1_Secondary_Individual__r.MobilePhone, Related_Account__c, 
                                                             WEG_HH_Business_Owner__c, HH_Business_Owner_Email__c, 
                                                             HH_Business_Owner_Mobile_Phone__c                 
                                                             FROM Account_Servicing__c WHERE Id = :accountServicingId];
        if(accoutServicingDetails[0].WEGP1_Primary_Individual__c != null) {
            Recipients__c asSigner1 = new Recipients__c();
            asSigner1.Name__c = accoutServicingDetails[0].WEGP1_Primary_Individual__r.Account.Name;
            asSigner1.Email__c = accoutServicingDetails[0].WEGP1_Primary_Individual__r.Email;
            asSigner1.Phone_Number__c = accoutServicingDetails[0].WEGP1_Primary_Individual__r.MobilePhone;
            asSigner1.Order__c = 1;
            asSigner1.Sign_Type__c = 'Sign';
            asSigner1.Signer_Type__c = 'Primary';
            asSignerList.add(asSigner1);
        }
        if(accoutServicingDetails[0].WEGP1_Secondary_Individual__c != null) {
            Recipients__c asSigner2 = new Recipients__c();
            asSigner2.Name__c = accoutServicingDetails[0].WEGP1_Secondary_Individual__r.Account.Name;
            asSigner2.Email__c = accoutServicingDetails[0].WEGP1_Secondary_Individual__r.Email;
            asSigner2.Phone_Number__c = accoutServicingDetails[0].WEGP1_Secondary_Individual__r.MobilePhone;
            asSigner2.Order__c = 2;
            asSigner2.Sign_Type__c = 'Sign';
            asSigner2.Signer_Type__c = 'Secondary';
            asSignerList.add(asSigner2);
        }
        if(accoutServicingDetails[0].Related_Account__c != null) {
            Recipients__c asRep = new Recipients__c();
            asRep.Name__c = accoutServicingDetails[0].WEG_HH_Business_Owner__c;
            asRep.Email__c = accoutServicingDetails[0].HH_Business_Owner_Email__c;
            asRep.Phone_Number__c = accoutServicingDetails[0].HH_Business_Owner_Mobile_Phone__c;
            asRep.Signer_Type__c = 'Advisor';
            asSignerList.add (asRep);
        }
        return asSignerList;
    }
    
    @AuraEnabled
    public static List<DocOrderClass> getDocumentOrder(String formGroupId ) {
        List<DocOrderClass> documentOrderWrap = new List<DocOrderClass>();
        Map<String, String> UniqueIdAndForm = new Map<String, String>();
        Map<String, String> grpAndUniqueId = new Map<String, String>();
        Map<String, String> CustodianMap = new Map<String, String>();
        Map<String, String> formIdMap = new Map<String, String>();
        Map<String, String> deliverToMap = new Map<String, String>();
        Map<String, String> createdDateMap = new Map<String, String>();
        Map<String, List<Recipients__c>> docAndRelatedTo = new Map<String, List<Recipients__c>>();
        List<AS_Quik_Forms_Group__c> quikFormList = [SELECT Name, FormName__c, Account_Servicing__c, Financial_Account_Servicing__c,
                                                     Financial_Account_Servicing__r.WEG_Custodian__c,UniqueId__c, Custodian__c, 
                                                     Financial_Account_Servicing__r.WEG_Custodian_Info__r.Custodian_Email_1__c,
                                                     Financial_Account_Servicing__r.WEG_Custodian_Info__r.Custodian_Email_2__c,
                                                     Financial_Account_Servicing__r.WEG_Custodian_Info__r.Custodian_Name__c,
                                                     Financial_Account_Servicing__r.Name, FAS_Id_List__c, FAS_List__c, Callout_Status__c, 
                                                     CreatedDate FROM AS_Quik_Forms_Group__c 
                                                     WHERE Callout_Status__c = 'Completed' AND Account_Servicing__c = :formGroupId 
                                                     AND DocuSign_Envelope_Status__c != 'Completed' ORDER BY CreatedDate ASC];
        for(AS_Quik_Forms_Group__c each : quikFormList) {
            grpAndUniqueId.put(each.Name, each.UniqueId__c);
            createdDateMap.put(each.Name, String.valueOf(each.CreatedDate));
            if(each.Custodian__c == null ) {
                CustodianMap.put(each.Name, '');
            } else {
                CustodianMap.put(each.Name, each.Financial_Account_Servicing__r.WEG_Custodian__c);  
                String email1 = each.Financial_Account_Servicing__r.WEG_Custodian_Info__r.Custodian_Email_1__c;
                String email2 = each.Financial_Account_Servicing__r.WEG_Custodian_Info__r.Custodian_Email_2__c;
                String deliverCustodian = '';
                if(each.FAS_List__c.contains('Household / Business')) {
                    deliverCustodian += 'WEAS, ';
                }
                if(each.Custodian__c.contains(', ')) {
                    for(String str : each.Custodian__c.split(', ')) {
                        deliverCustodian += str + ', ';
                    }
                } else {
                    deliverCustodian += each.Custodian__c + ', ';
                }
                deliverToMap.put(each.Id, deliverCustodian.removeEnd(', '));
            }
        }
        for(AS_Quik_Forms__c each : [SELECT Name, UniqueId__c, Form_Numbers__c, AS_Quik_Forms_Group__r.Id, CreatedDate 
                                     FROM AS_Quik_Forms__c WHERE UniqueId__c != null AND AS_Quik_Forms_Group__r.Id IN :quikFormList])
        {
            UniqueIdAndForm.put(each.UniqueId__c, each.Form_Numbers__c);
            formIdMap.put(each.AS_Quik_Forms_Group__r.Id, each.Id);
        }
        for(Recipients__c each : [SELECT Name__c, AS_Quik_Form__c, AS_Quik_Forms_Group__c, Document_Order__c, AS_Quik_Forms_Group__r.Name, 
                                  Email__c, Envelope_Id__c, WEG_eSign_Authorization_Type__c, Order__c, Phone_Number__c, 
                                  Related_To__c, Role__c, Signer_Type__c, Sign_Type__c, Status__c
                                  FROM Recipients__c 
                                  WHERE AS_Quik_Forms_Group__c IN :quikFormList])
        {
            if (docAndRelatedTo.containsKey(each.AS_Quik_Forms_Group__r.Name)) {
                docAndRelatedTo.get(each.AS_Quik_Forms_Group__r.Name).add(each);
            } else {
                docAndRelatedTo.put(each.AS_Quik_Forms_Group__r.Name, new List<Recipients__c>{ each });
            } 
        }
        for(AS_Quik_Forms_Group__c each : quikFormList) {
            String uniqueId = grpAndUniqueId.get(each.Name);
            DateTime createdDateTimeValue = DateTime.valueOf(createdDateMap.get(each.Name));
            String modifiedDateTime = createdDateTimeValue.format('dd-MM-yyyy hh:mm:ss a');
            if(deliverToMap.get(each.Id) != null) {
                documentOrderWrap.add(new DocOrderClass('', CustodianMap.get(each.Name), each, formIdMap.get(each.Id), 
                                                        UniqueIdAndForm.get(uniqueId), docAndRelatedTo.get(each.Name), 
                                                        deliverToMap.get(each.Id), modifiedDateTime));
            } else {
                documentOrderWrap.add(new DocOrderClass('', CustodianMap.get(each.Name), each, formIdMap.get(each.Id), 
                                                        UniqueIdAndForm.get(uniqueId), docAndRelatedTo.get(each.Name), 'WEAS', 
                                                        modifiedDateTime));
            }
        }
        return  documentOrderWrap;
    }
    
    public class DocOrderClass{
        @AuraEnabled 
        public String  orderWrap;
        @AuraEnabled 
        public String  custodianValue;
        @AuraEnabled 
        public AS_Quik_Forms_Group__c  nameWrap;
        @AuraEnabled 
        public String formId;
        @AuraEnabled 
        public String formNumber;
        @AuraEnabled 
        public List<Recipients__c> recipients;
        @AuraEnabled 
        public String deliverTo;
        @AuraEnabled 
        public String createdDate;
        
        public DocOrderClass(String order, String custodian, AS_Quik_Forms_Group__c Name, String quikFormId, String formNumbers, 
                             List<Recipients__c> reci, String deliverToName, String created_date)
        {
            orderWrap = order;
            custodianValue = custodian;
            nameWrap = Name;
            formId = quikFormId;
            formNumber = formNumbers;
            recipients = reci;
            deliverTo =   deliverToName;
            createdDate = created_date;
        }
    }
    
    @AuraEnabled
    public static List<String> sendMailToSigners(String detailsInOrder, List<Recipients__c> signersList) {
        List<String> qfGroupIdList = new List<String>();
        JSONParser parser = JSON.createParser(detailsInOrder);
        while(parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                parser.nextValue();
                if(parser.getCurrentName() == 'recipients') {
                    while(parser.nextToken() != JSONToken.END_ARRAY) {
                        if(parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                            parser.nextValue();
                            if(parser.getCurrentName() == 'AS_Quik_Forms_Group__c') {
                                qfGroupIdList.add(parser.getText());
                            }
                        }
                    }
                }
            }
        }
        Docusign_Credentails__mdt mdtSettings = [SELECT Endpoint__c, Integrator_Key__c, User_Name__c, Password__c 
                                                 FROM Docusign_Credentails__mdt WHERE DeveloperName = 'Receipients'];
        List<AS_Quik_Forms_Group__c> qfGroupRecs = [SELECT Docusign_Envelope_Id__c, Recipients_Size__c, DocuSign_Envelope_Status__c, 
                                                    Financial_Account_Servicing__r.WEG_Custodian_Info__r.WEG_eSign_Authorization_Type__c, 
                                                    (SELECT Id, Name__c, Email__c, Order__c, Sign_Type__c, Docusign_Recipient_Id__c, 
                                                     Phone_Number__c, Signer_Type__c, WEG_eSign_Authorization_Type__c, AS_Quik_Forms_Group__c,
                                                     AS_Quik_Forms_Group__r.Financial_Account_Servicing__r.WEG_Custodian_Info__r.WEG_eSign_Authorization_Type__c
                                                     FROM Recipients__r ORDER BY Order__c ASC) 
                                                    FROM AS_Quik_Forms_Group__c WHERE Id IN :qfGroupIdList];
        Map<Id, Recipients__c> docuSignRecipientToUpdate = new Map<Id, Recipients__c>();
        for(AS_Quik_Forms_Group__c qfRec : qfGroupRecs) {
            Map<String, Recipients__c> recipientIdUpdateFromDS = new Map<String, Recipients__c>();
            Map<String, Recipients__c> recipientIdUpdateFromDSName = new Map<String, Recipients__c>();
            Map<Id, Recipients__c> recipientRecWithId = new Map<Id, Recipients__c>();
            for(Recipients__c record : qfRec.Recipients__r) {
                recipientIdUpdateFromDS.put(record.Signer_Type__c, record);
                recipientIdUpdateFromDSName.put(record.Name__c, record);
                recipientRecWithId.put(record.Id, record);
            }
            String receipientEndpoint = mdtSettings.Endpoint__c + qfRec.Docusign_Envelope_Id__c + '/recipients';
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
            HTTPResponse res = new HTTPResponse ();
            try {
                if(!Test.isRunningTest()) {
                    res = http.send(receipientRequest);
                }
                if(res.getStatusCode() != 200) {
                    QuikErrorLogGeneration.createErrorLog('', res.getBody(), '', '', 'Quik_NewEnvelopeController', 'getRecipients', null);
                }
            } catch(Exception exc) {
                QuikErrorLogGeneration.createErrorLog('', res.getBody(), '', exc.getMessage(), 'Quik_NewEnvelopeController', 
                                                      'getRecipients', exc.getLineNumber());
            }
            
            if (Test.isRunningTest()) {
                res.setStatusCode(200);
                String resultBody = '{"signers": [{"creationReason": "sender","isBulkRecipient": "false","name": "1own_0.Name",';
                resultBody += '"email": "1own_0.Mail@test.com","recipientId": "1","recipientIdGuid": "02508aca-ec88-44e5-8e22-2c62b8dce263",';
                resultBody += '"requireIdLookup": "false","userId": "f0b9bd75-72b5-40b0-9bc4-419d720d8546","routingOrder": "1",';
                resultBody += '"status": "created"},{"creationReason": "sender","isBulkRecipient": "false","name": "2own_0.Name",';
                resultBody += '"email": "2own_0.Mail@test.com","recipientId": "2","recipientIdGuid": "f6ac4895-fd32-4aca-bac9-e9351ba018a4",';
                resultBody += '"requireIdLookup": "false","userId": "588ab78a-93c0-49cc-9436-f311530a9d89","routingOrder": "1",';
                resultBody += '"status": "created"},{"creationReason": "sender","isBulkRecipient": "false","name": "3own_0.Name",';
                resultBody += '"email": "3own_0.Mail@test.com","recipientId": "3","recipientIdGuid": "26039a90-65f2-4f11-a987-16f3f67a8100",';
                resultBody += '"requireIdLookup": "false","userId": "d2fb5b0e-ae56-4f0b-82a0-cb771b4869c3","routingOrder": "2",';
                resultBody += '"status": "created"}],"agents": [],"editors": [],"intermediaries": [],"carbonCopies": [],';
                resultBody += '"certifiedDeliveries": [],"inPersonSigners": [],"seals": [],"witnesses": [],"recipientCount": "3"}';
                res.setBody(resultBody);
            }
            
            Integer ccRecipientIdUpdate = 0;
            Quik_RecipientDetailsJSON obj = Quik_RecipientDetailsJSON.parse(res.getBody());
            List<Quik_SignUrl.Receipients> recpToDel = new List<Quik_SignUrl.Receipients>();
            Map<String, Quik_RecipientDetailsJSON.cls_signers> recpJsonRecpIdMap = new Map<String, Quik_RecipientDetailsJSON.cls_signers>();
            Map<String, List<Quik_RecipientDetailsJSON.cls_signers>> recpJsonRoutingOrderMap = new 
                Map<String, List<Quik_RecipientDetailsJSON.cls_signers>>();
            for(Quik_RecipientDetailsJSON.cls_signers data : obj.signers) {
                recpJsonRecpIdMap.put(data.recipientId, data);
                if(recpJsonRoutingOrderMap.containsKey(data.routingOrder)) {
                    recpJsonRoutingOrderMap.get(data.routingOrder).add(data);
                } else {
                    recpJsonRoutingOrderMap.put(data.routingOrder, new List<Quik_RecipientDetailsJSON.cls_signers>{ data });
                }
            }
            List<String> completedRecipientIdsInSF = new List<String>();
            List<String> completedRecipientIdsInJson = new List<String>();
            for(Id recpId : recipientRecWithId.keySet()) {
                Recipients__c recpRec = recipientRecWithId.get(recpId);
                for(String str : recpJsonRecpIdMap.keySet()) {
                    Quik_RecipientDetailsJSON.cls_signers quikRecpJsonRec = recpJsonRecpIdMap.get(str);
                    if((String.valueOf(recpRec.Order__c) == quikRecpJsonRec.routingOrder) && (recpRec.Email__c == quikRecpJsonRec.email)) {
                        if(!completedRecipientIdsInSF.contains(recpId)) {
                            if(!completedRecipientIdsInJson.contains(str)) {
                                recpRec.Docusign_Recipient_Id__c = quikRecpJsonRec.recipientId;
                                for(Recipients__c signerRecp : signersList) {
                                    if((recpRec.Name__c == signerRecp.Name__c) && (recpRec.Email__c == signerRecp.Email__c)) {
                                        if(recpRec.Phone_Number__c != signerRecp.Phone_Number__c) {
                                            recpRec.Phone_Number__c = signerRecp.Phone_Number__c;
                                        }
                                    } else if(recpRec.Email__c == signerRecp.Email__c) {
                                        if(recpRec.Name__c != signerRecp.Name__c) {
                                            recpRec.Name__c = signerRecp.Name__c;
                                        }
                                        if(recpRec.Phone_Number__c != signerRecp.Phone_Number__c) {
                                            recpRec.Phone_Number__c = signerRecp.Phone_Number__c;
                                        }
                                    }
                                }
                                docuSignRecipientToUpdate.put(recpId, recpRec);
                                completedRecipientIdsInSF.add(recpId);
                                completedRecipientIdsInJson.add(quikRecpJsonRec.recipientId);
                            }
                        }
                    } else if(recpRec.Email__c == quikRecpJsonRec.email) {
                        if(!completedRecipientIdsInSF.contains(recpId)) {
                            if(!completedRecipientIdsInJson.contains(str)) {
                                recpRec.Docusign_Recipient_Id__c = quikRecpJsonRec.recipientId;
                                recpRec.Order__c = Decimal.valueOf(quikRecpJsonRec.routingOrder);
                                for(Recipients__c signerRecp : signersList) {
                                    if((recpRec.Name__c == signerRecp.Name__c) && (recpRec.Email__c == signerRecp.Email__c)) {
                                        if(recpRec.Phone_Number__c != signerRecp.Phone_Number__c) {
                                            recpRec.Phone_Number__c = signerRecp.Phone_Number__c;
                                        }
                                    } else if(recpRec.Email__c == signerRecp.Email__c) {
                                        if(recpRec.Name__c != signerRecp.Name__c) {
                                            recpRec.Name__c = signerRecp.Name__c;
                                        }
                                        if(recpRec.Phone_Number__c != signerRecp.Phone_Number__c) {
                                            recpRec.Phone_Number__c = signerRecp.Phone_Number__c;
                                        }
                                    }
                                }
                                docuSignRecipientToUpdate.put(recpId, recpRec);
                                completedRecipientIdsInSF.add(recpId);
                                completedRecipientIdsInJson.add(quikRecpJsonRec.recipientId);
                            }
                        }
                    }
                }
            }
            for(Quik_RecipientDetailsJSON.cls_carbonCopies data : obj.carbonCopies) {
                if(recipientIdUpdateFromDSName.containsKey(data.name)) {
                    ++ccRecipientIdUpdate;
                    Recipients__c recpRec = recipientIdUpdateFromDSName.get(data.name);
                    recpRec.Docusign_Recipient_Id__c = data.recipientId;
                    docuSignRecipientToUpdate.put(recpRec.Id, recpRec);
                }
            }
        }
        update docuSignRecipientToUpdate.values();
        
        List<Recipients__c> recipientsToDelete = [SELECT Id, Docusign_Recipient_Id__c FROM Recipients__c 
                                                  WHERE AS_Quik_Forms_Group__c IN : qfGroupIdList AND Docusign_Recipient_Id__c = null];
        delete recipientsToDelete;
        return qfGroupIdList;
    }
    
    @AuraEnabled
    public static void callDS(List<String> qfGroupIdList) {
        List<Recipients__c> callDSRecp = [SELECT AS_Quik_Forms_Group__c, Document_Order__c, Docusign_Recipient_Id__c, Email__c, 
                                          WEG_eSign_Authorization_Type__c, Phone_Number__c, Name__c, Role__c, Sign_Type__c, 
                                          Signer_Type__c, Status__c, AS_Quik_Forms_Group__r.Docusign_Envelope_Id__c 
                                          FROM Recipients__c 
                                          WHERE AS_Quik_Forms_Group__c IN : qfGroupIdList];
        QuikFormHandler.callDocusign(JSON.serialize(callDSRecp));
    }
    
    @AuraEnabled
    public static String checkEnvelopeStatus(String asQfId) {
        String res = '';
        List<String> asQfIdList = asQfId.split(',');
        Integer asQfLength = asQfIdList.size();
        Integer envpIdDone = 0;
        List<AS_Quik_Forms__c> asQFRecList = [SELECT AS_Quik_Forms_Group__c, AS_Quik_Forms_Group__r.Docusign_Envelope_Id__c 
                                              FROM AS_Quik_Forms__c 
                                              WHERE Id IN :asQfIdList];
        for(AS_Quik_Forms__c asQfRec : asQFRecList) {
            if(asQFRec.AS_Quik_Forms_Group__r.Docusign_Envelope_Id__c != null 
               && asQFRec.AS_Quik_Forms_Group__r.Docusign_Envelope_Id__c != '') 
            {
                ++envpIdDone;
            }
        }
        if(asQfLength == envpIdDone) {
            res = 'success';
        } else {
            res = 'fail';
        }
        return res;
    }
    
    @AuraEnabled
    public static String checkDocusignId(String qfId) {
        String res = '';
        AS_Quik_Forms__c asQFRec = [SELECT AS_Quik_Forms_Group__c, AS_Quik_Forms_Group__r.Docusign_Envelope_Id__c 
                                    FROM AS_Quik_Forms__c 
                                    WHERE Id = :qfId];
        if(asQFRec.AS_Quik_Forms_Group__r.Docusign_Envelope_Id__c != null 
           && asQFRec.AS_Quik_Forms_Group__r.Docusign_Envelope_Id__c != '') 
        {
            res = 'success';
        } else {
            res = 'fail';
        }
        return res;
    }
    
}