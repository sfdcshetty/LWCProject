public class ContactTriggerHandler implements TriggerInterface {
    private static ContactTriggerHandler instance;
    public static ContactTriggerHandler getInstance() {
        if (instance == null) {
            instance = new ContactTriggerHandler();
        }
        return instance;
    }

    public void beforeInsert() {
        ratingUpdate((List<Contact>) Trigger.new);
        campaignDates((List<Contact>) Trigger.new);
        updateConvertedContacts((List<Contact>) Trigger.new);
    }

    public void beforeUpdate() {
        fieldUpdate((Map<Id, Contact>) Trigger.newMap, (Map<Id, Contact>) Trigger.oldMap);
        campaignDates((Map<Id, Contact>) Trigger.newMap, (Map<Id, Contact>) Trigger.oldMap);
        setOffice((Map<Id, Contact>) Trigger.newMap, (Map<Id, Contact>) Trigger.oldMap);
    }

    public void beforeDelete() {
    }

    public void afterInsert() {
        flow_milestone((List<Contact>) Trigger.new);
        updateHHAccountFields((Map<Id, Contact>) Trigger.newMap);
        updateHHAccountAfter((Map<Id, Contact>) Trigger.newMap);
        convertFulfilmentItems((Map<Id, Contact>) Trigger.newMap);
    }

    public void afterUpdate() {
        flow_chase_phase((Map<Id, Contact>) Trigger.newMap, (Map<Id, Contact>) Trigger.oldMap);
        updateHHAccountFields((Map<Id, Contact>) Trigger.newMap, (Map<Id, Contact>) Trigger.oldMap);
        updateHHAccountAfter((Map<Id, Contact>) Trigger.newMap);
        convertFulfilmentItems((Map<Id, Contact>) Trigger.newMap);
    }

    public void afterDelete() {
    }

    public void finish() {
    }

    private static void ratingUpdate(List<Contact> newContacts) {
        for (Contact c : newContacts) {
            if (c.Request_Meeting__c == 'Yes') {
                c.Rating__c = 'Hot';
            } else {
                c.Rating__c = 'Warm';
            }
        }
    }

    private static void fieldUpdate(Map<Id, Contact> newContacts, Map<Id, Contact> oldContacts) {
        for (Id key : newContacts.keyset()) {
            if (newContacts.get(key).Request_Meeting__c != oldContacts.get(key).Request_Meeting__c) {
                if (newContacts.get(key).Request_Meeting__c == 'Yes') {
                    newContacts.get(key).Rating__c = 'Hot';
                } else {
                    newContacts.get(key).Rating__c = 'Warm';
                }
            }

            //This code was taken from WEG_contactTriggerHandler.  beforeUpdate()
            if (newContacts.get(key).WEGP1_UnsubscribeAllEmails__c != oldContacts.get(key).WEGP1_UnsubscribeAllEmails__c) {
                newContacts.get(key).WEGP1_DateUserUnsubscribe__c = DateTime.now();
            }

            //This code was taken from WEG_contactTriggerHandler.  beforeUpdate()
            if (oldContacts.get(key).Phone == null && newContacts.get(key).Phone != null) {
                switch on newContacts.get(key).WEGP1_PrimaryPhone__c {
                    when 'Work' {
                        // when block 1
                        newContacts.get(key).AssistantPhone = newContacts.get(key).Phone;
                    }
                    when 'Cell' {
                        // when block 2
                        newContacts.get(key).MobilePhone = newContacts.get(key).Phone;
                    }
                    when 'Other' {
                        // when block 3
                        newContacts.get(key).OtherPhone = newContacts.get(key).Phone;
                    }
                    when else {
                        // default block, optional
                        newContacts.get(key).WEGP1_PrimaryPhone__c = 'Home';
                        newContacts.get(key).HomePhone = newContacts.get(key).Phone;
                    }
                }
            }

            //This code was taken from WEG_contactTriggerHandler.  beforeUpdate()
            if (newContacts.get(key).WEGP1_LeadFulfillmentItems__c != oldContacts.get(key).WEGP1_LeadFulfillmentItems__c) {
                newContacts.get(key).WEGP1_FulfillmentItems__c = newContacts.get(key).WEGP1_LeadFulfillmentItems__c;
            }
        }
    }

    private static void campaignDates(List<Contact> newContacts) {
        for (Contact c : newContacts) {
            if (c.WEG_FirstRespondedCampaign__c != null) {
                c.WEG_FirstRespondedDate__c = Date.today();
            }

            if (c.WEG_LastRespondedCampaign__c != null) {
                c.WEG_LastRespondedDate__c = Date.today();
            }
        }
    }

    private static void campaignDates(Map<Id, Contact> newContacts, Map<Id, Contact> oldContacts) {
        for (Id key : newContacts.keySet()) {
            if (newContacts.get(key).WEG_FirstRespondedCampaign__c != oldContacts.get(key).WEG_FirstRespondedCampaign__c) {
                newContacts.get(key).WEG_FirstRespondedDate__c = Date.today();
            }

            if (newContacts.get(key).WEG_LastRespondedCampaign__c != oldContacts.get(key).WEG_LastRespondedCampaign__c) {
                newContacts.get(key).WEG_LastRespondedDate__c = Date.today();
            }
        }
    }

    private static void updateHHAccountFields(Map<Id, Contact> newcontacts) {
        Set<Id> householdIds = new Set<Id>();
        for (Contact c : [
            SELECT Id, Account.WEGP1_Primary_Household__c
            FROM Contact
            WHERE Id IN :newcontacts.keySet() AND Account.WEGP1_Primary_Household__c != NULL
        ]) {
            householdIds.add(c.Account.WEGP1_Primary_Household__c);
        }
        // update the household mailing name for the households
        WEG_Util_UpdateMailingName mailingNameUtility = new WEG_Util_UpdateMailingName();
        mailingNameUtility.updateHouseholds(householdIds);
    }

    private static void updateHHAccountFields(Map<Id, Contact> newcontacts, Map<Id, Contact> oldcontacts) {
        Set<Id> individualAccountIds = new Set<Id>();
        for (Id key : newcontacts.keySet()) {
            if (
                newcontacts.get(key).AccountId != null &&
                (newcontacts.get(key).WEGP1_ContactStatus__c != oldcontacts.get(key).WEGP1_ContactStatus__c ||
                newcontacts.get(key).Salutation != oldcontacts.get(key).Salutation ||
                newcontacts.get(key).WEGP1_InformalFullName__c != oldcontacts.get(key).WEGP1_InformalFullName__c ||
                newcontacts.get(key).Suffix != oldcontacts.get(key).Suffix)
            ) {
                individualAccountIds.add(key);
            }
        }

        if (individualAccountIds.size() > 0) {
            // iterate the individual accounts, gathering the household account ids
            Set<Id> householdIds = new Set<Id>();
            for (Account a : [SELECT Id, WEGP1_Primary_Household__c FROM Account WHERE Id IN :individualAccountIds AND WEGP1_Primary_Household__c != NULL]) {
                householdIds.add(a.WEGP1_Primary_Household__c);
            }
            // update the household mailing name for the households
            WEG_Util_UpdateMailingName mailingNameUtility = new WEG_Util_UpdateMailingName();
            mailingNameUtility.updateHouseholds(householdIds);
        }
    }

    //This code was taken from WEG_contactTriggerHandler.  beforeInsert() and updateConvertedContacts() methods
    private static void updateConvertedContacts(List<Contact> newContacts) {
        for (Contact contact : newContacts) {
            if (contact.WEGP1_LeadConvertedStatus__c == 'Converted') {
                if (String.isBlank(contact.Phone) && !String.isBlank(contact.MobilePhone)) {
                    // in this case, primary phone should be set to Mobile
                    contact.Phone = contact.MobilePhone;
                    contact.WEGP1_PrimaryPhone__c = 'Cell';
                } else {
                    // update home phone equal to primary phone (primary phone is mapped during conversion)
                    contact.HomePhone = contact.Phone;
                    contact.WEGP1_PrimaryPhone__c = 'Home';
                }
                contact.WEGP1_PersonalEmail__c = contact.Email;

                // set the defaults for the address/email/phone type picklists
                contact.WEGP1_PrimaryAddress__c = 'Home';
                contact.WEGP1_PrimaryEmail__c = 'Personal';

                // populate fulfillment items
                contact.WEGP1_FulfillmentItems__c = contact.WEGP1_LeadFulfillmentItems__c;
            }

            // if the user unsubscribe field is checked, update the user unsubscribe timestamp
            if (contact.WEGP1_UnsubscribeAllEmails__c == 'Unsubscribed') {
                contact.WEGP1_DateUserUnsubscribe__c = DateTime.now();
            }
        }
    }

    //This code was taken from WEG_contactTriggerHandler.  beforeUpdate() and setNearestOffice() methods
    private static void setOffice(Map<Id, Contact> newContactMap, Map<Id, Contact> oldContactMap) {
        //List<Account> updateAccounts = new List<Account>();
        Map<Id, Account> updateAccountsMap = new Map<Id, Account>();
        Map<Id, Id> hhAccounts = new Map<Id, Id>();
        Set<Id> updateIds = new Set<Id>();

        for (Id key : newContactMap.keySet()) {
            if (
                newContactMap.get(key).MailingLatitude != oldContactMap.get(key).MailingLatitude ||
                newContactMap.get(key).MailingLongitude != oldContactMap.get(key).MailingLongitude
            ) {
                updateIds.add(key);
                hhAccounts.put(newContactMap.get(key).AccountId, null);
            }
        }

        if (updateIds.size() == 0) {
            return;
        }

        for (Account a : [SELECT Id, WEGP1_Primary_Household__c FROM Account WHERE Id IN :hhAccounts.keySet()]) {
            hhAccounts.put(a.Id, a.WEGP1_Primary_Household__c);
        }

        List<WEGP1_Office__c> offices = [
            SELECT Id, Name, WEGP1_Location__c, WEGP1_GeographicRegion__c, WEGP1_NationalRadius__c
            FROM WEGP1_Office__c
            WHERE WEGP1_Location__latitude__s != NULL AND WEGP1_Location__longitude__s != NULL AND WEGP1_NationalRadius__c != NULL
        ];
        if (offices.size() == 0) {
            System.debug('No Offices');
            return;
        }

        List<WEGP1_Office__c> nationalOffice = [SELECT Id, Name, WEGP1_GeographicRegion__c FROM WEGP1_Office__c WHERE Name = 'National'];
        if (nationalOffice.size() == 0) {
            System.debug('No National Office');
            return;
        }

        for (Id key : updateIds) {
            // null the nearest fields if no latitude or longitude exist
            if (newContactMap.get(key).MailingLatitude == null || newContactMap.get(key).MailingLongitude == null) {
                newContactMap.get(key).WEGP1_DistanceNearestOffice__c = null;
                newContactMap.get(key).WEGP1_NearestOffice__c = null;
                newContactMap.get(key).WEGP1_GeographicalRegion__c = null;
                continue;
            }
            Location contactLocation = Location.newInstance(newContactMap.get(key).MailingLatitude, newContactMap.get(key).MailingLongitude);

            WEGP1_Office__c nearestOffice = null;
            for (WEGP1_Office__c office : offices) {
                if (newContactMap.get(key).MailingState == 'IL' && office.WEGP1_GeographicRegion__c != 'IL') {
                    continue;
                }

                Double distance = Location.getDistance(contactLocation, office.WEGP1_Location__c, 'mi');

                if (nearestOffice == null) {
                    nearestOffice = office;
                    newContactMap.get(key).WEGP1_NearestOffice__c = office.Name;
                    newContactMap.get(key).WEGP1_DistanceNearestOffice__c = distance;
                    newContactMap.get(key).WEGP1_GeographicalRegion__c = office.WEGP1_GeographicRegion__c;
                } else if (distance < newContactMap.get(key).WEGP1_DistanceNearestOffice__c) {
                    nearestOffice = office;
                    newContactMap.get(key).WEGP1_NearestOffice__c = office.Name;
                    newContactMap.get(key).WEGP1_DistanceNearestOffice__c = distance;
                    newContactMap.get(key).WEGP1_GeographicalRegion__c = office.WEGP1_GeographicRegion__c;
                }
            }

            if (newContactMap.get(key).MailingState != 'IL' && newContactMap.get(key).WEGP1_DistanceNearestOffice__c > nearestOffice.WEGP1_NationalRadius__c) {
                newContactMap.get(key).WEGP1_NearestOffice__c = nationalOffice[0].Name;
                newContactMap.get(key).WEGP1_GeographicalRegion__c = nationalOffice[0].WEGP1_GeographicRegion__c;
                nearestOffice = nationalOffice[0];
            }

            Account account = new Account();
            account.Id = newContactMap.get(key).AccountId;
            account.WEGP1_Region__c = newContactMap.get(key).WEGP1_GeographicalRegion__c;
            account.BillingStreet = newContactMap.get(key).MailingStreet;
            account.BillingCity = newContactMap.get(key).MailingCity;
            account.BillingState = newContactMap.get(key).MailingState;
            account.BillingCountry = newContactMap.get(key).MailingCountry;
            account.BillingPostalCode = newContactMap.get(key).MailingPostalCode;
            account.WEGP1_Lead_Type__c = newContactMap.get(key).WEGP1_Type__c;
            account.WEGP1_Lead_SubType__c = newContactMap.get(key).WEGP1_SubType__c;
            account.WEGP1_Lead_Type_Detail__c = newContactMap.get(key).WEGP1_TypeDetail__c;
            account.WEG_ReferredBy__c = newContactMap.get(key).WEGP1_ReferredBy__c;
            if (nearestOffice != null) {
                account.WEGP1_SalesOffice__c = nearestOffice.Id;
            }
            if (account.Id != null) {
                //updateAccounts.add(account);
                updateAccountsMap.put(account.Id, account);
            }

            Account hhAccount = new Account();
            hhAccount.Id = hhAccounts.get(newContactMap.get(key).AccountId);
            hhAccount.WEGP1_Region__c = newContactMap.get(key).WEGP1_GeographicalRegion__c;
            hhAccount.BillingStreet = newContactMap.get(key).MailingStreet;
            hhAccount.BillingCity = newContactMap.get(key).MailingCity;
            hhAccount.BillingState = newContactMap.get(key).MailingState;
            hhAccount.BillingCountry = newContactMap.get(key).MailingCountry;
            hhAccount.BillingPostalCode = newContactMap.get(key).MailingPostalCode;
            hhAccount.WEGP1_Lead_Type__c = newContactMap.get(key).WEGP1_Type__c;
            hhAccount.WEGP1_Lead_SubType__c = newContactMap.get(key).WEGP1_SubType__c;
            hhAccount.WEGP1_Lead_Type_Detail__c = newContactMap.get(key).WEGP1_TypeDetail__c;
            hhAccount.WEG_ReferredBy__c = newContactMap.get(key).WEGP1_ReferredBy__c;
            if (nearestOffice != null) {
                hhAccount.WEGP1_SalesOffice__c = nearestOffice.Id;
            }
            if (hhAccount.Id != null) {
                //updateAccounts.add(hhAccount);
                updateAccountsMap.put(hhAccount.Id, hhAccount);
            }
        }

        if (updateAccountsMap.size() > 0) {
            //Database.update(updateAccounts, false);
            Database.update(updateAccountsMap.values(), false);
        }
    }

    private static void flow_milestone(List<Contact> newContacts) {
        Id individualRTID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();

        List<Contact> flowContacts = new List<Contact>();
        for (Contact contact : newContacts) {
            //if (recordtypeMap.get(contact.recordtypeId) == 'IndustriesIndividual' && contact.Email != null) {
            if (contact.recordtypeId == individualRTID && (contact.Phone != null || contact.Email != null || contact.MailingPostalCode != null)) {
                flowContacts.add(contact);
            }
        }

        if (flowContacts.size() > 0) {
            Flow.Interview flow = new Flow.Interview.Interaction_Contact_Milestone_Standalone(new Map<String, Object>{ 'Contacts' => flowContacts });
            flow.start();
        }
    }

    private static void flow_chase_phase(Map<Id, Contact> newContacts, Map<Id, Contact> oldContacts) {
        Id individualRTID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        List<Contact> flowContacts = new List<Contact>();
        for (Id key : newContacts.keySet()) {
            if (newContacts.get(key).recordtypeId == individualRTID && newContacts.get(key).WEGP1_Chase_Phase__c != oldContacts.get(key).WEGP1_Chase_Phase__c) {
                flowContacts.add(newContacts.get(key));
            }
        }

        for (Contact contact : flowContacts) {
            Flow.Interview flow = new Flow.Interview.Interaction_Create(
                new Map<String, Object>{ 'ContactId' => contact.Id, 'RecordTypeName' => 'Milestone', 'InteractionName' => 'Chase Phase Update' }
            );
            flow.start();
        }
    }

    private static void updateHHAccountAfter(Map<Id, Contact> newContacts) {
        Map<Id, Account> updateAccounts = new Map<Id, Account>();

        for (Contact c : [
            SELECT
                Id,
                Account.WEGP1_Primary_Household__c,
                Account.WEGP1_Primary_Household__r.WEGP1_Lead_Type__c,
                Account.WEGP1_Primary_Household__r.WEGP1_Lead_SubType__c,
                Account.WEGP1_Primary_Household__r.WEGP1_Lead_Type_Detail__c,
                Account.WEGP1_Primary_Household__r.WEG_ReferredBy__c
            FROM Contact
            WHERE Id IN :newcontacts.keySet() AND Account.WEGP1_Primary_Household__c != NULL
        ]) {
            Account updateAccount = new Account();
            updateAccount.Id = c.Account.WEGP1_Primary_Household__c;
            if (newContacts.get(c.id).WEGP1_Type__c != null && c.Account.WEGP1_Primary_Household__r.WEGP1_Lead_Type__c == null) {
                updateAccount.WEGP1_Lead_Type__c = newContacts.get(c.id).WEGP1_Type__c;
                updateAccounts.put(updateAccount.Id, updateAccount);
            }
            if (newContacts.get(c.id).WEGP1_SubType__c != null && c.Account.WEGP1_Primary_Household__r.WEGP1_Lead_SubType__c == null) {
                updateAccount.WEGP1_Lead_SubType__c = newContacts.get(c.id).WEGP1_SubType__c;
                updateAccounts.put(updateAccount.Id, updateAccount);
            }
            if (newContacts.get(c.id).WEGP1_TypeDetail__c != null && c.Account.WEGP1_Primary_Household__r.WEGP1_Lead_Type_Detail__c == null) {
                updateAccount.WEGP1_Lead_Type_Detail__c = newContacts.get(c.id).WEGP1_TypeDetail__c;
                updateAccounts.put(updateAccount.Id, updateAccount);
            }
            if (c.Account.WEGP1_Primary_Household__r.WEG_ReferredBy__c != newContacts.get(c.id).WEGP1_ReferredBy__c) {
                updateAccount.WEG_ReferredBy__c = newContacts.get(c.id).WEGP1_ReferredBy__c;
                updateAccounts.put(updateAccount.Id, updateAccount);
            }
        }
        if (updateAccounts.size() > 0) {
            Database.update(updateAccounts.values());
        }
    }

    private void convertFulfilmentItems(Map<Id, Contact> newContactMap) {
        List<Fulfillment_Request__c> updaterequests = new List<Fulfillment_Request__c>();
        for (Fulfillment_Request__c req : [
            SELECT ID, WEGP1_Lead__c, WEGP1_Lead__r.ConvertedContactId
            FROM Fulfillment_Request__c
            WHERE WEGP1_Lead__r.ConvertedContactId IN :newContactMap.keySet()
        ]) {
            req.WEGP1_Contact__c = req.WEGP1_Lead__r.ConvertedContactId;
            req.WEGP1_Lead__c = null;
            updaterequests.add(req);
        }
        if (updaterequests.size() > 0) {
            Database.update(updaterequests, false);
        }
    }
}