/******************************************************************************************************************************
* @class name    : Wave6_TradeRequestBatch 
* @description   : This batch class is used to create clone of the trade requests.
* @steps to run batch : 1) Open Developer Console 
*                       2) Press Ctrl+E 
*                       3) Enter following apex code
*                            Wave6_TradeRequestBatch batchCls =new Wave6_TradeRequestBatch();
*                            database.executeBatch(batchCls); 
*                       4) Click Execute
*                       5) We can track batch processing job at Setup-->Jobs -->Apex Jobs
*                          
* @test class    : Wave6_TradeRequestBatchTest
* @author        : Ganesh Ekhande
* @date          : 05/15/2017               
*                   
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Wave6                       05/15/2017             Created.
*
******************************************************************************************************************************/
global class Wave6_TradeRequestBatch implements Database.Batchable<sObject> {
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : This is Start method of Database.Batchable interfcae.
    * @created      : 05/15/2017
    * @param        : Database.BatchableContext BC 
    * @return       : Database.QueryLocator
    */
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        // Form a query to fetch Individual Accounts Which Needs review this Month. 
        String qry ='';
        String closedStatus = 'Closed';
        String recordTypeName = 'DCA_Trade_Ticket_Parent';
        qry = Wave6_ProcessTradeRequest.baseQuery + 'WHERE Status__c != :closedStatus  AND (WEGP1_NextTradeDate__c = null OR WEGP1_NextTradeDate__c <= TODAY) AND RecordType.DeveloperName= :recordTypeName';
        System.debug('qry:>>'+qry);
        return Database.getQueryLocator(qry);
    }
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : This is Execute method of Database.Batchable interface to create clone copies of Trade request.
    * @created      : 05/15/2017
    * @param        : Database.BatchableContext BC,List<Account> accList 
    * @return       : void
    */
    global void execute(Database.BatchableContext BC, List<Trade_Request__c> tradeReqList){
        Wave6_ProcessTradeRequest.createTradeRequests(tradeReqList);
    }
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : This is Finish method of Database.Batchable interfcae. 
    * @created      : 05/15/2017
    * @param        : Database.BatchableContext BC 
    * @return       : void
    */
    global void finish(Database.BatchableContext BC){
    }
}