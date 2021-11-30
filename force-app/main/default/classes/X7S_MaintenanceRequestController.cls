/**
 * Created by 7Summits on 4/12/21.
 */

public without sharing class X7S_MaintenanceRequestController {

    @AuraEnabled
    public static List<Contact> getRelatedContactsForCurrentUser(){
        return getRelatedContactsForUserId(UserInfo.getUserId());
    }

    public static List<Contact> getRelatedContactsForUserId(String userId){
        List<User> currentUserQuery = [
                SELECT Id, ContactId, Contact.AccountId, Contact.Account.WEGP1_Primary_Household__c
                FROM User
                WHERE Id = :userId
        ];

        if(currentUserQuery.size() > 0) {
            User currentUser = currentUserQuery[0];
            if(currentUser.ContactId != null && currentUser.Contact.AccountId != null) {
                List<Contact> contactQuery = [
                        SELECT Id, FirstName, MiddleName, LastName, Salutation, Suffix, FinServ__PreferredName__c, Birthdate, MailingAddress, WEGP1_PrimaryAddress__c,
                                FinServ__BillingAddress__c, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode,
                                Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingPostalCode,
                                FinServ__OtherAddress__c, OtherStreet, OtherCity, OtherState, OtherPostalCode,
                                Phone, MobilePhone, OtherPhone, AssistantPhone, HomePhone, WEGP1_PrimaryPhone__c,
                                Email, WEGP1_PrimaryEmail__c, WEGP1_PersonalEmail__c, WEGP1_OtherEmail__c, WEG_Business_Email__c
                        FROM Contact
                        WHERE Account.WEGP1_Primary_Household__c = :currentUser.Contact.Account.WEGP1_Primary_Household__c
                ];

                return contactQuery;
            }
        }

        return null;
    }

    @AuraEnabled
    public static Boolean updateEmails(String contactId, String personalEmail, String workEmail, String otherEmail, String primaryEmail){
        Contact contactToUpdate = retrieveContactById(contactId);

        if(contactToUpdate != null) {
            primaryEmail = primaryEmail != null ? primaryEmail : 'Personal';
            Map<String, String> params = new Map<String, String>{
                    'contactId'=>contactId,
                    'input_personalEmail'=>personalEmail,
                    'input_workEmail'=>workEmail,
                    'input_otherEmail'=>otherEmail,
                    'input_primaryEmail'=>primaryEmail
            };
            if(!Test.isRunningTest()) {
                Flow.Interview.Simple_Maintenance_Request_Email_Update emailUpdateFlow = new Flow.Interview.Simple_Maintenance_Request_Email_Update(params);
                emailUpdateFlow.start();
            }
            return true;
        }
        return false;
    }

    @AuraEnabled
    public static Boolean updateNames(String contactId, String salutation, String firstName, String middleName, String lastName, String suffix, String informalName){
        Contact contactToUpdate = retrieveContactById(contactId);

        if(contactToUpdate != null) {
            Map<String, String> params = new Map<String, String>{
                    'contactId'=>contactId,
                    'input_salutation'=>salutation,
                    'input_firstName'=>firstName,
                    'input_middleName'=>middleName,
                    'input_lastName'=>lastName,
                    'input_suffix'=>suffix,
                    'input_informalName'=>informalName
            };
            if(!Test.isRunningTest()) {
                Flow.Interview.Simple_Maintenance_Request_Name_Update nameUpdateFlow = new Flow.Interview.Simple_Maintenance_Request_Name_Update(params);
                nameUpdateFlow.start();
            }
            return true;
        }
        return false;
    }

    @AuraEnabled
    public static Boolean updatePhones(String contactId, String mobilePhone, String workPhone, String homePhone, String otherPhone, String primaryPhone){
        Contact contactToUpdate = retrieveContactById(contactId);

        if(contactToUpdate != null) {
            Map<String, String> params = new Map<String, String>{
                    'contactId'=>contactId,
                    'input_homePhone'=>homePhone,
                    'input_workPhone'=>workPhone,
                    'input_mobilePhone'=>mobilePhone,
                    'input_otherPhone'=>otherPhone,
                    'input_primaryPhone'=>primaryPhone
            };
            System.debug(params);
            if(!Test.isRunningTest()) {
                Flow.Interview.Simple_Maintenance_Request_Phone_Update phoneUpdateFlow = new Flow.Interview.Simple_Maintenance_Request_Phone_Update(params);
                phoneUpdateFlow.start();
            }
            return true;
        }
        return false;
    }

    @AuraEnabled
    public static Boolean updateAddresses(String contactId,
            String homeStreet, String homeCity, String homeState, String homeZip, Boolean alsoChangeHomeAddressForCoClient,
            String workStreet, String workCity, String workState, String workZip, Boolean alsoChangeWorkAddressForCoClient,
            String otherStreet, String otherCity, String otherState, String otherZip, Boolean alsoChangeOtherAddressForCoClient,
            Boolean updateCustodianAccountsWithPrimaryAddress, String primaryAddress, Boolean isPrimaryAddressUpdated){

        Map<String, String> params = new Map<String, String>{
                'contactId'=>contactId,
                'input_homeStreet'=>homeStreet,
                'input_homeCity'=>homeCity,
                'input_homeState'=>homeState,
                'input_homeZip'=>homeZip,
                'input_changeHomeAddressForCoClient'=>String.valueOf(alsoChangeHomeAddressForCoClient),
                'input_workStreet'=>workStreet,
                'input_workCity'=>workCity,
                'input_workState'=>workState,
                'input_workZip'=>workZip,
                'input_changeWorkAddressForCoClient'=>String.valueOf(alsoChangeWorkAddressForCoClient),
                'input_otherStreet'=>otherStreet,
                'input_otherCity'=>otherCity,
                'input_otherState'=>otherState,
                'input_otherZip'=>otherZip,
                'input_changeOtherAddressForCoClient'=>String.valueOf(alsoChangeOtherAddressForCoClient),
                'input_updateCustodianAccounts'=>String.valueOf(updateCustodianAccountsWithPrimaryAddress),
                'input_primaryAddress'=>primaryAddress,
                'input_isPrimaryAddressUpdated'=>String.valueOf(isPrimaryAddressUpdated)
        };


        List<Contact> contactQuery = [
                SELECT Id, AccountId, Account.WEGP1_Primary_Household__c
                FROM Contact
                WHERE Id = :contactId
        ];
        if(contactQuery.size() > 0) {
            List<Contact> coClientContactQuery = [
                    SELECT Id, AccountId, Account.WEGP1_Primary_Household__c
                    FROM Contact
                    WHERE Id != :contactId AND Account.WEGP1_Primary_Household__c = :contactQuery[0].Account.WEGP1_Primary_Household__c
                    LIMIT 1
            ];
            if(coClientContactQuery.size() > 0){
                params.put('coClientContactId', coClientContactQuery[0].Id);
            }
        }
        if(!Test.isRunningTest()) {
            Flow.Interview.Simple_Maintenance_Request_Address_Update addressUpdateFlow = new Flow.Interview.Simple_Maintenance_Request_Address_Update(params);
                addressUpdateFlow.start();
        }
            return true;
       
    }

    private static Contact retrieveContactById(String contactId){
        List<Contact> contactQuery = [
                SELECT Id
                FROM Contact
                WHERE Id = :contactId
        ];
        if(contactQuery.size() > 0){
            return contactQuery[0];
        }
        return null;
    }
}