global class JournalingEmailMessageAttachments implements Database.Batchable<SObject>{
    
 
    global Database.queryLocator start(Database.BatchableContext ctx){
        
        String type = 'EmailMessage';
        String query = 'SELECT Name, BodyLength, parentID, ContentType FROM ATTACHMENT WHERE parent.type =: type AND CreatedDate = TODAY ';
        if (Test.isRunningTest()) {
            query = 'SELECT Name, BodyLength, parentID, ContentType FROM ATTACHMENT LIMIT 1';
        }
        return Database.getQueryLocator(query);
    }                
    
    global void execute(Database.BatchableContext ctx, List<Attachment> scope){
        Set <ID> emailMessagesIds = new Set <ID> ();
        for (Attachment att :scope) {
            emailMessagesIds.add (att.parentId);
        }
        Map <ID, ID> emailMsgWithJournalEC = new Map <ID, ID> ();
        emailMsgWithJournalEC = checkExisitngJournalEcs (emailMessagesIds);
        
        List <WEG_Journal_Attachment_Reference__c> attachmentsToInsert = new List <WEG_Journal_Attachment_Reference__c> ();
        
        for (Attachment att: scope) {
            system.debug('::::attID::::'+att);
            WEG_Journal_Attachment_Reference__c attReference = new WEG_Journal_Attachment_Reference__c ();
            attReference.WEG_File_Name__c = att.Name;
            attReference.WEG_File_Size_in_Bytes__c = att.BodyLength;
            attReference.WEG_Attachment_Id__c = att.ID;
            String type = '';
            try {
                List <String> attachmentType = att.Name.split ('\\.');
            
                type = attachmentType[attachmentType.size () - 1];
            }
            catch (Exception e) {
                type = att.contentType;
            }
            attReference.WEG_File_Type__c = type;
            attReference.WEG_JournalEC__c = emailMsgWithJournalEC.get (att.parentID);
            attachmentsToInsert .add (attReference);
        }
        insert attachmentsToInsert;
    }
    
    global void finish(Database.BatchableContext ctx){
    
    }
    public Map <ID, ID> checkExisitngJournalEcs (Set<ID> emailMsgIds) {
        Map <ID, ID> emailMsgWithJournal = new Map <ID, ID> ();
        for (WEG_journal_EC__c journal :[SELECT NAME, WEG_Related_To_ID__c FROM WEG_journal_EC__c WHERE WEG_Related_To_ID__c IN: emailMsgIds] ) {
            emailMsgWithJournal.put (journal.WEG_Related_To_ID__c, journal.ID);  
        } 
        Set <ID> emailsNotExist = new Set <ID> ();
        for (ID key :emailMsgIds) {
            if (!emailMsgWithJournal.containsKey (key))
                emailsNotExist.add (key);
        }
        if (emailsNotExist.size () > 0) {
            List <EmailMessage> emailRecords = new List <EmailMessage> ();
            emailRecords = [ SELECT relatedToId, hasAttachment, 
                            FromAddress, FromName, Headers, HtmlBody, createdDate, 
                            Subject, TextBody, ToAddress, contentDocumentIds
                            FROM EmailMessage WHERE ID IN:emailsNotExist];
            ComplianceArchivingHelper.emailMessageShare (emailRecords); 
            checkExisitngJournalEcs (emailMsgIds);
        }
        return emailMsgWithJournal;
    }
}