trigger PreventUserfromDeletingFiles on ContentDocument (before delete) {    
    
    Activate_FINACC_AND_ATTACH_TRIGGER__c active = new Activate_FINACC_AND_ATTACH_TRIGGER__c();
    active.Activate_Attachment__c = true;
    
    Id loggedInuserProfileId = UserInfo.getProfileID();
    Profile p = [Select id,Name from Profile where Name =: System.Label.System_Admin_Profile];
    
    if (Trigger.isBefore && Trigger.isDelete) {   
     
        for(ContentDocument cd : trigger.old){
            if(cd.id != NULL && loggedInuserProfileId != p.id) {
                cd.addError(System.Label.Delete_Error_Message);
            } 
        }
    }
}