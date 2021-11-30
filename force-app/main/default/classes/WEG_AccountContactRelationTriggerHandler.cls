public class WEG_AccountContactRelationTriggerHandler {
    
    // instantiate the sets needed for processing
    Set<Id> contactIds = new Set<Id>();
    Set<Id> householdIds = new Set<Id>();
    
    public void afterInsert(List<AccountContactRelation> newAccountContactRelations) {
        System.debug('>>>>>>>> WEG_AccountContactRelationTriggerHandler.afterInsert');
        
        // iterate the inserted/updated relations
        for (AccountContactRelation acr : newAccountContactRelations) {
            System.debug('>>>>>>>> ContactId: ' + acr.ContactId);
            System.debug('>>>>>>>> AccountId: ' + acr.AccountId);
            
            if (acr.FinServ__PrimaryGroup__c) {
                System.debug('>>>>>>>> ACR has Primary Group set');
                
                contactIds.add(acr.ContactId);
                householdIds.add(acr.AccountId);
            }
        }
        
        // HELPER METHOD - update all related individuals and households
        if (!contactIds.isEmpty() || !householdIds.isEmpty())
            updateHouseholdRelationInfo();
    }
    
    public void afterUpdate(List<AccountContactRelation> newAccountContactRelations, Map<Id,AccountContactRelation> oldAccountContactRelationsMap) {
        System.debug('>>>>>>>> WEG_AccountContactRelationTriggerHandler.afterUpdate');
        
        // iterate the inserted/updated relations
        for (AccountContactRelation acr : newAccountContactRelations) {
            System.debug('>>>>>>>> ContactId: ' + acr.ContactId);
            System.debug('>>>>>>>> AccountId: ' + acr.AccountId);
            
            if (acr.FinServ__PrimaryGroup__c || oldAccountContactRelationsMap.get(acr.Id).FinServ__PrimaryGroup__c) {
                System.debug('>>>>>>>> ACR has/had Primary Group set');
                
                contactIds.add(acr.ContactId);
                householdIds.add(acr.AccountId);
            }
        }
        
        // HELPER METHOD - update all related individuals and households
        if (!contactIds.isEmpty() || !householdIds.isEmpty())
            updateHouseholdRelationInfo();
    }
    
    public void afterDelete(List<AccountContactRelation> oldAccountContactRelations) {
        System.debug('>>>>>>>> WEG_AccountContactRelationTriggerHandler.afterDelete');
        
        // iterate the deleted relations
        for (AccountContactRelation acr : oldAccountContactRelations) {
            System.debug('>>>>>>>> ContactId: ' + acr.ContactId);
            System.debug('>>>>>>>> AccountId: ' + acr.AccountId);
            
            if (acr.FinServ__PrimaryGroup__c) {
                System.debug('>>>>>>>> ACR had Primary Group set');
                
                contactIds.add(acr.ContactId);
                householdIds.add(acr.AccountId);
            }
        }
        
        // HELPER METHOD - update all related individuals and households
        if (!contactIds.isEmpty() || !householdIds.isEmpty())
            updateHouseholdRelationInfo();
    }
    
    private void updateHouseholdRelationInfo() {
        // update primary household, primary individual, and secondary individual
        // for all affected relations
        updatePrimaryHousehold();
        updatePrimarySecondaryIndividuals();
        
        // update the household mailing name for the households
        WEG_Util_UpdateMailingName mailingNameUtility = new WEG_Util_UpdateMailingName();
        mailingNameUtility.updateHouseholds(householdIds);
    }
    
    private void updatePrimaryHousehold() {
        System.debug('>>>>>>>> WEG_AccountContactRelationTriggerHandler.updatePrimaryHousehold');
        
        // get the account side of the individuals
        Map<Id,Account> individualAccounts = new Map<Id,Account>([SELECT Id, WEGP1_Primary_Household__c
                                                                 FROM Account
                                                                 WHERE ID IN (SELECT AccountId FROM Contact WHERE ID IN :contactIds)]);
        
        // get the contacts and their relationships
        List<Contact> contacts = [SELECT Id, AccountId
                                  , (SELECT Id, AccountId, FinServ__Primary__c, Roles FROM AccountContactRelations WHERE IsActive = true AND FinServ__PrimaryGroup__c = true)
                                 FROM Contact
                                 WHERE Id IN :contactIds];
        
        // iterate the contacts affected, building the accounts to be updated
        for (Contact ct : contacts) {
            System.debug('>>>>>>>> Contact Id: ' + ct.Id);
            
            // get the account side of the contact
            Account acct = individualAccounts.get(ct.AccountId);
            if (acct != null) {
                System.debug('>>>>>>>> Individual Account Id: ' + acct.Id);
                
                // initially set the primary household to NULL
                // it will only be set after validating a set of rules
                acct.WEGP1_Primary_Household__c = null;
                
                System.debug('>>>>>>>> Contact Relations: ' + ct.AccountContactRelations);
                
                // the contact should only have 1 active primary group relation
                if (ct.AccountContactRelations.size() == 1) {
                    System.debug('>>>>>>>> One relation found.');
                    
                    for (AccountContactRelation acr : ct.AccountContactRelations) {
                        // the relation should be primary, or with a role of either ('Spouse' or 'Domestic Partner')
                        if (acr.FinServ__Primary__c) {
                            System.debug('>>>>>>>> Is Primary to Household Account Id: ' + acr.AccountId);
                            acct.WEGP1_Primary_Household__c = acr.AccountId;
                        }
                        else if (acr.Roles != null && (acr.Roles.contains('Spouse') || acr.Roles.contains('Domestic Partner'))) {
                            System.debug('>>>>>>>> Is Secondary to Household Account Id: ' + acr.AccountId);
                            acct.WEGP1_Primary_Household__c = acr.AccountId;
                        }
                    }
                }
            }
        }
        
        // update the account side of the individuals
        update individualAccounts.values();
    }
    
    private void updatePrimarySecondaryIndividuals() {
        System.debug('>>>>>>>> WEG_AccountContactRelationTriggerHandler.updatePrimarySecondaryIndividuals');
        
        // get the households and their relationships
        List<Account> households = [SELECT Id, WEGP1_Primary_Individual__c, WEGP1_Secondary_Individual__c
                                    , (SELECT Id, ContactId, FinServ__Primary__c, Roles FROM AccountContactRelations WHERE IsActive = true AND FinServ__PrimaryGroup__c = true)
                                    FROM Account
                                    WHERE Id IN :householdIds];
        
        // iterate the households affected, building the accounts to be updated
        for (Account acct : households) {
            System.debug('>>>>>>>> Household Account Id: ' + acct.Id);
            
            // initially set the primary/secondary individuals to NULL
            // they will only be set after validating a set of rules
            acct.WEGP1_Primary_Individual__c = null;
            acct.WEGP1_Secondary_Individual__c = null;
            
            // the household should only have 1 active primary relation & 1 active seecondary relation
            // validation rule ensures two primary members can't exist, only checking for two secondary members below
            boolean secondaryRelationAlreadyFound = false;
            
            // iterate the household relations
            for (AccountContactRelation acr : acct.AccountContactRelations) {
                System.debug('>>>>>>>> AccountContactRelation is: ' + acr);
                
                // for primary relations, set the primary contact
                if (acr.FinServ__Primary__c) {
                    System.debug('>>>>>>>> Has Primary Contact: ' + acr.ContactId);
                    acct.WEGP1_Primary_Individual__c = acr.ContactId;
                }
                // for secondary relations, ensure it's the first and only secondary relation
                // set the secondary contact when found, unset if additional exist
                else if (acr.Roles != null && (acr.Roles.contains('Spouse') || acr.Roles.contains('Domestic Partner'))) {
                    if (!secondaryRelationAlreadyFound) {
                        System.debug('>>>>>>>> Has Secondary Contact: ' + acr.ContactId);
                        acct.WEGP1_Secondary_Individual__c = acr.ContactId;
                        secondaryRelationAlreadyFound = true;
                    }
                    else
                        acct.WEGP1_Secondary_Individual__c = null;
                }
            }
        }
        
        // update the households
        update households;
    }
    
    
    
    
    
    
    
    
}