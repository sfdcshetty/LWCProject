global without sharing class DocuvaultFileRequest {
    
    public ID fileRequestID { get; set; }
    public String folderName { get; set; }
    public ID parentRecID { get; set; }
    public String parentObjectName { get; set; }
    public String errorMessage { get; set; }
    public String message { get; set; }
    public String myIP { get; set; }
    global string bucketName { get; set; }
    
    global DocuvaultFileRequest () {
        bucketName = '';
        TVA_CFB__CloudFiles_Settings__c credentials = TVA_CFB__CloudFiles_Settings__c.getInstance(UserInfo.getUserID());
        bucketName = credentials.TVA_CFB__Bucket_name__c;
        
        myIP = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        try {
        
            String encodedId = '';
            
            if (!Test.isRunningTest())
                encodedId = System.currentPageReference().getUrl();
            if (Test.isRunningTest ())
                encodedId = System.currentPagereference().getParameters().get ('encodedIDVal');
                
            Integer length = encodedId.length();
            Integer index = encodedId.indexof('?');
            encodedId = encodedId.substring(index+1, length);
            
            if (String.isNotBlank(encodedId)) {
                Blob decodedId ;
                try {
                    decodedId = EncodingUtil.base64Decode(encodedId);
                    if (String.isNotBlank (decodedId.toString())) {
                        String fileRequestDate = '';
                        fileRequestDate = decodedId.toString().split('id=')[1];
                        if (fileRequestDate.contains('#')) {
                            List<String> lstString = fileRequestDate.split('/#');
                            String strCompleteDate = lstString[0];
                            String strFileRequestId = lstString[1];
                            fileRequestID = Id.valueOf(strFileRequestId);
                            fileRequestID = String.escapeSingleQuotes(fileRequestID);
                        }
                    }
                } catch (Exception e) {}
            }
            TVA_CFB__File_Request__c req = [SELECT 
                                     TVA_CFB__Parent_ID__c, CreatedDate , 
                                     TVA_CFB__Expiration_Date__c, TVA_CFB__Message__c, 
                                     TVA_CFB__Upload_Count__c, TVA_CFB__Folder__c 
                                     FROM TVA_CFB__File_Request__c 
                                     WHERE 
                                     Id =: fileRequestID];
                                     
            folderName = req.TVA_CFB__Folder__c;
            parentRecID = req.TVA_CFB__Parent_ID__c;
            
            List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();
            Map<String,String> objectMap = NEW Map<String,String>();
            
            for (Schema.SObjectType f : gd)
            {
                objectMap.put(f.getDescribe().getKeyPrefix(), f.getDescribe().getName());
            }
            
            String accId = req.TVA_CFB__Parent_ID__c; 
            String prefix = accId.subString(0,3);
            parentObjectName = objectMap.get(prefix);
            parentObjectName = String.escapeSingleQuotes(parentObjectName);
            
            if (String.isNotBlank (accId)) {
                TVA_CFB__CloudFiles_Lookup_Mapping__c childObjectSetting = [
                    SELECT Name, TVA_CFB__Field_Name__c, TVA_CFB__Object_Api__c 
                    FROM TVA_CFB__CloudFiles_Lookup_Mapping__c 
                    WHERE (Name =: ParentObjectName OR TVA_CFB__Object_API__c =: ParentObjectName) 
                    LIMIT 1];
                parentObjectName = childObjectSetting.TVA_CFB__Field_Name__c;
            }
            else {
                parentObjectName = 'TVA_CFB__File_Request__c';
            }
        }
        catch (Exception e) {}
        
    }
    @remoteAction
    global static void createJournalRecord (String reqType, String frRecId, String IPAddress) {
        TVA_CFB__Cloud_Files__c cloudFile = NEW TVA_CFB__Cloud_Files__c ();
        Set <ID> cloudFileIds = new Set <ID> ();
        

        if (frRecID != NULL) {
            try {
                cloudFile = [ SELECT 
                                ID
                            FROM 
                                TVA_CFB__Cloud_Files__c 
                            WHERE 
                                TVA_CFB__File_Request__c =: frRecID 
                            AND 
                                TVA_CFB__E_tag__c != NULL 
                            Order By CreatedDate Desc LIMIT 1];
                cloudFileIds.add (cloudFile.ID);
                ComplianceArchivingHelper.documentShare (cloudFileIds, null, reqType, ipAddress);
            } catch (Exception e) {}
        }
    }
    
    // Method to create tracking record as a reference of cloud file
    @remoteAction 
    global static void createTrackingRecord (Tracking_Info__c trackingInfo, String type, String frRecID) {
        TVA_CFB__Cloud_Files__c cloudFile = NEW TVA_CFB__Cloud_Files__c ();
        
        if (frRecID != NULL) {
            try {
                cloudFile = [ SELECT 
                                OwnerID 
                            FROM 
                                TVA_CFB__Cloud_Files__c 
                            WHERE 
                                TVA_CFB__File_Request__c =: frRecID 
                            AND 
                                TVA_CFB__E_tag__c != NULL 
                            Order By CreatedDate Desc LIMIT 1];
            
                trackingInfo.Cloud_Files__c = cloudFile.ID;
                trackingInfo.OwnerID = cloudFile.OwnerID;
            }
            catch (Exception e) {}
        }
        trackingInfo.Tracking_Type__c = type;
        
        insert trackingInfo;    
        Docuvault_Tracking_Info__c customSettingDetails = Docuvault_Tracking_Info__c.getInstance (UserInfo.getUserID ());
        DocuvaultFileDownload.sendCloudFileAsEmail (trackingInfo.Cloud_Files__c, customSettingDetails.File_Upload_Template_Name__c, 'Upload');
    }
    
    @remoteAction
    global Static void updateFileRequestUploadCount (String fileCount, String fileReqID) {
        try {
            
            List <TVA_CFB__File_Request__c> lstFRToUpdate = NEW List <TVA_CFB__File_Request__c>();
            for (TVA_CFB__File_Request__c f : [SELECT 
                                     TVA_CFB__Upload_Count__c 
                                     FROM TVA_CFB__File_Request__c 
                                     WHERE Id =: fileReqID
                                     LIMIT 1]) {
                 Decimal count = 0;
                 if (f.TVA_CFB__Upload_Count__c != NULL) {
                     count = f.TVA_CFB__Upload_Count__c + Decimal.valueOf (fileCount);
                 }
                 else {
                     count = Decimal.valueOf(fileCount);
                 }
                
                 f.TVA_CFB__Upload_Count__c = count;
                 lstFRToUpdate.add(f);
             }
             update lstFRToUpdate;
        }
        Catch (Exception e) {}
        
    }
    @remoteAction
    global Static Map<String, String> calculateSignature (Map <String, String> s3Details) {
        try {
            TVA_CFB__CloudFiles_Settings__c credentials = TVA_CFB__CloudFiles_Settings__c.getInstance(UserInfo.getUserID());
            Map <String, TVA_CFB__Cloud_Files_Region_Endpoints__c> regionEndpoints = TVA_CFB__Cloud_Files_Region_Endpoints__c.getAll();
            
            String objectCreatedDate = DateTime.NOW().formatGmt('yyyy-MM-dd') + 'T' + DateTime.NOW().formatGmt('HH:mm:ss') +'Z';
            
            Map <String, String> metaDataMap = NEW Map <String, String> ();
            metaDataMap.put('x-amz-meta-parentId', s3Details.get('parentID'));
            metaDataMap.put('x-amz-meta-filename', s3Details.get('fileName'));
            metaDataMap.put('x-amz-meta-parentobjectname', s3Details.get('parentObjectName'));
            metaDataMap.put('x-amz-meta-ownername', userInfo.getName());
            metaDataMap.put('x-amz-meta-objectCreatedDate', objectCreatedDate);
            if (s3Details.containsKey ('aclKey'))
                metaDataMap.put ('aclKey', s3Details.get ('aclKey'));
            
            Map <String, String> signatureMap = NEW Map <String, String>();

            signatureMap = calculateFileUploadSignature (credentials, s3Details.get('BucketName'), 
                                                                                    s3Details.get('region'), regionEndpoints, 
                                                                                    metaDataMap);
            return signatureMap ;
        }
        catch (Exception e) {
            throw e;
        }
    }
    global static String getBucketLocation(TVA_CFB__CloudFiles_Settings__c s3Credentials, String bucketName)
    {
        try{
            String Authorization = 'Authorization';
            String region = 'us-east-1';
            Datetime now = Datetime.now();
            String amzDate = now.formatGmt('yyyyMMdd')+'T'+now.formatGmt('HHmmss')+'Z';

            Blob hash = Crypto.generateDigest('SHA-256', Blob.valueOf(''));
            String Payloadaction = EncodingUtil.convertToHex (hash);
            String amazonUrl = s3Credentials.TVA_CFB__Amazon_URL__c.replace('https://', 'https://'+bucketName+'.');
            String CanonicalRequest = 'GET\n/'+'\nlocation=' +
                                        +'\ncontent-type:application/json'+
                                        +'\nhost:'+amazonUrl.removeStart ('https://').removeStart ('http://')
                                        +'\nx-amz-content-sha256:'+Payloadaction
                                        +'\nx-amz-date:'+amzDate+
                                        +'\nx-amz-target:s3:*'
                                        +'\n\ncontent-type;host;x-amz-content-sha256;'
                                        +'x-amz-date;x-amz-target\n'
                                        +Payloadaction;
            Blob hashCanonical = Crypto.generateDigest('SHA-256', Blob.valueOf(CanonicalRequest));
            String canonicalHash = EncodingUtil.convertToHex (hashCanonical);

            String StringtoSign = 'AWS4-HMAC-SHA256\n'+amzDate
                                +'\n'+DateTime.Now ().formatGmt('yyyyMMdd')
                                +'/'+region+'/s3/aws4_request\n'+canonicalHash;
            Blob kDate  = Crypto.generateMac('HMAC-SHA256', 
                            Blob.valueOf(DateTime.Now ().formatGmt('yyyyMMdd')), 
                            Blob.valueOf('AWS4'+s3Credentials.TVA_CFB__secret_key__c)); 

            Blob kRegion = Crypto.generateMac('HMAC-SHA256', Blob.valueOf(region), kDate);
            Blob kService = Crypto.generateMac('HMAC-SHA256', Blob.valueOf('s3'), kRegion);
            Blob kSigning = Crypto.generateMac('HMAC-SHA256', Blob.valueOf('aws4_request'),
                                                kService);
            Blob bsig = Crypto.generateMac('HMAC-SHA256', Blob.valueOf(StringtoSign), kSigning);

            String signature = EncodingUtil.convertToHex (bsig);

            String AuthHeader = 'AWS4-HMAC-SHA256 Credential='+s3Credentials.TVA_CFB__Access_Key__c
                                +'/'+DateTime.Now ().formatGmt ('yyyyMMdd')+'/'+region
                                +'/s3/aws4_request,SignedHeaders=content-type;host;'
                                +'x-amz-target;x-amz-content-sha256;x-amz-date,Signature=';
            AuthHeader = AuthHeader+signature;
            HttpRequest con = NEW HttpRequest ();
            con.setMethod ('GET');
            con.setEndPoint (amazonURL.replace (bucketName+'.', '')+'?location') ;
            con.setHeader('host', amazonURL.removeStart ('https://').removeStart ('http://'));
            con.setHeader('Content-Type', 'application/json');
            con.setHeader('x-amz-target','s3:*');
            con.setHeader('x-amz-content-sha256', Payloadaction);
            con.setHeader('x-amz-date', amzDate);
            con.setHeader(Authorization, AuthHeader);
            con.setTimeout(120000);

            Http http = NEW Http();
            HTTPResponse res = NEW HTTPResponse();

            if(!Test.isRunningTest())
                res = http.send (con);
            
            if(Test.isRunningTest())
                res.setBody('">us-east-1</LocationConstraint>');
            String responseBody = res.getBody ();
            try{
                region = responseBody
                            .subStringBetween('">','</LocationConstraint>');
            }
            Catch (Exception e){
            }
            if(region == '' || region == null){
                region = 'us-east-1';
                /* Default region to US Standard ( us-east-1 ) */
            }
            return region;
        }
        catch (Exception e){
            throw e;
        }
    }
    global static Map<String, String> calculateFileUploadSignature(
                                    TVA_CFB__CloudFiles_Settings__c s3Credentials,
                                    String bucketName, String region,
                                    Map <String, TVA_CFB__Cloud_Files_Region_Endpoints__c> regionEndPoints,
                                    Map <String, String> metaDataMap)
    {
        
        try{
            /****** To get Bucket Region for the First File Upload *************/
            String currentRegion = region;
            if(currentRegion == '')
                currentRegion = getBucketLocation (s3Credentials, bucketName);

            String dateFormat = DateTime.Now ().formatGmt ('yyyyMMdd');
            /* Signature will expire in next 120 Minutes */
            Datetime signatureExpirationTime = DateTime.now().addMinutes(120);

            if(metaDataMap.containsKey ('DaysToExpire')){
                Integer expireDays = Integer.valueOf(metaDataMap.get('DaysToExpire'));
                signatureExpirationTime = DateTime.now().addDays(expireDays );
            }

            String formattedExpire = signatureExpirationTime.formatGmt('yyyy-MM-dd')+'T'
                                    +signatureExpirationTime.formatGmt('HH:mm:ss')+'.'
                                    + signatureExpirationTime.formatGMT ('SSS') + 'Z';

            String amzDate = signatureExpirationTime.formatGmt('yyyyMMdd')+'T'
                            +signatureExpirationTime.formatGmt ('HHmmss')+'Z';

            String xamzcredentials = s3Credentials.TVA_CFB__Access_Key__c+'/'+dateFormat+'/'+currentRegion
                                    +'/s3/aws4_request';
            String xamzAlgorithm = 'AWS4-HMAC-SHA256';
            System.debug (regionEndpoints);
            System.debug (currentRegion);
            
            String s3EndpointURL = regionEndpoints.get (currentRegion).TVA_CFB__Endpoint_URL__c.replace('https://', 'https://'+bucketName+'.')+'/';

            Boolean encryptionFlag = s3Credentials.TVA_CFB__Server_Side_Encryption__c;

            String aclKey = 'private';

            if(metaDataMap.containsKey('aclKey'))
                aclKey = metaDataMap.get ('aclKey');
            String contentResponseType = '';
            String fileName = metaDataMap.get ('x-amz-meta-filename');
            Integer i = fileName.lastIndexOf ('.');
            String extension ;
            if(i > 0)
                extension = fileName.subString(i+1);
            try{
                TVA_CFB__CloudFiles_MIME_Types__c fileMIMETypes = [SELECT 
                                                            Name, TVA_CFB__Content_Type__c 
                                                        FROM 
                                                            TVA_CFB__CloudFiles_MIME_Types__c 
                                                        WHERE 
                                                            Name =:extension];

                contentResponseType = fileMIMETypes.TVA_CFB__Content_Type__c;
            }
            catch(Exception e){
            }
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('x-amz-meta-parentobjectname',
                                metaDataMap.get('x-amz-meta-parentobjectname'));
            gen.writeEndObject();
            String parentObjectName = gen.getAsString();

            JSONGenerator gen1 = JSON.createGenerator(true);
            gen1.writeStartObject();
            gen1.writeStringField('x-amz-meta-ownername', metaDataMap.get('x-amz-meta-ownername'));
            gen1.writeEndObject();

            String ownerName = gen1.getAsString ();

            JSONGenerator gen2 = JSON.createGenerator(true);
            gen2.writeStartObject();
            gen2.writeStringField('x-amz-meta-filename', metaDataMap.get('x-amz-meta-filename'));
            gen2.writeEndObject();
            String metafileName = gen2.getAsString();

            String policyData = '{ "expiration": "'+formattedExpire+'",'
                                +'"conditions": ['
                                    +'{"bucket": "'+bucketName+'"},';
            if(encryptionFlag)
                policyData += '{"x-amz-server-side-encryption": "AES256"},';

            policyData += '{"x-amz-meta-parentId": "'+metaDataMap.get ('x-amz-meta-parentId')+'" },'
                        +metafileName+','
                        +parentObjectName+','
                        +ownerName +','
                        +'{"x-amz-meta-objectCreatedDate": "'
                        +metaDataMap.get ('x-amz-meta-objectCreatedDate')+'" },'
                        +'["starts-with", "$key", ""],'
                        +'{"acl": "'+aclKey+'"},';

            if(contentResponseType != '')
                policyData += '{"content-type": "'+contentResponseType+'"},';

            policyData += '{"success_action_redirect": ""},'
                        +'["starts-with", "$x-amz-meta-tag", ""],\n'
                        +'{"x-amz-credential": "'+xamzcredentials+'"},'
                        +'{"x-amz-algorithm": "'+xamzAlgorithm+'"},'
                        +'{"x-amz-date": "'+amzDate+'" }'
                        +']'
                        +'}';

            String stringToSignIn = EncodingUtil.base64Encode(Blob.valueOf(policyData));
            Blob kDate = Crypto.generateMac('HMAC-SHA256', Blob.valueOf (dateFormat),
                Blob.valueOf('AWS4'+s3Credentials.TVA_CFB__Secret_Key__c));
            Blob kRegion = Crypto.generateMac('HMAC-SHA256', Blob.valueOf(currentRegion), kDate);
            Blob kService = Crypto.generateMac('HMAC-SHA256', Blob.valueOf('s3'), kRegion);
            Blob kSigning = Crypto.generateMac('HMAC-SHA256', Blob.valueOf('aws4_request'),
                            kService);
            Blob bsig = Crypto.generateMac('HMAC-SHA256', Blob.valueOf(stringToSignIn), 
                        kSigning);
            String amazonS3Signature = EncodingUtil.convertToHex(bsig);
            Map<String, String> authenticationDetailsMap = NEW Map<String, String> ();
            authenticationDetailsMap.put('X-Amz-Credential', xamzcredentials);
            authenticationDetailsMap.put('accessKey', s3Credentials.TVA_CFB__Access_Key__c);
            authenticationDetailsMap.put('expirationKey', s3Credentials.TVA_CFB__Secret_Key__c);

            authenticationDetailsMap.put('region', currentRegion);
            authenticationDetailsMap.put('EndpointURL', s3EndpointURL);
            authenticationDetailsMap.put('BucketName', bucketName);
            authenticationDetailsMap.put('X-Amz-Algorithm', xamzAlgorithm);
            authenticationDetailsMap.put('X-Amz-Date', amzDate);
            authenticationDetailsMap.put('Policy', stringToSignIn);
            authenticationDetailsMap.put('X-Amz-Signature', amazonS3Signature);
            authenticationDetailsMap.put('content-type', contentResponseType);

            authenticationDetailsMap.put('x-amz-meta-ownername',
                                            metaDataMap.get('x-amz-meta-ownername'));
            authenticationDetailsMap.put('x-amz-meta-parentId',
                                            metaDataMap.get('x-amz-meta-parentId'));
            authenticationDetailsMap.put('x-amz-meta-filename',
                                            metaDataMap.get('x-amz-meta-filename'));
            authenticationDetailsMap.put('x-amz-meta-parentobjectname',
                                            metaDataMap.get('x-amz-meta-parentobjectname'));
            authenticationDetailsMap.put('x-amz-meta-objectCreatedDate',
                                            metaDataMap.get('x-amz-meta-objectCreatedDate'));
            
            if(encryptionFlag){
                authenticationDetailsMap.put ('x-amz-server-side-encryption', 'AES256');
                authenticationDetailsMap.put ('EnableServerEncryption', 'TRUE');
            }
            else
                authenticationDetailsMap.put ('EnableServerEncryption', 'FALSE');

            return authenticationDetailsMap;
        }
        catch(Exception e){
            Map<String, String> errorDetailsMap = NEW Map<String, String> ();
            errorDetailsMap.put('ErrorMessage', e.getMessage());
            return errorDetailsMap;
        }
    }
    @remoteAction
    global Static String uploadStandaloneFile (String record, Map <String, String> fileDetailsMap) {  
        
        TVA_CFB__Cloud_files__c obj = new TVA_CFB__Cloud_files__c ();
        try {
            obj = (TVA_CFB__Cloud_files__c )JSON.deserialize(record, TVA_CFB__Cloud_files__c.class);
        } catch (Exception e) {}
        
        try {
            if (obj.Name == NULL) {
                String name = '';
                name = fileDetailsMap.containsKey ('Name') ? fileDetailsMap.get ('Name') : name;
                name = fileDetailsMap.containsKey ('fileName') ? fileDetailsMap.get ('fileName') : name;
                name = fileDetailsMap.containsKey ('filename') ? fileDetailsMap.get ('filename') : name;
                name = fileDetailsMap.containsKey ('Filename') ? fileDetailsMap.get ('Filename') : name;
                name = fileDetailsMap.containsKey ('FileName') ? fileDetailsMap.get ('FileName') : name;
                name = fileDetailsMap.containsKey ('name') ? fileDetailsMap.get ('name') : name;
                obj.put('Name', name);
            }
            if (obj.TVA_CFB__File_Type__c == NULL) {
                String fileType = '';
                fileType = fileDetailsMap.containsKey ('FileType') ? fileDetailsMap.get ('FileType') : fileType;
                fileType = fileDetailsMap.containsKey ('fileType') ? fileDetailsMap.get ('fileType') : fileType;
                obj.put ('TVA_CFB__File_Type__c', fileType);
            }
            if (obj.TVA_CFB__File_Size_in_Bytes__c == NULL) {
                Decimal fileSize = 0;
                fileSize = fileDetailsMap.containsKey ('FileSize') ? Decimal.valueOf (fileDetailsMap.get ('FileSize')) : fileSize;
                fileSize = fileDetailsMap.containsKey ('fileSize') ?  Decimal.valueOf (fileDetailsMap.get ('fileSize')) : fileSize;
                obj.put ('TVA_CFB__File_Size_in_Bytes__c', fileSize);
            }
            if (obj.TVA_CFB__Bucket_name__c == NULL) {
                String bucketName = '';
                bucketName = fileDetailsMap.containsKey ('BucketName') ? fileDetailsMap.get ('BucketName') : bucketName;
                bucketName = fileDetailsMap.containsKey ('bucketName') ? fileDetailsMap.get ('bucketName') : bucketName;
                obj.put ('TVA_CFB__Bucket_name__c', bucketName);
            }
            
            if (obj.TVA_CFB__Region__c == NULL) {
                String region = '';
                region = fileDetailsMap.containsKey ('Region') ? fileDetailsMap.get ('Region') : region;
                region = fileDetailsMap.containsKey ('region') ? fileDetailsMap.get ('region') : region;
                obj.put ('TVA_CFB__Region__c', region);
            }
            
            if (obj.Name.length () > 75) {
                String fileTypeVal = obj.TVA_CFB__File_Type__c;
                if (fileTypeVal == NULL)
                    fileTypeVal = '';
                else
                    fileTypeVal = '.'+fileTypeVal;
                obj.put ('Name', obj.Name.subString (0, 75)+fileTypeVal);
            }
            
            if (obj.ID == NULL) {
                insert obj;
            }
            else {
                update obj;
            }
            return obj.id;
        }
        catch (DMLException e) {
            throw e ;
        }
        catch (Exception e) {
            throw e;
        }
    }
    @remoteAction
    global Static String deleteFailedRec (String delID) {
        List<TVA_CFB__Cloud_Files__c> obj = new List<TVA_CFB__Cloud_Files__c> ();
        String delObjID = String.escapeSingleQuotes(delID);
        delete [ SELECT ID FROM TVA_CFB__Cloud_Files__c WHERE ID =: delObjID];
        
        return 'Success';
    }
    
    @remoteAction
    global Static String updateETag(String Etag, String VersionID, String cloudFileID, String responseStatus) {
        TVA_CFB__Cloud_Files__c childObject = new TVA_CFB__Cloud_Files__c ();
        childObject.put ('Id', cloudFileId);
        childObject.put ('TVA_CFB__E_Tag__c', ETag.removeEnd('"').removeStart('"'));
        childObject.put ('TVA_CFB__Amazon_Version_ID__c', versionID);
        childObject.put ('TVA_CFB__Reponse_Code__c', responseStatus);
        update childObject;
        return 'Success';
    } 
    
}