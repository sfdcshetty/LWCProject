public without sharing class SkienceDeleteAttachmentsHelper {
    /*
    boolean isFAAttachmentUploaded(TVA_CFB__Cloud_Files__c newRec, TVA_CFB__Cloud_Files__c oldRec) {
        return newRec.TVA_CFB__E_Tag__c != oldRec.TVA_CFB__E_Tag__c &&
            newRec.TVA_CFB__E_Tag__c != null && 
            oldRec.WEGP1_FinancialAccount__c != null && 
            !String.isBlank(oldRec.TVA_CFB__Attachment_ID__c);
    }  
    */
    public void run() {
        return;
        
        /*
        if(Trigger.isBefore) {
            for (TVA_CFB__Cloud_Files__c cloudfile: (List<TVA_CFB__Cloud_Files__c>) Trigger.NEW) {
                if(isFAAttachmentUploaded(cloudfile, (TVA_CFB__Cloud_Files__c)Trigger.oldMap.get(cloudfile.id)))
                    cloudfile.TVA_CFB__Attachment_ID__c = null;
            }
            return;
        } 
        
        if(Trigger.isAfter) {
            List<attachment> attachmentsToDelete = new List<attachment>();
            List<Id> affectedFAIds = new List<Id>();
            map<Id,Id> affectedFAattachmentIdsCFids = new map<Id,Id>();
            for (TVA_CFB__Cloud_Files__c cloudfile: (List<TVA_CFB__Cloud_Files__c>)Trigger.OLD) {
                if(isFAAttachmentUploaded((TVA_CFB__Cloud_Files__c)Trigger.newMap.get(cloudfile.id),cloudfile)) {
                    attachmentsToDelete.add(new attachment(id = cloudfile.TVA_CFB__Attachment_ID__c));
                    affectedFAIds.add(cloudfile.WEGP1_FinancialAccount__c);
                    affectedFAattachmentIdsCFids.put(cloudfile.TVA_CFB__Attachment_ID__c, cloudfile.id);
                    // continue and update the FAForms with the clould file id

                }
            }
            if(attachmentsToDelete.size() <= 0) return;
            try {
                delete attachmentsToDelete;
            } catch (Exception ex) {
                system.debug('Exeptions when deleting attachments:' + ex);
                for(attachment att:attachmentsToDelete) system.debug('Attachment could not be deleted:' + att);
                //ignore the exception
            }
            list<SkienceFinSln__FinancialAccountForm__c> FAForms = [select id, SkienceFinSln__Signed_Attachment__c from SkienceFinSln__FinancialAccountForm__c
                                                               where    SkienceFinSln__Financial_Account_Id__c in :affectedFAIds // For use of index
                                                              and SkienceFinSln__Signed_Attachment__c in :affectedFAattachmentIdsCFids.keySet()];
            for(SkienceFinSln__FinancialAccountForm__c FAForm : FAForms) FAForm.SkienceFinSln__Signed_Attachment__c =  String.valueOf(affectedFAattachmentIdsCFids.get(FAForm.SkienceFinSln__Signed_Attachment__c)).substring(0,18);                                                                
            update FAForms;
            return;
        }
		*/
    }
}