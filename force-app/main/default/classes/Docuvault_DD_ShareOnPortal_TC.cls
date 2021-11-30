@isTest
public class Docuvault_DD_ShareOnPortal_TC{
    static testMethod void Method1(){
        Account acc = NEW Account ();
        acc.Name = 'test';
        insert acc;
        
        TVA_CFB__Cloud_Files__c cloudFileDetails = NEW TVA_CFB__Cloud_Files__c ();
        cloudFileDetails.Name = 'Test_\\.pdf';
        cloudFileDetails.WEGP1_DocumentType__c = 'Document Submission';
        cloudFileDetails.TVA_CFB__Folder__c = 'Test';
        cloudFileDetails.WEGP1_Ready_for_Review__c = true;  
        cloudFileDetails.TVA_CFB__Version__c = 1;
        cloudFileDetails.TVA_CFB__Parent_ID__c = acc.ID;
        cloudFileDetails.WEGP1_Household__c = acc.ID;
        cloudFileDetails.Share_On_Portal__c = false;
        cloudFileDetails.TVA_CFB__Region__c = 'us-east-1';
        insert cloudFileDetails;
       
        TVA_CFB__Cloud_Files__c cloudFileDetails1 = NEW TVA_CFB__Cloud_Files__c ();
        cloudFileDetails1.Name = 'Test_\\.pdf';
        cloudFileDetails1.WEGP1_DocumentType__c = 'Document Submission';
        cloudFileDetails1.TVA_CFB__Folder__c = 'Test';
        cloudFileDetails1.WEGP1_Ready_for_Review__c = true;  
        cloudFileDetails1.TVA_CFB__Version__c = 1;
        cloudFileDetails1.TVA_CFB__Parent_ID__c = acc.ID;
        cloudFileDetails1.WEGP1_Household__c = acc.ID;
        cloudFileDetails1.Share_On_Portal__c = false;
        cloudFileDetails1.TVA_CFB__Region__c = 'us-east-1';
        insert cloudFileDetails1;
        
        TVA_CFB__Cloud_Files_Region_Endpoints__c regionEndPoints = NEW TVA_CFB__Cloud_Files_Region_Endpoints__c ();
        regionEndPoints.TVA_CFB__Endpoint_URL__c = 'https://s3.amazonaws.com';
        regionEndPoints.Name = 'us-east-1';
        insert regionEndPoints;
        
        WEG_Document_Delivery__c documentDelivery = new WEG_Document_Delivery__c();
        documentDelivery.WEG_Status__c = 'Pending';
        documentDelivery.WEG_Document__c = cloudFileDetails.Id;
        insert documentDelivery;
        
        TVA_CO__Email_Message__c emailMsg = new TVA_CO__Email_Message__c();
        emailMsg.Name = 'Test';
        emailMsg.Cloud_Files__c = cloudFileDetails.Id;
        emailMsg.TVA_CO__Bounced__c = true;
        insert emailMsg;
         
        Apexpages.StandardSetController sc = new Apexpages.StandardSetController(new List<TVA_CFB__Cloud_Files__c>{cloudFileDetails});
        Docuvault_DD_ShareOnPortal obj = new Docuvault_DD_ShareOnPortal(sc);
        Docuvault_DD_ShareOnPortal.updateCloudFileRecords(new list<id>{cloudFileDetails.Id});
        Database.executeBatch(new Docuvault_ShareOnPortalBatch(new List<Id>{cloudFileDetails.Id}), 1);
        Database.executeBatch(new Docuvault_CreatePortalFile(new List<Id>{cloudFileDetails.Id}), 1);
    }
    static testMethod void Method2(){
        Account acc = NEW Account ();
        acc.Name = 'test';
        insert acc;
        
        TVA_CFB__Cloud_Files__c cloudFileDetails = NEW TVA_CFB__Cloud_Files__c ();
        cloudFileDetails.Name = 'Test_\\.pdf';
        cloudFileDetails.WEGP1_DocumentType__c = 'Document Submission';
        cloudFileDetails.TVA_CFB__Folder__c = 'Test';
        cloudFileDetails.WEGP1_Ready_for_Review__c = true;  
        cloudFileDetails.TVA_CFB__Version__c = 1;
        cloudFileDetails.WEG_Document_Name__c = 'QAMR';
        cloudFileDetails.TVA_CFB__Parent_ID__c = acc.ID;
        cloudFileDetails.WEGP1_Household__c = acc.ID;
        cloudFileDetails.Share_On_Portal__c = false;
        insert cloudFileDetails;
        Docuvault_CreatePortalFileSchedule_QAMR obj = new Docuvault_CreatePortalFileSchedule_QAMR();    
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, obj); 
        Database.executeBatch(new Docuvault_CreatePortalFileNightlyBatch('CCPY'));
        Docuvault_CreatePortalFileSchedule_CCPY obj1 = new Docuvault_CreatePortalFileSchedule_CCPY();    
        system.schedule('Test Territory Check1', sch, obj1); 
        
        Database.executeBatch(new Docuvault_CreatePortalFileNightlyBatch('QAMR'));
        
        Docuvault_CreatePortalFileSchedule obj2 = new Docuvault_CreatePortalFileSchedule ();
        system.schedule('Test Territory Check2', sch, obj2);
    }
}