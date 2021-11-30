@isTest
public class PreventUserfromDeletingAttachments_TC{
        
 static testmethod void AttachmentTesting(){
    
        Activate_FINACC_AND_ATTACH_TRIGGER__c active = new Activate_FINACC_AND_ATTACH_TRIGGER__c();
           active.Activate_Attachment__c = true;
        insert active;
 
        Id loggedInuserProfileId = UserInfo.getProfileID();
        Profile p = [Select id,Name from Profile where Name =: 'System Administrator'];
        
       Account acc = New Account();
           acc.Name = 'test';
       insert acc;
           
       
       Attachment att = new Attachment ();
       att.Name = 'test.jpg';
       att.body  = Blob.valueOf ('test');
       att.parentId = acc.id;
       insert att;
       Delete att;
        
        
        
       
  }
        
}