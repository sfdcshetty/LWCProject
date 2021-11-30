Public with sharing class Docuvault_RenameAWSFileHelper {

    public static HTTPResponse renameFile (String region, 
            String currentBucketName, String currentFileName,
            String newBucketName, String newFileName, String contentType) {
            
        
        TVA_CFB__CloudFiles_Settings__c s3Credentials = TVA_CFB__CloudFiles_Settings__c.getInstance (userInfo.getUserID ());
        Map <String, TVA_CFB__Cloud_Files_Region_Endpoints__c> regionEndPoints = TVA_CFB__Cloud_Files_Region_Endpoints__c.getAll ();
        
        Boolean encryptionFlag = s3Credentials.TVA_CFB__Server_Side_Encryption__c;
        String versionTypeFlag = TVA_CFB.checkLicense.checkPremiumLicense ();
        Datetime now = Datetime.now ();
        String amzDate = now.formatGmt ('yyyyMMdd')+'T'+now.formatGmt ('HHmmss')+'Z';
        
        Blob hash = Crypto.generateDigest ('SHA-256', Blob.valueOf (''));
        String Payloadaction = EncodingUtil.convertToHex (hash);

        String amazonUrl = regionEndpoints.get (region).TVA_CFB__Endpoint_URL__c;                    
        String CanonicalRequest = 'PUT\n/'+newBucketName+'/'+newFileName 
                               +'\n\ncontent-type:'+contentType
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
            con.setHeader ('Content-Type', contentType);  
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
        if (!Test.isRunningTest())
            res = http.send (con);
        return res;           
        
    }
}