//Test Class: Docuvault_JournalingEmailController_TC

public with sharing class Docuvault_JournalingEmailController {

    public static String getAllFields(String objectName) {
        string fields = '';
        sObjectType objectType = Schema.getGlobalDescribe().get(objectName);

        if (objectType == null)
        return fields;
        for (string f : objectType.getDescribe().fields.getMap().keySet())
        fields += f + ', ';
        return fields.removeEnd(', ');
    }

    // Method to send Cloud file as an attachment to Journal Email
    public Static void sendCloudFileAsEmail(String cloudFileID, String templateName) {
        try {
            if (cloudFileID != '' && cloudFileID != NULL) {

                TVA_CFB__CloudFiles_Settings__c credentials = TVA_CFB__CloudFiles_Settings__c.getInstance(UserInfo.getUserID());
                Map<String, TVA_CFB__Cloud_Files_Region_Endpoints__c> regionEndpoints = TVA_CFB__Cloud_Files_Region_Endpoints__c.getAll();
                Docuvault_Journaling_Email__c customSettingDetails = Docuvault_Journaling_Email__c.getInstance(UserInfo.getUserID());

                SObject CDocType = NEW TVA_CFB__Cloud_Files__c();
                String query = 'SELECT ' + getAllFields('TVA_CFB__Cloud_Files__c') + ' FROM TVA_CFB__Cloud_Files__c ' +
                ' WHERE ID =: cloudFileID LIMIT 1';

                cDocType = Database.Query(query);

                SObject u = NEW User();
                try {
                    String OwnerID = (String) cDocType.get('OwnerId');
                    query = 'SELECT ' + getAllFields('User') + ' FROM USer ' +
                    ' WHERE ID =: ownerID LIMIT 1';
                    u = Database.Query(query);
                }
                Catch(Exception e) { }

                String fileName = CDocType.ID + '.' + CDocType.get('TVA_CFB__File_Type__c');

                if (CDocType.get('TVA_CFB__External_File_Name__c') != null) {
                    fileName = (String) CDocType.get('TVA_CFB__External_File_Name__c');
                    fileName = EncodingUtil.URLEncode(fileName, 'UTF-8');
                    fileName = fileName.replace('+', '%20');
                    fileName = fileName.replace('%2F', '/');
                }

                Map<String, String> mapCFileDetails = NEW Map<String, String> ();
                mapCFileDetails.put('bucket', (String) CDocType.get('TVA_CFB__Bucket_Name__c'));
                mapCFileDetails.put('fileName', fileName);
                mapCFileDetails.put('region', (String) CDocType.get('TVA_CFB__Region__c'));
                HttpResponse response = NEW HttpResponse();

                if (!Test.isRunningTest()) {
                    response = TVA_CFB.amazonS3Authentication.getFileRequest(credentials, mapCFileDetails, regionEndpoints);

                } else {
                    response.setHeader('Content-Type', 'application/json');
                    response.setBody('{"foo":"bar"}');
                    response.setStatusCode(200);
                }
                if (response.getStatusCode() == 200) {
                    String templateBody = '';
                    String templateSubject = '';
                    String Temptype = '';
                    EmailTemplate template;

                    String primaryTemplateBody = '';
                    String primaryTemplateSubject = '';
                    String primaryTemptype = '';
                    EmailTemplate primaryTemplate;

                    String secondaryTemplateBody = '';
                    String secondaryTemplateSubject = '';
                    String secondaryTemptype = '';
                    EmailTemplate secondaryTemplate;


                    TemplateBodyWrapper wrapper = new TemplateBodyWrapper(templateName, CDocType, u);

                    System.debug('templateBody' + wrapper.templateBody);
                    System.debug('templateSubject' + wrapper.templateSubject);
                    System.debug('tempType' + wrapper.tempType);
                    System.debug('template' + wrapper.template);

                    templateBody = wrapper.templateBody;
                    templateSubject = wrapper.templateSubject;
                    Temptype = wrapper.tempType;
                    template = wrapper.template;

                    if(templateName == customSettingDetails.Share_on_Portal_Email_Template__c) {
                        String primaryTempName = '';
                        if(String.valueOf(cDocType.get('WEG_Document_Name__c')) != NULL &&
                           String.valueOf(cDocType.get('WEG_Document_Name__c')).contains('QAMR')
                        ) {
                            primaryTempName = customSettingDetails.QAMR_Share_on_Portal_Primary__c;
                        } 
                        if(String.valueOf(cDocType.get('WEG_Document_Name__c')) != NULL &&
                           String.valueOf(cDocType.get('WEG_Document_Name__c')).contains('CCPY')) 
                        {
                            primaryTempName = customSettingDetails.CCPY_Share_on_Portal_Primary__c;
                        } 
                        TemplateBodyWrapper wrapper1 = new TemplateBodyWrapper(primaryTempName, CDocType, u);
                        System.debug('templateBody1' + wrapper1.templateBody);
                        System.debug('templateSubject1' + wrapper1.templateSubject);
                        System.debug('tempType1' + wrapper1.tempType);
                        System.debug('template1' + wrapper1.template);

                        primaryTemplateBody = wrapper1.templateBody;
                        primaryTemplateSubject = wrapper1.templateSubject;
                        primaryTemptype = wrapper1.tempType;
                        primaryTemplate = wrapper1.template;

                        String secondaryTempName = '';
                        if(String.valueOf(cDocType.get('WEG_Document_Name__c')) != NULL &&
                           String.valueOf(cDocType.get('WEG_Document_Name__c')).contains('QAMR')) 
                        {
                            secondaryTempName = customSettingDetails.QAMR_Share_on_Portal_Secondary__c;
                        } 
                        if(String.valueOf(cDocType.get('WEG_Document_Name__c')) != NULL &&
                           String.valueOf(cDocType.get('WEG_Document_Name__c')).contains('CCPY')) 
                        {
                            secondaryTempName = customSettingDetails.CCPY_Share_on_Portal_Secondary__c;
                        } 

                        TemplateBodyWrapper wrapper2 = new TemplateBodyWrapper(secondaryTempName, CDocType, u);
                        System.debug('templateBody2' + wrapper2.templateBody);
                        System.debug('templateSubject2' + wrapper2.templateSubject);
                        System.debug('tempType2' + wrapper2.tempType);
                        System.debug('template2' + wrapper2.template);

                        secondaryTemplateBody = wrapper2.templateBody;
                        secondaryTemplateSubject = wrapper2.templateSubject;
                        secondaryTemptype = wrapper2.tempType;
                        secondaryTemplate = wrapper2.template;

                    }

                    /*SendEmailsUsingContacto.SendEmailMessageFlow messageList = new SendEmailsUsingContacto.SendEmailMessageFlow();
                    messageList.fromAddress = System.Label.WegGroupEmail;
                    messageList.toAddress = customSettingDetails.Email__c;
                    messageList.templatesubject = templateSubject;
                    messageList.templateBody = templateBody;
                    messageList.templateType = Temptype;
                    messageList.parentId = cloudFileId;
                    Map<Id, String> ResponseMap = SendEmailsUsingContacto.sendEmailFromContacto(messageList);
                    system.debug('responseresponse' + ResponseMap);
                    system.debug('cloudFileIDcloudFileID' + cloudFileID);
                    String ResData = ResponseMap.get(cloudFileID);
                    String messageId = ResData.substringbetween('<MessageId>', '</MessageId>');*/
                    String messageId2 = '';
                    String messageId1 = '';
                    List<WEG_Document_Delivery__c> documentDeliveryToUpdate = new List<WEG_Document_Delivery__c> ();
                    TVA_CFB__Cloud_Files__c cloudFilerecord = new TVA_CFB__Cloud_Files__c();
                    cloudFilerecord = [Select Parent_CloudFile_Id__c, Primary_Portal_User__c, Primary_Portal_User__r.Email, 
                                              Secondary_Portal_User__c, Secondary_Portal_User__r.Email, Name, 
                                              WEG_Document_Name__c,WEGP1_Household__c, WEGP1_Household__r.WEGP1_Secondary_Individual__c,
                                              WEGP1_Household__r.WEGP1_Primary_Individual__c
                                       From TVA_CFB__Cloud_Files__c Where Id = :cloudfileId];
                    System.debug(':::DJEC cloudFilerecord::: ' + cloudFilerecord);

                    if (cloudFilerecord.Parent_CloudFile_Id__c != NULL) {
                        TVA_CFB__Cloud_Files__c ddCloudFile = [Select RecordType.Name, Name, WEG_Document_Name__c,WEGP1_Household__c, WEGP1_Household__r.WEGP1_Secondary_Individual__c,
                                                                      WEGP1_Household__r.WEGP1_Primary_Individual__c
                                                               From TVA_CFB__Cloud_Files__c Where Id = :cloudFilerecord.Parent_CloudFile_Id__c];
                        if (ddCloudFile.RecordType.Name == 'Digital Delivery' && cloudFilerecord.Primary_Portal_User__c != NULL) {
                            SendEmailsUsingContacto.SendEmailMessageFlow messageList1 = new SendEmailsUsingContacto.SendEmailMessageFlow();
                            messageList1.fromAddress = System.Label.WegGroupEmail;
                            messageList1.toAddress = cloudFilerecord.Primary_Portal_User__r.Email;

                            if(primaryTemplateSubject != '') {
                                messageList1.templatesubject = primaryTemplateSubject;
                            } else {
                                messageList1.templatesubject = templateSubject;
                            }
                            if(primaryTemplateBody != '') {
                                messageList1.templateBody = primaryTemplateBody;
                            }else {
                                messageList1.templateBody = templateBody;
                            }
                            if(primaryTemptype != '') {
                                messageList1.templateType = primaryTemptype;
                            }else{
                                messageList1.templateType = Temptype;
                            }
                            
                            messageList1.parentId = ddCloudFile.Id;
                            Map<Id, String> ResponseMap1 = SendEmailsUsingContacto.sendEmailFromContacto(messageList1);
                            String ResData1 = ResponseMap1.get(ddCloudFile.Id);
                            messageId1 = ResData1.substringbetween('<MessageId>', '</MessageId>');

                        }
                        if (ddCloudFile.RecordType.Name == 'Digital Delivery' && cloudFilerecord.Secondary_Portal_User__c != NULL) {
                            SendEmailsUsingContacto.SendEmailMessageFlow messageList2 = new SendEmailsUsingContacto.SendEmailMessageFlow();
                            messageList2.fromAddress = System.Label.WegGroupEmail;
                            messageList2.toAddress = cloudFilerecord.Secondary_Portal_User__r.Email;
                            
                            if(secondaryTemplateSubject != '') {
                                messageList2.templatesubject = secondaryTemplateSubject;
                            } else {
                                messageList2.templatesubject = templateSubject;
                            }
                            if(secondaryTemplateBody != '') {
                                messageList2.templateBody = secondaryTemplateBody;
                            }else {
                                messageList2.templateBody = templateBody;
                            }
                            if(secondaryTemptype != '') {
                                messageList2.templateType = secondaryTemptype;
                            }else{
                                messageList2.templateType = Temptype;
                            }
                            messageList2.parentId = ddCloudFile.Id;
                            Map<Id, String> ResponseMap2 = SendEmailsUsingContacto.sendEmailFromContacto(messageList2);
                            String ResData2 = ResponseMap2.get(ddCloudFile.Id);
                            messageId2 = ResData2.substringbetween('<MessageId>', '</MessageId>');
                        }
                        /*if(!cloudFilerecord.WEG_Document_Name__c.contains('QAMR') && !cloudFilerecord.WEG_Document_Name__c.contains('CCPY')) {
                            System.debug('Entered');
                            SendEmailsUsingContacto.createEmailSendAndEmailMessage(template.Id, customSettingDetails.Email__c, System.Label.WegGroupEmail, cloudFilerecord.Id, cloudFilerecord.Name, messageId, 'Cloud_Files__c');
                        }*/
                        Id primaryEmailMsg = null;
                        Id secondaryEmailMsg = null;
                        if (ddCloudFile.RecordType.Name == 'Digital Delivery' && cloudFilerecord.Primary_Portal_User__c != NULL && primaryTemplate == NULL) {
                            System.debug('Entered1');
                            primaryEmailMsg = SendEmailsUsingContacto.createEmailSendAndEmailMessage(template.Id, cloudFilerecord.Primary_Portal_User__r.Email, System.Label.WegGroupEmail, ddCloudFile.Id, ddCloudFile.Name, messageId1, 'Cloud_Files__c');
                        } 
                        if (ddCloudFile.RecordType.Name == 'Digital Delivery' && cloudFilerecord.Primary_Portal_User__c != NULL && primaryTemplate != NULL) {
                            System.debug('Entered2');
                            primaryEmailMsg = SendEmailsUsingContacto.createEmailSendAndEmailMessage(primaryTemplate.Id, cloudFilerecord.Primary_Portal_User__r.Email, System.Label.WegGroupEmail, ddCloudFile.Id, ddCloudFile.Name, messageId1, 'Cloud_Files__c');
                        } 
                        if (ddCloudFile.RecordType.Name == 'Digital Delivery' && cloudFilerecord.Secondary_Portal_User__r != NULL && secondaryTemplate == NULL) {
                            System.debug('Entered3');
                            secondaryEmailMsg = SendEmailsUsingContacto.createEmailSendAndEmailMessage(template.Id, cloudFilerecord.Secondary_Portal_User__r.Email, System.Label.WegGroupEmail, ddCloudFile.Id, ddCloudFile.Name, messageId2, 'Cloud_Files__c');
                        }
                        if (ddCloudFile.RecordType.Name == 'Digital Delivery' && cloudFilerecord.Secondary_Portal_User__r != NULL && secondaryTemplate != NULL) {
                            System.debug('Entered4');
                            secondaryEmailMsg = SendEmailsUsingContacto.createEmailSendAndEmailMessage(secondaryTemplate.Id, cloudFilerecord.Secondary_Portal_User__r.Email, System.Label.WegGroupEmail, ddCloudFile.Id, ddCloudFile.Name, messageId2, 'Cloud_Files__c');
                        }
                        if(response.getStatusCode() == 200) {
                            for(WEG_Document_Delivery__c documentDelivery :[SELECT WEG_Status__c, WEG_Primary_Individual__c, WEG_Secondary_Individual__c, 
                                                                            WEG_Primary_Email_Message1__c, WEG_Secondry_Email_Message1__c 
                                                                            From WEG_Document_Delivery__c 
                                                                            WHERE WEG_Document__c = :cloudFilerecord.Parent_CloudFile_Id__c]) 
                            {
                                documentDelivery.WEG_Status__c = 'Notified';
                                documentDelivery.WEG_Portal_Document__c = cloudFileID;
                                if(primaryEmailMsg != null) {
                                    documentDelivery.WEG_Primary_Email_Message1__c = primaryEmailMsg;
                                }
                                if(secondaryEmailMsg != null) {
                                    documentDelivery.WEG_Secondry_Email_Message1__c = secondaryEmailMsg;
                                }
                                if(ddCloudFile.WEGP1_Household__r.WEGP1_Primary_Individual__c != null) {
                                    documentDelivery.WEG_Primary_Individual__c = ddCloudFile.WEGP1_Household__r.WEGP1_Primary_Individual__c;
                                }
                                if(ddCloudFile.WEGP1_Household__r.WEGP1_Secondary_Individual__c != null) {
                                    documentDelivery.WEG_Secondary_Individual__c  = ddCloudFile.WEGP1_Household__r.WEGP1_Secondary_Individual__c;
                                }
                                if(ddCloudFile.WEGP1_Household__c != null) {
                                    documentDelivery.WEG_Journal__c = ddCloudFile.WEGP1_Household__c;
                                }
                                documentDeliveryToUpdate.add(documentDelivery);
                            }
                        }
                        system.debug('aaaaaaaaaaaa' + documentDeliveryToUpdate);

                        if (documentDeliveryToUpdate.size() != null) {
                            system.debug('aaaaaaaaaaaa');
                            update documentDeliveryToUpdate;
                        }
                    }
                }
            }
        } Catch(Exception e) {
            System.Debug('---- Exception ---' + e.getMessage());
        }
    }

    public class TemplateBodyWrapper {
        public String templateBody;
        public String tempType;
        public String templateSubject;
        public String templateName;
        public Sobject CDocType;
        public EmailTemplate template;
        public Sobject U;
        public TemplateBodyWrapper(String emailTempName, Sobject cloudFile, Sobject userRec) {
            templateBody = '';
            tempType = '';
            templateSubject = '';
            templateName = emailTempName;
            CDocType = cloudFile;
            template = null;
            U = userRec;

            List<EmailTemplate> templates = [SELECT Body, HtmlValue, Subject, Templatetype, markup, brandtemplateId
                                             FROM EmailTemplate
                                             WHERE developerName = :templateName];
            if (templates.size() != 1) { return; }

            template = templates[0];
            System.Debug('---- Email Template ' + template);

            templateBody = '';
            tempType = '';
            if (template.TemplateType == 'Text') {
                tempType = 'text/plain';
                templateBody = template.Body;
            }
            else if (template.TemplateType == 'HTML' || template.TemplateType == 'Custom') {
                tempType = 'text/html';
                templateBody = template.htmlvalue;
            }
            else if (template.TemplateType == 'visualforce') {
                tempType = 'text/html';
                templateBody = template.markup;
            }

            templateSubject = template.Subject;

            List<String> fieldAPis = new List<String> ();
            List<String> fieldSubjectAPis = new List<String> ();

            Integer noOfFields = templateBody.CountMatches('{!');
            Integer noOfSubjectFields = templateSubject.CountMatches('{!');

            for (integer i = 0; i<noOfFields; i++) {
                fieldAPis.add(templateBody.subStringBetween('{!', '}'));
                templateBody = templateBody.remove('{!' + fieldAPis[i] + '}');
            }

            for (integer i = 0; i<noOfSubjectFields; i++) {
                fieldSubjectAPis.add(templateSubject.subStringBetween('{!', '}'));
                templateSubject = templateSubject.remove('{!' + fieldSubjectAPis[i] + '}');
            }
            System.Debug('-----------' + fieldAPis);
            templateSubject = template.Subject;
            if (template.TemplateType == 'Text') {
                templateBody = template.Body;
            }
            else if (template.TemplateType == 'HTML' || template.TemplateType == 'Custom') {
                templateBody = template.htmlvalue;
            }
            else if (template.TemplateType == 'visualforce') {
                templateBody = template.markup;
            }

            for (integer i = 0; i<fieldAPis.size(); i++)
            {
                if (fieldAPis[i] != NULL && fieldAPis[i] != '') {
                    if (fieldAPis[i].contains('TVA_CFB__Cloud_Files__c')) {
                        try {
                            templateBody = templateBody.replace('{!' + fieldAPis[i] + '}',
                                                                String.valueOf(CDocType.get(fieldAPis[i].replace('TVA_CFB__Cloud_Files__c.', ''))));
                        }
                        catch(Exception e) {
                            templateBody = templateBody.replace('{!' + fieldAPis[i] + '}', '');
                        }
                    }
                    try {
                        if (fieldAPis[i].contains('User'))
                        templateBody = templateBody.replace('{!' + fieldAPis[i] + '}',
                                                            String.valueOf(u.get(fieldAPis[i].replace('User.', ''))));
                    }
                    catch(Exception e) { }
                }
            }

            for (integer i = 0; i<fieldSubjectAPis.size(); i++)
            {
                if (fieldAPis[i] != NULL && fieldAPis[i] != '') {
                    if (fieldSubjectAPis[i].contains('TVA_CFB__Cloud_Files__c'))
                    templateSubject = templateSubject.replace('{!' + fieldSubjectAPis[i] + '}',
                                                              String.valueOf(CDocType.get(fieldSubjectAPis[i].replace('TVA_CFB__Cloud_Files__c.', ''))));
                }
            }

            System.Debug('---------' + templateBody);

        }
    }
}