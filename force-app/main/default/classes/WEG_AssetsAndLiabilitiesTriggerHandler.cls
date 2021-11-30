public class WEG_AssetsAndLiabilitiesTriggerHandler {
    public void beforeInsert(List<FinServ__AssetsAndLiabilities__c> newAssetsAndLiabilities) {
        
        for (FinServ__AssetsAndLiabilities__c al : newAssetsAndLiabilities) {
            // sync primary owner/household to account
            if (al.FinServ__Household__c != null)
                al.WEG_Account__c = al.FinServ__Household__c;
            else
                al.WEG_Account__c = al.FinServ__PrimaryOwner__c;

            
        }
    }
    
    public void beforeUpdate(List<FinServ__AssetsAndLiabilities__c> newAssetsAndLiabilities, Map<Id, FinServ__AssetsAndLiabilities__c> oldAssetsAndLiabilitiesMap) {
        
        for (FinServ__AssetsAndLiabilities__c al : newAssetsAndLiabilities) {
            FinServ__AssetsAndLiabilities__c oldAL = oldAssetsAndLiabilitiesMap.get(al.Id);
            
            if (al.FinServ__PrimaryOwner__c != oldAL.FinServ__PrimaryOwner__c || al.FinServ__Household__c != oldAL.FinServ__Household__c) {
                // sync primary owner/household to account
                if (al.FinServ__Household__c != null)
                    al.WEG_Account__c = al.FinServ__Household__c;
                else
                    al.WEG_Account__c = al.FinServ__PrimaryOwner__c;
            }
        }
    }
}