public class x7sEventNotificationEmailController {
	
    /*public class EmailWrapper {
        @InvocableVariable public String individualName;
        @InvocableVariable public String strEmailTemplate;
        @InvocableVariable public String strRecipientId;
        @InvocableVariable public String strRecipientEmail;
        @InvocableVariable public String Subject;
        @InvocableVariable public String Description;
        @InvocableVariable public DateTime StartDateTime;
	}
    
    @InvocableMethod
    public static void sendEventEmail(list<EmailWrapper> lstEmailWrapper){
        
        List<EmailTemplate> emailTemplateList = [
            SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body 
            FROM EmailTemplate WHERE Name = :lstEmailWrapper[0].strEmailTemplate
        ];
        String originalHtmlValue = emailTemplateList[0].HtmlValue;
        
        if(emailTemplateList.size() > 0){
            System.debug('lstEmailWrapper[0].individualName' + lstEmailWrapper[0].individualName);
            emailTemplateList[0].HtmlValue = emailTemplateList[0].HtmlValue.replace('{{IndividualName}}', lstEmailWrapper[0].individualName);
            emailTemplateList[0].HtmlValue = emailTemplateList[0].HtmlValue.replace('{{Subject}', lstEmailWrapper[0].Subject);
            emailTemplateList[0].HtmlValue = emailTemplateList[0].HtmlValue.replace('{{Description}}', lstEmailWrapper[0].Description);
            emailTemplateList[0].HtmlValue = emailTemplateList[0].HtmlValue.replace('{{StartDateTime}}', string.valueOfGmt(lstEmailWrapper[0].StartDateTime));
        }
        
		Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage();
        
        System.debug('Param 1::' + lstEmailWrapper[0].strRecipientEmail);
        System.debug('Param 2::' + lstEmailWrapper[0].strEmailTemplate);
        System.debug('Param 2::' + lstEmailWrapper[0].strRecipientId);
        
        // Set the Email of the Recipient.
        objEmail.setToAddresses(new list<String>{lstEmailWrapper[0].strRecipientEmail});
        //objEmail.setToAddresses(new list<String>{'janavi.trivedi@7summitsinc.com'});
		
        System.debug('Temp::' + [SELECT Name FROM EmailTemplate WHERE Name = :lstEmailWrapper[0].strEmailTemplate LIMIT 1].Id);
        // Set the Template Id
        objEmail.setTemplateId([SELECT Name FROM EmailTemplate WHERE Name = :lstEmailWrapper[0].strEmailTemplate LIMIT 1].Id);
         
        String emailSubject = objEmail.getSubject();
        objEmail.setSubject(emailSubject);
        objEmail.setHtmlBody(emailTemplateList[0].HtmlValue);
        objEmail.saveAsActivity = false;
        // To set the context and ensures that merge fields in the template contain the correct data.
        objEmail.setTargetObjectId(lstEmailWrapper[0].strRecipientId);
        objEmail.setTreatTargetObjectAsRecipient(false);
        
        Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {objEmail});
        if(!emailResult[0].isSuccess()){
            System.debug('Error :' +emailResult[0].getErrors());
        } else{
            System.debug('Success');
        } 
    }*/
}