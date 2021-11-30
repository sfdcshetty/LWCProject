/******************************************************************************************************************************
* @class name    : Wave6_AutoCreateHouseholdTest
* @description   : This is class provides unit test for Wave6_AutoCreateHousehold & Wave6_LeadTrigger.
* @author        : Ganesh Ekhande
* @date          : 08/11/2017               
*                   
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              08/11/2017             Created.

******************************************************************************************************************************/
@isTest
private class Wave6_AutoCreateHouseholdTest {

    private static testMethod void autoCreateHouseholdTest() {
        
        List<Id> individualIDs = new List<Id>();
        
        // create a Lead
        Lead lead=new Lead(LastName='Doe',FirstName='John',Company='John Doe',Status='New', Phone='1122334455', Email='test@weg.com');
        insert lead;    
        
        Account acc = new Account(Name = 'Test Account', recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId());
        insert acc;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setAccountId(acc.Id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Qualified');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        individualIDs.add(acc.FinServ__IndividualId__c);
        
        Wave6_AutoCreateHousehold.HouseholdCreateAction(individualIDs);
    }
}