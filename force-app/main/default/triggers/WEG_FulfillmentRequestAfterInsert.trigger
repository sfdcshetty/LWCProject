trigger WEG_FulfillmentRequestAfterInsert on Fulfillment_Request__c (after insert) {
    WEG_FulfillmentRequestTriggerHandler handler = new WEG_FulfillmentRequestTriggerHandler();
    handler.afterInsert();
}