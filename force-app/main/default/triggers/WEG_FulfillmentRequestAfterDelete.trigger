trigger WEG_FulfillmentRequestAfterDelete on Fulfillment_Request__c (after delete) {
    WEG_FulfillmentRequestTriggerHandler handler = new WEG_FulfillmentRequestTriggerHandler();
    handler.afterDelete();
}