@isTest
private class Docuvault_S3NotificationController_TC {
    static testMethod void newCloudFileMethod () {
        TVA_CFB__Cloud_Files_Region_Endpoints__c customSetting = NEW TVA_CFB__Cloud_Files_Region_Endpoints__c ();
        customSetting.TVA_CFB__Endpoint_URL__c = 'test';
        customSetting.Name = 'us - east - 1';
        insert customSetting;   
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();

        Account acc = NEW Account ();
        acc.Name = 'test';
        acc.RecordTypeId = devRecordTypeId; 
        insert acc;
        DateTime dateTimeNow = dateTime.now();
        String unixTime = ''+dateTimeNow.getTime()/1000;
        
        String reqBody = '   {   "Type": "Notification", ';
        reqBody += '"Message": "{\\"Records\\":[{\\"awsRegion\\":\\"us - east - 1\\",\\"s3\\":{\\"bucket\\":{\\"name\\":\\"wealthenhancement\\"},\\"object\\":{\\"key\\":\\"test_'+unixTime+'.jpg\\",\\"size\\":1400676}}}]}"';
        reqBody += '}';
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'http://testing.com';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(reqBody);
        Blob body1 = req.requestBody;
        String bodyString = body1.toString(); 
        RestContext.request = req;
        RestContext.response = res;
        Docuvault_S3NotificationController obj = NEW Docuvault_S3NotificationController();
        Docuvault_S3NotificationController.getSNSNotification(); 
    }  
    static testMethod void method1() {
        TVA_CFB__Cloud_Files_Region_Endpoints__c customSetting = NEW TVA_CFB__Cloud_Files_Region_Endpoints__c ();
        customSetting.TVA_CFB__Endpoint_URL__c = 'test';
        customSetting.Name = 'us - east - 1';
        insert customSetting;   
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        
        Account acc = NEW Account ();
        acc.Name = 'test';
        acc.RecordTypeId = devRecordTypeId;
        insert acc;
        
        TVA_CFB__Cloud_Files__c cloudFileDetails = NEW TVA_CFB__Cloud_Files__c ();
        
        cloudFileDetails.Name = 'Test_\\.pdf';
        cloudFileDetails.WEGP1_DocumentType__c = 'Document Submission';
        cloudFileDetails.TVA_CFB__Folder__c = 'Test';
        cloudFileDetails.WEGP1_Ready_for_Review__c = true;  
        cloudFileDetails.TVA_CFB__Version__c = 1;
        cloudFileDetails.TVA_CFB__Parent_ID__c = acc.ID;
        cloudFileDetails.WEGP1_Household__c = acc.ID;
        insert cloudFileDetails;
        
        String reqBody = '   {   "Type": "Notification", ';
        reqBody += '"Message": "{\\"Records\\":[{\\"awsRegion\\":\\"us - east - 1\\",\\"s3\\":{\\"bucket\\":{\\"name\\":\\"wealthenhancement\\"},\\"object\\":{\\"key\\":\\"test_'+cloudFileDetails.Id+'.jpg\\",\\"size\\":1400676}}}]}"';
        reqBody += '}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'http://testing.com';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(reqBody);
        Blob body1 = req.requestBody;
        String bodyString = body1.toString(); 
        RestContext.request = req;
        RestContext.response = res;
        Docuvault_S3NotificationController obj = NEW Docuvault_S3NotificationController();
        Docuvault_S3NotificationController.getSNSNotification(); 
    }  
    static testMethod void method2 () {
        TVA_CFB__Cloud_Files_Region_Endpoints__c customSetting = NEW TVA_CFB__Cloud_Files_Region_Endpoints__c ();
        customSetting.TVA_CFB__Endpoint_URL__c = 'test';
        customSetting.Name = 'test';
        insert customSetting;   
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Account acc = NEW Account ();
        acc.Name = 'test';
        acc.RecordTypeId = devRecordTypeId;
        insert acc;
        
        TVA_CFB__Cloud_Files__c cloudFileDetails = NEW TVA_CFB__Cloud_Files__c ();
        
        cloudFileDetails.Name = 'Test_\\.pdf';
        cloudFileDetails.WEGP1_DocumentType__c = 'Document Submission';
        cloudFileDetails.TVA_CFB__Folder__c = 'Test';
        cloudFileDetails.WEGP1_Ready_for_Review__c = true;  
        cloudFileDetails.TVA_CFB__Version__c = 1;
        cloudFileDetails.TVA_CFB__Parent_ID__c = acc.ID;
        cloudFileDetails.WEGP1_Household__c = acc.ID;
        insert cloudFileDetails;
        
        String reqBody = '   { "Type": "SubscriptionConfirmation"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'http://testing.com';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(reqBody);
        Blob body1 = req.requestBody;
        String bodyString = body1.toString(); 
        RestContext.request = req;
        RestContext.response = res;
        Docuvault_S3NotificationController obj = NEW Docuvault_S3NotificationController();
        Docuvault_S3NotificationController.getSNSNotification();

    }
       static testMethod void method3() {
        TVA_CFB__Cloud_Files_Region_Endpoints__c customSetting = NEW TVA_CFB__Cloud_Files_Region_Endpoints__c ();
        customSetting.TVA_CFB__Endpoint_URL__c = 'test';
        customSetting.Name = 'us - east - 1';
        insert customSetting;   
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        
        Account acc = NEW Account ();
        acc.Name = 'test';
        acc.RecordTypeId = devRecordTypeId;
        insert acc;
        
        TVA_CFB__Cloud_Files__c cloudFileDetails = NEW TVA_CFB__Cloud_Files__c ();
        
        cloudFileDetails.Name = 'Test_\\.pdf';
        cloudFileDetails.WEGP1_DocumentType__c = 'Document Submission';
        cloudFileDetails.TVA_CFB__Folder__c = 'Test';
        cloudFileDetails.WEGP1_Ready_for_Review__c = true;  
        cloudFileDetails.TVA_CFB__Version__c = 1;
        cloudFileDetails.TVA_CFB__Parent_ID__c = acc.ID;
        cloudFileDetails.WEGP1_Household__c = acc.ID;
        insert cloudFileDetails;
        
        String bucketName = label.wegdigitalPrdBucket;
        String reqBody = '   {   "Type": "Notification", ';
        reqBody += '"Message": "{\\"Records\\":[{\\"awsRegion\\":\\"us - east - 1\\",\\"s3\\":{\\"bucket\\":{\\"name\\":\\"'+bucketName +'\\"},\\"object\\":{\\"key\\":\\"236794_QAMR_'+cloudFileDetails.Id+'.jpg\\",\\"size\\":1400676}}}]}"';
        reqBody += '}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'http://testing.com';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(reqBody);
        Blob body1 = req.requestBody;
        String bodyString = body1.toString(); 
        RestContext.request = req;
        RestContext.response = res;
        Docuvault_S3NotificationController obj = NEW Docuvault_S3NotificationController();
        Docuvault_S3NotificationController.getSNSNotification(); 
    }
     
}