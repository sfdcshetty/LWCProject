public class Docuvault_ChangeFolder {
    
    @AuraEnabled 
    public static List <TVA_CFB__DocuVault_Folders__c> getFolderNames(String recordTypeName , String objectName) { 
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        List <TVA_CFB__DocuVault_Folders__c> FolderNames = NEW List <TVA_CFB__DocuVault_Folders__c> ();
        FolderNames = [select TVA_CFB__Value__c From TVA_CFB__DocuVault_Folders__c Where TVA_CFB__Record_Type_ID__c =: devRecordTypeId And TVA_CFB__Object_Name__c =:objectName];
        System.debug(FolderNames); 
        return FolderNames;
    }
}