trigger UpdateDocumentDeliveryStatus on TVA_CO__Email_Message__c (after insert, after update) {
    Set<Id> cloudFileIdsSet = new Set<Id>();
    List<WEG_Document_Delivery__c> ddRecordsToUpdate = new List<WEG_Document_Delivery__c>();
    for (TVA_CO__Email_Message__c eachRecord : Trigger.NEW) {
        if(eachRecord.Cloud_Files__c != NULL && eachRecord.TVA_CO__Bounced__c) {
            cloudFileIdsSet.add(eachRecord.Cloud_Files__c);
        }
    }
    if(cloudFileIdsSet.size() > 0) {
        for(WEG_Document_Delivery__c documentDelivery : [SELECT WEG_Status__c, WEG_Document__c
                                                         FROM WEG_Document_Delivery__c 
                                                         WHERE WEG_Document__c in: cloudFileIdsSet]) {
            if(documentDelivery.WEG_Status__c != 'Bounced') {
                documentDelivery.WEG_Status__c = 'Bounced';
                ddRecordsToUpdate.add(documentDelivery);
            }
               
        }
    }
    if(ddRecordsToUpdate.size() > 0) {
        update ddRecordsToUpdate;
    }
        
}