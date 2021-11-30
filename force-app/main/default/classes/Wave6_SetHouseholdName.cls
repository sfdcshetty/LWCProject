/******************************************************************************************************************************
* @class name    : Wave6_SetHouseholdName
* @description   : This is class contains invokable method which is used to calculate household name based on the child individual records.
* @test class    : Wave6_SetHouseholdNameTest
* @author        : Ganesh Ekhande
* @date          : 05/26/2017               
*                   
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              05/26/2017             Created.

******************************************************************************************************************************/
public class Wave6_SetHouseholdName {
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : This is invokable method which is used to set Household name based on the child individuals for provided household accounts.
    * @created      : 05/26/2017
    * @param        : list<Id> householdAccIds 
    * @return       : void
    */
    @InvocableMethod(label='Wave6_HouseholdNameUpdateAction')
    public static void HouseholdNameUpdateAction(List<Id> householdAccIds ){
        list<Account> householdsToUpdate = new List<Account>();
        
        list<Account> householdAccounts =     [SELECT ID, Name, ( SELECT ID, AccountId, ContactId, Contact.FirstName, Contact.LastName, Roles, FinServ__PrimaryGroup__c, FinServ__Primary__c 
                                                                  FROM AccountContactRelations 
                                                                  WHERE Roles INCLUDES ('Client','Spouse','Domestic Partner')
                                                                 )
                                               FROM Account 
                                               WHERE ID IN :householdAccIds];
       system.debug('householdAccounts:>>'+householdAccounts);
        
       for(Account hhAcc : householdAccounts){
           if(!hhAcc.AccountContactRelations.isEmpty()){
               hhAcc.Name = calculateHouseholdName(hhAcc.AccountContactRelations);
           }
           system.debug('hhAcc.Name:>>'+hhAcc.Name);
       } 
       update householdAccounts;
    }
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : This method is used to evaluate Household name based on the child individuals for provided household accounts.
    * @created      : 05/26/2017
    * @param        : List<AccountContactRelation> acrList 
    * @return       : void
    */
    public static String calculateHouseholdName(List<AccountContactRelation> acrList){
        
        string householdName='';
        if(acrList.size() == 1){
            AccountContactRelation acr = acrList[0];
            if(acr.Contact.FirstName != null){
                householdName = acr.Contact.FirstName+' ';
            }
            householdName += acr.Contact.LastName +' Household';  
        }else if(acrList.size() > 1){
            Boolean isSameLastName = false;
            AccountContactRelation primaryACR = new AccountContactRelation();
            List<AccountContactRelation> otherACRList = new List<AccountContactRelation>();
            
            set<String> lastNames = new set<String>();
            for(AccountContactRelation acr : acrList){
                lastNames.add(acr.Contact.LastName);
                if(acr.FinServ__Primary__c){
                   primaryACR = acr;
                }else{
                   otherACRList.add(acr); 
                }
            }
            system.debug('lastNames:>>'+lastNames);
            system.debug('primaryACR:>>'+primaryACR);
            system.debug('otherACRList:>>'+otherACRList);
            
            if(lastNames.size() == 1){
                isSameLastName = true;    
            }
            if(isSameLastName){
                if(primaryACR.Contact.FirstName != null){
                    householdName = primaryACR.Contact.FirstName;
                }
                for(AccountContactRelation acr : otherACRList){
                    if(acr.Contact.FirstName != null){
                        if(householdName != ''){
                            householdName += ' and '  ;  
                        }
                        householdName += acr.Contact.FirstName;   
                    }
                }
                householdName += ' '+ primaryACR.Contact.LastName+' Household';
            }else{
                if(primaryACR.Contact.FirstName != null){
                     householdName = primaryACR.Contact.FirstName+' ';
                }
                householdName += primaryACR.Contact.LastName;
                
                for(AccountContactRelation acr : otherACRList){
                    householdName += ' and ';
                    if(acr.Contact.FirstName != null){
                        householdName += acr.Contact.FirstName+' ';    
                    }
                    householdName += acr.Contact.LastName;   
                }
                householdName += ' Household';
            }
        }
        system.debug('householdName:>>'+householdName);
        return householdName;
    }
}