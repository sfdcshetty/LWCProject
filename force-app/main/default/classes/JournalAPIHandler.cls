@RestResource(urlMapping='/JournalAPI/*')
global without sharing class JournalAPIHandler {

    @HttpGET
    global static String doGET ()
    {
        if (RestContext.request.params.containsKey ('From')) {
            String fromDate = RestContext.request.params.get('From');
            String toDate = RestContext.request.params.get('To');
            System.Debug (fromDate+'==='+toDate);
            RestContext.response.addHeader('Content-Type', 'application/json');
    
            if (fromDate != '' && fromDate != NULL && toDate != '' && toDate != NULL) {
                fromDate = fromDate.replaceAll (' ', '+');
                toDate = toDate.replaceAll (' ', '+');
                List <WEG_Journal_EC__c> journalRecords = new List <WEG_Journal_EC__c> ();
                List <WEG_Journal_EC__c> journalRecordsToUpdate = new List <WEG_Journal_EC__c> ();
                String query = '';
                query = 'SELECT ID, WEG_Bcc_Address__c, WEG_CC_Address__c, WEG_From_Address__c, WEG_From_Name__c,'
                             +'WEG_Has_Attachment__c, WEG_Header__c, WEG_Html_Body__c, WEG_Is_Incoming__c, WEG_Message_Date__c,'
                             +'Message_Type__c, WEG_Subject__c, WEG_TextBody__c, WEG_ToAddress__c, WEG_ToName__c, '
                                 +' (SELECT S3_File_Name__c, WEG_File_Name__c, WEG_File_Size_in_Bytes__c ' 
                                 +' FROM Journal_Attachment_References__r WHERE WEG_IsArchived__c = FALSE) '
                                 +' FROM WEG_Journal_EC__c ';
                if (!test.isRunningTest()) {
                    query += 'WHERE WEG_RIA_Only__c = FALSE AND'
                          +' WEG_Message_Date__c >= '+ fromDate + ' AND  WEG_Message_Date__c <='+ toDate;
                }
                system.debug(query);
                journalRecords = Database.query (query);
                
                 
                String jsonBody = JSON.Serialize (journalRecords);  
                for (WEG_Journal_EC__c journal: journalRecords) {
                    journal.LastRetrivedDate__c = DateTime.Now ();
                    journalRecordsToUpdate.add (journal);
                }   
                update journalRecordsToUpdate;
                            
                return jsonBody;                 
            }
            else {
                return '{"error" : "From/To date is missing in the request."}';
            }
        } 
        
       /* else if (RestContext.request.params.containsKey ('FileName')) {
            TVA_CFB__CloudFiles_Settings__c credentials = TVA_CFB__CloudFiles_Settings__c.getInstance (UserInfo.getUserID ());
            String downloadURL = '';
            Map <String, TVA_CFB__Cloud_Files_Region_Endpoints__c> regionEndPoints = TVA_CFB__Cloud_Files_Region_Endpoints__c.getAll ();
            Map <String, String> cloudFileDetails = NEW Map <String, String> ();
            
            WEG_Journal_Attachment_Reference__c obj = NEW WEG_Journal_Attachment_Reference__c ();
            String recId = RestContext.request.params.get('FileName');
            recId = recId.Substring(0, 18);

            obj = [ SELECT 
                        WEG_Bucket_Name__c, WEG_File_Name__c, WEG_File_Type__c,WEG_Region__c
                        
                    FROM 
                        WEG_Journal_Attachment_Reference__c 
                    WHERE 
                        ID =: recId ];
    
            if (obj.WEG_Bucket_Name__c != NULL && obj.WEG_Region__c != NULL) {
                
                cloudFileDetails.put ('ID', obj.ID);
                cloudFileDetails.put ('bucket', obj.WEG_Bucket_Name__c);
                cloudFileDetails.put ('region', obj.WEG_Region__c);
                cloudFileDetails.put ('fileName', obj.WEG_File_Name__c);
                cloudFileDetails.put ('fileType', obj.WEG_File_Type__c);
                cloudFileDetails.put ('s3FileName', obj.ID+'.'+obj.WEG_File_Type__c);
                if (!test.isRunningTest()) 
                    downloadURL = TVA_CFB.amazonS3Authentication.generateDownloadLink (credentials, regionEndPoints, cloudFileDetails, 1000);
                
            } 
        
            return '{"URL" : "'+downloadURL +'"}';
        } */
         else {
            return '';
        }      
                        
    }    
    
}