/*
    Created By         : Docuvault Team
    Created Date       : 09-09-2017
    Test Class Name    : DocuvaultFileDownload_TC
    Description        : Class to download the password protected file from site guest user
*/

Global without sharing class DocuvaultFileDownload {

    global Static List <TVA_CFB__Cloud_Files__c> file2 { get; set; }
    global String errorMessage { set; get; }
    global String myIP { get; set; }
    global Static string cloudFileId { get; set; }
    
    global DocuvaultFileDownload () {
        try {
            file2 = new List <TVA_CFB__Cloud_Files__c> ();
            myIP = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
            errorMessage = '';
            String cloudRecId = System.currentPageReference ().getUrl ();
            if ( Test.isRunningTest ()) {
                cloudRecId =  'http://google.com/PublicFileDownload?aWQ9YTAzMjgwMDAwMDA2R290';
            }
            Integer length = cloudRecId.length ();
            Integer index = cloudRecId.indexof ('?');
            cloudRecId = cloudRecId.substring (index+1, length);
            cloudRecId = EncodingUtil.base64Decode (cloudRecId).toString ();
            cloudRecId = cloudRecId.split ('id=')[1];
            cloudRecId = String.escapeSingleQuotes(cloudRecId);
            file2 = [SELECT 
                            Name, TVA_CFB__Region__c, TVA_CFB__Password__c, TVA_CFB__Password_Protect__c,
                            TVA_CFB__File_Type__c, TVA_CFB__File_Size__c,
                            TVA_CFB__File_Size_in_Bytes__c, TVA_CFB__Bucket_Name__c 
                        FROM 
                            TVA_CFB__Cloud_Files__c 
                        WHERE 
                            ID =: cloudRecId 
                            AND TVA_CFB__Password_Protect__c = TRUE 
                            AND TVA_CFB__Password__c != NULL 
                        LIMIT 1];
            if (file2.size () == 0) 
                errorMessage = 'The Link you are trying to access is not Accessible.';
            
        }
        catch (Exception e) {
            errorMessage = 'Some thing went Wrong. Please reload the page and try Again!.';
        }
    }
    
    // Method to generate downloadable file URL
    @remoteAction 
    global static String downloadFile (String filePassword, String pageURL) {
        String returnString ;
        Map <String, TVA_CFB__Cloud_Files_Region_Endpoints__c> regionEndpoints = TVA_CFB__Cloud_Files_Region_Endpoints__c.getAll();

        TVA_CFB__CloudFiles_Settings__c credentials = TVA_CFB__CloudFiles_Settings__c.getInstance (UserInfo.getUserId ());
        cloudFileId = pageURL;
        Integer length = cloudFileId.length ();
        Integer index = cloudFileId.indexof ('?');
        cloudFileId = cloudFileId.subString (index+1, length);
        cloudFileId = EncodingUtil.base64Decode (cloudfileId).toString ();
        cloudFileId = cloudFileId.split ('id=') [1];
        cloudFileID = String.escapeSingleQuotes(cloudFileID);
        try {
            TVA_CFB__Cloud_Files__c obj = NEW TVA_CFB__Cloud_Files__c ();
            obj = [ SELECT 
                        Name, TVA_CFB__Region__c, TVA_CFB__Password__c, 
                            TVA_CFB__Downloads__c, TVA_CFB__File_Type__c, TVA_CFB__File_Size__c, 
                            TVA_CFB__File_Size_in_Bytes__c, TVA_CFB__Download_File__c, 
                            TVA_CFB__Bucket_Name__c , TVA_CFB__External_File_Name__c
                        FROM 
                            TVA_CFB__Cloud_Files__c 
                        WHERE 
                            ID =: cloudFileId 
                        AND 
                            TVA_CFB__Password_Protect__c = TRUE 
                        WITH SECURITY_ENFORCED];

            if ((obj.TVA_CFB__Password__c).equals (filePassword)) {
                Map <String, String> cloudFileDetails = NEW Map <String, String> ();
                    cloudFileDetails.put ('ID', obj.ID);
                    cloudFileDetails.put ('bucket', obj.TVA_CFB__Bucket_Name__c);
                    cloudFileDetails.put ('region', obj.TVA_CFB__Region__c);
                    cloudFileDetails.put ('fileName', obj.Name);
                    cloudFileDetails.put ('fileType', obj.TVA_CFB__File_type__c);
                    cloudFileDetails.put ('s3FileName', obj.ID+'.'+obj.TVA_CFB__File_type__c);
                if (obj.TVA_CFB__External_File_name__c != null) {
                    String externalfileName = obj.TVA_CFB__ExterNal_File_Name__c;
                    externalfileName = EncodingUtil.URLEncode (externalfileName , 'UTF-8');
                    externalfileName = externalfileName .replace ('+', '%20');
                    externalfileName = externalfileName .replace ('%2F', '/');
                    cloudFileDetails.put ('externalFileName', externalfileName);
                    cloudFileDetails.put ('s3FileName', externalfileName);
                }
                String downloadURL = '';
                if (!Test.isRunningTest ())
                    downloadURL = TVA_CFB.amazonS3Authentication.generateDownloadLink (credentials, regionEndPoints, cloudFileDetails, 200);

                if (Test.isRunningTest ())
                    downloadURL = 'test.com';
                if (downloadURL != '') {
                    if (obj.TVA_CFB__Downloads__c == NULL)
                        obj.TVA_CFB__Downloads__c = 1;
                    else
                        obj.TVA_CFB__Downloads__c = obj.TVA_CFB__Downloads__c + 1;

                    update obj;
                }
                returnString = downloadURL ;
            }
            else{
                returnString = 'Invalid Password';
            }
        }
        Catch ( Exception e){
            returnString = 'The Link you are trying to access is not Accessible.';
        }
        return returnString ;
    
    }
    
    @remoteAction
    global static void createJournalRecord (String recID, String ipAddress, String reqType) {
        Set <ID> cloudFileIds = new Set <ID> ();
        cloudFileIds.add (recID);
        ComplianceArchivingHelper.documentShare (cloudFileIds, null, reqType, ipAddress);
    }
    // Method to create tracking record as a reference of cloud file
    @remoteAction 
    global static void createTrackingRecord (Tracking_Info__c trackingInfo, String type, string recID) {
        if (recID != NULL) {
            try {
                trackingInfo.ownerID = [ SELECT OwnerID FROM TVA_CFB__Cloud_Files__c WHERE ID =: recID].OwnerID;
            }
            catch (Exception e) {}
        }
        trackingInfo.Tracking_Type__c = type;
        trackingInfo.Cloud_Files__c = recID;
        insert trackingInfo;    
        Docuvault_Tracking_Info__c customSettingDetails = Docuvault_Tracking_Info__c.getInstance (UserInfo.getUserID ());
        //DocuvaultFileDownload.sendCloudFileAsEmail (trackingInfo.Cloud_Files__c, customSettingDetails.File_Download_Template_Name__c, 'Download');
    }
    
    
    // Method to send Cloud file as an attachment to Journal Email
    @Future (Callout = TRUE)
    global Static void sendCloudFileAsEmail (String cloudFileID, String templateName, String type) {
        /*try {
            if (cloudFileID != '' && cloudFileID != NULL) {
                TVA_CFB__CloudFiles_Settings__c credentials = TVA_CFB__CloudFiles_Settings__c.getInstance(UserInfo.getUserID ());
                Map <String, TVA_CFB__Cloud_Files_Region_Endpoints__c> regionEndpoints = TVA_CFB__Cloud_Files_Region_Endpoints__c.getAll();
                Docuvault_Tracking_Info__c customSettingDetails = Docuvault_Tracking_Info__c.getInstance (UserInfo.getUserID ());
                
                SObject CDocType = NEW TVA_CFB__Cloud_Files__c ();
                String query = 'SELECT '+getAllFields ('TVA_CFB__Cloud_Files__c')+' FROM TVA_CFB__Cloud_Files__c '+
                                ' WHERE ID =: cloudFileID LIMIT 1';
                                
                cDocType = Database.Query (Query);
                                
                SObject trackingInfo = NEW Tracking_Info__c ();
                query = 'SELECT '+getAllFields ('Tracking_Info__c')+' FROM Tracking_Info__c '+
                                ' WHERE Cloud_Files__c =: cloudFileID AND Tracking_Type__c =: type Order By CreatedDate Desc LIMIT 1';
                                
                trackingInfo = Database.Query (query);
                System.Debug ('-----------'+trackingInfo);                
                SObject u = NEW User ();
                try {
                    String OwnerID = (String) cDocType.get('OwnerId');
                    query = 'SELECT '+getAllFields ('User')+' FROM USer '+
                                ' WHERE ID =: ownerID LIMIT 1';
                    u = Database.Query (query);
                }
                Catch (Exception e) {}
                EmailTemplate template = new EmailTemplate();
                template = [ 
                    SELECT Body, HtmlValue, Subject
                    FROM EmailTemplate 
                    WHERE developerName =: templateName];
                                       
                String fileName = CDocType.ID+'.'+CDocType.get ('TVA_CFB__File_Type__c');
                
                if (CDocType.get ('TVA_CFB__External_File_Name__c') != null) {
                    fileName = (String) CDocType.get ('TVA_CFB__External_File_Name__c');
                    fileName = EncodingUtil.URLEncode (fileName , 'UTF-8');
                    fileName = fileName .replace ('+', '%20');
                    fileName = fileName .replace ('%2F', '/');                
                }
                
                Map <String, String> mapCFileDetails = NEW Map <String, String> ();
                    mapCFileDetails.put ('bucket', (String)CDocType.get ('TVA_CFB__Bucket_Name__c'));
                    mapCFileDetails.put ('fileName', fileName);
                    mapCFileDetails.put ('region', (String)CDocType.get ('TVA_CFB__Region__c'));
                HttpResponse response = NEW HttpResponse();
                
                if (!Test.isRunningTest()) {
                    response = TVA_CFB.amazonS3Authentication.getFileRequest(credentials, mapCFileDetails, regionEndpoints);
               
                } else {
                    response.setHeader ('Content-Type', 'application/json');
                    response.setBody ('{"foo":"bar"}');
                    response.setStatusCode (200);
                }
                if (response.getStatusCode () == 200) {
                    String templateBody = template.htmlValue;
                    String templateSubject = template.Subject;
                    
                    List<String> fieldAPis = new List<String>();
                    List<String> fieldSubjectAPis = new List<String>();
                    
                    Integer noOfFields = templateBody.CountMatches('{!');
                    Integer noOfSubjectFields = templateSubject.CountMatches('{!');
                    
                    for ( integer i =0; i<noOfFields;i++){
                        fieldAPis.add(templateBody.subStringBetween('{!','}'));
                        templateBody = templateBody.remove('{!'+fieldAPis[i]+'}');
                    }
                    
                    for ( integer i =0; i<noOfSubjectFields;i++){
                        fieldSubjectAPis.add(templateSubject.subStringBetween('{!','}'));
                        templateSubject= templateSubject.remove('{!'+fieldSubjectAPis[i]+'}');
                    }
                    System.Debug ('-----------'+fieldAPis );
                    templateSubject = template.Subject;
                    templateBody = template.htmlValue;
                    
                    for (integer i = 0;i<fieldAPis.size();i++)
                    {
                        
                        if (fieldAPis[i] != NULL && fieldAPis[i] != '') {
                            if (fieldAPis[i].contains ('TVA_CFB__Cloud_Files__c'))
                                templateBody = templateBody.replace('{!'+fieldAPis[i]+'}', 
                                                String.valueOf(CDocType.get(fieldAPis[i].replace('TVA_CFB__Cloud_Files__c.','')))); 
                                                
                            try {
                                if (fieldAPis[i].contains ('User'))
                                    templateBody = templateBody.replace('{!'+fieldAPis[i]+'}', 
                                                    String.valueOf(u.get(fieldAPis[i].replace('User.','')))); 
                            }
                            catch (Exception e) {}
                            
                            if (fieldAPis[i].contains ('Tracking_Info__c'))
                                templateBody = templateBody.replace('{!'+fieldAPis[i]+'}', 
                                                String.valueOf(trackingInfo.get(fieldAPis[i].replace('Tracking_Info__c.','')))); 
                                                
                        }
                    }
                    
                    for (integer i = 0;i<fieldSubjectAPis.size();i++)
                    {
                        if (fieldAPis[i] != NULL && fieldAPis[i] != '') {
                            if (fieldSubjectAPis[i].contains ('TVA_CFB__Cloud_Files__c'))
                                templateSubject = templateSubject.replace('{!'+fieldSubjectAPis[i]+'}', 
                                                    String.valueOf(CDocType.get(fieldSubjectAPis[i].replace('TVA_CFB__Cloud_Files__c.','')))); 
                            
                            if (fieldSubjectAPis[i].contains ('Tracking_Info__c'))
                                templateSubject = templateSubject.replace('{!'+fieldSubjectAPis[i]+'}', 
                                                    String.valueOf(trackingInfo.get(fieldSubjectAPis[i].replace('Tracking_Info__c.','')))); 
                        }
                    }
                        
                    System.Debug ('---------'+templateBody);
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setSubject (templateSubject);
                    email.setToAddresses (new List <String> {customSettingDetails.Email__c});
                    email.setHTMLBody (templateBody);
                    try {
                        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :customSettingDetails.From_Email__c];
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        if ( owea.size() > 0 ) {
                            email.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                    }
                    Catch (Exception e) {}
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment ();
                    efa.setFileName ((String) CDocType.get ('Name'));
                    efa.setBody (response.getBodyAsBlob());
                    
                    email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                    
                    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});  
    
                }
            }
        } Catch (Exception e) {
            System.Debug ('---- Exception ---'+e.getMessage ());
        }*/
            
    }
    public static String getAllFields (String objectName) {
        string fields = '';
        sObjectType objectType = Schema.getGlobalDescribe ().get (objectName);
        
        if (objectType == null)
            return fields;
        for (string f :objectType.getDescribe ().fields.getMap ().keySet ())
            fields += f+ ', ';
        return fields.removeEnd(', '); 
        
    }
}