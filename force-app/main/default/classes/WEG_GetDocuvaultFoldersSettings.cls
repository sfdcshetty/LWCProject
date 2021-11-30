public with sharing class WEG_GetDocuvaultFoldersSettings {
    
    @AuraEnabled
    public static List<TVA_CFB__DocuVault_Folders__c> getDocuvaultFolders() {
        return [SELECT TVA_CFB__Object_Name__c,TVA_CFB__Record_Type_ID__c, TVA_CFB__Value__c from TVA_CFB__DocuVault_Folders__c];
    }
    
}