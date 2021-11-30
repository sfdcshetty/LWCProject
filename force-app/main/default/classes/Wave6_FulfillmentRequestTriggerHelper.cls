/******************************************************************************************************************************
* @class name    : Wave6_FulfillmentRequestTriggerHelper
* @description   : This class is a helper class for trigger Wave6_FulfillmentRequestTrigger which is used for counting the total open
*                  Fulfillment records under perticular Lead record.
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
public class Wave6_FulfillmentRequestTriggerHelper{


    public static void updatedFulFillmentRequestCount(set<Id> leadIds){
        List<Lead> leadsToUpdate = new List<Lead>();
        try{
            // get a map of the Leads with the number of Open Fulfillments
            map<Id,Lead> leadMap = new map<Id,Lead>([select Id, WEGP1_No_of_Open_Fulfillments__c from Lead where id IN :leadIds]);
            system.debug('leadMap:>>'+leadMap);

            // query the Leads and the related Fulfillment Request and add the size of the Open Fulfillment Request  to the Lead's WEGP1_No_of_Open_Fulfillments__c
            for (Lead ld : [Select Id, Name, WEGP1_No_of_Open_Fulfillments__c,(Select id from Fulfillment_Requests__r Where WEGP1_Status__c = 'Open') From Lead Where Id IN :leadIds]) {
                leadMap.get(ld.Id).WEGP1_No_of_Open_Fulfillments__c = ld.Fulfillment_Requests__r.size();

                // add the value/Lead in the map to a list so we can update it
                leadsToUpdate.add(leadMap.get(ld.Id));
            }
            system.debug('leadsToUpdate:>>'+leadsToUpdate);

            update leadsToUpdate;

        }catch(exception ex){
            system.debug('Error occurred while updating Leads : '+ ex.getMessage());
        }
    }
}