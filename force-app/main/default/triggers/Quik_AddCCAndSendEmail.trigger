/*
Test class - QuikFormHandler_TEST
*/
trigger Quik_AddCCAndSendEmail on AS_Quik_Forms_Group__c (after update) {
                     
    Set<Id> asformGroupIds = new Set<Id>();  
    Set<Id> sendNotiASFGroupIds = new Set<Id>();                                               
    for(AS_Quik_Forms_Group__c asFormGrp : Trigger.new) {
        sendNotiASFGroupIds.add(asFormGrp.Id); 
        AS_Quik_Forms_Group__c oldRec = Trigger.oldMap.get(asFormGrp.Id);
        if(asFormGrp.DocuSign_Envelope_Status__c == 'Ready to Send' && oldRec.DocuSign_Envelope_Status__c != 'Ready to Send') {
            asformGroupIds.add(asFormGrp.Id);
        }
    }
    if(asformGroupIds.size() > 0) {
        Quik_SignUrl.callAddccAddresses(asformGroupIds);
    }   
    
    // To Send Chatter Notifications to respective people based on conditions
    Quik_SendChatterNotification.sendNotification(sendNotiASFGroupIds);
}