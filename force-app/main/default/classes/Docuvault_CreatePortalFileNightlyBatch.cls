//TestClassName: Docuvault_DD_ShareOnPortal_TC 

global class Docuvault_CreatePortalFileNightlyBatch implements Database.Batchable <sObject>, Database.AllowsCallouts, Database.Stateful {

   
    global List <Id> portalFileIds = new List<Id>();
    global List <Id> recordIds = new List<Id>();
    global String documentName = '';
    
    global Docuvault_CreatePortalFileNightlyBatch(String docName) {
        documentName = '%'+docName+'%';
    }
    global Database.QueryLocator start (Database.BatchableContext BC) {
         String siteGuest = System.Label.DD_SiteGuestUser;
         String query = ' SELECT Name, CreatedById,Share_On_Portal__c,WEGP1_Household__c,WEGP1_Household__r.WEGP1_Primary_Individual__c, '
                      +' WEGP1_Household__r.WEGP1_Secondary_Individual__c, TVA_CFB__File_Size_in_Bytes__c,'
                      +' Portal_Folder__c, TVA_CFB__Bucket_Name__c, TVA_CFB__File_Type__c, WEG_Document_Name__c,'
                      +' TVA_CFB__Region__c, Send_Notification__c, Last_shared_on_Portal__c,'
                      +' Primary_Portal_User__c, Secondary_Portal_User__c'
                      +' From TVA_CFB__Cloud_Files__c '
                      +' where Share_On_Portal__c = false AND Primary_Portal_User__c = null '
             		  +' AND CreatedBy.Name = :siteGuest '
                      + 'AND WEG_Document_Name__c Like:documentName';
                        
        if(Test.isRunningTest()) {
             query = ' SELECT Name, CreatedById,Share_On_Portal__c,WEGP1_Household__c,WEGP1_Household__r.WEGP1_Primary_Individual__c, '
                      +' WEGP1_Household__r.WEGP1_Secondary_Individual__c, TVA_CFB__File_Size_in_Bytes__c,'
                      +' Portal_Folder__c, TVA_CFB__Bucket_Name__c, TVA_CFB__File_Type__c, WEG_Document_Name__c,'
                      +' TVA_CFB__Region__c, Send_Notification__c, Last_shared_on_Portal__c,'
                      +' Primary_Portal_User__c, Secondary_Portal_User__c'
                      +' From TVA_CFB__Cloud_Files__c '
                      +' where Share_On_Portal__c = false AND Primary_Portal_User__c = null '
                      + 'AND WEG_Document_Name__c Like:documentName';
        }       
        return Database.getQueryLocator (query);
    }
    global void execute (Database.BatchableContext BC,
                            List <TVA_CFB__Cloud_Files__c> scope) {
       
        List <TVA_CFB__Cloud_Files__c> portalFilesList = NEW List <TVA_CFB__Cloud_Files__c> ();
        for (TVA_CFB__Cloud_Files__c cloudFile : scope) {
            cloudFile.Share_On_Portal__c = true;
            recordIds.add(cloudFile.Id);  
        }
        system.debug(':::recordIds:::'+recordIds);
        update  scope;
       
    }
    
    global void finish (Database.BatchableContext BC) {
        Database.executeBatch (new Docuvault_CreatePortalFile (recordIds), 1);
    }
}