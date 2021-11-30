@istest
public class JournalingEmailMessageAttachments_Test{
    static testMethod void testing(){
        
        Account acc = New Account();
            acc.Name = 'test';
        insert acc;
        
        
        
        list<EmailMessage> msgList = New list<EmailMessage> ();
        EmailMessage msg = New EmailMessage();
            msg.FromAddress = 'test@gmail.com';
            msg.FromName = 'test';
            msg.HtmlBody = 'test';
            msg.Subject = 'test';
            msg.ToAddress = 'test@gmail.com';           
        insert msg;
        msgList.add(msg);
        
        Attachment attach=new Attachment();     
            attach.Name='Unit Test Attachment';
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=bodyBlob;
            attach.parentId=msg.id;           
        insert attach;
        
        WEG_Journal_EC__c journal = New WEG_Journal_EC__c();
            journal.WEG_Related_To_ID__c = msg.id;
        insert journal;
        
        WEG_Journal_Attachment_Reference__c attachRef = New WEG_Journal_Attachment_Reference__c ();
            attachRef.WEG_JournalEC__c = journal.id;            
        insert attachRef;
        
        JournalingEmailMessageAttachments attachments = new JournalingEmailMessageAttachments();
        DataBase.executeBatch(attachments);
       

        
    }
}