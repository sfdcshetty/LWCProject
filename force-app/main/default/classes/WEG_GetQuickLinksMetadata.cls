public with sharing class WEG_GetQuickLinksMetadata {    
    @AuraEnabled
    public static List<WEG_Portal_Quick_Link__mdt> getQuickLinks() {
        return [SELECT Id,Title__c, URL__c, Is_External__c, Display_Order__c from WEG_Portal_Quick_Link__mdt];
    }
}