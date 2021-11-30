/******************************************************************************************************************************
* @class name    : Wave6_AccountContactRelationHelper
* @description   : This class is used as helper class for Wave6_AccountContactRelationTrigger. 
*                  
* @test class    : Wave6_AccountContactRelationTriggerTest
* @author        : Ganesh Ekhande
* @date          : 05/30/2017               
*                   
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              05/30/2017             Created.
* Ganesh Ekhande              12/22/2017             Added updatePrimarySecondaryContacts method to populate Primary & Secondary Contact on Household Account.
*
******************************************************************************************************************************/
public class Wave6_AccountContactRelationHelper {
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : This method is used to identify primary household for provided individuals.
    * @created      : 05/30/2017
    * @param        : set<string> contactIds
    * @return       : None
    */
    public static void calculatePrimaryHousehold(set<string> contactIds){
        Map<String,String> indAccTohhAccMap = new Map<String,String>();
        
        // Fetch AccountContactRelation records to get the primary household for each contact
        for(AccountContactRelation acr : [SELECT Id, AccountId, ContactId, Contact.AccountId 
                                          FROM AccountContactRelation 
                                          WHERE ContactId IN :contactIds 
                                          AND FinServ__PrimaryGroup__c = true]){
                                              
            indAccTohhAccMap.put(acr.Contact.AccountId, acr.AccountId);    
        }
        system.debug('indAccTohhAccMap:>>'+indAccTohhAccMap);
        
        List<Account> updatedIndAccounts = new List<Account>();
        for(Account acc : [SELECT Id, WEGP1_Primary_Household__c FROM Account WHERE ID IN (SELECT AccountId FROM Contact WHERE ID IN :contactIds)]){
            if(indAccTohhAccMap.containsKey(acc.Id)){
                if(acc.WEGP1_Primary_Household__c != indAccTohhAccMap.get(acc.Id)){
                    acc.WEGP1_Primary_Household__c = indAccTohhAccMap.get(acc.Id);
                }    
            }else{
                acc.WEGP1_Primary_Household__c = null;
            }   
            updatedIndAccounts.add(acc);
        }
        system.debug('updatedIndAccounts:>>'+updatedIndAccounts);
        if(!updatedIndAccounts.isEmpty()){
            update updatedIndAccounts; 
        }
    }
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : This method is used to populate Primary & Secondary Contact on Household Account.
    * @created      : 12/22/2017
    * @param        : set<string> householdAccIds
    * @return       : None
    */
    public static void updatePrimarySecondaryContacts(set<string> householdAccIds){
        
        // Create Map of Account Id and Account record.
        map<String,Account> accountMap = new map<String,Account>([SELECT Id, Name, WEGP1_Primary_Individual__c, WEGP1_Secondary_Individual__c FROM Account WHERE Id IN:householdAccIds]);
        system.debug('accountMap:>>'+accountMap);
        
        // Create Map of Household Account Id and Primary Contact Id
    	map<string, string> accIdPrimaryConIdMap =  new map<string,string>();
    	for(AccountContactRelation acr : [SELECT Id, AccountId, ContactId, Contact.AccountId 
    									  FROM AccountContactRelation 
    									  WHERE AccountId IN : accountMap.keySet()
    									  AND FinServ__Primary__c = true]){	  
    		
    		accIdPrimaryConIdMap.put(acr.AccountId,acr.ContactId);
    	}
    	system.debug('accIdPrimaryConIdMap:>>'+accIdPrimaryConIdMap);
    	
    	// Create Map of Household Account Id and Secondary Contact Id
    	map<string, map<string,string>> accIdSecondaryConIdsMap =  new map<string,map<string,string>>(); 
    	for(AccountContactRelation acr : [SELECT Id, Roles, AccountId, ContactId, Contact.AccountId 
    									  FROM AccountContactRelation 
    									  WHERE AccountId IN : accountMap.keySet()
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
    	for(Account acc : accountMap.values()){
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
    	system.debug('accountMap 2:>>'+accountMap);
    	
    	update accountMap.values();
    }
}