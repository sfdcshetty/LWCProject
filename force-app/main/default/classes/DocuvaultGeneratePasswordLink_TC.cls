@isTest 
private class DocuvaultGeneratePasswordLink_TC {
    static testMethod void generateNewPasswordLink () {
        Test.startTest ();
            TVA_CFB__CloudFiles_Settings__c customSettings = NEW TVA_CFB__CloudFiles_Settings__c ();
            customSettings.TVA_CFB__bucket_name__c = 'testBucket';
            customSettings.TVA_CFB__Access_Key__c = 'testKey';
            customSettings.TVA_CFB__Secret_Key__c = 'testSecret';
            customSettings.TVA_CFB__Folder_Share_URL__c = 'test.com';       
            customSettings.TVA_CFB__Salesforce_Site_URL__c='test';
            customSettings.TVA_CFB__Enable_Google_URL_Shortener__c =true;
            insert customSettings;
            
            TVA_CFB__Cloud_Files_Region_Endpoints__c regionEnd = new TVA_CFB__Cloud_Files_Region_Endpoints__c();
            regionEnd.Name = 'us-east-1';
            regionEnd.TVA_CFB__Endpoint_URL__c = 'https://s3.amazonaws.com';
            insert regionEnd;
            
            Account parent = NEW Account();
            parent.name = 'Test';
            insert parent;

            TVA_CFB__Cloud_Files__c doc = NEW TVA_CFB__Cloud_Files__c();
            doc.TVA_CFB__file_type__c = 'jpg';
            doc.TVA_CFB__Account__c = parent.ID;
            doc.TVA_CFB__Parent_ID__c = parent.id;
            doc.Name = 'test.doc';
            doc.TVA_CFB__Bucket_Name__c = 'testBucket';
            doc.TVA_CFB__Folder__c = 'test';
            doc.TVA_CFB__Region__c = 'us-east-1';
            doc.TVA_CFB__ExterNal_File_Name__c = 'Test';
            doc.TVA_CFB__File_Size_in_Bytes__c = 100;
            
            insert doc;
            
    
            DocuvaultGeneratePasswordLinkController Track = NEW DocuvaultGeneratePasswordLinkController ();
            DocuvaultGeneratePasswordLinkController.generateShareableLink (doc.id, 'test@gmail.com');
           
            System.Assert (doc.Name == 'test.doc');
        Test.stopTest ();
    }
    
    static testMethod void generateExistingPasswordLink () {
        Test.startTest ();
            TVA_CFB__CloudFiles_Settings__c customSettings = NEW TVA_CFB__CloudFiles_Settings__c ();
            customSettings.TVA_CFB__bucket_name__c = 'testBucket';
            customSettings.TVA_CFB__Access_Key__c = 'testKey';
            customSettings.TVA_CFB__Secret_Key__c = 'testSecret';
            customSettings.TVA_CFB__Folder_Share_URL__c = 'test.com';       
            customSettings.TVA_CFB__Salesforce_Site_URL__c='test';
            customSettings.TVA_CFB__Enable_Google_URL_Shortener__c =true;
            insert customSettings;
            
            TVA_CFB__Cloud_Files_Region_Endpoints__c regionEnd = new TVA_CFB__Cloud_Files_Region_Endpoints__c();
            regionEnd.Name = 'us-east-1';
            regionEnd.TVA_CFB__Endpoint_URL__c = 'https://s3.amazonaws.com';
            insert regionEnd;
            
            Account parent = NEW Account();
            parent.name = 'Test';
            insert parent;

            TVA_CFB__Cloud_Files__c doc = NEW TVA_CFB__Cloud_Files__c();
            doc.TVA_CFB__file_type__c = 'jpg';
            doc.TVA_CFB__Account__c = parent.ID;
            doc.TVA_CFB__Parent_ID__c = parent.id;
            doc.Name = 'test.doc';
            doc.TVA_CFB__Bucket_Name__c = 'testBucket';
            doc.TVA_CFB__Folder__c = 'test';
            doc.TVA_CFB__Region__c = 'us-east-1';
            doc.TVA_CFB__ExterNal_File_Name__c = 'Test';
            doc.TVA_CFB__Cloud_Public_Access_URL__c = 'www.test.com';
            doc.TVA_CFB__Password__c = 'Docuvault';
            doc.TVA_CFB__Password_Protect__c = TRUE; 
            doc.TVA_CFB__File_Size_in_Bytes__c = 100;
            
            insert doc;
            
    
            DocuvaultGeneratePasswordLinkController Track = NEW DocuvaultGeneratePasswordLinkController ();
            DocuvaultGeneratePasswordLinkController.generateShareableLink (doc.id, 'test@gmail.com');
           
            System.Assert (doc.Name == 'test.doc');
        Test.stopTest ();
    }
}