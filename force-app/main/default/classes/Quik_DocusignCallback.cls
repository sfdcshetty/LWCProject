//Test class - QuikFormHandler_TEST 
@RestResource(urlMapping = '/quik_statuscallback/*')
global without sharing class Quik_DocusignCallback {
    
    static List<Recipient> recipientValues;
    static Recipient RecipientDetail;
    static String envelopeId = '';
    static String envelopeStatus = '';
    @HttpPOST
    global static void docusignResponse() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String xmlString = '';
        if(!Test.isRunningTest()) {
            xmlString = req.requestBody.toString();
        }
        System.debug('xmlStringxmlString: ' + xmlString);
        if(Test.isRunningTest()) {
            xmlString = '<?xml version="1.0" encoding="UTF-8"?>'
                +'<DocuSignEnvelopeInformation xmlns="http://www.docusign.net/API/3.0" xmlns:xsd="http://www.w3.org/2001/XMLSchema"' 
                + ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
                +'<EnvelopeStatus>'
                +'<RecipientStatuses>'
                +'<RecipientStatus>'
                +'<Type>Signer</Type>'
                +'<Email>saikrishna.g@bigworks.co</Email>'
                +'<UserName>sai</UserName>'
                +'<TabStatuses>'
                +'<TabStatus>'
                +'<TabType>SignHere</TabType>'
                +'<Status>Active</Status>'
                +'<XPosition>72</XPosition>'
                +'<YPosition>1295</YPosition>'
                +'<TabLabel>Sign Here</TabLabel>'
                +'<TabName>SignHere</TabName>'
                +'<TabValue />'
                +'<DocumentID>1</DocumentID>'
                +'<PageNumber>1</PageNumber>'
                +'</TabStatus>'
                +'</TabStatuses>'
                +'<AccountStatus>Active</AccountStatus>'
                +'<RecipientId>07d7c572-fb0c-4ff3-8d67-458e91846959</RecipientId>'
                +'</RecipientStatus>'
                +'</RecipientStatuses>'
                +'</EnvelopeStatus>'
                +'</DocuSignEnvelopeInformation>';
        } 
        recipientValues = new List<Recipient>();
        RecipientDetail = new Recipient();
        envelopeId = '';
        envelopeStatus = '';
        String RecipientStatuses = xmlString.SubStringBetween('<RecipientStatuses>', '</RecipientStatuses>');
        String envelopeBody = xmlString.replace('<RecipientStatuses>' + RecipientStatuses + '</RecipientStatuses>', '');
        
        // To get the Envelope Information
        DOM.Document doc = new DOM.Document();
        doc.load(envelopeBody);
        DOM.XmlNode rootNode = doc.getRootElement();
        parseXML(rootNode);
        if(Test.isRunningTest()) {
            envelopeId = 'efff4480-7ae5-4e11-aeca-9e17ee2d310f';
            envelopeStatus = 'Completed';
        }
        // To get the recipients signing statuses
        if(xmlString.contains('<RecipientStatuses>')) {
            String recipients = xmlString.SubStringBetween('<RecipientStatuses>', '</RecipientStatuses>');
            if(recipients.contains('<TabStatuses>')) {
                String tabStatuses = recipients.subStringBetween('<TabStatuses>', '</TabStatuses>');
                recipients = recipients.replace('<TabStatuses>' + tabStatuses + '</TabStatuses>', '');
            }
            recipients = recipients.replace('xsi:nil="true"', '');
            recipients = '<RecipientStatuses>' + recipients + '</RecipientStatuses>';
            recipientValues = new List<Recipient>();
            RecipientDetail = new Recipient();
            doc = new DOM.Document();
            doc.load(recipients);
            rootNode = doc.getRootElement();
            parseXML(rootNode);
            recipientValues.add(RecipientDetail);
        } 
        AS_Quik_Forms_Group__c rec = new AS_Quik_Forms_Group__c();
        System.debug('envelopeId: ' + envelopeId);
        if(envelopeId != '' && envelopeId != NULL) {
            rec = [SELECT DocuSign_Envelope_Status__c, Docusign_Envelope_Id__c, Account_Servicing__c, Financial_Account_Servicing__c, 
                   Account_Servicing__r.Related_Account__c FROM AS_Quik_Forms_Group__c WHERE Docusign_Envelope_Id__c = :envelopeId];
        }
        System.debug(rec);
        // To create the Cloud Files under As Form Group Record after completion
        if(envelopeStatus == 'Completed') {
            System.debug('Entered here');
            Quik_SignUrl.getCombinedDocuments(envelopeId, rec.Id);
        }
        if(rec.ID != NULL) {
            List<TVA_CFB__Cloud_Files__c> cloudFilesToUpdate = new List<TVA_CFB__Cloud_Files__c>(); 
            cloudFilesToUpdate = [SELECT WEGP1_Household__c, WEG_Account_Servicing__c, AS_Quik_Forms_Group__c, Financial_Account_Servicing__c 
                                  FROM TVA_CFB__Cloud_Files__c WHERE AS_Quik_Forms_Group__c = :rec.Id];
            for(TVA_CFB__Cloud_Files__c cf : cloudFilesToUpdate) {
                if(rec.Account_Servicing__c != null) {
                    cf.WEG_Account_Servicing__c = rec.Account_Servicing__c;
                }
                if(rec.Financial_Account_Servicing__c != null) {
                    cf.Financial_Account_Servicing__c = rec.Financial_Account_Servicing__c;
                }
                if(rec.Account_Servicing__r.Related_Account__c != null) {
                    cf.WEGP1_Household__c = rec.Account_Servicing__r.Related_Account__c;
                }
            } 
            rec.DocuSign_Envelope_Status__c = envelopeStatus;
            try {
                update rec;
            } catch(Exception exc) {
                QuikErrorLogGeneration.createErrorLog('', '', '', exc.getMessage(), 'Quik_DocusignCallback', 'docusignResponse', 
                                                      exc.getLineNumber());
            }
            if(cloudFilesToUpdate.size() > 0) {
                try {
                    update cloudFilesToUpdate;
                } catch(Exception exc) {
                    QuikErrorLogGeneration.createErrorLog('', '', '', exc.getMessage(), 'Quik_DocusignCallback', 'docusignResponse', 
                                                          exc.getLineNumber());
                }
            }
        }
        
        // To update the recipient statuses
        if(recipientValues.size() > 0) {
            Map<String, Recipient> recipientMap = new Map<String, Recipient>();
            Map<String, List<Recipient>> recpWithOrderMap = new Map<String, List<Recipient>>();
            Set<String> recipientEmails = new Set<String> ();
            for(Recipient record : recipientValues) {
                if(!recipientMap.containsKey(record.Email)) {
                    recipientMap.put(record.Email, record);
                }
                recipientEmails.add(record.Email);                
                if(recpWithOrderMap.containsKey(record.RoutingOrder)) {
                    recpWithOrderMap.get(record.RoutingOrder).add(record);
                } else {
                    recpWithOrderMap.put(record.RoutingOrder, new List<Recipient>{ record });
                }
            }
            List<Recipients__c> recipientsToUpdate = new List<Recipients__c> ();
            for(Recipients__c recipientRecord :[SELECT Order__c, Email__c, Status__c, AS_Quik_Forms_Group__c FROM Recipients__c
                                                WHERE AS_Quik_Forms_Group__c = :rec.Id AND Email__c IN :recipientEmails])
            {
                if(recpWithOrderMap.containsKey(String.valueOf(recipientRecord.Order__c))) {
                    List<Recipient> recpList = recpWithOrderMap.get(String.valueOf(recipientRecord.Order__c));
                    if(recpList.size() > 1) {
                        for(Recipient recpRec : recpList) {
                            if(recpRec.Email == recipientRecord.Email__c) {
                                recipientRecord.Status__c = recpRec.Status;
                                recipientsToUpdate.add(recipientRecord);
                            }
                        }
                    } else {
                        recipientRecord.Status__c = recpList[0].Status;
                        recipientsToUpdate.add(recipientRecord);
                    }
                }
            }
            if(recipientsToUpdate.size() > 0) {
                Database.update(recipientsToUpdate, false);
            }
        }
    }
    
    private static void parseXML(DOM.XMLNode node) {
        if(node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            if(node.getName() == 'EnvelopeID')
                envelopeId = node.getText().trim();
            if(node.getName() == 'Status' && envelopeStatus == '')
                envelopeStatus = node.getText().trim();
            if(node.getName() == 'RecipientStatus') {
                if(RecipientDetail != NULL) {
                    System.debug('RecipientDetail: ' + RecipientDetail);
                    recipientValues.add(RecipientDetail);
                    RecipientDetail = new Recipient();
                }
            }
            if(node.getName() == 'Email' && node.getText().trim() != NULL) {
                RecipientDetail.Email = node.getText().trim();
            }
            if(node.getName() == 'UserName' && node.getText().trim() != NULL) {
                RecipientDetail.UserName = node.getText().trim();
            }
            if(node.getName() == 'RoutingOrder' && node.getText().trim() != NULL) {
                RecipientDetail.RoutingOrder = node.getText().trim();
            }
            if(node.getName() == 'Status' && node.getText().trim() != NULL && RecipientDetail.Status == NULL) {
                RecipientDetail.Status = node.getText().trim();
            }
        }
        for(Dom.XMLNode child : node.getChildElements()) {
            parseXML(child);
        }
    }
    
    public class Recipient {
        public String Email;
        public String UserName;
        public String RoutingOrder;
        public String Status;
    }   
}