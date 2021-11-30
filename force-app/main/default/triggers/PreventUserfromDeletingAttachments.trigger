/*
    Name : PreventUserfromDeletingAttachments
    TestClassName : PreventUserfromDeletingAttachments_TC
    Developer Name: K P Sai Sampath
    Reviewed by : Srikanth Valluri
    Description : "Trigger to Prevent Users from Deleting Attachments except for System Administrator.
*/

trigger PreventUserfromDeletingAttachments on Attachment (before delete) {    
    
   Activate_FINACC_AND_ATTACH_TRIGGER__c active = new Activate_FINACC_AND_ATTACH_TRIGGER__c();
   active.Activate_Attachment__c = true;
    
   Id loggedInuserProfileId = UserInfo.getProfileID();
   Profile p = [Select id,Name from Profile where Name =: System.Label.System_Admin_Profile];
   
   if (Trigger.isBefore && Trigger.isDelete) {
        for (Attachment att : Trigger.old) {
            if (att.id != NULL && loggedInuserProfileId != p.id) {
                att.addError(System.Label.Delete_Error_Message);
            } 
        }
    }
}