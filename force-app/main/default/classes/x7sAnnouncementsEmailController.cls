/*
 * Copyright (c) 2020. 7Summits Inc.
 */


public with sharing class x7sAnnouncementsEmailController {
    /*
     * This method will send emails to Community Users with a certain Profile. The email will be sent to the
     * email address on the Community User's related Contact record, and will use the specified Email Template.
     *
     * To use this method set the emailTemplateName and profileName to the desired Email Template and User Profile
     */
    @InvocableMethod
    public static void sendAnnouncementEmail(List<Id> announcementIDs) {
        try {
            String emailTemplateName = x7sAnnouncementsSettings.AnnouncementEmailTemplate;
            String profileNames = x7sAnnouncementsSettings.AnnouncementProfile;
            List<String> profileList = profileNames.split(',\\s*');

            List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();

            Id templateId = [SELECT Id FROM EmailTemplate WHERE EmailTemplate.Name = :emailTemplateName].Id;
            List<User> recipientList = [SELECT Id, Name, Email, ContactId, Contact.Email FROM User WHERE Profile.Name IN :profileList WITH SECURITY_ENFORCED];

            // For each Announcement
            for (Id theAnnouncementId : announcementIDs) {
                // For each recipient, create a single email message and add to to List
                for (User theUser : recipientList) {
                    System.debug('Email recipient : ' + theUser);

                    if (theUser.ContactId != null && theUser.Email != null) {
                        System.debug('ContactId: ' + theUser.ContactId + ' email: ' + theUser.Email);
                        Messaging.SingleEmailMessage singleMessage = new Messaging.SingleEmailMessage();

                        singleMessage.setTemplateId(templateId); singleMessage.setTargetObjectId(theUser.ContactId); singleMessage.setWhatId(theAnnouncementId); singleMessage.saveAsActivity = false; messageList.add(singleMessage);
                    }
                }
            }

            // Send List of emails
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messageList);

            // Debug message to verify email was sent
            for (Integer i = 0; i < results.size(); i++) {
                System.debug('Results = ' + results[i].isSuccess());
            }
        } catch (Exception e) {
			System.debug('sendAnnouncementEmail() : ' + e.getMessage() + ' line number ' + e.getLineNumber());
        }
    }
}