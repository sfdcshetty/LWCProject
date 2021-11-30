Public With sharing Class Docuvault_DownloadSelectedFiles {

    private ApexPages.StandardSetController standardController;
    public List <ID> cloudFileIDs { get; set; }
    public Integer count { get; set; }
    
    public Docuvault_DownloadSelectedFiles (ApexPages.StandardSetController standardController) {
        this.standardController = standardController;
        cloudFileIDs = NEW List <ID> ();
        count = 0;
        for (TVA_CFB__Cloud_Files__c record: (List <TVA_CFB__Cloud_Files__c>)standardController.getSelected()){ 
            cloudFileIDs.add (record.Id);
        }
        count = cloudFileIDs.size ();
        
    }
    @remoteAction
    public static String generateDownloadURL (String cloudFileRecordID) {
        if (cloudFileRecordID != '') {
            try {
                Set <ID> setIDS = NEW Set <ID> ();
                setIDs.add (cloudFileRecordID);
                
                TVA_CFB.CRUDAndFLSPermissions permission = NEW TVA_CFB.CRUDAndFLSPermissions ();    
                if (permission.isOwnedBy (setIds, 'Read')) {
                    Map <String, String> cloudFileMap = NEW Map <String, String> ();
                    cloudFileMap.put('ID', cloudFileRecordID);
                    
                    return Docuvault_DownloadSelectedFiles.download (cloudFileMap);
                }
                else {
                    return '';
                }
            }
            catch (Exception e) {
                return '';
            }
        }
        else 
            return '';
        
    }
    public static String download (Map <String, String> fileDetails) {
        String downloadURL = '';
        try {
            String errorMessage = TVA_CFB.DownloadFile.checkFilePermissions (fileDetails.get ('ID'));
            
            if (errorMessage == '') {
                TVA_CFB__CloudFiles_Settings__c credentials = TVA_CFB__CloudFiles_Settings__c.getInstance (UserInfo.getUserID ());
                Map <String, TVA_CFB__Cloud_Files_Region_Endpoints__c> regionEndPoints = TVA_CFB__Cloud_Files_Region_Endpoints__c.getAll ();
                Map <String, String> cloudFileDetails = NEW Map <String, String> ();
                
                TVA_CFB__Cloud_Files__c obj = [ SELECT 
                                            TVA_CFB__Downloads__c, TVA_CFB__Region__c, TVA_CFB__File_type__c,
                                            TVA_CFB__Bucket_Name__c, Name, TVA_CFB__External_File_name__c,
                                            Operations_File_Name__c
                                        FROM 
                                            TVA_CFB__Cloud_Files__c 
                                        WHERE 
                                            ID =: fileDetails.get ('ID') ];
                cloudFileDetails.put ('ID', fileDetails.get ('ID'));
                cloudFileDetails.put ('bucket', obj.TVA_CFB__Bucket_Name__c);
                cloudFileDetails.put ('region', obj.TVA_CFB__Region__c);
                if (obj.Operations_File_Name__c != NULL)
                    cloudFileDetails.put ('fileName', obj.Operations_File_Name__c);
                else
                    cloudFileDetails.put ('fileName', obj.Name);
                cloudFileDetails.put ('fileType', obj.TVA_CFB__File_type__c);
                cloudFileDetails.put ('s3FileName', obj.ID+'.'+obj.TVA_CFB__File_type__c);
                if (obj.TVA_CFB__ExterNal_File_Name__c != null) {
                    String externalFileName = obj.TVA_CFB__ExterNal_File_Name__c;
                    externalFileName = EncodingUtil.URLEncode (externalFileName, 'UTF-8');
                    externalFileName = externalFileName.replace ('+', '%20');
                    externalFileName = externalFileName.replace ('%2F', '/');
                    
                    cloudFileDetails.put ('externalFileName', externalFileName);
                    cloudFileDetails.put ('s3FileName', externalFileName);
                }
                if (!Test.isRunningTest())
                    downloadURL = TVA_CFB.amazonS3Authentication.generateDownloadLink (credentials, regionEndPoints, 
                                                                            cloudFileDetails, 200);
                if (Test.isRunningTest ())
                    downloadURL = 'test.com';
                if (downloadURL != '') {
                    TVA_CFB.CRUDAndFLSPermissions permission = NEW TVA_CFB.CRUDAndFLSPermissions ();
                    TVA_CFB__Cloud_Files__c cloudPermission = NEW TVA_CFB__Cloud_Files__c ();
                    
                    List <String> lstCloudCreate = NEW List <String> ();
                    lstCloudCreate.add('TVA_CFB__Downloads__c');
                    
                    String fieldCreate = permission.isAuthorized (cloudPermission, lstCloudCreate, 'Create');
                    String fieldEdit = permission.isAuthorized (cloudPermission, lstCloudCreate, 'Edit');
                    Set <Id> setIds = new Set <Id> ();
                    setIds.add (fileDetails.get ('ID'));
                    
                    if (fieldCreate == '' 
                        && fieldEdit == '' 
                        && permission.isOwnedBy (setIds, 'Read') 
                        && permission.isOwnedBy (setIds, 'Edit')){
                        
                        if (obj.TVA_CFB__Downloads__c != NULL)
                            obj.TVA_CFB__Downloads__c = obj.TVA_CFB__Downloads__c + 1;
                        else
                            obj.TVA_CFB__Downloads__c = 1;
                            
                        obj.WEGP1_D3P__c = True;
                        update obj;
                    }
                }
            }
            return downloadURL;
        }
        catch (Exception e) {
            return '';
        }
    }
}