@isTest
Public class ComplianceArchivingHelper_TC {
    public static testMethod void method1() {
    User adminUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
    List<Secure_Messaging__c> secureMsgList = New List<Secure_Messaging__c> ();
        system.runAs(adminUser) {
        Account hhAcc = new Account(Name='HH Account1', recordTypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('Household').getRecordTypeId(), WEGP1_AccountTeamIds__c='HHDummyValue');
            insert hhAcc;
        Account  indAcc = new Account(Name='Ind Account1', WEGP1_Primary_Household__c=hhAcc.Id, recordTypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('Individual').getRecordTypeId(),WEGP1_AccountTeamIds__c='IndDummyValue');
            insert indAcc;
        Contact con = [SELECT Id  FROM Contact WHERE AccountId =: indAcc.Id];
        Secure_Messaging__c sm = new Secure_Messaging__c();
            sm.Name ='Test Message';
            sm.Message__c ='Test Message';
            sm.Account__c = indAcc.Id;
        secureMsgList.add(sm); 
        Set<ID> cloudFileIdSet = New Set<ID> ();
        Map<ID,ID> portalUsersMap = New Map<ID,ID> (); 
        TVA_CFB__Cloud_Files__c cloudFile = new TVA_CFB__Cloud_Files__c ();
            cloudFile.TVA_CFB__External_File_Name__c = 'Amaxon Test.jpg';
            cloudFile.TVA_CFB__Region__c = 'us-east-1';
            cloudFile.TVA_CFB__Bucket_Name__c = 'AWS_Test_Bucket';
            cloudFile.TVA_CFB__File_Type__c = 'jpg';
            cloudFile.TVA_CFB__E_TAG__c = 'test';
            cloudFile.TVA_CFB__Amazon_Version_ID__c = 'test';
            cloudFile.Name = 'Test.jpg';
        insert cloudFile;
        TVA_CFB__CloudFiles_Settings__c credentials = New TVA_CFB__CloudFiles_Settings__c(); 
            credentials.Journal_Bucket_name__c = 'test';
            credentials.TVA_CFB__Access_Key__c = 'test';
            credentials.TVA_CFB__Secret_Key__c = 'test';
        insert credentials;
        TVA_CFB__Cloud_Files_Region_Endpoints__c regionEndPoints = NEW TVA_CFB__Cloud_Files_Region_Endpoints__c ();
        regionEndPoints.TVA_CFB__Endpoint_URL__c = 'https://s3.amazonaws.com';
        regionEndPoints.Name = 'us-east-1';
        insert regionEndPoints;
        cloudFileIdSet.add(cloudFile.id);
        Attachment attach=new Attachment();     
            attach.Name='Unit Test Attachment';
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=bodyBlob;
            attach.parentId=con.id;
        insert attach;
        List<EmailMessage> msgList = New List<EmailMessage> ();
        EmailMessage msg = New EmailMessage();
            msg.FromAddress = 'test@gmail.com';
            msg.FromName = 'test';
            msg.HtmlBody = 'test';
            msg.Subject = 'test';
            msg.ToAddress = 'test@gmail.com';
        insert msg;
        msgList.add(msg);
        WEG_Journal_EC__c journal = New WEG_Journal_EC__c();
        insert journal;
        WEG_Journal_Attachment_Reference__c attachRef = New WEG_Journal_Attachment_Reference__c ();
            attachRef.WEG_JournalEC__c = journal.id;
            
        insert attachRef;
        Set<ID> attachRefIds = New Set<ID> ();
        attachRefIds.add(attachRef.id);
        List<ID> cloudFilesList = New List<ID> ();
        cloudFilesList.add(cloudFile.id);
        
        ComplianceArchivingHelper obj = New ComplianceArchivingHelper ();
        ComplianceArchivingHelper.JournalSecureMessageToClient(secureMsgList);
        ComplianceArchivingHelper.fieldMapping(sm);
        ComplianceArchivingHelper.documentShare(cloudFileIdSet,portalUsersMap ,'Secure File Share','');
        ComplianceArchivingHelper.documentShare(cloudFileIdSet,portalUsersMap ,'Document Receipt','');
        ComplianceArchivingHelper.documentShare(cloudFileIdSet,portalUsersMap ,'Secure File Receipt','');
        ComplianceArchivingHelper.documentShare(cloudFileIdSet,portalUsersMap ,'Secure File Send','');
        ComplianceArchivingHelper.documentShare(cloudFileIdSet,portalUsersMap ,'Document Share','');
        ComplianceArchivingHelper.documentShare(cloudFileIdSet,portalUsersMap ,'File Upload','');
        ComplianceArchivingHelper.documentShare(cloudFileIdSet,portalUsersMap ,'File Download','');
        ComplianceArchivingHelper.documentShare(cloudFileIdSet,portalUsersMap ,'Share on Portal','');
        ComplianceArchivingHelper.documentShare(cloudFileIdSet,portalUsersMap ,'Document Share Secondary','');
        ComplianceArchivingHelper.JournalSecureMessageFromClient(secureMsgList, null);
        ComplianceArchivingHelper.emailMessageShare(msgList);
        //ComplianceArchivingHelper.sendEmailAttachmentToS3(attachRefIds);
        ComplianceArchivingHelper.IdListReturned wrapper = new ComplianceArchivingHelper.IdListReturned ();
        wrapper.returnedObj= 'Cloud File';
        wrapper.returnIds = cloudFile.id;
        List<ComplianceArchivingHelper.IdListReturned> wrprList = New List<ComplianceArchivingHelper.IdListReturned> ();
        wrprList.add(wrapper);
        ComplianceArchivingHelper.createJournalRec (wrprList);
        }
        
    }
}