public with sharing class WEG_TamaracSsoController {
    
    // determine if the logged in user has access to Tamarac Single-Sign On
    @AuraEnabled
    public static boolean userHasSignOnAccess() {
        
        User u = [SELECT Id, WEG_TamaracSsoUser__c, WEG_TamaracSsoUsername__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        if (u != null && u.WEG_TamaracSsoUser__c && string.isNotBlank(u.WEG_TamaracSsoUsername__c))
            return true;
        else
            return false;
    }
}