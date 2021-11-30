public class Docuvault_ComplianceQueueable implements Queueable {

    public List <Id> portalSharableFileIds;
    
    public Docuvault_ComplianceQueueable(List <Id> cloudFileIds) {
        portalSharableFileIds = NEW List <Id> ();
        this.portalSharableFileIds = cloudFileIds;
    }
    public void execute(QueueableContext context) {
        Map <ID, ID> portalUsers = new Map <ID, ID> ();
        Map <ID, ID> secondaryPortalUsers = new Map <ID, ID> ();
        Set <ID> portalFIleIdSet = new Set <ID> ();
        List <ComplianceArchivingHelper.IdListReturned> objList = new List <ComplianceArchivingHelper.IdListReturned> ();
        List <ComplianceArchivingHelper.IdListReturned> objList1 = new List <ComplianceArchivingHelper.IdListReturned> ();
        
        
        for (TVA_CFB__Cloud_Files__c cloudFile: [SELECT Secondary_Portal_User__r.Contact.Account.Portal_User_Status__c, 
                                                 Secondary_Portal_User__c, 
                                                 Primary_Portal_User__c FROM TVA_CFB__Cloud_Files__c 
                                                 WHERE ID IN: portalSharableFileIds]) 
        {
            ComplianceArchivingHelper.IdListReturned obj = new ComplianceArchivingHelper.IdListReturned ();
            obj.returnedObj = 'Cloud File';
            obj.returnIds = cloudFile.ID;
            objList.add (obj);
            
            
            
            
            portalFIleIdSet.add(cloudFile.ID);
            portalUsers.put (cloudFile.ID, cloudFile.Primary_Portal_User__c);
            if (cloudFile.Secondary_Portal_User__c != NULL) {
                if (cloudFile.Secondary_Portal_User__r.Contact.Account.Portal_User_Status__c == 'Active Portal User') {
                    secondaryPortalUsers.put (cloudFile.ID, cloudFile.Secondary_Portal_User__c);
                    
                    ComplianceArchivingHelper.IdListReturned obj1 = new ComplianceArchivingHelper.IdListReturned ();
                    obj1.returnedObj = 'Cloud File Secondary';
                    obj1.returnIds = cloudFile.ID;
                    objList1.add (obj1);
                }
            }
        }
        // compliance when user shares the cloud file record with Community User
        if (objList.size () > 0) {
            ComplianceArchivingHelper.documentShare (portalFIleIdSet, portalUsers, 'Document Share', '');
            ComplianceArchivingHelper.createJournalRec (objList);                    
        }
        if (secondaryPortalUsers.size () > 0) {
            ComplianceArchivingHelper.documentShare (portalFIleIdSet, secondaryPortalUsers, 'Document Share Secondary', '');
            if (objList1.size () > 0)
                ComplianceArchivingHelper.createJournalRec (objList1);                    
        }
    }
}