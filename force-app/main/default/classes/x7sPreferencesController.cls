/**
 * Created by tricia.igoe on 6/11/21.
 */

public with sharing class x7sPreferencesController {

    @AuraEnabled
    public static Preference grabPreferences(){
        User currentUser = [SELECT Id, Contact.WEGP1_EmailPreferencesWEG__c, Contact.Portal_Email_Preferences__c, ContactId FROM User WHERE Id = : UserInfo.getUserId()];
        Preference userNotification = new Preference();

        if(currentUser.ContactId != null) {
            System.debug('currentUser.Contact.WEGP1_EmailPreferencesWEG__c='+currentUser.Contact.WEGP1_EmailPreferencesWEG__c);
            System.debug('Portal_Email_Preferences__c='+currentUser.Contact.Portal_Email_Preferences__c);
            //new insights get
            if(currentUser.Contact.WEGP1_EmailPreferencesWEG__c == 'No News & Updates') {
                
                userNotification.newInsights = false;
            }

            //to Dos get
            if(String.isNotBlank(currentUser.Contact.Portal_Email_Preferences__c) && (currentUser.Contact.Portal_Email_Preferences__c.contains('No To Do Assignments'))) {
                
                userNotification.toDos = false;
            }

            //profile Updates get
            if(String.isNotBlank(currentUser.Contact.Portal_Email_Preferences__c) && (currentUser.Contact.Portal_Email_Preferences__c.contains('No Profile Updates'))) {
                userNotification.profileUpdates = false;
            }
        }

        return userNotification;

    }

    @AuraEnabled
    public static List<String> savePreferences(Preference userNotification) {
        System.debug('USER PREFS=====>' + userNotification);

        List<String> returnList = new List<String>();
        User currentUser = [SELECT Id, Contact.WEGP1_EmailPreferencesWEG__c, Contact.Portal_Email_Preferences__c, ContactId FROM User WHERE Id = : UserInfo.getUserId()];
        if(String.isNotBlank(currentUser.ContactId)) {
            Contact currentContact = [SELECT Id, WEGP1_EmailPreferencesWEG__c, Portal_Email_Preferences__c FROM Contact WHERE Id =: currentUser.ContactId];
            //new insights get
            if(userNotification.newInsights) {
                currentContact.WEGP1_EmailPreferencesWEG__c = '';
            } else {
                currentContact.WEGP1_EmailPreferencesWEG__c = 'No News & Updates';
            }

            Boolean noAnnounce;

            if(currentContact.Portal_Email_Preferences__c != null) {
                noAnnounce = currentContact.Portal_Email_Preferences__c.contains('No Portal Announcements');
            } else {
                noAnnounce = false;
            }

            //to Dos get
            if(!userNotification.toDos && !userNotification.profileUpdates && noAnnounce) {
                currentContact.Portal_Email_Preferences__c = 'No To Do Assignments;No Profile Updates;No Portal Announcements';
            } else if(userNotification.toDos && !userNotification.profileUpdates && noAnnounce) {
                currentContact.Portal_Email_Preferences__c = 'No Profile Updates;No Portal Announcements';
            } else if(!userNotification.toDos && userNotification.profileUpdates && noAnnounce) {
                currentContact.Portal_Email_Preferences__c = 'No To Do Assignments;No Portal Announcements';
            } else if(userNotification.toDos && userNotification.profileUpdates && noAnnounce) {
                currentContact.Portal_Email_Preferences__c = 'No Portal Announcements';
            } else if(!userNotification.toDos && !userNotification.profileUpdates && !noAnnounce) {
                currentContact.Portal_Email_Preferences__c = 'No To Do Assignments;No Profile Updates';
            } else if(userNotification.toDos && !userNotification.profileUpdates && !noAnnounce) {
                currentContact.Portal_Email_Preferences__c = 'No Profile Updates';
            } else if(!userNotification.toDos && userNotification.profileUpdates && !noAnnounce) {
                currentContact.Portal_Email_Preferences__c = 'No To Do Assignments';
            } else if(userNotification.toDos && userNotification.profileUpdates && !noAnnounce) {
                currentContact.Portal_Email_Preferences__c = '';
            }
            System.debug('USER PREFSsssss=====>' + currentContact.WEGP1_EmailPreferencesWEG__c);
            try{
                System.debug('USER PREFSsssss=====>' + currentContact.WEGP1_EmailPreferencesWEG__c);
                returnList.add(currentContact.WEGP1_EmailPreferencesWEG__c);
                returnList.add(currentContact.Portal_Email_Preferences__c);
                update currentContact;
                returnList.add('successfully updated');
            } catch(Exception e) {
                returnList.add(e.getMessage());
                returnList.add(e.getStackTraceString());
            }

        }

        return returnList;
    }

    public class Preference{

        @AuraEnabled
        public Boolean newInsights {get;set;}

        @AuraEnabled
        public Boolean toDos {get;set;}

        @AuraEnabled
        public Boolean profileUpdates {get;set;}

        public Preference() {
            newInsights = true;
            toDos = true;
            profileUpdates = true;
        }
    }

}