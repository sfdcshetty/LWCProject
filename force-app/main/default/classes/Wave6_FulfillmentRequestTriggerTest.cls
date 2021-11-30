/******************************************************************************************************************************
* @class name    : Wave6_FulfillmentRequestTriggerTest
* @description   : This class is test class for Wave6_FulfillmentRequestTrigger.
* @author        : Ganesh Ekhande
* @date          : 27/09/2017
*
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              27/09/2017             Created.
******************************************************************************************************************************/
@isTest
private class Wave6_FulfillmentRequestTriggerTest {

    private static testMethod void FulfillmentRequestTriggerTest() {

        Lead ld = new Lead();
        ld.FirstName = 'Test WEG';
        ld.LastName = 'Lead';
        ld.Phone = '1122334455';
        ld.Email = 'lead@weg.com';
        ld.Company = 'Test WEG Lead';
        ld.Status = 'New';
        insert ld;

        Fulfillment_Request__c fr = new Fulfillment_Request__c();
        fr.WEGP1_Status__c = 'New';
        fr.WEGP1_Lead__c = ld.Id;
        insert fr;

        Lead leadRecord = [Select Id,WEGP1_No_of_Open_Fulfillments__c From Lead Where Id =: ld.Id];
        system.assertEquals(0,leadRecord.WEGP1_No_of_Open_Fulfillments__c);

        fr.WEGP1_Status__c = 'Open';
        update fr;

        leadRecord = new Lead();
        leadRecord = [Select Id,WEGP1_No_of_Open_Fulfillments__c From Lead Where Id =: ld.Id];
        system.assertEquals(1,leadRecord.WEGP1_No_of_Open_Fulfillments__c);


        fr.WEGP1_Status__c = 'Completed';
        update fr;

        leadRecord = new Lead();
        leadRecord = [Select Id,WEGP1_No_of_Open_Fulfillments__c From Lead Where Id =: ld.Id];
        system.assertEquals(0,leadRecord.WEGP1_No_of_Open_Fulfillments__c);

        fr.WEGP1_Status__c = 'Open';
        update fr;

        leadRecord = new Lead();
        leadRecord = [Select Id,WEGP1_No_of_Open_Fulfillments__c From Lead Where Id =: ld.Id];
        system.assertEquals(1,leadRecord.WEGP1_No_of_Open_Fulfillments__c);

        delete fr;

        leadRecord = new Lead();
        leadRecord = [Select Id,WEGP1_No_of_Open_Fulfillments__c From Lead Where Id =: ld.Id];

        system.assertEquals(0,leadRecord.WEGP1_No_of_Open_Fulfillments__c);
    }

}