public class WEG_UserTriggerHandler {
    
    public void afterInsertOrUpdate() {
    
        // iterate the inserted/updated contacts
        Set<Id> userIds = new Set<Id>();
        List<User> users = new List<User>();
        for (User user : (List<User>)Trigger.new) {
            if (user.IsActive && user.UserType == 'Standard') {
                userIds.add(user.Id);
                users.add(user);
            }
        }
        
        updateContacts(userIds);
    }
    
    @future
    private static void updateContacts(Set<Id> userIds) {
        
        // get the users
        List<User> users = [SELECT Id, Email, FirstName, LastName, Department, Phone, MobilePhone, Title
                                , Street, City, State, PostalCode, Country FROM User WHERE Id IN :userIds];
        
        // get the contacts corresponding the user Ids
        List<Contact> contacts = [SELECT Id, WEG_User__c FROM Contact WHERE WEG_User__c IN :userIds];
 
        Map <Id, Id> userContactMap = new Map <Id, Id>(); // Create a user contact map of userId, contactId
        for(Contact userContact : contacts) {
            userContactMap.put(userContact.WEG_User__c , userContact.Id);
        }
        
        // get the WEG business account
        List<Account> wegBusinesses = [SELECT Id FROM Account WHERE Name = 'WEG'];
        
        // get the employee record type
        Id employeeTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Employee').getRecordTypeId();
        
        // instantiate the list of contacts to upsert
        List<Contact> contactsToUpsert = new List<Contact>(); // Create a list of contacts to upsert
        
        for (User u : users) {                              // Loop through each upserted user
 
            Contact c = new Contact(                        // Create a contact record in memory
                RecordTypeId = employeeTypeId,              // Populate the record type
                WEG_User__c = u.Id,                         // Populate the user lookup
                Email = u.Email,                            // Populate the email
                FirstName = u.FirstName,                    // Populate the first name
                LastName = u.LastName,                      // Populate the last name
                Department = u.Department,                  // Populate the user department
                Phone = u.Phone,                            // Populate the phone number
                MobilePhone = u.MobilePhone,                // Populate the mobile phone number
                Title = u.Title,                            // Populate the title of user
                MailingStreet = u.Street,                   // Populate the mailing street
                MailingCity = u.City,                       // Populate the mailing city
                MailingState = u.State,                     // Populate the mailing state
                MailingPostalCode = u.PostalCode,           // Populate the postal code
                MailingCountry = u.Country,                 // Populate the country
                OwnerId = u.Id);                            // Populate the contact owner
            
            if (wegBusinesses.size() > 0) {
                c.AccountId = wegBusinesses[0].Id;      // Populate the account lookup
            }
            
            if (userContactMap.get(u.Id) != null) {
                c.Id = userContactMap.get(u.Id);            // specify the contact to be updated
            }
 
            contactsToUpsert.add(c);                        // Add the contact to the bulk upsert list
        }
 
        if(contactsToUpsert.size() > 0){
            upsert contactsToUpsert;                        // Upsert all contacts in single DML statement
        }
    }
}