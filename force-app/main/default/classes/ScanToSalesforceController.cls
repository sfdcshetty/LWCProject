public class ScanToSalesforceController {
    @AuraEnabled
    public static TVA_CFB__Cloud_Files__c createCloudFile (TVA_CFB__Cloud_Files__c cloudFile, String type) {
        try {
            if (cloudFile.Name != null) {
                if (!cloudFile.Name.EndsWith ('.pdf')) {
                    cloudFile.Name = cloudFile.Name+'.pdf';
                }
                if (type != 'Version' ) {
                    try {
                        cloudFile.recordTypeId = Schema.SObjectType.TVA_CFB__Cloud_Files__c
                            .getRecordTypeInfosByName()
                            .get('Scan')
                            .getRecordTypeId();
                    } catch (Exception e) {
                    }
                    insert cloudFile;
                    
                }
                if (type == 'Version') {
                    TVA_CFB__Cloud_Files__c cloudFileDetails = NEW TVA_CFB__Cloud_Files__c ();
                    cloudFileDetails = [ SELECT Name, TVA_CFB__Version__c, TVA_CFB__Amazon_Version_ID__c,
                                        TVA_CFB__File_Size_in_Bytes__c, TVA_CFB__File_Type__c,
                                        WEGP1_DocumentType__c, TVA_CFB__Folder__c,
                                        WEGP1_Ready_for_Review__c, TVA_CFB__E_Tag__c 
                                        FROM TVA_CFB__Cloud_Files__c 
                                        WHERE Id =:cloudFile.ID ];
                    TVA_CFB__Version_History__c versionFile = NEW TVA_CFB__Version_History__c ();
                    if (cloudFileDetails.TVA_CFB__Version__c != NULL)
                        versionFile.Name = String.valueOf (cloudFileDetails.TVA_CFB__Version__c + 1);
                    else
                        versionFile.Name = '1';
                    
                    versionFile.TVA_CFB__Amazon_Version_ID__c = cloudFile.TVA_CFB__Amazon_Version_ID__c;
                    versionFile.TVA_CFB__Cloud_Files__c = cloudFile.ID;
                    versionFile.TVA_CFB__File_Name__c = cloudFile.Name;
                    versionFile.TVA_CFB__File_Size_in_Bytes__c = cloudFile.TVA_CFB__File_Size_in_Bytes__c;
                    versionFile.TVA_CFB__File_Type__c = cloudFile.TVA_CFB__File_Type__c;
                    insert versionFile;
                    
                    cloudFileDetails.Name = cloudFile.Name;
                    cloudFileDetails.WEGP1_DocumentType__c = cloudFile.WEGP1_DocumentType__c;
                    cloudFileDetails.TVA_CFB__Folder__c = cloudFile.TVA_CFB__Folder__c;
                    cloudFileDetails.WEGP1_Ready_for_Review__c = cloudFile.WEGP1_Ready_for_Review__c;
                    if (cloudFileDetails.TVA_CFB__Version__c != NULL)
                        cloudFileDetails.TVA_CFB__Version__c = cloudFileDetails.TVA_CFB__Version__c + 1;
                    else
                        cloudFileDetails.TVA_CFB__Version__c = 1;
                    update cloudFileDetails;
                    cloudFile = cloudFileDetails;
                    
                }
                User user = [ SELECT ADName__c FROM User WHERE ID =:UserInfo.getUserID ()];
                DateTime currentTime = System.Now ();
                cloudFile.TVA_CFB__E_Tag__c = user.ADName__c+'_'
                    +checkLength(currentTime.month())+checkLength(currentTime.day())+checkLength(currentTime.year())+'-'
                    +checkLength(currentTime.hour())+checkLength(currentTime.minute())+checkLength(currentTime.second());
                return cloudFile;
            }
            else {
                return null;
            }
        }
        catch (Exception e) {
            return null;
        }
    }
    private static String checkLength(Integer value){
        String val = string.valueOf (value);
        if(String.isNotBlank(val) && val.length() == 1){
            val = '0' + val;
        }
        return val;
    }
    @AuraEnabled
    public static List <String> getDocumentTypes (){
        List <String> options = new List <String>();
        Schema.DescribeFieldResult fieldResult = TVA_CFB__Cloud_Files__c.WEGP1_DocumentType__c.getDescribe();
        List <Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add (p.getLabel());
        }
        return options;
    }
    @AuraEnabled
    public static String getFileName (Id recordId, String type){
        String fileName = '';
        if (type != 'Version') {
            Account acc = NEW Account ();
            acc = [ SELECT WEGP1_WEGID__c FROM Account WHERE ID =: recordId ];
            if (acc.WEGP1_WEGID__c != NULL)
                fileName = acc.WEGP1_WEGID__c;
        }
        else {
            TVA_CFB__Cloud_Files__c cloudFile = NEW TVA_CFB__Cloud_Files__c ();
            cloudFile = [ SELECT Name FROM TVA_CFB__Cloud_Files__c WHERE ID =: recordId ];
            if (cloudFile.Name != NULL)
                fileName = cloudFile.Name;
        }
        return fileName;
    }
    
    @AuraEnabled
    public static List <sObject> searchRecords (String searchKeyWord, 
                                               String objName, String fieldAPI, 
                                               Integer dataLimit) 
    {
        List <sObject> sObjList = new List <sObject> ();
        List <String> fieldsList = new List <String> ();
        String searchKey = '%' + searchKeyWord + '%';
        String accountfolders = 'Account';
        String query = 'SELECT name, TVA_CFB__Value__c from ';
        if (dataLimit == null) {
            query += objName + ' WHERE TVA_CFB__Object_Name__c =:accountfolders AND TVA_CFB__Value__c like: searchKey' ;
        }            
        else if(dataLimit != null) {
            query += objName + ' WHERE ' +fieldAPI+ ' like: searchKey limit ' +dataLimit;
        }
        sObjList = Database.query(query);
        return sObjList;
    }
    
    @AuraEnabled
    public static Sobject defaultFolder (String objectName, String folderValue) {
        Sobject defaultFolder = null;
        try {
            defaultFolder = [SELECT Name, TVA_CFB__Value__c FROM TVA_CFB__DocuVault_Folders__c 
                             WHERE TVA_CFB__Object_Name__c =: objectName 
                             AND TVA_CFB__Value__c =: folderValue LIMIT 1];
        }
        catch (Exception e) {}
        return defaultFolder;
    }
    
}