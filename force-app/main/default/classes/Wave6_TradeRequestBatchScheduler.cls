/******************************************************************************************************************************
* @class name    : Wave6_TradeRequestBatchScheduler 
* @description   : This scheduler class Wave6_TradeRequestBatch class. 
*                  
* @test class    : Wave6_TradeRequestBatchTest
* @author        : Ganesh Ekhande
* @date          : 09/19/2017               
*                   
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              09/19/2017             Created.
*
******************************************************************************************************************************/
global class Wave6_TradeRequestBatchScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Execute Batch class 
        Wave6_TradeRequestBatch batch = new Wave6_TradeRequestBatch();
        database.executebatch(batch);
   }
}