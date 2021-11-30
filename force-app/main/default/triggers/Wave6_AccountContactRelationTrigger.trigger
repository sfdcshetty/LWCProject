/******************************************************************************************************************************
* @class name    : Wave6_AccountContactRelationTrigger
* @description   : This trigger contains logic to identify primary household for individual accounts.    
* @test class    : Wave6_AccountContactRelationTriggerTest
* @author        : Troy Solland
* @date          : 03/15/2019
*                   
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              05/18/2017             Created.
* Ganesh Ekhande              12/22/2017             Added code to populate Primary & Secondary Contact on Household Account.
* Troy Solland				  03/15/2019			 Re-worked the trigger to utilize a new handler. Removed logic from trigger.
******************************************************************************************************************************/
trigger Wave6_AccountContactRelationTrigger on AccountContactRelation (after insert, after update, after delete){    
    // create the trigger handler
    WEG_AccountContactRelationTriggerHandler handler = new WEG_AccountContactRelationTriggerHandler();
    
    // execute the appropriate handler method, depending on the trigger
    if(trigger.isInsert)
        handler.afterInsert(trigger.New);
    else if(trigger.isUpdate)
        handler.afterUpdate(trigger.New, trigger.OldMap);
    else
        handler.afterDelete(trigger.Old);
}