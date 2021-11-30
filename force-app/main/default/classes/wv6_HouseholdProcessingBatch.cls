/******************************************************************************************************************************
* @class name    : wv6_HouseholdProcessingBatch 
* @description   : This class is used to for one time processing of all household accounts. As part of one time processing 
*                  Primary Advisor, Secondary Advisor and Primary CSM fields will be populated on all existing household accounts. 
*
* @test class    : wv6_HouseholdProcessingBatchTest
* @author        : Ganesh Ekhande
* @date          : 01/12/2018
*
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              01/12/2018             Created.
*
******************************************************************************************************************************/
global class wv6_HouseholdProcessingBatch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC){
        // Fetch Household Account Record Type Id
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        // Form a query to fetch Household Accounts.
        String qry ='SELECT Id, Name, WEGP1_Primary_Individual__c, WEGP1_Secondary_Individual__c FROM Account WHERE recordTypeId =:householdRecordTypeId';
        return Database.getQueryLocator(qry);
    }

    global void execute(Database.BatchableContext BC, List<Account> accList){
        // Create Set of Household Account Id
        // as well as a Mapping of Account Id to Name
        Set<String> accIdSet = new Set<String>();
        Map<String, Account> householdAccMap = new Map<String, Account>();
        for(Account acc : accList){
            accIdSet.add(acc.Id);
            householdAccMap.put(acc.Id, acc);
        }
        // Create Map of Household Account Id and Primary Contact Id
        map<string, string> accIdPrimaryConIdMap =  new map<string,string>();
        for(AccountContactRelation acr : [SELECT Id, AccountId, ContactId, Contact.AccountId 
                                          FROM AccountContactRelation 
                                          WHERE AccountId IN : householdAccMap.keySet()
                                          AND FinServ__Primary__c = true]){   
            
            accIdPrimaryConIdMap.put(acr.AccountId,acr.ContactId);
        }
        system.debug('accIdPrimaryConIdMap:>>'+accIdPrimaryConIdMap);
        
        // Create Map of Household Account Id and Secondary Contact Id
        map<string, map<string,string>> accIdSecondaryConIdsMap =  new map<string,map<string,string>>(); 
        for(AccountContactRelation acr : [SELECT Id, Roles, AccountId, ContactId, Contact.AccountId 
                                          FROM AccountContactRelation 
                                          WHERE AccountId IN : householdAccMap.keySet()
                                          AND FinServ__PrimaryGroup__c = true AND Roles IN ('Spouse','Domestic Partner')]){   
            
            if(accIdSecondaryConIdsMap.containsKey(acr.AccountId)){
                map <string,string> accIdConIdMap = accIdSecondaryConIdsMap.get(acr.AccountId);
                accIdConIdMap.put(acr.Roles,acr.ContactId);
                accIdSecondaryConIdsMap.put(acr.AccountId,accIdConIdMap);
            }else{
                accIdSecondaryConIdsMap.put(acr.AccountId,new map<string,string>{acr.Roles => acr.ContactId});
            }
        }
        system.debug('accIdSecondaryConIdsMap:>>'+accIdSecondaryConIdsMap);
        
        // Populate Primary Contact Id and Secondary Contact Id on Household Account.
        for(Account acc : householdAccMap.values()){
            if(accIdPrimaryConIdMap.containsKey(acc.Id)){
                acc.WEGP1_Primary_Individual__c = accIdPrimaryConIdMap.get(acc.Id);
            }else{
                acc.WEGP1_Primary_Individual__c = null;    
            }
            
            if(accIdSecondaryConIdsMap.containsKey(acc.Id)){
                map<string,string> accIdConIdMap = accIdSecondaryConIdsMap.get(acc.Id);
                if(accIdConIdMap.containsKey('Spouse')){
                    acc.WEGP1_Secondary_Individual__c = accIdConIdMap.get('Spouse');    
                }else if(accIdConIdMap.containsKey('Domestic Partner')){
                    acc.WEGP1_Secondary_Individual__c = accIdConIdMap.get('Domestic Partner'); 
                }
            }else{
                acc.WEGP1_Secondary_Individual__c = null;
            }
        }
        system.debug('householdAccMap 2:>>'+householdAccMap);
        
        update householdAccMap.values();
    }

    global void finish(Database.BatchableContext BC){
    }
}