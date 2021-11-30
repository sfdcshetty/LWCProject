/******************************************************************************************************************************
* @class name    : Wave6_ReviewRequestBatchTest
* @description   : This class provides unit tests for Wave6_ReviewRequestBatch class.
* @author        : Ganesh Ekhande
* @date          : 05/24/2017
*
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              05/24/2017             Created.
* Santosh Rahane              10/16/2017             Added a logic to prepone the batch execution and create Plan and Review Request for next month.
*
******************************************************************************************************************************/
@isTest
private class Wave6_ReviewRequestBatchTest {

    /*
    * @author       : Ganesh Ekhande
    * @description  : This method is used to create test data for this test class.
    * @created      : 05/24/2017
    */
    @testSetup
    private static void setupTestData() {
        // Fetch Household Account Record Type Id
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Id individualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();

        // Create test household account record
        Account hhAcc = new Account();
        DateTime d = datetime.now();
        String nextMonthName = d.addMonths(1).format('MMMMM');
        hhAcc.Name = 'Test Account';
        hhAcc.WEGP1_Review_Months__c = nextMonthName;
        hhAcc.RecordTypeId = householdRecordTypeId;
        hhAcc.FinServ__Status__c = 'Active';
        insert hhAcc;

        system.debug('hhAcc:>>'+hhAcc);

        // Create test individual account
        Account indAcc = new Account();
        indAcc.Name = 'Individual Account';
        indAcc.RecordTypeId = individualRecordTypeId;
        insert indAcc;

        system.debug('indAcc:>>'+indAcc);

        // Create Test individual contact record
        // Fetch individual contact Record Type Id
        Id indConRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        Contact con = new Contact();
        con.RecordTypeId = indConRecordTypeId;
        con.FirstName = 'Test First Name';
        con.LastName = 'Test Last Name';
        con.AccountId = indAcc.Id;
        insert con;

        // Create AccountContactRelation
        AccountContactRelation acr = new AccountContactRelation();
        acr.AccountId = hhAcc.Id;
        acr.ContactId = con.Id;
        acr.FinServ__Primary__c = true;
        insert acr;

        system.debug('contact:>>'+[Select Id, FirstName From Contact]);
        system.debug('AccountContactRelation:>>'+[Select Id From AccountContactRelation]);

    }

    /*
    * @author       : Ganesh Ekhande
    * @description  : This method provides unit tests for batch class when Plan & Review request is not created already for current month.
    * @created      : 05/24/2017
    */
    public static testMethod void testReviewRequestBatch1(){
        Test.startTest();
        Wave6_ReviewRequestBatch batchCls =new Wave6_ReviewRequestBatch();
        database.executeBatch(batchCls);
        Test.stopTest();

        List<Plan_Review_Request__c> allRequests = [SELECT ID FROM Plan_Review_Request__c];
        System.assertEquals(1, allRequests.size()); //created one request

    }

    /*
    * @author       : Ganesh Ekhande
    * @description  : This method provides unit tests for batch class when Plan & Review request is created already for current month.
    * @created      : 05/24/2017
    */
    public static testMethod void testReviewRequestBatch2(){

        Account hhAcc = [Select Id, OwnerId From Account Where RecordTypeId =:Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId()];
        Account indAcc = [Select Id, OwnerId From Account Where RecordTypeId =:Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId()];
        
        // get the "Review" record type
        Id reviewTypeId = Schema.SObjectType.Plan_Review_Request__c.getRecordTypeInfosByName().get('Review').getRecordTypeId();

        // Create Plan & Review Request record
        Plan_Review_Request__c prRequest = new Plan_Review_Request__c();
        prRequest.WEGP1_Household__c = hhAcc.Id;
        prRequest.WEGP1_Individual__c = indAcc.Id;
        prRequest.OwnerId = hhAcc.OwnerId;
        prRequest.WEGP1_Status__c = 'New';
        prRequest.WEGP1_RequestedDate__c = SYSTEM.TODAY();
        prRequest.RecordTypeId = reviewTypeId;
        insert prRequest;
        
        // Set created date in 1 month Past
        Test.setCreatedDate(prRequest.Id, system.now().addMonths(-1));
        
        Test.startTest();
        
        Wave6_ReviewRequestBatch batchCls =new Wave6_ReviewRequestBatch();
        database.executeBatch(batchCls);
        Test.stopTest();

        List<Plan_Review_Request__c> allRequests = [SELECT ID FROM Plan_Review_Request__c];
        System.assertEquals(1, allRequests.size()); //didn't create another request
    }

     private static testmethod void  Wave6_ReviewRequestBatchSchedulerTest(){
        Test.startTest();
        Wave6_ReviewRequestBatchScheduler sh1 = new Wave6_ReviewRequestBatchScheduler();
        String sch = '0  00 1 3 * ?';
        system.schedule('Test', sch, sh1);
        Test.stopTest();
    }

}