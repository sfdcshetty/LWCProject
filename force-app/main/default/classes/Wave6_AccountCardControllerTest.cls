/******************************************************************************************************************************
* @class name    : Wave6_AccountCardControllerTest
* @description   : This class provides unit tests for Wave6_AccountCardController class. 
* 
* @author        : Ganesh Ekhande
* @date          : 05/31/2017               
*                   
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              05/31/2017             Created.
* Ganesh Ekhande              08/01/2017             Updated test class to cover newly added code related to new record types(Trust).
*
******************************************************************************************************************************/
@isTest
private class Wave6_AccountCardControllerTest {
    
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : This method provides unit tests for getAccountDetails method.
    * @created      : 05/31/2017
    */
    private static testMethod void getAccountDetailstest() {
       
        test.startTest();
        String accid;
        List<Account> accList = new List<Account>();
        //Create individual record
        Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        acc.name = 'Test Individual Account 1';       
        accList.add(acc);
        
        //Create partner record
        acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        acc.name = 'Test Partner Account 1';
        accList.add(acc);
        
        //Create household record
        acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        acc.name = 'Test Household Account 1';
        accList.add(acc);
        
        //Create Business record
        acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        acc.name = 'Test Business Account 1';
        accList.add(acc);
        
        //Create Institution record
        acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Institution').getRecordTypeId();
        acc.name = 'Test Institution Account 1';
        accList.add(acc);
        
        //Create Trust record
        acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Trust').getRecordTypeId();
        acc.name = 'Test Trust Account 1';
        accList.add(acc);
        
        insert accList;
        accid = acclist[0].id;
       // String rectype = 'Individual';
        
        // get details of all the created accounts.
        list <Wave6_AccountCardController.AccountFieldWrapper> accWrap = Wave6_AccountCardController.getFieldsToQuery('Individual'); 
        system.assert(accWrap != null);
        
        accWrap = Wave6_AccountCardController.getFieldsToQuery('Partner');
        system.assert(accWrap != null);
        
        accWrap = Wave6_AccountCardController.getFieldsToQuery('Household');
        system.assert(accWrap != null);
        
        accWrap = Wave6_AccountCardController.getFieldsToQuery('Business');
        system.assert(accWrap != null);
        
        accWrap = Wave6_AccountCardController.getFieldsToQuery('Institution');
        system.assert(accWrap != null);
        
        accWrap = Wave6_AccountCardController.getFieldsToQuery('Trust');
        system.assert(accWrap != null);
        
        Wave6_AccountCardController.IndividualHouseHolds accWrap2 = Wave6_AccountCardController.getIndividualRecordsDetails(accid,'Individual');
        Wave6_AccountCardController.AccountFieldWrapper afr = new Wave6_AccountCardController.AccountFieldWrapper();
        Wave6_AccountCardController.IndividualHouseHolds afr2 = new Wave6_AccountCardController.IndividualHouseHolds();
        Wave6_AccountCardController.PortalUserDetails (acc.Id, acc.Id);
        
        test.stopTest();
    }
}