@isTest 
private class DocuvaultFileRequest_TC {
    static testMethod void DocuvaultFileRequestMethod() {
        Test.startTest ();
            TVA_CFB__CloudFiles_Settings__c customSettings = NEW TVA_CFB__CloudFiles_Settings__c ();
            customSettings.TVA_CFB__bucket_name__c = 'testBucket';
            customSettings.TVA_CFB__Access_Key__c = 'testKey';
            customSettings.TVA_CFB__Secret_Key__c = 'testSecret';
            customSettings.TVA_CFB__Folder_Share_URL__c = 'test.com';       
            customSettings.TVA_CFB__Salesforce_Site_URL__c='test';
            customSettings.TVA_CFB__Enable_Google_URL_Shortener__c =true;
            customSettings.TVA_CFB__Amazon_URL__c = 'https://s3.amazonaws.com';
            insert customSettings;
            
            TVA_CFB__Cloud_Files_Region_Endpoints__c regionEnd = new TVA_CFB__Cloud_Files_Region_Endpoints__c();
            regionEnd.Name = 'us-east-1';
            regionEnd.TVA_CFB__Endpoint_URL__c = 'https://s3.amazonaws.com';
            insert regionEnd;
            
            TVA_CFB__CloudFiles_LookUp_Mapping__c settings = new TVA_CFB__CloudFiles_LookUp_Mapping__c ();
            settings.name = 'Account';
            settings.TVA_CFB__Field_Name__c = 'TVA_CFB__Account__c';
            settings.TVA_CFB__Object_API__c = 'Account';
            insert settings;
            
            Account parent = NEW Account();
            parent.name = 'Test';
            insert parent;
            
            TVA_CFB__File_request__c fr = NEW TVA_CFB__File_request__c ();
            fr.TVA_CFB__Account__c = parent.id;
            fr.TVA_CFB__Parent_ID__c = parent.id;
            insert fr;

            TVA_CFB__Cloud_Files__c doc = NEW TVA_CFB__Cloud_Files__c();
            doc.TVA_CFB__file_type__c = 'jpg';
            doc.TVA_CFB__Account__c = parent.ID;
            doc.TVA_CFB__Parent_ID__c = parent.id;
            doc.TVA_CFB__File_Size_in_Bytes__c = 12354;
            doc.Name = 'test.doc';
            doc.TVA_CFB__Bucket_Name__c = 'testBucket';
            doc.TVA_CFB__Folder__c = 'test';
            doc.TVA_CFB__Region__c = 'us-east-1';
            doc.TVA_CFB__ExterNal_File_Name__c = 'Test';
            doc.TVA_CFB__File_request__c = fr.Id;
            doc.TVA_CFB__E_tag__c = 'testt';
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
    
            fr = [ SELECT TVA_CFB__Parent_ID__c, CreatedDate, TVA_CFB__Upload_Count__c,
                        TVA_CFB__Expiration_Date__c From TVA_CFB__File_Request__c WHERE ID =: fr.ID ];
                
            
            Blob beforeblob = Blob.valueOf('id='+fr.CreatedDate+'/#'+fr.Id);
            System.currentPagereference().getParameters().put ('encodedIDVal', EncodingUtil.base64Encode(beforeblob));
            try {
                TVA_CFB.RequestFileUpload uploadController = NEW TVA_CFB.RequestFileUpload();
    
                uploadController.encodedId = 'https://google.com/TVA_CFB__RequestFile?'+EncodingUtil.base64Encode(beforeblob);  
            }
            catch (Exception e) {}  
            DocuvaultFileRequest Track = NEW DocuvaultFileRequest();
            DocuvaultFileRequest.updateFileRequestUploadCount('4', fr.ID);
            DocuvaultFileRequest.createTrackingRecord (trac, 'Upload', fr.Id);
            DocuvaultFileRequest.createJournalRecord  ('Document Share',fr.id,'123.123.123.123');
            
            Map <String, String> s3Details = new Map <String, String> ();
            s3Details.put ('parentID', fr.TVA_CFB__Parent_ID__c);
            s3Details.put ('fileName', 'test.pdf');
            s3Details.put ('parentObjectName', 'TVA_CFB__Account__c');
            s3Details.put ('aclKey', 'private');
            s3Details.put ('BucketName', 'testBucket');
            s3Details.put ('region', 'us-east-1');
            
            DocuvaultFileRequest.calculateSignature (s3Details);
            DocuvaultFileRequest.getBucketLocation (customSettings, 'testBucket');
            DocuvaultFileRequest.uploadStandaloneFile (JSON.serialize (doc), null);
            
            DocuvaultFileRequest.updateETag ('"test"', 'test', doc.Id, '204');
            DocuvaultFileRequest.deleteFailedRec (doc.Id);
            
            System.Assert (doc.id == trac.Cloud_files__c);
        Test.stopTest ();
    }
}