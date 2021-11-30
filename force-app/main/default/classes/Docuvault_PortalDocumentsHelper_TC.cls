@isTest
private class Docuvault_PortalDocumentsHelper_TC {
    Public Static TVA_CFB__CloudFiles_Settings__c cloudFileSettings () {
        TVA_CFB__CloudFiles_Settings__c customSettings = NEW TVA_CFB__CloudFiles_Settings__c ();
        customSettings.TVA_CFB__bucket_name__c = 'testBucket';
        customSettings.TVA_CFB__Access_Key__c = 'testAccess';
        customSettings.TVA_CFB__Secret_Key__c = 'testScret';
        customSettings.TVA_CFB__Salesforce_URL__c = 'www.test.com';
        customSettings.TVA_CFB__Amazon_URL__c = 'http://s3.amazonaws.com';
        customSettings.TVA_CFB__Google_URL_Shortner_URL__c = 'tst.com';
        customSettings.TVA_CFB__Enable_Google_URL_Shortener__c = TRUE;
        customSettings.TVA_CFB__Enable_GeoLocation__c = TRUE;
        customSettings.TVA_CFB__File_Request_URL__c = 'www.test.com';
        customSettings.TVA_CFB__Google_API_Key__c = 'abc';
        customSettings.TVA_CFB__Salesforce_Site_URL__c = 'www.test.com';
        customSettings.TVA_CFB__Server_Side_Encryption__c = TRUE;
        customSettings.TVA_CFB__Web_To_Case_Attachment__c = TRUE;
        customSettings.TVA_CFB__Web_To_Lead_Attachment__c = TRUE;        
        return customSettings;
    }
    Public Static TVA_CFB__Cloud_Files_Region_Endpoints__c cloudFileRegionEndpoins () {
        TVA_CFB__Cloud_Files_Region_Endpoints__c regionEndPoints = NEW TVA_CFB__Cloud_Files_Region_Endpoints__c ();
        regionEndPoints.TVA_CFB__Endpoint_URL__c = 'https://s3.amazonaws.com';
        regionEndPoints.Name = 'us-east-1';
        return regionEndPoints ;
    }
    Public Static TVA_CFB__CloudFiles_MIME_Types__c cloudFileMIMETypes () {
        TVA_CFB__CloudFiles_MIME_Types__c mimeTypes = NEW TVA_CFB__CloudFiles_MIME_Types__c ();
        mimeTypes.TVA_CFB__Content_Type__c = 'image/jpeg';
        mimeTypes.Name = 'jpg';
        return mimeTypes ;
    }
    
    static testMethod void renameFile () {
        TVA_CFB__CloudFiles_Settings__c settings = cloudFileSettings ();
        insert settings;
        
        TVA_CFB__Cloud_Files_Region_Endpoints__c regions = cloudFileRegionEndpoins ();
        insert regions;
        
        TVA_CFB__CloudFiles_MIME_Types__c mimeTypes = cloudFileMIMETypes ();
        insert mimeTypes;
        
        TVA_CFB__Cloud_Files__c cloudFile = new TVA_CFB__Cloud_Files__c ();
        cloudFile.TVA_CFB__External_File_Name__c = 'Amaxon Test.jpg';
        cloudFile.TVA_CFB__Region__c = 'us-east-1';
        cloudFile.TVA_CFB__Bucket_Name__c = 'AWS_Test_Bucket';
        cloudFile.TVA_CFB__File_Type__c = 'jpg';
        cloudFile.TVA_CFB__E_TAG__c = 'test';
        
        cloudFile.TVA_CFB__Amazon_Version_ID__c = 'test';
        cloudFile.Name = 'Test.jpg';
        
        
        List <Id> cloudFileIds = NEW List <Id> ();
        cloudFileIds.add (cloudFile.Id);
        Test.startTest ();
            Contact con = new Contact();
            con.LastName = ' Test Contact';
            con.WEGP1_PrimaryAddress__c = 'Work';
            con.WEGP1_PrimaryEmail__c ='Work';
            con.WEGP1_PrimaryPhone__c = 'Work';
            con.HomePhone = '1111111111';
            con.AssistantPhone = '2222222222';
            con.MobilePhone = '3333333333';
            con.OtherPhone = '4444444444';
            con.WEG_Business_Email__c = 'work_email@weg.com';
            con.WEGP1_OtherEmail__c = 'other_email@weg.com';
            con.WEGP1_PersonalEmail__c = 'test@weg.com';
            con.Email = 'test@weg.com';
            con.OtherStreet = 'OtherStreet';
            con.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Business').getRecordTypeId();
            insert con;

            Account acc = new Account (
                Name = 'newAcc1',
                WEGP1_Primary_Individual__c = con.id,
                recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId()
            );  
            insert acc;
            
            
            
            Document__c doc = new Document__c (
                Name = 'Test Doc',
                Account__c = acc.Id
            );
            insert doc;
            cloudFile.WEGP1_Household__c = acc.ID;
            cloudFile.TVA_CFB__Parent_ID__c = acc.ID;
            insert cloudFile;
            
            cloudFile.Share_on_Portal__c = true;
            update cloudFile;
            
            Docuvault_PortalDocumentsHelper.getRelatedAccountID ();
            Docuvault_PortalDocumentsHelper.getPickListOptions ('Account', 'Name');
            Docuvault_PortalDocumentsHelper.getPortalDocumentId (acc.Id);
            Docuvault_PortalDocumentsHelper.checkPortalUser(cloudFile.Id);
        Test.stopTest ();
    }
    public static testMethod void method1() {
        Contact con = new Contact();
            con.LastName = ' Test Contact';
            con.WEGP1_PrimaryAddress__c = 'Work';
            con.WEGP1_PrimaryEmail__c ='Work';
            con.WEGP1_PrimaryPhone__c = 'Work';
            con.HomePhone = '1111111111';
            con.AssistantPhone = '2222222222';
            con.MobilePhone = '3333333333';
            con.OtherPhone = '4444444444';
            con.WEG_Business_Email__c = 'work_email@weg.com';
            con.WEGP1_OtherEmail__c = 'other_email@weg.com';
            con.WEGP1_PersonalEmail__c = 'test@weg.com';
            con.Email = 'test@weg.com';
            con.OtherStreet = 'OtherStreet';
            con.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Business').getRecordTypeId();
            insert con;
        
         	Account houseHoldAccount1 = new Account(Name = 'TestAccount',recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId());
            Database.insert(houseHoldAccount1);

            Account acc = new Account (
                Name = 'newAcc1',
                WEGP1_Primary_Individual__c = con.id,
                WEGP1_Primary_Household__c = houseHoldAccount1.Id
                
            );  
            insert acc;
            TVA_CFB__Cloud_Files__c cloudFile = new TVA_CFB__Cloud_Files__c ();
            cloudFile.WEGP1_Household__c = houseHoldAccount1.Id;
            cloudFile.TVA_CFB__Parent_ID__c = acc.Id;
            cloudFile.TVA_CFB__File_Type__c = 'jpg';
            insert cloudFile;
            Docuvault_PortalDocumentsHelper.checkPortalUser(cloudFile.Id);
    }
}