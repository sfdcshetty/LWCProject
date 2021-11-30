/******************************************************************************************************************************
* @class name    : wv6_LightningDataTableControllerTest
* @description   : Contains test methods for class wv6_LightningDataTableController
* @test class    : 
* @author        : Rohan Lokhande (Wave6)
* @date          : 04/27/2018
*
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Rohan Lokhande (Wave6)      04/27/2018             Created.
*
******************************************************************************************************************************/
@isTest
private class wv6_LightningDataTableControllerTest{
    private static testMethod void test() {
        
        Account hhAcc = new Account(Name='HH Account1', recordTypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('Household').getRecordTypeId(), WEGP1_AccountTeamIds__c='HHDummyValue');
        insert hhAcc;
        Account indAcc= new Account(Name='Ind Account1', WEGP1_Primary_Household__c=hhAcc.Id, recordTypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('Individual').getRecordTypeId(),WEGP1_AccountTeamIds__c='IndDummyValue');
        insert indAcc;
        FinServ__FinancialAccount__c fAccount = new FinServ__FinancialAccount__c();
        fAccount.FinServ__Status__c = 'Open';
        fAccount.FinServ__Balance__c = 1234;
        fAccount.FinServ__PrimaryOwner__c = indAcc.id;
        fAccount.FinServ__Managed__c = true;
        fAccount.FinServ__FinancialAccountNumber__c = '12312311';
        fAccount.Updated_by_Tamarac_Integration__c = true;
        insert fAccount;
        
        
        wv6_LightningTableWrapper wrap = wv6_LightningDataTableController.getRecords('FinServ__FinancialAccount__c', 
                                                    ' WEGP1_Held_Status__c = \'WEG Held\' AND FinServ__Status__c = \'Open\' AND FinServ__Balance__c != 0',
                                                    'WEGP1_Owner_Type__c ASC, FinServ__Balance__c DESC', 
                                                    'WEG Client Portal', '');
        System.assert(wrap!=NULL);
    }

}