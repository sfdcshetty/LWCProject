/******************************************************************************************************************************
* @class name    : Wave6_ReviewRequestBatchScheduler 
* @description   : This scheduler class Wave6_ReviewRequestBatch class. 
*                  
* @test class    : Wave6_ReviewRequestBatchTest
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
global class Wave6_ReviewRequestBatchScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Execute Batch class with batch size 10
        Wave6_ReviewRequestBatch batch = new Wave6_ReviewRequestBatch();
        database.executebatch(batch,10);
   }
}