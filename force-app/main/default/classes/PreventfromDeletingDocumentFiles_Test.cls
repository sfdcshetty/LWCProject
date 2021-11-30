@isTest
public class PreventfromDeletingDocumentFiles_Test{
    static testmethod void Testing(){
    
        Activate_FINACC_AND_ATTACH_TRIGGER__c active = new Activate_FINACC_AND_ATTACH_TRIGGER__c();
           active.Activate_Attachment__c = true;
        insert active;
 
        Id loggedInuserProfileId = UserInfo.getProfileID();
        Profile p = [Select id,Name from Profile where Name =: 'System Administrator'];
        
       Account acc = New Account();
           acc.Name = 'test';
       insert acc;
           
       
       Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='Header_Picture1', 
            PathOnClient ='/Header_Picture1.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
       
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        delete documents;
        
        
        
       /* System.assertEquals(documents.size(), 1);
        System.assertEquals(documents[0].Id, contentVersion_2.ContentDocumentId);
        System.assertEquals(documents[0].LatestPublishedVersionId, contentVersion_2.Id);
        System.assertEquals(documents[0].Title, contentVersion_2.Title);
        System.assertEquals(contentlink.ContentDocumentId,contentVersion_2.ContentDocumentId );*/
  }
        
}