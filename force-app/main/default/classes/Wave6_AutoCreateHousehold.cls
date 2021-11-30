/******************************************************************************************************************************
* @class name    : Wave6_AutoCreateHousehold
* @description   : This is class contains invokable method which is used to create household automatically when Individual account is created from lead conversion.
*                  ASSUMPTION: Lead will always be converted into new account and not existing account.    
* @test class    : Wave6_AutoCreateHouseholdTest
* @author        : Ganesh Ekhande
* @date          : 08/11/2017               
*                   
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              08/11/2017             Created.
* Ganesh Ekhande              09/28/2017             OIL # 397 : Added mapping for below 3 new fields.
* Ganesh Ekhande              09/29/2017             OIL # 397 : Added code to map Individual Account owner to Household Account owner.
* Troy Solland                05/09/2018             Marketing Cloud Implementation: Pulling Type and Region fields from Account rather than Contact, mapping new Sales Office lookup
******************************************************************************************************************************/
public class Wave6_AutoCreateHousehold {
    
    @InvocableMethod(label='Wave6_AutoCreateHouseholdAction')
    public static void HouseholdCreateAction(List<Id> individualIds) {
        system.debug('>>>>>>>>>> In Wave6_AutoCreateHouseholdAction');
        
        list<Account> indAccountList = new list<Account>();
        indAccountList =[Select Id, Name, OwnerId, WEGP1_SalesOffice__c, WEGP1_Region__c
                        , WEGP1_Lead_Type__c, WEGP1_Lead_SubType__c, WEGP1_Lead_Type_Detail__c, WEG_ReferredBy__c
                        , (Select Id From Contacts)
                        FROM Account WHERE Id IN: individualIds];
        
        map<string, Contact> indAccIdToConMap = new map<string, Contact>();
        for(Account acc: indAccountList) {
            if(!acc.Contacts.isEmpty()) {
                indAccIdToConMap.put(acc.Id, acc.Contacts[0]);
            }
        }
        system.debug('>>>>>>>>>> indAccIdToConMap: '+indAccIdToConMap);
        
        map<Id,Account> indIdTohhAccMap = new Map<Id,Account>();
        list<Account> hhAccList = new list<Account>();
        
        // Create Household Account
        for(Account acc : indAccountList) {
            if(indAccIdToConMap.containsKey(acc.Id)) {
                Account hhAcc = new Account();
                hhAcc.Name = acc.Name +' Household';
                hhAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
                hhAcc.WEGP1_SalesOffice__c = acc.WEGP1_SalesOffice__c;
                hhAcc.WEGP1_Region__c = acc.WEGP1_Region__c;
                hhAcc.WEGP1_Lead_Type__c = acc.WEGP1_Lead_Type__c;
                hhAcc.WEGP1_Lead_SubType__c = acc.WEGP1_Lead_SubType__c;
                hhAcc.WEGP1_Lead_Type_Detail__c = acc.WEGP1_Lead_Type_Detail__c;
                hhAcc.WEG_ReferredBy__c = acc.WEG_ReferredBy__c;
                hhAcc.OwnerId = acc.OwnerId;
                
                indIdTohhAccMap.put(acc.Id,hhAcc);
                
                system.debug('>>>>>>>>>> Contact Id: '+ indAccIdToConMap.get(acc.Id).Id);
                system.debug('>>>>>>>>>> : Lead Type: '+ acc.WEGP1_Lead_Type__c + ' && Referred By: ' + acc.WEG_ReferredBy__c);
            }
        }
        
        system.debug('>>>>>>>>>> indIdTohhAccMap: '+ indIdTohhAccMap);
        
        if(!indIdTohhAccMap.values().isEmpty()) {
            try { insert indIdTohhAccMap.values(); } catch(Exception ex) { system.debug('>>>>>>>>>> Error creating HH :: ' + ex.getMessage()); }
        }
        
        system.debug('>>>>>>>>>> indIdTohhAccMap: '+ indIdTohhAccMap);
        
        // Create Account Contact Relationship record
        list<AccountContactRelation> acrList = new list<AccountContactRelation>();
        for(Account acc : indAccountList) {
            if(indAccIdToConMap.containsKey(acc.Id)) {
                AccountContactRelation acr = new AccountContactRelation();
                acr.contactId = indAccIdToConMap.get(acc.Id).Id;
                acr.AccountId = indIdTohhAccMap.get(acc.Id).Id;
                acr.Roles = 'Client';
                acr.FinServ__Primary__c = true;
                acr.FinServ__PrimaryGroup__c = true;
                acrList.add(acr);
                
                system.debug('>>>>>>>>>> acr: ' + acr);
            }
        }
        
        system.debug('>>>>>>>>>> acrList: '+acrList);
        
        if(!acrList.isEmpty()) {
            insert acrList;
        } 
    }
}