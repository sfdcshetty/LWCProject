/******************************************************************************************************************************
* @class name    : Wave6_HouseholdNameUpdate
* @description   : This is class contains invokable method which is used to calculate household name for parent households based on the child individual records.
* @test class    : Wave6_SetHouseholdNameTest
* @author        : Ganesh Ekhande
* @date          : 05/22/2017               
*                   
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              05/22/2017             Created.

******************************************************************************************************************************/
public class Wave6_HouseholdNameUpdate {
    
    // Fetch Individual Account Record Type Id
   static Id individualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : This is invokable method which is used to set Household name.
    * @created      : 05/22/2017
    * @param        : list<Id> individualIds 
    * @return       : void
    */
    @InvocableMethod(label='Wave6_HouseholdNameAction')
    public static void HouseholdNameAction(List<Id> individualIds ){
        
        list<Account> householdsToUpdate = new List<Account>();
        
        // Create Map of Account ID and Corresponding Individual Id
        Map<String,String> accIdIndividualIdMap = new Map<String,String>();
        for(Account acc : [SELECT Id, FinServ__IndividualId__c From Account Where Id IN: individualIds AND recordTypeId =: individualRecordTypeId]){
            accIdIndividualIdMap.put(acc.Id,acc.FinServ__IndividualId__c);
        }
        System.debug('accIdIndividualIdMap:>>'+accIdIndividualIdMap);
        
        // Create Map of Indivdual ID and Corresponding Contact Id
        List<Contact> contactList = [SELECT Id, FinServ__IndividualId__c 
                                     FROM Contact 
                                     WHERE FinServ__IndividualId__c IN: accIdIndividualIdMap.values()];
        
        Map<String, String> individualIdConIdMap = new Map<String, String>();
        for(Contact con : contactList){
            individualIdConIdMap.put(con.FinServ__IndividualId__c,con.Id);    
        }
        
        System.debug('contactList:>>'+contactList);
        System.debug('individualIdConIdMap:>>'+individualIdConIdMap);
        
        
        // Fetch AccountContactRelation records with Primary Household information for individual accounts
        List<AccountContactRelation> accConRelationList = new List<AccountContactRelation>();
        accConRelationList = [SELECT Id, AccountId, ContactId, FinServ__Primary__c, Roles, Contact.FirstName, Contact.LastName, Account.Name, Account.RecordTypeId
                              FROM  AccountContactRelation 
                              WHERE ContactId IN:individualIdConIdMap.values()
                              AND FinServ__PrimaryGroup__c = true
                              AND Roles INCLUDES ('Client','Spouse','Domestic Partner') ];
        
        System.debug('accConRelationList:>>'+accConRelationList);
        
        // Create Map of Contact Id and Household account Id
        Map<String, List<AccountContactRelation>> housholdIdIndividualsMap = new Map<String, List<AccountContactRelation>>();
        Set<String> householdIds = new Set<String>(); 
        
        for(AccountContactRelation acr : accConRelationList){
            householdIds.add(acr.AccountId);
        }
        system.debug('householdIds:>>'+householdIds);
        
        for(AccountContactRelation acr : [SELECT Id, AccountId, ContactId, FinServ__Primary__c, Roles,Contact.FirstName, Contact.LastName, Account.Name, Account.RecordTypeId
                                          FROM  AccountContactRelation 
                                          WHERE AccountId IN:householdIds
                                          AND Roles INCLUDES ('Client','Spouse','Domestic Partner') ]){
            system.debug('acr:>>'+acr);
            if(!housholdIdIndividualsMap.containsKey(acr.AccountId)){
                housholdIdIndividualsMap.put(acr.AccountId,new list<AccountContactRelation>{acr});                
            }else{
                housholdIdIndividualsMap.get(acr.AccountId).add(acr);
            }
        }
        System.debug('housholdIdIndividualsMap:>>'+housholdIdIndividualsMap);
        
        for(String householdId : housholdIdIndividualsMap.keySet()){
           if(housholdIdIndividualsMap.containsKey(householdId) &&  housholdIdIndividualsMap.get(householdId).size() > 0){
                Account acc = New account(Id = householdId);
                acc.Name = Wave6_SetHouseholdName.calculateHouseholdName(housholdIdIndividualsMap.get(householdId));
                householdsToUpdate.add(acc);
           }
       } 
       update householdsToUpdate;   
    }
}