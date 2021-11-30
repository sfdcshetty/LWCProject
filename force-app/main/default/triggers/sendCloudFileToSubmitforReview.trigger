trigger sendCloudFileToSubmitforReview on TVA_CFB__Cloud_Files__c (after update) {
  
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    Set<Id> ownerIds = new Set<Id>();
    for(TVA_CFB__Cloud_Files__c  cloudfile : Trigger.new) {
    
        TVA_CFB__Cloud_Files__c  oldCloudFile = Trigger.oldMap.get(cloudfile.Id);
        
        if(cloudfile.WEG_Account_Servicing__c != NULL && cloudFile.WEGP1_DocumentType__c == 'Document Submission'
        && cloudFile.Scan_Date__c != NULL
        && (oldCloudFile.Scan_Date__c != cloudFile.Scan_Date__c 
        || oldCloudFile.WEGP1_DocumentType__c  != cloudFile.WEGP1_DocumentType__c
        || oldCloudFile.WEG_Account_Servicing__c != cloudFile.WEG_Account_Servicing__c )) {
        
        String showMessage = SubmitForReviewController.checkFieldValues(cloudFile.WEG_Account_Servicing__c); 
            if(showMessage != '' && showMessage != null && cloudFile.ownerId != null) {
                showMessage = showMessage.replaceAll('\n','<br>');  
                //sendEmail(showMessage, cloudFile.OwnerId);
            } 
        }
    }
    /*
    public void sendEmail(String message, Id ownerId) {
        List<String> sendTo = new List<String>();
        User ownerEmail = [SELECT Email FROM User WHERE Id =:ownerId];
        sendTo.add(ownerEmail.Email);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // Step 2: Set list of people who should get the email
    
        mail.setToAddresses(sendTo);
        
        // Step 4. Set email contents - you can use variables!
        mail.setSubject('Suitability Review');
        
        mail.setHtmlBody('Hello, <br/>Please fill the following fields. <br/>'+message);
        
        // Step 5. Add your email to the master list
        mails.add(mail);
        Messaging.sendEmail(mails);
    }
    */
}