/******************************************************************************************************************************
* @name          : Wave6_FulfillmentRequestTrigger
* @description   : Trigger for Fulfillment_Request__c object
* @test class    : Wave6_FulfillmentRequestTriggerTest
* @author        : Ganesh Ekhande
* @date          : 27/09/2017
*
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              27/09/2017             Created.
******************************************************************************************************************************/
trigger Wave6_FulfillmentRequestTrigger on Fulfillment_Request__c (after delete, after insert, after update) {

    // Collect Lead Ids which needs Number of Open Fulfillment Request re-calculation
    set<Id> leadIds = new set<Id>();
    if (Trigger.isUpdate || Trigger.isInsert) {
        for (Fulfillment_Request__c fr : Trigger.new){
            if(fr.WEGP1_Status__c == 'Open'){
                leadIds.add(fr.WEGP1_Lead__c);
            }
        }
    }
    system.debug('leadIds1:>>'+leadIds);
    if (Trigger.isUpdate || Trigger.isDelete) {
        for (Fulfillment_Request__c fr : Trigger.old){
            if(fr.WEGP1_Status__c == 'Open'){
                leadIds.add(fr.WEGP1_Lead__c);
            }
        }
    }
    system.debug('leadIds2:>>'+leadIds);

    if(!leadIds.isEmpty()){
        Wave6_FulfillmentRequestTriggerHelper.updatedFulFillmentRequestCount(leadIds);
    }
}