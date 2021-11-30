//Test Class: Docuvault_S3NotificationController_TC

global class Docuvault_CopyAWSFileController {
    global Static String eDeliveryRecord = '';
    global static void copyAWSObject (Map <ID, Map <String, String>> fileDetailsMap) {
        List <String> fileDetails = NEW List <String> ();
        
        
        for (ID key :fileDetailsMap.keySet ()) {
            fileDetails.add (fileDetailsMap.get (key).get ('currentBucketName'));
            fileDetails.add (fileDetailsMap.get (key).get ('currentFileName'));
            fileDetails.add (fileDetailsMap.get (key).get ('newBucketName'));
            fileDetails.add (fileDetailsMap.get (key).get ('newFileName'));
            fileDetails.add (fileDetailsMap.get (key).get ('region'));
            fileDetails.add (key);
            
        }
        
        Docuvault_CopyAWSFileController.copyAWSObject (fileDetails);
    }
    
    @Future (Callout = TRUE)
    global static Void copyAWSObject(List <String> fileDetails) {
        
        List <SObject> cloudFilesToUpdate = NEW List <SObject> ();  
        List <Messaging.SingleEmailMessage> mails = New List <Messaging.SingleEmailMessage> ();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String currentFileName = '';
        try {
            for (Integer i=0; i < fileDetails.size(); i = i+6) {
            
                String currentBucketName = fileDetails[i+0];
                currentFileName = fileDetails[i+1];
                String newBucketName = fileDetails[i+2];
                String newFileName = fileDetails[i+3];
                String region = fileDetails[i+4];
                ID cloudFileId = fileDetails[i+5];
                System.debug('iiiiiiiiiiiii'+cloudFileId);
                TVA_CFB__Cloud_Files__c cloudFileRecord = [SELECT TVA_CFB__Box_File_Status__c 
                                                           FROM TVA_CFB__Cloud_Files__c
                                                           WHERE Id =: cloudFileId];
                eDeliveryRecord =  cloudFileRecord.TVA_CFB__Box_File_Status__c; 
                system.debug('eeeeeeeeeeeee'+eDeliveryRecord);                                         
                        
                
                try {
                    TVA_CFB__CloudFiles_Settings__c s3Credentials = TVA_CFB__CloudFiles_Settings__c.getInstance (userInfo.getUserID ());
                    Map <String, TVA_CFB__Cloud_Files_Region_Endpoints__c> regionEndPoints = TVA_CFB__Cloud_Files_Region_Endpoints__c.getAll ();
                    
                    Boolean encryptionFlag = s3Credentials.TVA_CFB__Server_Side_Encryption__c;
                    String versionTypeFlag = TVA_CFB.checkLicense.checkPremiumLicense();
                    
                    Datetime now = Datetime.now ();
                    String amzDate = now.formatGmt ('yyyyMMdd')+'T'+now.formatGmt ('HHmmss')+'Z';
                    
                    Blob hash = Crypto.generateDigest ('SHA-256', Blob.valueOf (''));
                    String Payloadaction = EncodingUtil.convertToHex (hash);
                    String amazonUrl = regionEndpoints.get (region).TVA_CFB__Endpoint_URL__c;                    
                    String CanonicalRequest = 'PUT\n/'+newBucketName+'/'+newFileName 
                                           +'\n\ncontent-type:application/json'+
                                           +'\nhost:'+amazonUrl.removeStart ('https://')
                                           
                                           +'\nx-amz-content-sha256:'+Payloadaction
                                           +'\nx-amz-copy-source:/'+currentBucketName+'/'+currentFileName
                                           +'\nx-amz-date:'+amzDate
                                           +'\nx-amz-metadata-directive:COPY';
                   String storageValue = 'STANDARD';
                   if (encryptionFlag && versionTypeFlag == '')
                       CanonicalRequest += '\nx-amz-server-side-encryption:AES256';
                       
                       CanonicalRequest += '\nx-amz-storage-class:'+storageValue
                                           +'\nx-amz-target:s3:*'
                                           +'\n\ncontent-type;host;x-amz-content-sha256;x-amz-copy-source;'
                                           +'x-amz-date;x-amz-metadata-directive;';
                   if (encryptionFlag && versionTypeFlag == '')
                       CanonicalRequest += 'x-amz-server-side-encryption;';
                       
                       CanonicalRequest += 'x-amz-storage-class;x-amz-target\n'+Payloadaction;
                    
                    Blob hashCanonical = Crypto.generateDigest ('SHA-256', Blob.valueOf (CanonicalRequest));
                    String canonicalHash = EncodingUtil.convertToHex (hashCanonical);
                    
                    String StringtoSign = 'AWS4-HMAC-SHA256\n'+amzDate+'\n'
                                        +DateTime.Now().formatGmt('yyyyMMdd')
                                        +'/'+region+'/s3/aws4_request\n'+canonicalHash;
                    
                    Blob kDate     = Crypto.generateMac ('HMAC-SHA256', 
                                            Blob.valueOf (DateTime.Now ().formatGmt ('yyyyMMdd')),
                                            Blob.valueOf ('AWS4'+s3Credentials.TVA_CFB__secret_key__c)); 
            
                    Blob kRegion   = Crypto.generateMac ('HMAC-SHA256', Blob.valueOf (region), kDate);
                    blob kService  = Crypto.generateMac ('HMAC-SHA256', Blob.valueOf ('s3'), kRegion);
                    blob kSigning  = Crypto.generateMac ('HMAC-SHA256', Blob.valueOf ('aws4_request'), kService);
                    Blob bsig      = Crypto.generateMac ('HMAC-SHA256', Blob.valueOf (StringtoSign), kSigning);  
                    
                    String signature = EncodingUtil.convertToHex (bsig);
                    
                    String AuthHeader = 'AWS4-HMAC-SHA256 Credential='+s3Credentials.TVA_CFB__Access_Key__c+'/'
                                        +DateTime.Now ().formatGmt ('yyyyMMdd')+'/'+region
                                        +'/s3/aws4_request,'
                                        +'SignedHeaders=content-type;host;x-amz-target;x-amz-content-sha256;'
                                        +'x-amz-metadata-directive;x-amz-copy-source;';
                    if (encryptionFlag && versionTypeFlag == '')
                        AuthHeader += 'x-amz-server-side-encryption;';
                                    
                    AuthHeader += 'x-amz-storage-class;x-amz-date,Signature=';         
                    AuthHeader = AuthHeader+signature;
                    
                    
                    HttpRequest con = NEW HttpRequest ();
                        con.setMethod ('PUT');   
                        con.setEndPoint (regionEndpoints.get (region).TVA_CFB__Endpoint_URL__c+'/'+newBucketName+'/'+newFileName ) ;
                        con.setHeader ('x-amz-copy-source', '/'+currentBucketName+'/'+currentFileName);
                        con.setHeader ('host', amazonUrl.removeStart('https://'));  
                        con.setHeader ('Content-Type', 'application/json');  
                        con.setHeader ('x-amz-target','s3:*');
                        con.setHeader ('x-amz-content-sha256', Payloadaction);
                        con.setHeader ('x-amz-date', amzDate);
                        con.setHeader ('x-amz-metadata-directive', 'COPY');
                        con.setHeader ('x-amz-storage-class', storageValue);
                        con.setHeader ('Authorization', AuthHeader );
                        if (encryptionFlag && versionTypeFlag == '')
                            con.setHeader ('x-amz-server-side-encryption', 'AES256');
                                             
                        con.setHeader ('Connection', 'keep-alive');
                        con.setTimeOut (120000);
                    Http http = NEW Http ();
                    HTTPResponse res = NEW HTTPResponse ();
                    if (!Test.isRunningTest ())
                        res = http.send (con);
                    System.debug (StringtoSign);
                    System.debug (canonicalRequest);
                    
                    System.debug (res.getBody());
                    if (Test.isRunningTest()) {
                        res.setStatusCode (200);
                        res.setBody('<ETag>&quot;adsfasfadsacsdf2321dafsf&quot;</ETag>');
                    }
                    if (res.getStatusCode () == 200) {
                        String eTag = res.getBody ();
                        eTag = eTag.subStringBetween ('<ETag>&quot;', '&quot;</ETag>');
                        String versionId = res.getHeader ('x-amz-version-id');
                        SObject cloudFile = new TVA_CFB__Cloud_Files__c ();
                        cloudFile.id = cloudFileID ;
                        if(eDeliveryRecord != 'Edelivery') {
                             cloudFile.put ('recordTypeId', Schema.SObjectType.TVA_CFB__Cloud_Files__c
                                                            .getRecordTypeInfosByName()
                                                            .get('Standard')
                                                            .getRecordTypeId());
                        }                       
                        cloudFile.put ('TVA_CFB__E_Tag__c', eTag);
                        cloudFile.put ('TVA_CFB__Bucket_Name__c', newBucketName);
                        cloudFile.put ('TVA_CFB__Amazon_Version_ID__c', versionId);
                        cloudFilesToUpdate.add (cloudFile);
                        
                    } else {
                        SObject cloudFile = new TVA_CFB__Cloud_Files__c ();
                        cloudFile.id = cloudFileID ;
                        if(eDeliveryRecord != 'Edelivery') {
                             cloudFile.put ('recordTypeId', Schema.SObjectType.TVA_CFB__Cloud_Files__c
                                                            .getRecordTypeInfosByName()
                                                            .get('Standard')
                                                            .getRecordTypeId());
                        }                       
                        cloudFile.put ('AWS_Error__c', res.getBody());
                        cloudFilesToUpdate.add (cloudFile);
                    }
                }
                catch (Exception e) {
                    List <String> sendTo = new List <String>();
                    sendTo.add (Label.Scan_to_SF_Exception_Email);
                    mail.setToAddresses (sendTo);
                    if(eDeliveryRecord == 'Edelivery') {
                        mail.setSubject ('Edelivery');
                    } else {
                        mail.setSubject ('Scan to SF Notification');
                    }
                    mail.setHtmlBody ('A cloud file named '+currentFileName +' could not be updated via scan to salesforce because this cloud file is locked');
                    mails.add (mail);
                    Messaging.sendEmail (mails);
                }
                
            }
            if (cloudFilesToUpdate.size () > 0)
                Update cloudFilesToUpdate; 
        }
        catch (Exception e) {
            
            List <String> sendTo = new List <String>();
            sendTo.add (Label.Scan_to_SF_Exception_Email);
            mail.setToAddresses (sendTo);
            if(eDeliveryRecord == 'Edelivery') {
                mail.setSubject ('Edelivery');
            } else {
                 mail.setSubject ('Scan to SF Notification');
            }
            mail.setHtmlBody ('A cloud file named '+currentFileName +' could not be updated via scan to salesforce because this cloud file is locked');
            mails.add (mail);
            Messaging.sendEmail (mails);
        }         
    }
}