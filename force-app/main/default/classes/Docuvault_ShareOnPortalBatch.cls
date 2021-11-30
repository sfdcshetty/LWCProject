//TestClassName: Docuvault_DD_ShareOnPortal_TC
global class Docuvault_ShareOnPortalBatch implements Database.Batchable <sObject>, Database.AllowsCallouts, Database.Stateful {

    global List <Id> portalFileIds;
    global Docuvault_ShareOnPortalBatch (List <Id> cloudFileIds) {
        portalFileIds = NEW List <Id> ();
        portalFileIds = cloudFileIds;
    }
    global Database.QueryLocator start (Database.BatchableContext BC) {
        String query = ' SELECT TVA_CFB__Attachment_ID__c, TVA_CFB__Region__c, TVA_CFB__Bucket_Name__c, Parent_CloudFile_Id__c,'
                        +' Name, TVA_CFB__File_Type__c '
                        +' FROM TVA_CFB__Cloud_Files__c '
                        +' WHERE Id IN: portalFileIds ';
        return Database.getQueryLocator (query);
    }
    
    global void execute (Database.BatchableContext BC, List <TVA_CFB__Cloud_Files__c> scope) {
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
            Set<Id> cloudFileIds = new Set<Id>();
            for (TVA_CFB__Cloud_Files__c cloudFile : scope) {
                cloudFileIds.add(cloudFile.Parent_CloudFile_Id__c);
                Docuvault_CreatePortalDocumentBatch obj = new Docuvault_CreatePortalDocumentBatch(new List <Id>());
                TVA_CFB__Cloud_Files__c file = obj.copyS3File (cloudFile, 
                    settings, 
                    contentTypeMap, 
                    cloudFile.TVA_CFB__Bucket_Name__c, 
                    cloudFile.TVA_CFB__Attachment_ID__c+'.'+cloudFile.TVA_CFB__File_Type__c);
                    
                cloudFilesToUpdate.add (file);
                Docuvault_JournalingEmailController.sendCloudFileAsEmail (file.Id, shareOnPortalEmailEmailTemplate);

            }
            if (cloudFilesToUpdate.size () > 0) {
                update cloudFilesToUpdate;
            }
        } catch (Exception e) {}
    
    }
    global void finish (Database.BatchableContext BC) {
        if (portalFileIds.size () > 0) {
            System.enqueuejob(NEW Docuvault_ComplianceQueueable(portalFileIds));
                                
        }
    }

}