public with Sharing class DocuvaultUploadQueuable implements Queueable {
    List <ID> cloudFileIds = NEW List <ID> ();
    
    public DocuvaultUploadQueuable (List <ID> recordIds) {
        cloudFileIds = recordIds;
    }
    public void execute (QueueableContext context) {
        TVA_CFB.UploadAttachmentToCloud.attachmentupload (cloudFileIds,'');          
    }
}