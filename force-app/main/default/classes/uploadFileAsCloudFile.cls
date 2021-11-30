global withOut sharing class uploadFileAsCloudFile {
    
    webService static void createCloudFile (String fileName, String contentMIMEType, 
                                            Decimal fileSize, String parentID, 
                                            Blob fileData)
    {
        String prefix = '';
        String parentObjectName = '';
        String parentName = '';
        ID userId = userInfo.getUserId();
        TVA_CFB__CloudFiles_Settings__c credentials = TVA_CFB__CloudFiles_Settings__c.getInstance (userId);
        List <SObject> cloudFilesToInsert = new List <SObject> ();
        List <TVA_CFB__CloudFiles_LookUp_Mapping__c> childObjectSetting = new List <TVA_CFB__CloudFiles_LookUp_Mapping__c> ();
        List <Schema.SObjectType> gd = Schema.getGlobalDescribe().Values ();
        Map <String,String> objectMap = NEW Map <String,String> ();
        for (Schema.SObjectType f : gd){
            objectMap.put (f.getDescribe ().getKeyPrefix (), f.getDescribe ().getName ());
        }
        ID recParentID = parentID;
        if (parentID != null || parentId != '') {
            prefix = (parentID).subString (0,3);
            parentName = objectMap.get (prefix);
            system.debug('parentName'+parentName);
            try {
                childObjectSetting = [ SELECT Name, TVA_CFB__Field_Name__c, TVA_CFB__Object_API__c 
                                      FROM TVA_CFB__CloudFiles_LookUp_Mapping__c 
                                      WHERE (Name =: parentName OR TVA_CFB__Object_API__c =: parentName )
                                      LIMIT 1 ];
            }catch (Exception e) {
                System.debug('Entered Catch'+e.getMessage());
            }
            if (childObjectSetting.size () > 0) {
                for (TVA_CFB__CloudFiles_LookUp_Mapping__c mapping :childObjectSetting) 
                    if (mapping.Name == parentName || mapping.TVA_CFB__Object_API__c == parentName)
                    parentObjectName = mapping.TVA_CFB__Field_Name__c;
            }
        }
        if (parentObjectName != '' ) {
            sObject childObject = Schema.getGlobalDescribe ().get ('TVA_CFB__Cloud_Files__c').newsObject() ; 
            childObject.put (parentObjectName , parentId);
            childObject.put ('Name', fileName );
            childObject.put ('TVA_CFB__File_Size_in_Bytes__c', fileSize);
            String[] fileNames = (fileName).split('\\.');
            childObject.put ('TVA_CFB__File_Type__c', fileNames.get (fileNames.size() -1));
            childObject.put ('TVA_CFB__Bucket_name__c', credentials.TVA_CFB__Bucket_Name__c);
            childObject.put ('TVA_CFB__Parent_ID__c', recParentID );
            cloudFilesToInsert.add (childObject);
        }
        if (cloudFilesToInsert.size () > 0 ) {
            insert cloudFilesToInsert;
            List <ID> cloudFileIDs = new List <ID> ();
            for (SObject cloudFile : cloudFilesToInsert) {
                cloudFileIDs.add (cloudFile.ID);
            }
            uploadFileAsCloudFile.uploadToCloud (cloudFileIDs, fileData, contentMIMEType);
        }        
    }
    
    @Future (callout = TRUE) 
    global static void uploadToCloud ( List<ID> cloudFileIdsList, Blob fileContent, String fileMIMEType) {
        List <TVA_CFB__Cloud_files__c> cloudFilesToUpdate = new List <TVA_CFB__Cloud_files__c> ();
        List <TVA_CFB__Cloud_files__c> cloudFilesToDelete = new List <TVA_CFB__Cloud_files__c> ();
        ID userId = userInfo.getUserId();
        TVA_CFB__CloudFiles_Settings__c credentials = TVA_CFB__CloudFiles_Settings__c.getInstance (userId); 
        Map <String, TVA_CFB__Cloud_Files_Region_Endpoints__c> regionEndpoints = new Map <String, TVA_CFB__Cloud_Files_Region_Endpoints__c>();
        regionEndpoints = TVA_CFB__Cloud_Files_Region_Endpoints__c.getAll ();   
        List <TVA_CFB__Cloud_files__c> cloudFilesList = new List<TVA_CFB__Cloud_files__c> ();
        cloudFilesList = [ SELECT 
                          Name, CreatedDate, TVA_CFB__External_File_name__c,
                          TVA_CFB__File_Size_in_Bytes__c ,TVA_CFB__File_Type__c ,
                          TVA_CFB__Bucket_name__c ,TVA_CFB__Parent_ID__c ,
                          TVA_CFB__Attachment_ID__c, TVA_CFB__Region__c
                          FROM 
                          TVA_CFB__Cloud_Files__c  
                          WHERE 
                          ID in: cloudFileIdsList ];
        String region = '';
        if (!Test.isRunningTest ())
            region = TVA_CFB.amazonS3Authentication.getBucketLocation (credentials, credentials.TVA_CFB__Bucket_Name__c);
        for (TVA_CFB__Cloud_Files__c  sigleCloudFile : cloudFilesList) {
            try {
                String fileName = (String.valueOf (sigleCloudFile.ID)+'.'+sigleCloudFile.TVA_CFB__File_Type__c);
                if (sigleCloudFile.TVA_CFB__External_File_name__c != null) {
                    fileName = EncodingUtil.urlEncode (sigleCloudFile.TVA_CFB__External_File_name__c, 'UTF-8');
                }
                String objectCreatedDate = sigleCloudFile.CreatedDate.formatGmt('yyyy-MM-dd') + 'T' + sigleCloudFile.CreatedDate.formatGmt ('HH:mm:ss') +'Z';
                String parentObjectName = '';
                if (sigleCloudFile.TVA_CFB__Region__c != NULL)
                    region = sigleCloudFile.TVA_CFB__Region__c;
                String BucketName = sigleCloudFile.TVA_CFB__Bucket_Name__c;
                if (BucketName == NULL)
                    BucketName = credentials.TVA_CFB__Bucket_Name__c;
                if (!Test.isRunningTest ())
                    parentObjectName = TVA_CFB.amazonS3Authentication.getCurrentRecordID (sigleCloudFile.TVA_CFB__Parent_ID__c);
                Map <String, String> mapCFileDetails = NEW Map <String, String> ();
                mapCFileDetails.put ('bucket', BucketName);
                mapCFileDetails.put ('fileName', fileName);
                mapCFileDetails.put ('region', region);
                if (fileMIMEType == '' || fileMIMEType == NULL) {
                    fileMIMEType = 'application/x-amz-json-1.0';
                }
                mapCFileDetails.put ('cType', fileMIMEType);
                Map <String, String> metaDataMap = NEW Map <String, String> ();
                metaDataMap.put ('x-amz-meta-filename', sigleCloudFile.Name);
                metaDataMap.put ('x-amz-meta-objectcreateddate', objectCreatedDate);
                metaDataMap.put ('x-amz-meta-ownername',userInfo.getName ());
                metaDataMap.put ('x-amz-meta-parentid',sigleCloudFile.TVA_CFB__Parent_ID__c);
                metaDataMap.put ('x-amz-meta-parentobjectname', parentObjectName);
                HTTPResponse response = NEW HTTPResponse ();
                if (!Test.isRunningTest()) {
                    response = TVA_CFB.amazonS3Authentication.UploadAttachmentToS3 (credentials, mapCFileDetails, 
                                                                                    metaDataMap, regionEndPoints, 
                                                                                    fileContent);
                }    
                if (Test.isRunningTest())
                    response.setstatusCode (200);
                if (response.getStatusCode () == 200) {
                    sigleCloudFile.TVA_CFB__Region__c = region ;
                    sigleCloudFile.TVA_CFB__E_Tag__c = response.getHeader ('ETag').removeStart ('"').removeEnd ('"');
                    sigleCloudFile.TVA_CFB__Amazon_Version_ID__c = response.getHeader ('x-amz-version-id');
                    sigleCloudFile.TVA_CFB__Reponse_Code__c = String.valueOf (response.getStatusCode ());
                    cloudFilesToUpdate.add (sigleCloudFile);
                }
                if (response.getStatusCode () != 200 ) {
                    cloudFilesToDelete.add (sigleCloudFile);
                }
            }
            catch (Exception e) {
                System.debug('Entered Catch2'+e.getMessage());
                System.debug('Entered Catch2'+e.getLineNumber());
                cloudFilesToDelete.add (sigleCloudFile);
            }
        }
        if (!cloudFilesToUpdate.isEmpty ())
            Update cloudFilesToUpdate;
        if (!cloudFilesToDelete.isEmpty ()) 
            Delete cloudFilesToDelete;
    }
}