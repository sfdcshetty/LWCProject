/******************************************************************************************************************************
* @class name    : Wave6_WEGAccountSharingUpdate
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
global class Wave6_WEGAccountSharingUpdate implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Execute Batch class with batch size = 1
        Wave6_WEGAccountSharingBatch editModeBatch = new Wave6_WEGAccountSharingBatch(false);
        database.executebatch(editModeBatch,1);
   }
}