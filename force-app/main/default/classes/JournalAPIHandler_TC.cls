@isTest
public class JournalAPIHandler_TC {
    public static testMethod void method1 () {
    String fromDate = String.valueOf(datetime.now());
    fromDate.replaceAll (' ', '+');
    WEG_Journal_EC__c journal = New WEG_Journal_EC__c();
        journal.WEG_Bcc_Address__c = 'test@gmail.com';
        journal.WEG_CC_Address__c = 'test@gmail.com';
        journal.WEG_From_Address__c = 'test@gmail.com';
        journal.WEG_From_Name__c = 'test';
        journal.WEG_Has_Attachment__c = true;
        journal.WEG_Header__c = 'test';
        journal.WEG_Html_Body__c = 'test';
        journal.WEG_Is_Incoming__c = true;
        
        journal.WEG_Message_Date__c = date.valueOf(fromDate);
    insert journal;
    WEG_Journal_Attachment_Reference__c  attach = New WEG_Journal_Attachment_Reference__c ();
        attach.WEG_File_Name__c ='test.jpg';
        attach.WEG_File_Type__c = 'jpg';
        attach.WEG_JournalEC__c = journal.id;
        attach.WEG_IsArchived__c =false;
    insert attach;
    RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/JournalAPI'; 
        req.params.put('From',fromDate );
        req.params.put('To', fromDate );
        req.params.put('FileName',attach.id);
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        JournalAPIHandler obj = new JournalAPIHandler ();
            JournalAPIHandler.doGET ();
            
    }
    public static testMethod void method2 () {
    WEG_Journal_Attachment_Reference__c  attach = New WEG_Journal_Attachment_Reference__c ();
    insert attach;
    RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/JournalAPI'; 
        req.params.put('FileName',attach.id);
        req.params.put('From','' );
        req.params.put('To','' );
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        JournalAPIHandler obj = new JournalAPIHandler ();
            JournalAPIHandler.doGET ();
    }
    public static testMethod void method3 () {
    WEG_Journal_Attachment_Reference__c  attach = New WEG_Journal_Attachment_Reference__c ();
    insert attach;
    RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/JournalAPI'; 
        req.params.put('FileName',attach.id);
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        JournalAPIHandler obj = new JournalAPIHandler ();
            JournalAPIHandler.doGET ();
    }
    
}