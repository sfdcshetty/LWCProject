trigger WEG_FulfillmentRequestAfterUpdate on Fulfillment_Request__c (after update) {
    WEG_FulfillmentRequestTriggerHandler handler = new WEG_FulfillmentRequestTriggerHandler();
    handler.afterUpdate();
}