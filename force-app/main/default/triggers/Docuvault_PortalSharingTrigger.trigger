//testClassName=Docuvault_DD_ShareOnPortal_tc
trigger Docuvault_PortalSharingTrigger on TVA_CFB__Cloud_Files__c (before update, after update) {
    
    // Sharing a Cloud Files to Portal.
    if (Trigger.isBefore && Trigger.isUpdate) {  
        List <Id> portalFileIds = NEW List <Id> ();
        List <Id> accountIds = NEW List <Id> ();        
        Map <Id, Id> portalIdFromAccount = NEW Map <Id, Id> ();
        Map <Id, Account> accountMap = NEW Map <Id, Account> ();
        List <Id> contactIds = NEW List <Id> ();        
        
        List <TVA_CFB__Cloud_Files__c> portalFilesList = NEW List <TVA_CFB__Cloud_Files__c> ();
        for (TVA_CFB__Cloud_Files__c cloudFile : Trigger.New) {
            if (Trigger.new.size() == 1 && Trigger.OldMap.get (cloudFile.Id).Share_On_Portal__c == false && cloudFile.Share_On_Portal__c == true && !System.isBatch()) {
                accountIds.add (cloudFile.WEGP1_Household__c);
                System.debug('AccountIds'+accountIds);
                System.debug('cloudfile'+cloudFile.Id);
            }
            
        }
        for (Document__c doc : [SELECT Account__c
                                FROM Document__c WHERE Account__c IN: accountIds]) {
                                    portalIdFromAccount.put (doc.Account__c, doc.ID);
         }
        
        for (Account acc : [SELECT Id, WEGP1_Primary_Individual__c, WEGP1_Secondary_Individual__c FROM Account WHERE Id IN: accountIds]) {
            accountMap.put (acc.Id, acc);
            if(acc.WEGP1_Primary_Individual__c != NULL) {
                contactIds.add(acc.WEGP1_Primary_Individual__c);
            }
            if(acc.WEGP1_Secondary_Individual__c != NULL) {
                contactIds.add(acc.WEGP1_Secondary_Individual__c);
            }
        }
        
        Map<Id, User> ContactIdToUserMap = new map<Id, User>();
        //AND UserType ='CSPLitePortal' AND  profile.Name ='WEG Customer Community'
        for(User usr : [SELECT Id, ContactId, isActive FROM User WHERE isActive = TRUE AND ContactId IN: contactIds ]){
            ContactIdToUserMap.put(usr.ContactId, usr);
        }
        Set <ID> portalRecIds = new SET <ID> ();
        Map <ID, ID> portalUsers = new Map <ID, ID> ();
        List<Id> cloudFileIdsList = new List<Id>();
        for (TVA_CFB__Cloud_Files__c cloudFile : Trigger.New) {
            if (Trigger.new.size() == 1 && Trigger.OldMap.get (cloudFile.Id).Share_On_Portal__c == false && cloudFile.Share_On_Portal__c == true && !System.isBatch()) {
                    TVA_CFB__Cloud_Files__c portalFile = NEW TVA_CFB__Cloud_Files__c ();
                    portalFile.Name = cloudFile.Name;
                    portalFile.Parent_CloudFile_Id__c = cloudFile.Id;
                    portalFile.TVA_CFB__File_Type__c = cloudFile.TVA_CFB__File_Type__c;
                    portalFile.TVA_CFB__File_Size_in_Bytes__c = cloudFile.TVA_CFB__File_Size_in_Bytes__c;
                    //portalFile.TVA_CFB__Folder__c = cloudFile.Portal_Folder__c;
                    portalFile.TVA_CFB__Folder__c = cloudFile.TVA_CFB__Folder__c;
                    portalFile.WEG_Document_Name__c = cloudFile.WEG_Document_Name__c; 
                    if (portalIdFromAccount.containsKey (cloudFile.WEGP1_Household__c)) {
                        
                        portalFile.TVA_CFB__Parent_ID__c = portalIdFromAccount.get (cloudFile.WEGP1_Household__c);
                        portalFile.Portal_Document__c = portalIdFromAccount.get (cloudFile.WEGP1_Household__c);
                    }
                    portalFile.TVA_CFB__Attachment_ID__c = cloudFile.Id;
                    portalFile.UniqueId__c = cloudFile.Id+' - ShareOnPortal';
                    portalFile.TVA_CFB__Bucket_Name__c = cloudFile.TVA_CFB__Bucket_Name__c;
                    portalFile.TVA_CFB__Region__c = cloudFile.TVA_CFB__Region__c;
                    if (ContactIdToUserMap!= NULL && ContactIdToUserMap.size () > 0) {
                        System.Debug (':::ContactIdToUserMap:::::'+ContactIdToUserMap);
                        if(ContactIdToUserMap.containsKey(accountMap.get(cloudFile.WEGP1_Household__c).WEGP1_Primary_Individual__c)){
                            
                            portalFile.Primary_Portal_User__c = ContactIdToUserMap.get(accountMap.get(cloudFile.WEGP1_Household__c).WEGP1_Primary_Individual__c).Id;    
                            
                        }
                        //System.debug(cloudFile.WEGP1_Household__c).WEGP1_Secondary_Individual__c);
                        if(ContactIdToUserMap.containsKey(accountMap.get(cloudFile.WEGP1_Household__c).WEGP1_Secondary_Individual__c)){
                            portalFile.Secondary_Portal_User__c = ContactIdToUserMap.get(accountMap.get(cloudFile.WEGP1_Household__c).WEGP1_Secondary_Individual__c).Id;     
                        }
                    }
                    
                    portalFile.Send_Notification__c = TRUE;
                    system.debug('portalFile:>>'+portalFile);
                    portalFilesList.add (portalFile);
                    
                    
                    cloudFile.Last_shared_on_Portal__c = System.Now ();
              
            }
        }
       
        if (portalFilesList.size () > 0) {
            Database.insert(portalFilesList, false);
            List <ComplianceArchivingHelper.IdListReturned> objList = new List <ComplianceArchivingHelper.IdListReturned> ();
            for (TVA_CFB__Cloud_Files__c cloudFile : portalFilesList) {
                portalFileIds.add (cloudFile.Id);
                portalRecIds.add (cloudFile.ID);
                ComplianceArchivingHelper.IdListReturned obj = new ComplianceArchivingHelper.IdListReturned ();
                obj.returnedObj = 'Cloud File';
                obj.returnIds = cloudFile.ID;
                objList.add (obj);
            }
            if (portalFileIds.size () > 0) {
                System.enqueuejob(NEW Docuvault_PortalFilesQueueable (portalFileIds));
               
            }
        } 
        
    }

    
    //Journaling email section.
    if (Trigger.isAfter && Trigger.isUpdate) {
        set<ID> cloudFileIdSet = New Set<ID> ();
        Set <ID> secureFileSendList = new Set <ID> ();
        Docuvault_Journaling_Email__c customSettingDetails = Docuvault_Journaling_Email__c.getInstance (UserInfo.getUserID ());
        String downloadEmailEmailTemplate = customSettingDetails.Download_Email_Template__c;
        String viewEmailEmailTemplate = customSettingDetails.View_Email_Template__c;
        String uploadEmailEmailTemplate = customSettingDetails.Upload_Email_Template__c;
        String shareOnPortalEmailEmailTemplate = customSettingDetails.Share_on_Portal_Email_Template__c;
        String keyPrefix = getObjectKeyPrefix ();
        for (TVA_CFB__Cloud_Files__c cloudFile : Trigger.New) {
            
            if (cloudFile.TVA_CFB__Parent_ID__c != NULL) {
                //Download File condition checking.
                
                if (Trigger.OldMap.get (cloudFile.Id).TVA_CFB__Downloads__c != cloudFile.TVA_CFB__Downloads__c 
                    && cloudFile.TVA_CFB__Parent_ID__c.startsWith (keyPrefix )) {
                        ComplianceArchivingHelper.documentShare (new Set<Id>{cloudFile.Id}, null, 'File Download', NULL);
                       // System.enqueueJob(NEW Docuvault_JournalingQueueableController (cloudFile.Id, downloadEmailEmailTemplate));
                    }
                                
                //View File condition checking
                if (Trigger.OldMap.get (cloudFile.Id).TVA_CFB__Previews__c != cloudFile.TVA_CFB__Previews__c 
                    && cloudFile.TVA_CFB__Parent_ID__c.startsWith (keyPrefix )) {
                        ComplianceArchivingHelper.documentShare (new Set<Id>{cloudFile.Id}, null, 'File View', NULL);
                        //System.enqueueJob(NEW Docuvault_JournalingQueueableController (cloudFile.Id, viewEmailEmailTemplate));
                    }
                
                //Upload file condition checking.
                if (Trigger.OldMap.get (cloudFile.Id).TVA_CFB__Amazon_Version_ID__c != cloudFile.TVA_CFB__Amazon_Version_ID__c 
                    && cloudFile.TVA_CFB__Parent_ID__c.startsWith (keyPrefix ) && cloudFile.TVA_CFB__Attachment_ID__c == NULL) {
                        ComplianceArchivingHelper.documentShare (new Set<Id>{cloudFile.Id}, null, 'File Upload', NULL);
                        //System.enqueueJob(NEW Docuvault_JournalingQueueableController (cloudFile.Id, uploadEmailEmailTemplate));
                    }
                
                //File shared with client through Portal
                if (Trigger.new.size() == 1 && Trigger.OldMap.get (cloudFile.Id).Share_On_Portal__c == false && cloudFile.Share_On_Portal__c == true && !System.isBatch()) {
                    //System.enqueueJob(NEW Docuvault_JournalingQueueableController (cloudFile.Id, shareOnPortalEmailEmailTemplate));                    
                    ComplianceArchivingHelper.documentShare (new Set<Id>{cloudFile.Id}, null, 'Share on Portal', NULL);
                }
                if(cloudFile.Portal_Document__c != NULL & cloudFile.TVA_CFB__E_Tag__c != NULL && Trigger.oldMap.get (cloudFIle.ID).TVA_CFB__E_Tag__c == NULL) {
                    cloudFileIdSet.add (cloudFile.ID);
                }
                if (Trigger.OldMap.get (cloudFile.ID).Email__c != cloudFile.Email__c) {
                    secureFileSendList.add (cloudFile.ID);
                }
            }
        }
        //Compliance when user sends a password protected link.
        if (secureFileSendList.size () > 0) {
            ComplianceArchivingHelper.documentShare (secureFileSendList, null, 'Secure File Send', NULL);
        }
        // Compliance When User upload files from Community.
        if(cloudFileIdSet.size () > 0) {
            Set <ID> portalDocuments = new Set <ID> ();
            Map <ID, ID> portalUserMap = new Map <ID, ID> ();
            for(TVA_CFB__Cloud_Files__c  cloudFile : [SELECT CreatedById, Owner.Profile.Name 
                                                      From TVA_CFB__Cloud_Files__c 
                                                      where Id in : cloudFileIdSet 
                                                      AND Owner.Profile.Name LIKE '%community%']) {
                                                          portalDOcuments.add (cloudFile.ID);
                                                          portalUserMap.put (cloudFile.ID, cloudFile.CreatedById);
                                                      }
            if (portalDocuments.size () > 0)
                ComplianceArchivingHelper.documentShare (portalDocuments, portalUserMap, 'Document Receipt', NULL);
        }
    }
    
    public static String getObjectKeyPrefix () {
        Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe() ;
        Schema.SObjectType s = m.get('Document__c') ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        String keyPrefix = r.getKeyPrefix();
        return keyPrefix;
    }
}