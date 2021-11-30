global without sharing class WEG_ManagePortalUserController {
    
    private static string ACTIVE_PORTAL_USER_STATUS = 'Active Portal User';
    private static string INACTIVE_PORTAL_USER_STATUS = 'Inactive Portal User';
    
    global class PortalUser {
        @AuraEnabled public Id AccountId {get; set;}
        @AuraEnabled public Id ContactId {get; set;}
        @AuraEnabled public Id UserId {get; set;}
        
        @AuraEnabled public string Email {get; set;}
        @AuraEnabled public string UserEmail {get; set;}
        @AuraEnabled public string MobilePhone {get; set;}
        @AuraEnabled public string UserMobilePhone {get; set;}
        @AuraEnabled public boolean IsActive {get; set;}
        @AuraEnabled public boolean UserIsActive {get; set;}
        
        @AuraEnabled public string Username {get; set;}
        
        @AuraEnabled public string ErrorTitle {get; set;}
        @AuraEnabled public string ErrorMessage {get; set;}
        
        global PortalUser() {
            IsActive = false;
        }
    }
    
    /******************************* PUBLIC METHODS *********************************/
    @AuraEnabled
    public static PortalUser getPortalUser(Id accountId) {
        system.debug('>>>>>>>> WEG_ManagePortalUserController.getContact');
        system.debug('>>>>>>>> accountId: ' + accountId);
        
        PortalUser portalUser = new PortalUser();
        
        // get the contact (including user info)
        Contact contact = getContact(accountId);
        if (contact == null) {
            portalUser.ErrorMessage = 'Error getting the contact.';
            return portalUser;
        }
        
        portalUser.AccountId = accountId;
        portalUser.ContactId = contact.Id;
        portalUser.UserId = contact.WEG_PortalUser__c;
        portalUser.Username = contact.WEG_PortalUser__r.Username;
        
        if (contact.WEG_PortalUser__c != null) {
            portalUser.Email = contact.WEG_PortalUser__r.Email;
            portalUser.UserEmail = contact.WEG_PortalUser__r.Email;
            portalUser.MobilePhone = contact.WEG_PortalUser__r.MobilePhone;
            portalUser.UserMobilePhone = contact.WEG_PortalUser__r.MobilePhone;
            portalUser.IsActive = contact.WEG_PortalUser__r.IsActive;
            portalUser.UserIsActive = contact.WEG_PortalUser__r.IsActive;
        
        } else {
            portalUser.Email = contact.Email;
            portalUser.UserEmail = null;
            portalUser.MobilePhone = contact.MobilePhone;
            portalUser.UserMobilePhone = contact.MobilePhone;
            portalUser.IsActive = true;
            portalUser.UserIsActive = false;
        }
        
        return portalUser;
    }
        
    @AuraEnabled
    public static PortalUser validateInput(PortalUser portalUser) {
        system.debug('>>>>>>>> WEG_ManagePortalUserController.validateActiveUser');
        system.debug('>>>>>>>> portalUser: ' + portalUser);
        
        // null check
        if (portalUser == null || portalUser.AccountId == null || portalUser.ContactId == null) {
            portalUser = new PortalUser();
            portalUser.ErrorMessage = 'Bad portalUser parameter.';
        }
        
        // a change must be made
        else if (portalUser.IsActive == portalUser.UserIsActive && portalUser.Email == portalUser.UserEmail && portalUser.MobilePhone == portalUser.UserMobilePhone) {
            portalUser.ErrorMessage = 'No changes were made.';
        }
        
        // user must exist if inactivating
        else if (!portalUser.IsActive && portalUser.UserId == null) {
            portalUser.ErrorMessage = 'Cannot inactivate. User does not exist.';
        }
        
        // email and mobile phone are required
        else if (portalUser.IsActive && (string.isBlank(portalUser.Email) || string.isBlank(portalUser.MobilePhone))) {
            portalUser.ErrorMessage = 'Email and Mobile Phone are required.';
        }
        
        // ensure the new email address is unique if changed
        else if (portalUser.IsActive && portalUser.Email != portalUser.UserEmail && emailAlreadyExist(portalUser)) {
            portalUser.ErrorMessage = 'Portal user already exists with same username/email address.';
        }
        
        // return the response
        return portalUser;
    }
    
    @AuraEnabled
    public static PortalUser deactivateUser(PortalUser portalUser) {
        system.debug('>>>>>>>> WEG_ManagePortalUserController.deactivateUser');
        system.debug('>>>>>>>> portalUser: ' + portalUser);
        
        // get the user
        User user = new User(Id = portalUser.UserId);
        
        // deactivate the user
        user.IsActive = false;
        
        // commit the change
        try {
            update user;
            return portalUser;
        } catch (Exception ex) { portalUser.ErrorTitle = 'Error deactivating User'; portalUser.ErrorMessage = ex.getMessage(); return portalUser; }
    }
    
    @AuraEnabled
    public static PortalUser updateMobileOnContact(PortalUser portalUser) {
        system.debug('>>>>>>>> WEG_ManagePortalUserController.updateMobileOnContact');
        system.debug('>>>>>>>> portalUser: ' + portalUser);
        
        // get the contact (including user info)
        Contact contact = new Contact(Id = portalUser.ContactId);
        
        // set the mobile phone and update
        contact.MobilePhone = portalUser.MobilePhone;
        try {
            update contact;
            return portalUser;
        } catch (Exception ex) { portalUser.ErrorTitle = 'Error updating Mobile on Contact'; portalUser.ErrorMessage = ex.getMessage(); return portalUser; }
    }
    
    @AuraEnabled
    public static PortalUser createUser(PortalUser portalUser) {
        system.debug('>>>>>>>> WEG_ManagePortalUserController.createUser');
        system.debug('>>>>>>>> portalUser: ' + portalUser);
        
        // get the user
        Contact contact = [SELECT Id, LastName, FirstName, Classification__c FROM Contact WHERE Id = :portalUser.ContactId];
        
        String profileName = '';
        if(contact.Classification__c == 'Client'){
            profileName = 'WEG Customer Community Plus';
        } else {
            profileName = 'WEG Prospect Community Plus';
        }
        
        // get the Community profile
        Profile profile = [SELECT Id, Name
                           FROM Profile
                           WHERE Name = :profileName
                           LIMIT 1];
        system.debug('>>>>>>>> Community Profile: ' + profile);
        
        // ensure the profile was retrieved
        if (profile == null) {
            system.debug('>>>>>>>> Profile not found.');
            portalUser.ErrorMessage = 'Profile not found.';
            return portalUser;
        }
        
        // create the portal user
        User user = new User (
            LastName = contact.LastName,
            FirstName = contact.FirstName,
            Username = portalUser.Email,
            Email = portalUser.Email,
            Alias = portalUser.Email.left(4) + string.valueOf(Datetime.now().formatGMT('yyyyMMddHH:mm:ss.SSS')).right(4),
            //MobilePhone: not set because an SF trigger will pull mobile from the contact
            ProfileId = profile.Id,
            IsActive = true,
            CompanyName = 'Client',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Chicago',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ContactId = contact.Id
        );
        system.debug('>>>>>>>> user: ' + user);
        
        try {
            // insert and return the user record
            insert user;
            
            portalUser.UserId = user.Id;
            system.debug('>>>>>>>> userId: ' + user.Id);
            
            return portalUser;
        }
        catch(Exception e) { portalUser.ErrorTitle = 'Unable to create portal user'; portalUser.ErrorMessage = e.getMessage(); return portalUser; }
    }
    
    @AuraEnabled
    public static PortalUser linkUserOnContact(PortalUser portalUser) {
        system.debug('>>>>>>>> WEG_ManagePortalUserController.linkUserOnContact');
        system.debug('>>>>>>>> portalUser: ' + portalUser);
        
        // get the contact
        Contact contact = new Contact(Id = portalUser.ContactId);
        
        // set the mobile phone and update
        contact.WEG_PortalUser__c = portalUser.UserId;
        
        try {
            update contact;
            return portalUser;
        } catch (Exception ex) { portalUser.ErrorTitle = 'Error linking User to Contact'; portalUser.ErrorMessage = ex.getMessage(); return portalUser; }
    }
    
    @AuraEnabled
    public static PortalUser updateUser(PortalUser portalUser) {
        system.debug('>>>>>>>> WEG_ManagePortalUserController.updateUser');
        system.debug('>>>>>>>> portalUser: ' + portalUser);
        
        // get the user
        User user = new User(Id = portalUser.UserId);
        
        // update the properties
        user.IsActive = portalUser.IsActive;
        user.Email = portalUser.Email;
        user.MobilePhone = portalUser.MobilePhone;
        
        // commit the changes
        try {
            update user;
            return portalUser;
        } catch (Exception ex) { portalUser.ErrorTitle = 'Error updating User'; portalUser.ErrorMessage = ex.getMessage(); return portalUser; }
    }
    
    @AuraEnabled
    public static PortalUser updatePortalStatus(PortalUser portalUser) {
        system.debug('>>>>>>>> WEG_ManagePortalUserController.updatePortalStatus');
        system.debug('>>>>>>>> portalUser: ' + portalUser);
        
        // get the account
        Account acct = new Account(Id = portalUser.AccountId);
        
        // set the portal user status
        if (portalUser.IsActive)
            acct.Portal_User_Status__c = 'Active Portal User';
        else
            acct.Portal_User_Status__c = 'Inactive Portal User';
        
        // update the account
        try {
            update acct;
            return portalUser;
        } catch (Exception ex) { portalUser.ErrorTitle = 'Error updating Portal Status on Account'; portalUser.ErrorMessage = ex.getMessage(); return portalUser; }
    }
    
    /******************************* HELPER METHODS *********************************/
    private static Contact getContact(Id accountId) {
        //
        if(string.isBlank(accountId)) {
            system.debug('accountId is NULL.');
            return null;
        }
        
        // get the contacts for the account
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Email, MobilePhone
                                  , AccountId, Account.Portal_User_Status__c
                                  , WEG_PortalUser__c, WEG_PortalUser__r.Username, WEG_PortalUser__r.Email, WEG_PortalUser__r.MobilePhone, WEG_PortalUser__r.IsActive
                                  FROM Contact
                                  WHERE AccountId = :accountId];
        system.debug('>>>>>>>> Contacts: ' + contacts);
        
        // ensure a single contact was retrieved
        if (contacts.size() != 1) {
            system.debug('Contact does not exist for the person.');
            return null;
        }
        
        // return the contact
        return contacts[0];
    }
    
    private static boolean emailAlreadyExist(PortalUser portalUser) {
        // get any users where username or email = email
        List<User> users = [SELECT Id
                            FROM User
                            WHERE Id != :portalUser.UserId
                            AND (Username = :portalUser.Email OR Email = :portalUser.Email)];
        
        // return whether the size is greater than zero
        return users.size() > 0;
    }
}