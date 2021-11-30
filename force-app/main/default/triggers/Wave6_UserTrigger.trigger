trigger Wave6_UserTrigger on User (before insert, before update) {
    
    Set<String> queueNames = new Set<String>();
    for (User usr : Trigger.NEW) {
        
        // set the tamarac sso username = email
        if (Trigger.isBefore && Trigger.isInsert)
            usr.WEG_TamaracSsoUsername__c = usr.Email;
        
        if (usr.Support_Team__c != null) {
            queueNames.add(usr.Support_Team__c);
        }
    }
    
    if (queueNames.size() > 0) {
        List<Group> queues = [SELECT ID, Name FROM Group WHERE Name IN :queueNames AND Type='Queue'];
        
        if (queues.size() > 0) {
            Map<String, String> queueMap = new Map<String, String>();
            for (Group que : queues) {
                queueMap.put(que.Name, que.ID);
            }
            for (User usr : Trigger.NEW) {
                if (usr.Support_Team__c != null) {
                    String queId = queueMap.get(usr.Support_Team__c);
                    usr.Support_Team_Queue_ID__c = queId;
                } else {
                    usr.Support_Team_Queue_ID__c = null;
                }
            }
            
        }
    }
    try{
    // Update parent Account for portal users
    if(trigger.isBefore && trigger.isUpdate){
        Wave6_UserTriggerHelper.updateParentAccount(trigger.new,trigger.oldMap );
    }
    }catch(exception ex){
        system.debug('Exception thrown while updating Portal User Status on Account.');
    }
    
}