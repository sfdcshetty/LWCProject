/* 
Created by : Bigworks Team
Description: This class is used to Send Emails using Contacto App via Amazon SES
Test Class : SendEmailsUsingContacto_TC
*/
public class SendEmailsUsingContacto {
    public Static String generateUniqueId() {
        String hashString = Math.random() * 10000 + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String uniqueId = EncodingUtil.convertToHex(hash);
        return uniqueId;
    }

    // Send Email From Contacto
    public static Map<Id, String> sendEmailFromContacto(SendEmailMessageFlow recordToBeProcessed) {
        String fromAddress = recordToBeProcessed.fromAddress;
        String toAddress = recordToBeProcessed.toAddress;
        String templatesubject = recordToBeProcessed.templateSubject;
        String templateBody = recordToBeProcessed.templateBody;
        String templateType = recordToBeProcessed.templateType;
        String parentId = recordToBeProcessed.parentId;
        String uniqueId = SendEmailsUsingContacto.generateUniqueId();

        Map<Id, String> ResponseMapVal = new Map<Id, String> ();
        List<Attachment> attList = new List<Attachment> ();
        //attList.add(att);
        Map<String, List<Attachment>> DocumentMap = new Map<String, List<Attachment>> ();
        DocumentMap.put(parentId, attList);

        Map<Id, Map<String, String>> EmailMessageMap = new Map<Id, MAP<String, String>> ();
        Map<String, String> SingleEmailMap = new Map<String, String> ();
        System.debug('toAddress'+toAddress+ '  FromAddress '+fromAddress);
        System.debug('templateSubject'+templateSubject+ '  templateType '+templateType);
        System.debug('templateBody'+templateBody);
        System.debug('templateSubject'+templateSubject+ '  parentId '+parentId);

        SingleEmailMap.put('PersonEmail', toAddress);
        SingleEmailMap.put('FromAddress', fromAddress);
        SingleEmailMap.put('Subject', templateSubject);
        SingleEmailMap.put('mimeType', templateType);
        SingleEmailMap.put('body', templateBody);
        SingleEmailMap.put('Signature', 'False');
        SingleEmailMap.put('UniqueId', uniqueId);
        SingleEmailMap.put('tracking', 'true');
        SingleEmailMap.put('transactonalEmail', 'False');
        EmailMessageMap.put(parentId, SingleEmailMap);
        System.debug('email data' + SingleEmailMap);
        TVA_CO.SendEmailSES obj = new TVA_CO.SendEmailSES();
        if (!Test.isRunningTest())
            ResponseMapVal = obj.sendEmailFromAmazon1(EmailMessageMap, DocumentMap);
        else {
            ResponseMapVal.put(parentId, '<MessageId>52352342</MessageId>');
        }
        System.debug('ResponseMapValResponseMapVal'+ResponseMapVal);
        return ResponseMapVal;
    }

    //Insert Email Send and Email Message
   // @future
    public static Id createEmailSendAndEmailMessage(String tempId, String recepientEmail, String fromEmail, String parentId,
                                                        String emailSendName, String messageId, String parentObjApiName) 
    {
        String uniqueId = SendEmailsUsingContacto.generateUniqueId();
        Id emailMessageId = null;
        if ((tempId != NULL || tempId != '') && (recepientEmail != NULL || recepientEmail != '') &&
        (parentId != NULL || parentId != '') && (emailSendName != NULL || emailSendName != '') &&
        (uniqueId != NULL || uniqueId != '') && (messageId != NULL || messageId != '') &&
        (parentObjApiName != NULL || parentObjApiName != '') && (fromEmail != NULL || fromEmail != '')) {
            TVA_CO__Email_Send__c emailSend = new TVA_CO__Email_Send__c();
            emailSend.TVA_CO__Enable_Tracking__c = true;
            emailSend.TVA_CO__Processed_Template_Id__c = tempId;
            emailSend.TVA_CO__Recipient_Email__c = recepientEmail;
            emailSend.Name = emailSendName;
            insert emailSend;

            TVA_CO__Email_Message__c emailMessage = new TVA_CO__Email_Message__c();
            emailMessage.TVA_CO__Email_Send__c = emailSend.Id;
            emailMessage.TVA_CO__From_Email__c = fromEmail;
            emailMessage.TVA_CO__Parent_Record_ID__c = parentId;
            emailMessage.TVA_CO__Recipient_Email__c = recepientEmail;
            emailMessage.TVA_CO__Email_Message_Id__c = messageId;
            emailMessage.TVA_CO__Unique_ID__c = uniqueId;
            emailMessage.put(parentObjApiName, parentId);
            emailMessage.Name = emailSendName;
            insert emailMessage;
            emailMessageId = emailMessage.Id;
        }
        return emailMessageId;
    }
    public class SendEmailMessageFlow {
        public String toAddress;
        public String fromAddress;
        public String templateSubject;
        public String templateBody;
        public String templateType;
        public String parentId;

        public SendEmailMessageFlow() {
            toAddress = ''; fromAddress = ''; templateSubject = ''; templateBody = ''; templateType = ''; parentId = '';
        }
    }
}