//TestClass: Docuvault_S3NotificationController_TC

@RestResource (urlMapping='/Notification')
global without sharing class Docuvault_S3NotificationController {
    global static string eDelivery = '';           
    @HttpPost
    global static void getSNSNotification ()
    {
        List <Messaging.SingleEmailMessage> mails = New List <Messaging.SingleEmailMessage> ();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Map <String, Object> objectDetailsMap = NEW Map <String, Object> ();
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String bodyString = body.toString();
        
        try {
            Boolean notification = true;
            Boolean subscription = false;
            String parsedString;
            
            System.Debug('***** Response Body ******'+bodyString);
            
            JSONParser parser = JSON.createParser(bodyString);
            
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'Message')) {
                                    
                    parser.nextToken();
                    if (parser.getText().contains('\"')) {
                        parsedString = parser.getText().replaceAll('\"','"');
                                           
                    }
                }
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'Type')) {
                     
                     parser.nextToken();
                     if (parser.getText() == 'Notification') {
                         notification = true;
                     }
                     if (parser.getText() == 'SubscriptionConfirmation') {
                         subscription = true;
                     }
                }
            }
            
            if (subscription) {
            
                List <String> sendTo = new List <String>();
                sendTo.add (Label.Scan_to_SF_Exception_Email);
                mail.setToAddresses (sendTo);
            
                mail.setSubject ('SNS Notification');
                mail.setHtmlBody (bodyString);
                mails.add (mail);
                Messaging.sendEmail (mails);
            }
            if (notification) {
                system.debug('parsedStringparsedString'+parsedString);
                Map <String,Object> completeBodyMap = (Map <String, Object>) JSON.deserializeUntyped (parsedString);
                List <Object> recordDetails = ( List<Object>) completeBodyMap.get ('Records'); 
                TVA_CFB__CloudFiles_Settings__c s3Credentials = TVA_CFB__CloudFiles_Settings__c.getInstance (userInfo.getUserID ());    
                Set <ID> recordIds = NEW Set <ID> ();
                
                List <TVA_CFB__cloud_files__c> cloudFilesListUpdate = NEW List <TVA_CFB__cloud_files__c> ();
                List <TVA_CFB__cloud_files__c> cloudFilesList = NEW List <TVA_CFB__cloud_files__c> ();
                
                String guId = '';
                String ADName = '';
                Decimal fileSize = 0;
                Map <String, Object> jsonMap = NEW Map <String, Object> ();
                Map <String, Object> s3DetailsMap = NEW Map <String, Object> ();
                
                Map <String,Object> bucketDetailsMap = NEW Map <String, Object> ();
                
                for (Object obj: recordDetails) {
                    
                    jsonMap = (Map <String, Object>) JSON.deserializeUntyped (JSON.serialize(obj));
                    
                    s3DetailsMap = (Map <String, Object>) jsonMap.get ('s3'); 
                    objectDetailsMap = (Map <String, Object>) s3DetailsMap .get ('object');
                    bucketDetailsMap = (Map <String, Object>) s3DetailsMap .get ('bucket'); 
                    String currentFileName = (String) objectDetailsMap .get ('key');
                    
                    List <String> fileTypeList = currentFileName.split('\\.');
                    fileSize = (Decimal) objectDetailsMap.get ('size');
                    String fileType = fileTypeList [fileTypeList.size() - 1];
                    currentFileName = currentFileName.replace ('.'+fileType, '');
                    if (currentFileName.contains ('_')) {
                        guId = currentFileName.split ('_') [currentFileName.split ('_').size () - 1];
                        if (guId.length() >= 18)
                            guId = guId.substring(0, 18);
                        ADName = currentFileName.split ('_')[0];
                    }
                   
                }
                system.debug('namenamename'+bucketDetailsMap.get('name'));
                if(String.ValueOf(bucketDetailsMap.get('name')).trim() != System.Label.wegdigitalPrdBucket.trim()) {
                    if (guID != '' && guID != NULL && fileSize > 0) {
                        
                        cloudFilesList = [ SELECT 
                                                TVA_CFB__E_Tag__c, TVA_CFB__Amazon_Version_ID__c, TVA_CFB__Box_File_Status__c,
                                                TVA_CFB__File_Size_in_Bytes__c, TVA_CFB__Bucket_Name__c, 
                                                RecordType.Name, Name, TVA_CFB__File_Type__c, 
                                                TVA_CFB__Version__c, TVA_CFB__Region__c
                                            FROM TVA_CFB__Cloud_Files__c
                                            WHERE ID =: guID LIMIT 1];
                                            
                        if (cloudFilesList.size () > 0) {
                            eDelivery = cloudFilesList[0].TVA_CFB__Box_File_Status__c;
                            system.debug('nnnnnnnnnnnnnnnnnn'+eDelivery);
                            List <TVA_CFB__Version_History__c> versionFileList = NEW List <TVA_CFB__Version_History__c> ();
                            for (TVA_CFB__Cloud_Files__c cloudFile :cloudFilesList) {
                                if (cloudFile.RecordType.Name == 'Standard') {
                                    
                                    TVA_CFB__Version_History__c versionFile = NEW TVA_CFB__Version_History__c ();
                                    versionFile.Name = String.valueOf (cloudFile.TVA_CFB__Version__c);
                                        
                                    versionFile.TVA_CFB__Amazon_Version_ID__c = cloudFile.TVA_CFB__Amazon_Version_ID__c;
                                    versionFile.TVA_CFB__Cloud_Files__c = cloudFile.ID;
                                    versionFile.TVA_CFB__File_Name__c = cloudFile.Name;
                                    versionFile.TVA_CFB__File_Size_in_Bytes__c = cloudFile.TVA_CFB__File_Size_in_Bytes__c;
                                    versionFile.TVA_CFB__File_Type__c = cloudFile.TVA_CFB__File_Type__c;
                                    versionFileList.add (versionFile);
                                }
                                
                                
                                String currentFileName = (String) objectDetailsMap .get ('key');
                                List <String> fileTypeList = currentFileName.split('\\.');
                
                                String fileType = fileTypeList [fileTypeList.size() - 1];
                                
                                TVA_CFB__Cloud_Files__c record = NEW TVA_CFB__Cloud_Files__c ();
                                record.TVA_CFB__File_type__c = fileType;
                                record.TVA_CFB__File_Size_In_Bytes__c = (Decimal) objectDetailsMap.get ('size');
                                record.TVA_CFB__Reponse_Code__c = '204';
                                record.TVA_CFB__Bucket_Name__c = (String) bucketDetailsMap.get ('name');
                                record.TVA_CFB__Region__c = (String) jsonMap.get ('awsRegion');
                                record.ID = cloudFile.ID;
                                if (versionFileList.size () > 0) {
                                    if (cloudFile.TVA_CFB__Version__c != NULL)
                                        record.TVA_CFB__Version__c = cloudFile.TVA_CFB__Version__c + 1;
                                    else
                                        record.TVA_CFB__Version__c = 2;
                                }
                                cloudFilesListUpdate.add (record);
                                recordIds.add (cloudFile.ID);
                            }
                            if (versionFileList.size () > 0)
                                insert versionFileList;
                            if (cloudFilesListUpdate.size () > 0)
                                Update cloudFilesListUpdate;
                            
                            
                        }
                        else {
                            String currentFileName = (String) objectDetailsMap .get ('key');
                            List <String> fileTypeList = currentFileName.split('\\.');
            
                            String fileType = fileTypeList [fileTypeList.size() - 1];
                            ID ownerID = null;
                            try {
                                User owner = [SELECT ID From User WHERE ADName__c =: ADName];
                                ownerID = owner.ID;
                            } catch (Exception e) {}
                            TVA_CFB__cloud_files__c cloudFile = NEW TVA_CFB__cloud_files__c ();
                                if (ownerID != NULL)
                                    cloudFile.OwnerId = ownerID;
                            
                                cloudFile.Name = EncodingUtil.URLDecode(currentFileName, 'UTF-8');
                                cloudFile.TVA_CFB__File_type__c = fileType;
                                try {
                                    String dateTimeVal = '';
                                    Integer year, month, day, hour, min, sec;
                                    if (currentFileName.contains ('-')) {
                                        dateTimeVal = currentFileName.subStringbetween ('_', '_');
                                        month = Integer.valueOf (dateTimeVal.subString (0, 2));
                                        day = Integer.valueOf (dateTimeVal.subString (2, 4));
                                        year = Integer.valueOf (dateTimeVal.subString (4, 8));
                                        hour = Integer.valueOf (dateTimeVal.subString (9, 11));
                                        min = Integer.valueOf (dateTimeVal.subString (11, 13));
                                        sec = Integer.valueOf (dateTimeVal.subString (13, 15));
                                    }
                                    
                                    DateTime dateInstance = datetime.newInstance(year, month, day, hour, min, sec);                                
                                    Integer offset = UserInfo.getTimezone().getOffset(dateInstance);
                                    Datetime localTime = dateInstance.addSeconds(offset/1000);
                                    cloudFile.Scan_Date__c = localTime;
                                    System.Debug (cloudFile.Scan_Date__c);
                                    cloudFile.recordTypeId = Schema.SObjectType.TVA_CFB__Cloud_Files__c
                                        .getRecordTypeInfosByName()
                                        .get('Scan')
                                        .getRecordTypeId();
                                } catch (Exception e) {
                                
                                }
                                cloudFile.TVA_CFB__File_Size_In_Bytes__c = (Decimal) objectDetailsMap.get ('size');
                                cloudFile.TVA_CFB__Reponse_Code__c = '204';
                                cloudFile.TVA_CFB__Bucket_Name__c = (String) bucketDetailsMap.get ('name');
                                cloudFile.TVA_CFB__Region__c = (String) jsonMap.get ('awsRegion');
                                cloudFile.TVA_CFB__Version__c = 1;
                            insert cloudFile;
                            recordIds.add (cloudFile.ID);
                        }
                        
                    }
                    
                        
                    Map <ID, Map <String, String>> fileDetailsMap = NEW Map <ID, Map <String, String>> ();
                    
                    cloudFilesList = NEW List <TVA_CFB__Cloud_Files__c> ();
                    cloudFilesList = [ SELECT TVA_CFB__Bucket_Name__c, Name, TVA_CFB__File_type__c, TVA_CFB__Region__c
                                        FROM TVA_CFB__Cloud_Files__c
                                        WHERE ID IN :recordIds ];
                    for (SObject cloudFile :cloudFilesList) {
                        
                        
                        Map <String, String> innerMap = NEW Map <String, String> ();
                        innerMap.put ('currentBucketName', (String) cloudFile.get ('TVA_CFB__Bucket_Name__c'));
                        innerMap.put ('currentFileName', (String) objectDetailsMap .get ('key'));
                        innerMap.put ('newBucketName', s3Credentials.TVA_CFB__Bucket_Name__c);
                        innerMap.put ('newFileName', cloudFile.ID+'.'+(String) cloudFile.get ('TVA_CFB__File_type__c'));
                        innerMap.put ('region', (String) cloudFile.get ('TVA_CFB__Region__c'));
                        
                        fileDetailsMap.put (cloudFile.ID, innerMap);
                        
                    }
                    Docuvault_CopyAWSFileController.copyAWSObject (fileDetailsMap);
                } else{
                    system.debug('entered');
                
                    Docuvault_DD_CloudFileCreation.createCloudFile(recordDetails);
                }  
            }
        }
        catch (Exception e) {
            system.debug('Entered Catch'+e.getLineNumber());
            String fileName = '';
            if (objectDetailsMap.containsKey ('key')) {
                fileName = (String) objectDetailsMap .get ('key');
            }
            else {
                fileName = bodyString;
            }
            List <String> sendTo = new List <String>();
            sendTo.add (Label.Scan_to_SF_Exception_Email);
            mail.setToAddresses (sendTo);
            if(eDelivery == 'Edelivery') {
                mail.setSubject ('Edelivery');
            } else {
                mail.setSubject ('Scan to SF Notification');    
            }
            mail.setHtmlBody ('A cloud file named '+fileName +' could not be updated via scan to salesforce because this cloud file is locked');
            mails.add (mail);
            Messaging.sendEmail (mails);
        } 
        
    }
}