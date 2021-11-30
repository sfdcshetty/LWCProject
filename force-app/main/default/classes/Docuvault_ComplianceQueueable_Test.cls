@isTest
public class Docuvault_ComplianceQueueable_Test {
    public static testMethod void method1 () {
          TVA_CFB__Cloud_Files__c cloudFile = new TVA_CFB__Cloud_Files__c ();
            cloudFile.TVA_CFB__External_File_Name__c = 'Amaxon Test.jpg';
            cloudFile.TVA_CFB__Region__c = 'us-east-1';
            cloudFile.TVA_CFB__Bucket_Name__c = 'AWS_Test_Bucket';
            cloudFile.TVA_CFB__File_Type__c = 'jpg';
            cloudFile.TVA_CFB__E_TAG__c = 'test';
            cloudFile.TVA_CFB__Amazon_Version_ID__c = 'test';
            cloudFile.Name = 'Test.jpg';
        insert cloudFile;
        List<Id> cloudFileList = New List<Id> ();
            cloudFileList.add(cloudFile.id);
        Docuvault_ComplianceQueueable cm = new Docuvault_ComplianceQueueable(cloudFileList);
        System.enqueueJob(cm);
    }
}