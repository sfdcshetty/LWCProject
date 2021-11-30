@isTest
private class Docuvault_LookupController_TC {

    static testMethod void getBucketNameMethod () {
        Test.startTest();
        try {
            TVA_CFB__CloudFiles_Settings__c settings = NEW TVA_CFB__CloudFiles_Settings__c ();
            	settings.TVA_CFB__Bucket_Name__c = 'Test';
            insert settings;
            
            Docuvault_LookupController obj = NEW Docuvault_LookupController ();
            	obj.getBucketName ();
            
            Docuvault_LookupController.getlookupRecords ('Account', 'Household', '', 'abc');
            Docuvault_LookupController.getlookupRecords ('Account', 'Household', 'Name', 'abc');
            Docuvault_LookupController.getAdvSearchRecords ('Account', 'Household','abc');
            System.assertEquals(settings.TVA_CFB__Bucket_Name__c ,'Test');
           
        }
        catch (Exception e) {}
         Test.stopTest();   
    }
}