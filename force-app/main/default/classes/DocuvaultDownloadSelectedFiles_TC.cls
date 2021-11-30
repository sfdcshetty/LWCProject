@isTest 
private class DocuvaultDownloadSelectedFiles_TC {
    static testMethod void downloadFile () {
        Test.startTest ();
            TVA_CFB__CloudFiles_Settings__c customSettings = NEW TVA_CFB__CloudFiles_Settings__c ();
            customSettings.TVA_CFB__bucket_name__c = 'testBucket';
            customSettings.TVA_CFB__Access_Key__c = 'testKey';
            customSettings.TVA_CFB__Secret_Key__c = 'testSecret';
            customSettings.TVA_CFB__Folder_Share_URL__c = 'test.com';       
            customSettings.TVA_CFB__Salesforce_Site_URL__c='test';
            customSettings.TVA_CFB__Enable_Google_URL_Shortener__c =true;
            insert customSettings;
            
            Account parent = NEW Account();
            parent.name = 'Test';
            insert parent;
            
            List <TVA_CFB__Cloud_Files__c> cloudFileList = new List <TVA_CFB__Cloud_Files__c>();
            TVA_CFB__Cloud_Files__c doc = NEW TVA_CFB__Cloud_Files__c();
            doc.TVA_CFB__file_type__c = 'jpg';
            doc.TVA_CFB__Account__c = parent.ID;
            doc.TVA_CFB__Parent_ID__c = parent.id;
            doc.Name = 'test.doc';
            doc.TVA_CFB__Bucket_Name__c = 'testBucket';
            doc.TVA_CFB__Folder__c = 'test';
            doc.TVA_CFB__Region__c = 'us-east-1';
            doc.TVA_CFB__ExterNal_File_Name__c = 'Test';
            insert doc;
            cloudFileList.add (doc);
            
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController (cloudFileList);
            stdSetController.setSelected (cloudFileList);
            Docuvault_DownloadSelectedFiles obj = NEW Docuvault_DownloadSelectedFiles (stdSetController);
            Docuvault_DownloadSelectedFiles.generateDownloadURL (doc.Id);
            
        Test.stopTest ();
       
    }
}