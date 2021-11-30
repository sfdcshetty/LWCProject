/******************************************************************************************************************************
 * Class Name    : wv6_ChartControllerTest 
 * Description   : Contains test methods for ChartController class. 
 * Test class    : N/A
 * Author        : Rohan Lokhande
 * 
 * Modification Log :
 * -----------------------------------------------------------------------------------------------------------------
 * Developer                 Date(MM/DD/YYYY)       Description
 * -----------------------------------------------------------------------------------------------------------------
 * Rohan Lokhande            03/22/2018            Created
******************************************************************************************************************************/

@isTest(seeAllData = false)
private class wv6_ChartControllerTest {
    @testSetup static void setupData() {
        Account acc = new Account();
        acc.name = 'Test Name';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        insert acc;
        
        FinServ__FinancialAccount__c FA= new FinServ__FinancialAccount__c();
        FA.FinServ__PrimaryOwner__c = acc.ID;
        FA.WEG_Registration_Type__c = '401(k)';
        FA.Name = 'Test FA Account';
        insert FA;
    }
    static testMethod void validatePicklistValues() {
        String selectedObject = 'FinServ__FinancialAccount__c';
        String selectedfield = 'WEG_Registration_Type__c';
        List<String> pickValues = ChartController.retrivepicklistvalues(selectedObject, selectedfield);
        System.assert(pickValues.size() > 0, 'Picklist does not have values');
        
        List<ChartController.wrapperclass> listWrap = ChartController.generateDataa(selectedObject, selectedfield);
        //System.assert(listWrap.size()>0,'Does not have data to show on chart');
        ChartController.getBrandColors();
    }
}