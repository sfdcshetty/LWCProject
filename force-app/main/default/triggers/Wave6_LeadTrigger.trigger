/******************************************************************************************************************************
* @class name    : Wave6_LeadTrigger 
* @description   : This is trigger is used to update WEGP1_Is_Converted__c  field on individual accounts.
* @author        : Ganesh Ekhande
* @date          : 08/11/2017               
*                   
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              08/11/2017             Created.

******************************************************************************************************************************/
trigger Wave6_LeadTrigger on Lead (after update) {

    list<string> convertedAccIds = new list<String>();
    for(Lead lead:System.Trigger.new){
        if (lead.IsConverted){
            convertedAccIds.add(lead.ConvertedAccountId);
        }
    }
    system.debug('convertedAccIds:>>'+convertedAccIds);
    
    Id indRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
    Map<Id, Account> indAccountMap = new Map<Id, Account>([Select Id, Name, RecordTypeId,WEGP1_Is_Converted__c,WEGP1_Region__c, WEGP1_Office__c
                                                           From Account  
                                                           Where Id IN:convertedAccIds AND RecordTypeId =:indRecordTypeId
                                                               ]);
                                                               
    system.debug('indAccountMap:>>'+indAccountMap);                                                            
    
    for(Account acc: indAccountMap.Values()){
        acc.WEGP1_Is_Converted__c = true;
    }
    
    try{
        update indAccountMap.Values();
    }catch(exception ex){
        system.debug('Error Occurred while updating Accounts.');
    }
    
}