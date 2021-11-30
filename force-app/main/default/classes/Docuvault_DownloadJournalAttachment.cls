public with sharing class Docuvault_DownloadJournalAttachment {
    public String messageType { get; set; }
    public String message { get; set; }
    public String urlToDownload { get; set; }
    public void generateDownloadLink () {
        TVA_CFB__CloudFiles_Settings__c credentials = TVA_CFB__CloudFiles_Settings__c.getInstance (UserInfo.getUserID ());
        
        Map <String, TVA_CFB__Cloud_Files_Region_Endpoints__c> regionEndPoints = TVA_CFB__Cloud_Files_Region_Endpoints__c.getAll ();
        Map <String, String> cloudFileDetails = NEW Map <String, String> ();
        urlToDownload = '';
        WEG_Journal_Attachment_Reference__c obj = NEW WEG_Journal_Attachment_Reference__c ();
        String recId = apexpages.currentpage().getparameters().get('id');
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
            if(!test.isRunningTest()) 
            urlToDownload = TVA_CFB.amazonS3Authentication.generateDownloadLink (credentials, regionEndPoints, cloudFileDetails, 200);
            messageType = 'success';
            message = 'File Downloaded initiated.';
        } else {
            messageType = 'error';
            message = 'Failed to Download the file.';
        }    
    }
}