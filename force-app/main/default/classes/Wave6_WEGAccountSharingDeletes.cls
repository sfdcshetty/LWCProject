/******************************************************************************************************************************
* @class name    : Wave6_WEGAccountSharingDeletes
* @description   : This scheduler class Wave6_WEGAccountSharingBatch class. 
*                  
* @test class    : Wave6_WEGAccountSharingTest
* @author        : Ganesh Ekhande
* @date          : 07/07/2017               
*                   
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              07/07/2017             Created.
*
******************************************************************************************************************************/
global class Wave6_WEGAccountSharingDeletes implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Execute Batch class with batch size = 1
        Wave6_WEGAccountSharingBatch deleteModeBatch = new Wave6_WEGAccountSharingBatch(true);
        database.executebatch(deleteModeBatch, 1);
   }
}