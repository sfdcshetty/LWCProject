@isTest
private class SendEmailsUsingContacto_TC {

	@isTest
	private static void testName() {
		Account acc = NEW Account();
		acc.Name = 'test';
		insert acc;

		TVA_CFB__Cloud_Files__c cloudFileDetails = NEW TVA_CFB__Cloud_Files__c();
		cloudFileDetails.Name = 'Test_\\.pdf';
		cloudFileDetails.WEGP1_DocumentType__c = 'Document Submission';
		cloudFileDetails.TVA_CFB__Folder__c = 'Test';
		cloudFileDetails.WEGP1_Ready_for_Review__c = true;
		cloudFileDetails.TVA_CFB__Version__c = 1;
		cloudFileDetails.TVA_CFB__Parent_ID__c = acc.ID;
		cloudFileDetails.WEGP1_Household__c = acc.ID;
		cloudFileDetails.Share_On_Portal__c = false;
		insert cloudFileDetails;

		SendEmailsUsingContacto.generateUniqueId();
		SendEmailsUsingContacto.createEmailSendAndEmailMessage('test', 'Test@test.com', 'test@test.com', cloudFileDetails.Id,
																'test', 'test123', 'Cloud_Files__c');
		SendEmailsUsingContacto.SendEmailMessageFlow messageList = new SendEmailsUsingContacto.SendEmailMessageFlow();
		messageList.fromAddress = 'test@test.com';
		messageList.toAddress = 'test1@test.com';
		messageList.templatesubject = 'Test Subject';
		messageList.templateBody = 'Test body';
		messageList.templateType = 'text/html';
		messageList.parentId = cloudFileDetails.Id;
		SendEmailsUsingContacto.sendEmailFromContacto(messageList);
	}
}