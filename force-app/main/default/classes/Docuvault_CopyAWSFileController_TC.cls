@isTest
private class Docuvault_CopyAWSFileController_TC {
    static testMethod void method1() {
        TVA_CFB__CloudFiles_Settings__c settings = NEW TVA_CFB__CloudFiles_Settings__c ();
        settings.TVA_CFB__Server_Side_Encryption__c = true;
        settings.Name = 'test';
        settings.TVA_CFB__Bucket_Name__c = 'test';
        insert settings;
        
        TVA_CFB__Cloud_Files_Region_Endpoints__c customSetting = NEW TVA_CFB__Cloud_Files_Region_Endpoints__c ();
        customSetting.TVA_CFB__Endpoint_URL__c = 'test';
        customSetting.Name = 'test';
        
        insert customSetting;   
        
        Map <String, String> testMap = NEW Map <String, String> ();
        testMap.put('currentBucketName','test');
        testMap.put('currentFileName','test');
        testMap.put('newBucketName','test');
        testMap.put('newFileName','test');
        testMap.put('region','test');
        testMap.put('newFileName','test');
        
        Account acc = NEW Account ();
        acc.Name = 'test';
        insert acc;
        
        TVA_CFB__Cloud_Files__c cloudFileDetails = NEW TVA_CFB__Cloud_Files__c ();
        
        cloudFileDetails.Name = 'Test';
        cloudFileDetails.WEGP1_DocumentType__c = 'Document Submission';
        cloudFileDetails.TVA_CFB__Folder__c = 'Test';
        cloudFileDetails.WEGP1_Ready_for_Review__c = true;  
        cloudFileDetails.TVA_CFB__Version__c = 1;
        cloudFileDetails.TVA_CFB__Parent_ID__c = acc.ID;
        cloudFileDetails.WEGP1_Household__c = acc.ID;
        insert cloudFileDetails;  
        
        Map <ID, Map <String, String>> fileDetailsMap = NEW Map <ID, Map <String, String>>  ();
        fileDetailsMap.put(cloudFileDetails.ID,testMap);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Docuvault_CopyAWSFileController obj = NEW Docuvault_CopyAWSFileController();
        Docuvault_CopyAWSFileController.copyAWSObject(fileDetailsMap);
    }
    
    static testMethod void method2() {
        Map <String, String> testMap = NEW Map <String, String> ();
        testMap.put('currentBucketName','test');
        testMap.put('currentFileName','test');
        testMap.put('newBucketName','test');
        testMap.put('newFileName','test');
        testMap.put('region','test');
        testMap.put('newFileName','test');
        
        Account acc = NEW Account ();
        acc.Name = 'test';
        insert acc;
        
        TVA_CFB__Cloud_Files__c cloudFileDetails = NEW TVA_CFB__Cloud_Files__c ();
        
        cloudFileDetails.Name = 'Test';
        cloudFileDetails.WEGP1_DocumentType__c = 'Document Submission';
        cloudFileDetails.TVA_CFB__Folder__c = 'Test';
        cloudFileDetails.WEGP1_Ready_for_Review__c = true;  
        cloudFileDetails.TVA_CFB__Version__c = 1;
        cloudFileDetails.TVA_CFB__Parent_ID__c = acc.ID;
        cloudFileDetails.WEGP1_Household__c = acc.ID;
        insert cloudFileDetails;  
        
        Map <ID, Map <String, String>> fileDetailsMap = NEW Map <ID, Map <String, String>>  ();
        fileDetailsMap.put(cloudFileDetails.ID,testMap);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Docuvault_CopyAWSFileController obj = NEW Docuvault_CopyAWSFileController();
        Docuvault_CopyAWSFileController.copyAWSObject(fileDetailsMap);
    }
}