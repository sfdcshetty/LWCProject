trigger UpdateSecondaryOwner on User (after update) {
    try {
        if(Trigger.isUpdate) {
            Map <ID, ID> userIds = new Map <ID, Id> ();
            Map<Id,User> contactUserMap = New Map<Id,user> ();
            for(User usr : Trigger.New) {
                User old = Trigger.oldMap.get(usr.id);
                if(usr.IsActive != old.IsActive && usr.IsActive) {
                    contactUserMap.put(usr.contactId,usr);
                    userIds.put (usr.id, usr.id);
                }
            }
            Map<ID,ID> conAccMap = new Map<ID,Id> ();
            for(Contact con : [SELECT ID,AccountId FROM Contact WHERE ID IN : contactUserMap.keySet()]){
                conAccMap.put(con.AccountId,con.id);
            }
            Map<ID,ID> docAccMap = New Map<ID,ID> ();
            for(Document__c doc : [SELECT ID,Account__c FROM Document__c WHERE Account__c IN : conAccMap.keySet()]) {
                docAccMap.put(doc.id,doc.Account__c);
            }
            Set <ID> cloudFIlesIds = new Set <ID> ();
            
            List <TVA_CFB__Cloud_Files__c> cloudFilesList = new List <TVA_CFB__Cloud_Files__c> ();
            for(TVA_CFB__Cloud_Files__c cloudFile : [SELECT ID,Portal_Document__c FROM TVA_CFB__Cloud_Files__c WHERE Portal_Document__c IN : docAccMap.keySet()]) {
                cloudFile.Secondary_Portal_User__c = contactUserMap.get (conAccMap.get (docAccMap.get (cloudFile.Portal_Document__c))).Id;
                cloudFilesList.add (cloudFile);
                cloudFIlesIds.add(cloudFile.id);
                
            }
            if(cloudFilesList.size() > 0) {
                Database.update (cloudFilesList, false);
                ComplianceArchivingHelper.documentShare (cloudFIlesIds, userIds, 'Document Share Secondary', '');
            }
            
        }
    } catch (Exception e) {}
}