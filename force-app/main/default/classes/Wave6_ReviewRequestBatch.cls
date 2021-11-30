/******************************************************************************************************************************
* @class name    : Wave6_ReviewRequestBatch
* @description   : This Class Implements Database.Batchable interface to create Plan Review Request record for each individual acccount for the current month if not created already.
* @steps to run batch : 1) Open Developer Console
*                       2) Press Ctrl+E
*                       3) Enter following apex code
*                            Wave6_ReviewRequestBatch batchCls =new Wave6_ReviewRequestBatch();
*                            database.executeBatch(batchCls);
*                       4) Click Execute
*                       5) We can track batch processing job at Setup-->Jobs -->Apex Jobs
*
* @test class    : Wave6_ReviewRequestBatchTest
* @author        : Ganesh Ekhande
* @date          : 05/12/2017
*
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              05/12/2017             Created.
* Ganesh Ekhande              05/22/2017             Added logic to identify and populate primary individual account on Plan Review Request for household account being processed.
* Santosh Rahane              10/16/2017             Added a logic to prepone the batch execution and create Plan and Review Request for next month.
******************************************************************************************************************************/
global class Wave6_ReviewRequestBatch implements Database.Batchable<sObject> {

    /*
    * @author       : Ganesh Ekhande
    * @description  : This is Start method of Database.Batchable interfcae which fetches all Individual Accounts Which needs review this Month.
    * @created      : 05/12/2017
    * @param        : Database.BatchableContext BC
    * @return       : Database.QueryLocator
    */
    global Database.QueryLocator start(Database.BatchableContext BC){
        // Get current Month Name
        DateTime d = datetime.now();
        String nextMonthName= d.addMonths(1).format('MMMMM');
        
        // Fetch Household Account Record Type Id
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        
        // Form a query to fetch Household Accounts Which Needs review this Month.
        String qry ='SELECT Id, Name, WEGP1_Review_Months__c, OwnerId, Owner.Support_Team_Queue_ID__c, FinServ__IndividualId__c' +
                    ' FROM Account' +
                    ' WHERE RecordTypeId = :householdRecordTypeId AND FinServ__Status__c = \'Active\' AND WEGP1_Review_Months__c INCLUDES (\''+nextMonthName + '\')';
        system.debug('qry:>>'+qry);
        return Database.getQueryLocator(qry);
    }

    /*
    * @author       : Ganesh Ekhande
    * @description  : This is Execute method of Database.Batchable interfcae which create Plan Review Request record for each individual acccount for the current month if not created already.
    * @created      : 05/12/2017
    * @param        : Database.BatchableContext BC,List<Account> accList
    * @return       : void
    */
    global void execute(Database.BatchableContext BC, List<Account> accList){
        try{            
            // Create Set of Household Account Id
            // as well as a Mapping of Account Id to Name
            Set<String> accIdSet = new Set<String>();
            Map<String, String> householdNameMap = new Map<String, String>();
            for(Account acc : accList){
                accIdSet.add(acc.Id);
                householdNameMap.put(acc.Id, acc.Name);
            }

            // Create Map of Household account Id and Primary individual contact Id
            Map<String,String> householdIdIndividualContIdMap = new Map<String,String>();
            for(AccountContactRelation acr : [SELECT Id
                                              , AccountId
                                              , ContactId
                                              , Contact.AccountId //this is the Individual Account ID
                                              , FinServ__Primary__c
                                              FROM  AccountContactRelation
                                              WHERE AccountId IN:accIdSet
                                              AND FinServ__Primary__c = true]){

                householdIdIndividualContIdMap.put(acr.AccountId,acr.Contact.AccountId);
            }
            
            // only grab plan & review requests of type Review
            Id reviewTypeId= Schema.SObjectType.Plan_Review_Request__c.getRecordTypeInfosByName().get('Review').getRecordTypeId();

            // Fetch Plan & Review Request records for all above records for current month
            Set<Id> accWithPRR = new Set<Id>();
            for(Plan_Review_Request__c prr :  [SELECT Id, WEGP1_RequestedDate__c, WEGP1_Household__c
                                               FROM Plan_Review_Request__c
                                               WHERE WEGP1_Household__c IN :accIdSet
                                               AND RecordTypeId = :reviewTypeId
                                               AND  CreatedDate = LAST_90_DAYS 
                                               AND WEGP1_Status__c NOT IN('Closed - No Response','Closed - Declined','Closed - Completed')]){
                accWithPRR.add(prr.WEGP1_Household__c);
            }
            
            // get next month info
            DateTime nextMonth = datetime.now().addMonths(1);
            string nextMonthName = nextMonth.format('MMMMM');
            system.debug('>>>>>>>> nextMonthName: ' + nextMonthName);
            string nextMonthYear = nextMonth.format('Y');
            system.debug('>>>>>>>> nextMonthYear: ' + nextMonthYear);
            
            // Create Plan Review Request record for each acccount for the current month if not created already
            List<Plan_Review_Request__c> newPRRList = new List<Plan_Review_Request__c>();
            for(Account acc : accList){
                if(!accWithPRR.contains(acc.Id)){
                    Plan_Review_Request__c prRequest = new Plan_Review_Request__c();
                    prRequest.WEGP1_Household__c = acc.Id;
                    //set the Name of the request - based on HH Name & Review Month
                    String householdName = householdNameMap.get(acc.ID);
                    prRequest.Name = householdName + ' - Review - ' + nextMonthName + ' - ' + nextMonthYear;
                    //set the individual to the primary for the household
                    String individualAccountId = householdIdIndividualContIdMap.get(acc.ID);
                    prRequest.WEGP1_Individual__c = individualAccountId;
                    if(!Test.isRunningTest()){
                        prRequest.OwnerId = (acc.Owner.Support_Team_Queue_ID__c != null) ? acc.Owner.Support_Team_Queue_ID__c : acc.OwnerId; //assign to advisor queue if exists/configured
                    }
                    prRequest.recordTypeId = Schema.SObjectType.Plan_Review_Request__c.getRecordTypeInfosByName().get('Review').getRecordTypeId();
                    prRequest.WEGP1_Status__c = 'New';
                    prRequest.WEGP1_RequestedDate__c = SYSTEM.TODAY();
                    newPRRList.add(prRequest);
                }
            }
            
            //insert newPRRList;
            Database.SaveResult[] srList = Database.insert(newPRRList,false);
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted PRR. PRR ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        catch(exception ex){
            system.debug('Error occurred while processing Review Requests.');
        }
    }

    /*
    * @author       : Ganesh Ekhande
    * @description  : This is Finish method of Database.Batchable interfcae.
    * @created      : 05/12/2017
    * @param        : Database.BatchableContext BC
    * @return       : void
    */
    global void finish(Database.BatchableContext BC){
    }
}