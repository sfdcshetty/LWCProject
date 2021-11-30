@isTest
Public class Docuvault_DownloadJournalAttachment_TC {
    public static testMethod void method1 () {
        WEG_Journal_Attachment_Reference__c  attach = New WEG_Journal_Attachment_Reference__c ();
            attach.WEG_Bucket_Name__c = 'test';
            attach.WEG_File_Name__c ='test.jpg';
            attach.WEG_File_Type__c ='jpg';
            attach.WEG_Region__c = 'us-east-1';
        insert attach;
        String recId = apexpages.currentpage().getparameters().put('id',attach.id);
        Docuvault_DownloadJournalAttachment obj = New Docuvault_DownloadJournalAttachment  ();
            obj.generateDownloadLink ();
    }
    public static testMethod void method2 () {
        WEG_Journal_Attachment_Reference__c  attach = New WEG_Journal_Attachment_Reference__c ();
        insert attach;
        String recId = apexpages.currentpage().getparameters().put('id',attach.id);
        Docuvault_DownloadJournalAttachment obj = New Docuvault_DownloadJournalAttachment  ();
            obj.generateDownloadLink ();
    }
}