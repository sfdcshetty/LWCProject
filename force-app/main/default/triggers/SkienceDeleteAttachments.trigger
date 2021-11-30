trigger SkienceDeleteAttachments on TVA_CFB__Cloud_Files__c (after update, before update) {
    // For an updated FA cloud file, if the cloud load is complete, delete the attachment 
    new SkienceDeleteAttachmentsHelper().run();
}