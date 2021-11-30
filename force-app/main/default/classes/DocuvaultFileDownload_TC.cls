@isTest 
private class DocuvaultFileDownload_TC {
    static testMethod void TrackDocuvaultFilesMethod() {
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
            doc.TVA_CFB__Password__c = '12345';
            doc.TVA_CFB__Password_Protect__c = true;
            doc.TVA_CFB__ExterNal_File_Name__c = 'Test';
            
            insert doc;
            
            Tracking_Info__c trac =  NEW Tracking_Info__c();
            trac.Address_Info__c = 'test';
            trac.Browser_Details__c = 'test';
            trac.Cloud_Files__c = doc.id;
            
            Docuvault_Tracking_Info__c temp = NEW Docuvault_Tracking_Info__c();
            temp.Email__c = 'test@gmail.com' ;
            temp.File_Download_Template_Name__c = 'emailtest';
            insert temp;
            
            User thisUser = [select Id from User where Id = :UserInfo.getUserId()]; 
    
            System.runAs(thisUser)  
            { 
                EmailTemplate et  = new EmailTemplate();  
                et.isActive = true;  
                et.Name = 'testTemplate';  
                et.DeveloperName = temp.File_Download_Template_Name__c ;  
                et.TemplateType = 'text';  
                et.FolderId = UserInfo.getUserId();  
                et.Body = 'hi {!Tracking_Info__c.Cloud_Files__c} '; 
                et.Subject = '{!Tracking_Info__c.Cloud_Files__c} ';
                et.HtmlValue = 'hi {!Tracking_Info__c.Cloud_Files__c} ';
                insert et;  
            }
    
            DocuvaultFileDownload Track = NEW DocuvaultFileDownload ();
            DocuvaultFileDownload.downloadFile ('12345', 'http://google.com/PublicFileDownload?'+EncodingUtil.base64Encode (blob.valueOf ('id='+doc.Id)));
            DocuvaultFileDownload.sendCloudFileAsEmail(doc.id, temp.File_Download_Template_Name__c, 'Download');
            DocuvaultFileDownload.createTrackingRecord (trac, 'Download', doc.Id);
            DocuvaultFileDownload.createJournalRecord (doc.id,'123.123.123','test');
            DocuvaultFileDownload.getAllFields('Account');
            System.Assert (doc.id == trac.Cloud_files__c);
        Test.stopTest ();
    }
}