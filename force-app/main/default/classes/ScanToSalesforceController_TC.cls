@isTest
private class ScanToSalesforceController_TC {
    static testMethod void method1() {
      Account acc = NEW Account ();
          acc.Name = 'test';
          insert acc;
   
    TVA_CFB__Cloud_Files__c cloudFileDetails = NEW TVA_CFB__Cloud_Files__c ();
    
        cloudFileDetails.Name = 'Test';
        cloudFileDetails.WEGP1_DocumentType__c = 'Document Submission';
        cloudFileDetails.TVA_CFB__Folder__c = 'Test';
        cloudFileDetails.WEGP1_Ready_for_Review__c = true;  
        cloudFileDetails.TVA_CFB__Version__c = 1;
        cloudFileDetails.TVA_CFB__Parent_ID__c = acc.ID;
        cloudFileDetails.WEGP1_Household__c = acc.ID;
    insert cloudFileDetails;
    
    TVA_CFB__Version_History__c versionFile = NEW TVA_CFB__Version_History__c ();
    
        versionFile.TVA_CFB__Amazon_Version_ID__c = cloudFileDetails.TVA_CFB__Amazon_Version_ID__c;
        versionFile.TVA_CFB__Cloud_Files__c = cloudFileDetails.ID;
        versionFile.TVA_CFB__File_Name__c = 'test';
        versionFile.TVA_CFB__File_Size_in_Bytes__c = cloudFileDetails.TVA_CFB__File_Size_in_Bytes__c;
        versionFile.TVA_CFB__File_Type__c = cloudFileDetails.TVA_CFB__File_Type__c;
    insert versionFile;
    
        cloudFileDetails.TVA_CFB__Version__c = 2;
    update cloudFileDetails;
    
        ScanToSalesforceController obj = new ScanToSalesforceController(); 
        ScanToSalesforceController.createCloudFile(cloudFileDetails,'Version');
        ScanToSalesforceController.getDocumentTypes();
        ScanToSalesforceController.getFileName(acc.ID,'Test');  
        ScanToSalesforceController.getFileName(cloudFileDetails.ID,'Version'); 
    }
    static testMethod void method2() {
        Account acc = NEW Account ();
        acc.Name = 'test';
    insert acc;
    
    TVA_CFB__Cloud_Files__c cloudFileDetails = NEW TVA_CFB__Cloud_Files__c ();
    
        cloudFileDetails.Name = 'Test';
        cloudFileDetails.WEGP1_DocumentType__c = 'Document Submission';
        cloudFileDetails.TVA_CFB__Folder__c = 'Test';
        cloudFileDetails.WEGP1_Ready_for_Review__c = true;  
        cloudFileDetails.TVA_CFB__Version__c = 1;
        cloudFileDetails.TVA_CFB__Parent_ID__c = acc.ID;
        cloudFileDetails.WEGP1_Household__c = acc.ID;
    
    TVA_CFB__Version_History__c versionFile = NEW TVA_CFB__Version_History__c ();
    
        versionFile.TVA_CFB__Amazon_Version_ID__c = cloudFileDetails.TVA_CFB__Amazon_Version_ID__c;
        versionFile.TVA_CFB__Cloud_Files__c = cloudFileDetails.ID;
        versionFile.TVA_CFB__File_Name__c = 'test';
        versionFile.TVA_CFB__File_Size_in_Bytes__c = cloudFileDetails.TVA_CFB__File_Size_in_Bytes__c;
        versionFile.TVA_CFB__File_Type__c = cloudFileDetails.TVA_CFB__File_Type__c;
    insert versionFile;
    
    TVA_CFB__DocuVault_Folders__c folder = NEW TVA_CFB__DocuVault_Folders__c();
        folder.TVA_CFB__Object_Name__c = 'Account';
        folder.TVA_CFB__Value__c = 'doc';
        folder.Name = 'doc';
    insert folder;      
            
        ScanToSalesforceController obj = new ScanToSalesforceController(); 
        ScanToSalesforceController.createCloudFile(cloudFileDetails,'test');
        ScanToSalesforceController.getDocumentTypes();
        ScanToSalesforceController.getFileName(acc.ID,'Test');  
        ScanToSalesforceController.getFileName(cloudFileDetails.ID,'Version'); 
        ScanToSalesforceController.searchRecords('','TVA_CFB__DocuVault_Folders__c','Name',5); 
        ScanToSalesforceController.defaultFolder('TVA_CFB__DocuVault_Folders__c','doc');
    }
}