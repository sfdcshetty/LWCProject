//TestClassName: Docuvault_DD_ShareOnPortal_TC

global class Docuvault_CreatePortalFile implements Database.Batchable <sObject>, Database.AllowsCallouts, Database.Stateful {

    global List <Id> portalFileIds;
    global List <ID> recordIds;
    global Docuvault_CreatePortalFile(List <Id> cloudFileIds) {
        portalFileIds = NEW List <Id> ();
        recordIds = new List <ID> ();
        portalFileIds = cloudFileIds;
    }
    
    global Database.QueryLocator start (Database.BatchableContext BC) {
        String query = ' SELECT Name, CreatedById,Share_On_Portal__c,WEGP1_Household__c,WEGP1_Household__r.WEGP1_Primary_Individual__c, '
                      +' WEGP1_Household__r.WEGP1_Secondary_Individual__c, TVA_CFB__File_Size_in_Bytes__c,'
                      +' Portal_Folder__c, TVA_CFB__Bucket_Name__c, TVA_CFB__File_Type__c, WEG_Document_Name__c,'
                      +' TVA_CFB__Region__c, Send_Notification__c, Last_shared_on_Portal__c,'
                      +' Primary_Portal_User__c, Secondary_Portal_User__c'
                      +' From TVA_CFB__Cloud_Files__c '
                      +' where Id in : portalFileIds ';
                        
        
        return Database.getQueryLocator (query);
    }
    global void execute (Database.BatchableContext BC,
                            List <TVA_CFB__Cloud_Files__c> scope) {
                            
        List <Id> accountIds = NEW List <Id> ();  
        Map <Id, Id> portalIdFromAccount = NEW Map <Id, Id> ();
        Map <Id, Account> accountMap = NEW Map <Id, Account> ();
        List <Id> contactIds = NEW List <Id> ();
        List <TVA_CFB__Cloud_Files__c> portalFilesList = NEW List <TVA_CFB__Cloud_Files__c> ();
        for (TVA_CFB__Cloud_Files__c cloudFile : scope) {
            accountIds.add (cloudFile.WEGP1_Household__c);
        }
        for (Document__c doc : [SELECT Account__c
                                FROM Document__c WHERE Account__c IN: accountIds]) 
        {
            portalIdFromAccount.put (doc.Account__c, doc.ID);
        }
        for (Account acc : [SELECT Id, WEGP1_Primary_Individual__c, WEGP1_Secondary_Individual__c FROM Account WHERE Id IN: accountIds]) {
            accountMap.put (acc.Id, acc);
            if(acc.WEGP1_Primary_Individual__c != null) {
                contactIds.add(acc.WEGP1_Primary_Individual__c);
            }
            if(acc.WEGP1_Secondary_Individual__c != null) {
                contactIds.add(acc.WEGP1_Secondary_Individual__c);
            }
        }
        
        Map<Id, User> ContactIdToUserMap = new map<Id, User>();
        for(User usr : [SELECT Id, ContactId, isActive FROM User WHERE isActive = TRUE AND ContactId IN: contactIds ]){
            ContactIdToUserMap.put(usr.ContactId, usr);
        }
        for (TVA_CFB__Cloud_Files__c cloudFile : scope) {
            //cloudFile.Share_On_Portal__c = true;
            TVA_CFB__Cloud_Files__c portalFile = NEW TVA_CFB__Cloud_Files__c ();
            portalFile.Name = cloudFile.Name;
            portalFile.Parent_CloudFile_Id__c = cloudFile.Id;
            portalFile.UniqueId__c = cloudFile.Id+' - ShareOnPortal';
            portalFile.TVA_CFB__File_Type__c = cloudFile.TVA_CFB__File_Type__c;
            portalFile.TVA_CFB__File_Size_in_Bytes__c = cloudFile.TVA_CFB__File_Size_in_Bytes__c;
            portalFile.TVA_CFB__Folder__c = cloudFile.Portal_Folder__c;
            portalFile.WEG_Document_Name__c = cloudFile.WEG_Document_Name__c; 
            if (portalIdFromAccount.containsKey (cloudFile.WEGP1_Household__c)) {
                
                portalFile.TVA_CFB__Parent_ID__c = portalIdFromAccount.get (cloudFile.WEGP1_Household__c);
                portalFile.Portal_Document__c = portalIdFromAccount.get (cloudFile.WEGP1_Household__c);
            }
            portalFile.TVA_CFB__Attachment_ID__c = cloudFile.Id;
            portalFile.TVA_CFB__Bucket_Name__c = cloudFile.TVA_CFB__Bucket_Name__c;
            portalFile.TVA_CFB__Region__c = cloudFile.TVA_CFB__Region__c;
            if (ContactIdToUserMap!= NULL && ContactIdToUserMap.size () > 0) {
                System.Debug (':::ContactIdToUserMap:::::'+ContactIdToUserMap);
                if(ContactIdToUserMap.containsKey(accountMap.get(cloudFile.WEGP1_Household__c).WEGP1_Primary_Individual__c)){
                    
                    portalFile.Primary_Portal_User__c = ContactIdToUserMap.get(accountMap.get(cloudFile.WEGP1_Household__c).WEGP1_Primary_Individual__c).Id;    
                    
                }
                if(ContactIdToUserMap.containsKey(accountMap.get(cloudFile.WEGP1_Household__c).WEGP1_Secondary_Individual__c)){
                    portalFile.Secondary_Portal_User__c = ContactIdToUserMap.get(accountMap.get(cloudFile.WEGP1_Household__c).WEGP1_Secondary_Individual__c).Id;     
                }
            }
            
            portalFile.Send_Notification__c = TRUE;
            system.debug('portalFile:>>'+portalFile);
            portalFilesList.add (portalFile);
        } 
        //update scope;
        if (portalFilesList.size () > 0) {
            Database.insert(portalFilesList, false);
            system.debug(' portalFilesList portalFilesList'+portalFilesList);
            for (TVA_CFB__Cloud_Files__c cloudFile :portalFilesList) {
                recordIds.add (cloudFile.ID);
            }
            
            
        }

    
    }
    
    global void finish (Database.BatchableContext BC) {
    
        Database.executeBatch (new Docuvault_ShareOnPortalBatch(recordIds), 1);
    }
}