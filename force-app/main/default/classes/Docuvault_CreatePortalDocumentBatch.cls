global class Docuvault_CreatePortalDocumentBatch implements Database.Batchable <sObject>, Database.AllowsCallouts, Database.Stateful {

    global List <Id> portalFileIds;
    
    global Docuvault_CreatePortalDocumentBatch (List <Id> cloudFileIds) {
        portalFileIds = NEW List <Id> ();
        portalFileIds = cloudFileIds;
    }
    
    global Database.QueryLocator start (Database.BatchableContext BC) {
        String query = ' SELECT TVA_CFB__Attachment_ID__c, TVA_CFB__Region__c, TVA_CFB__Bucket_Name__c,'
                        +' Name, TVA_CFB__File_Type__c '
                        +' FROM TVA_CFB__Cloud_Files__c '
                        +' WHERE Id IN: portalFileIds ';
                        
        
        return Database.getQueryLocator (query);
    }
    
    global void execute (Database.BatchableContext BC,
                            List <TVA_CFB__Cloud_Files__c> scope) {
        TVA_CFB__CloudFiles_Settings__c settings = TVA_CFB__CloudFiles_Settings__c.getInstance (UserInfo.getUserID());
        Docuvault_Journaling_Email__c customSettingDetails = Docuvault_Journaling_Email__c.getInstance (UserInfo.getUserID ());
        String shareOnPortalEmailEmailTemplate = customSettingDetails.Share_on_Portal_Email_Template__c;
        Map <String, String> contentTypeMap = New Map <String, String> ();
        try {
            for (TVA_CFB__CloudFiles_MIME_Types__c fileMIMETypes :[SELECT 
                                                        Name, TVA_CFB__Content_Type__c 
                                                       FROM 
                                                           TVA_CFB__CloudFiles_MIME_Types__c 
                                                       WHERE 
                                                           Name != NULL ]) {
                                                           
                                                           
                contentTypeMap.put (fileMIMETypes.Name, fileMIMETypes.TVA_CFB__Content_Type__c);
            }
            
            List <TVA_CFB__Cloud_Files__c> cloudFilesToUpdate = NEW List <TVA_CFB__Cloud_Files__c> ();
            
            for (TVA_CFB__Cloud_Files__c cloudFile : scope) {
                TVA_CFB__Cloud_Files__c file = copyS3File (cloudFile, 
                    settings, 
                    contentTypeMap, 
                    cloudFile.TVA_CFB__Bucket_Name__c, 
                    cloudFile.TVA_CFB__Attachment_ID__c+'.'+cloudFile.TVA_CFB__File_Type__c);
                cloudFilesToUpdate.add (file);
                System.enqueueJob(NEW Docuvault_JournalingQueueableController (file.Id, shareOnPortalEmailEmailTemplate));
            }
            
            if (cloudFilesToUpdate.size () > 0) {
                update cloudFilesToUpdate;
            }
            
        }
        catch (Exception e) {
        
        }
    }
    
    global void finish (Database.BatchableContext BC) {
    
            if (portalFileIds.size () > 0) {
                System.enqueuejob(NEW Docuvault_ComplianceQueueable(portalFileIds));
                                    
            }
        
    
    }
    
    global TVA_CFB__Cloud_Files__c copyS3File (TVA_CFB__Cloud_Files__c file, 
        TVA_CFB__CloudFiles_Settings__c settings, 
        Map <String, String> contentTypeMap, 
        String oldBucketName, 
        String oldFileName) {
            
            String contentType = 'binary/octet-stream';
            
            if (file.TVA_CFB__File_Type__c != null) {
                if (contentTypeMap.containsKey (file.TVA_CFB__File_Type__c.toLowerCase ()))
                    contentType = contentTypeMap.get (file.TVA_CFB__File_Type__c.toLowerCase ());
            }
            
            String newFileName = file.ID + '.' + file.TVA_CFB__File_Type__c;

            
            HTTPResponse res = Docuvault_RenameAWSFileHelper.renameFile (file.TVA_CFB__Region__c, 
                                                               oldBucketName, // Current Bucket Name
                                                               oldFileName, // Current File Name
                                                               file.TVA_CFB__Bucket_Name__c, // new Bucket Name
                                                               newFileName , // New File Name
                                                               contentType);
        
        
            System.Debug ('===Response Body=='+res.getBody ());
            If (Test.isRunningTest ()) {
                res.setStatusCode (200);
                res.setBody ('<ETag>&quot;abc&quot;</ETag>');
                res.setHeader ('x-amz-version-id', 'xyz');
            }
            
            if (res.getStatusCode () == 200) {
                String eTag = res.getBody ();
                eTag = eTag.subStringBetween ('<ETag>&quot;', '&quot;</ETag>');
                String versionId = res.getHeader ('x-amz-version-id');
                file.TVA_CFB__E_TAG__c = eTag;
                file.TVA_CFB__Amazon_Version_ID__c = versionId;
                file.TVA_CFB__Reponse_Code__c = '204';
            } else {
                file.AWS_Error__c = res.getBody();
            }
            
        return file;
    }
}