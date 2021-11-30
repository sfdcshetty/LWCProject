trigger SkienceAttachmentAsCloudFile on Attachment (after insert) {
    // Uploads attachments to DocuVault. This is enabled only when the attachment is related to an FA.
    // Can be extended to other parent objects too.
    // 
    // Amazon Credentials stored in Custom settings
    ID userId = userInfo.getUserId();
    TVA_CFB__CloudFiles_Settings__c credentials = TVA_CFB__CloudFiles_Settings__c.getInstance(userId);
    Map <String, TVA_CFB__CloudFiles_LookUp_Mapping__c> lookupMappings = TVA_CFB__CloudFiles_LookUp_Mapping__c.getAll ();
    List <Sobject> cloudFilesList = new List <Sobject> ();
    String sObjName;
    for (Attachment att: Trigger.NEW) {
        if (att.ParentId != NULL) {
            sObjName = att.ParentId.getSObjectType ().getDescribe().getName();
            System.Debug (sObjName);
            System.Debug (lookupMappings+'==='+ lookupMappings.containsKey (sObjName));
            
            if (sObjName == 'FinServ__FinancialAccount__c' || lookupMappings.containsKey (sObjName)){
                // Creating cloud File Record for every attachment
                Sobject cloudFile = NEW TVA_CFB__Cloud_files__c ();
                
                String type = '';
                try {
                    system.debug('att.name:' + att.Name + 'Split:' + '\\.');
                    List <String> attachmentType = att.Name.split ('\\.');
                    type = attachmentType[attachmentType.size () - 1];
                } catch (Exception e) {
                    system.debug('e:' + e);
                    system.debug('Setting the type to contenttype:' + att.ContentType);
                    type = att.ContentType;
                }
                cloudFile.put('TVA_CFB__File_type__c', type);
                
                //cloudFile.put('TVA_CFB__File_type__c', att.ContentType);
                
                cloudFile.put ('Name', att.Name);
                cloudFile.put ('TVA_CFB__Parent_ID__c', att.ParentId);
                cloudFile.put ('TVA_CFB__File_Size_In_Bytes__c', att.BodyLength);
                cloudFile.put ('TVA_CFB__Bucket_Name__c', credentials.TVA_CFB__Bucket_Name__c);
                cloudFile.put ('TVA_CFB__Version__c', 1);
                cloudFile.put (lookupMappings.get (sObjName).TVA_CFB__Field_Name__c, att.ParentId);
                cloudFile.put ('TVA_CFB__Attachment_ID__c', att.id);
                cloudFilesList.add (cloudFile);
                system.debug('cloufile rec:' + JSON.serialize(cloudFile));
            }
        }
    }
    if(cloudFilesList.size() <= 0) return;
    Database.Insert (cloudFilesList, false);
    // Storing inserted cloud File Ids in a List
    List <Id> cloudFileIds = NEW List <ID> ();
    for (Sobject file: cloudFilesList) {
        cloudFileIds.add (file.ID);
    }
    // Calling Docuvault class to upload attachment as a cloud file.
    if (cloudFileIds.size () > 0) {
        // Future method TVA_CFB.UploadAttachmentToCloud.attachmentUpload(cloudFileIds, (sObjName=='FinServ__FinancialAccount__c'?'DELETE':''));
        // Sync method            TVA_CFB.UploadAttachmentToCloud.uploadAttachment(cloudFileIds, (sObjName=='FinServ__FinancialAccount__c'?'DELETE':''));
        //TVA_CFB.UploadAttachmentToCloud.uploadAttachment(cloudFileIds,'');
        System.enqueueJob(new DocuvaultUploadQueuable (cloudFileIds));
    }
}