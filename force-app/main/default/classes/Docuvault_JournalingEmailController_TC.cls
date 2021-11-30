@isTest
public class Docuvault_JournalingEmailController_TC {

	static testMethod void TrackDocuvaultFilesMethod() {
		Test.startTest();
		User thisUser = [select Id from User where Id = :UserInfo.getUserId()];

		System.runAs(thisUser) {
			EmailTemplate et = new EmailTemplate();
			et.isActive = true;
			et.Name = 'testTemplate';
			et.DeveloperName = 'testTemplate';
			et.TemplateType = 'text';
			et.FolderId = UserInfo.getUserId();
			et.Body = 'Test Mail{!TVA_CFB__Cloud_Files__c}{!User.Name}';
			et.Subject = 'A File has been downloaded from Portal. {!TVA_CFB__Cloud_Files__c.TVA_CFB__downloads__c}';
			et.HtmlValue = 'A file owned by Test John with email address test@john.cc has been downloaded through Client Portal with the following details: File Name: testPNG.png, File Type: PNG, Download Count: {!TVA_CFB__Cloud_Files__c.TVA_CFB__downloads__c}';
			insert et;

			Docuvault_Journaling_Email__c temp = NEW Docuvault_Journaling_Email__c();
			temp.Email__c = 'test@gmail.com';
			temp.From_Email__c = 'testuser@gmail.com';
			temp.Download_Email_Template__c = 'testTemplate';
            temp.Share_on_Portal_Email_Template__c = 'testTemplate';
			insert temp;
		}

		TVA_CFB__CloudFiles_Settings__c customSettings = NEW TVA_CFB__CloudFiles_Settings__c();
		customSettings.TVA_CFB__bucket_name__c = 'testBucket';
		customSettings.TVA_CFB__Access_Key__c = 'testKey';
		customSettings.TVA_CFB__Secret_Key__c = 'testSecret';
		customSettings.TVA_CFB__Folder_Share_URL__c = 'test.com';
		customSettings.TVA_CFB__Salesforce_Site_URL__c = 'test';
		customSettings.TVA_CFB__Enable_Google_URL_Shortener__c = true;
		insert customSettings;

		Account parent = NEW Account();
		parent.name = 'Test';
		insert parent;

		Id devRecordTypeId = Schema.SObjectType.TVA_CFB__Cloud_Files__c.getRecordTypeInfosByName().get('Digital Delivery').getRecordTypeId();

		TVA_CFB__Cloud_Files__c doc1 = NEW TVA_CFB__Cloud_Files__c();
		doc1.TVA_CFB__File_Type__c = 'jpg';
		doc1.TVA_CFB__Account__c = parent.Id;
		doc1.TVA_CFB__Parent_ID__c = parent.Id;
		doc1.Name = 'test.jpg';
		doc1.RecordTypeId = devRecordTypeId;
		doc1.TVA_CFB__Bucket_Name__c = 'testBucket';
		doc1.TVA_CFB__Folder__c = 'test';
		doc1.TVA_CFB__Region__c = 'us-east-1';
		doc1.TVA_CFB__ExterNal_File_Name__c = 'Test';
		doc1.TVA_CFB__Downloads__c = 0;
        doc1.WEG_Document_Name__c = 'ccpy';
		doc1.Primary_Portal_User__c = thisUser.Id;
		insert doc1;

		TVA_CFB__Cloud_Files__c doc = NEW TVA_CFB__Cloud_Files__c();
		doc.TVA_CFB__File_Type__c = 'jpg';
		doc.TVA_CFB__Account__c = parent.Id;
		doc.TVA_CFB__Parent_ID__c = parent.Id;
		doc.Parent_CloudFile_Id__c = doc1.Id;
		doc.Name = 'test.jpg';
		doc.TVA_CFB__Bucket_Name__c = 'testBucket';
		doc.TVA_CFB__Folder__c = 'test';
		doc.TVA_CFB__Region__c = 'us-east-1';
		doc.TVA_CFB__ExterNal_File_Name__c = 'Test';
		doc.TVA_CFB__Downloads__c = 0;
		doc.Primary_Portal_User__c = thisUser.Id;
		doc.Secondary_Portal_User__c = thisUser.Id;
		insert doc;

		String cloudFileId = doc.Id;
		doc.TVA_CFB__Downloads__c = 1;
		update doc;

		Docuvault_JournalingEmailController obj = new Docuvault_JournalingEmailController();
		Docuvault_JournalingEmailController.getAllFields('TVA_CFB__Cloud_Files__c');
		Docuvault_JournalingEmailController.sendCloudFileAsEmail(doc.Id, 'testTemplate');
		System.Assert(doc.id == cloudFileId);
		Test.stopTest();
	}
}