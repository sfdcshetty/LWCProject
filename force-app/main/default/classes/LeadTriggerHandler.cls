public with sharing class LeadTriggerHandler implements TriggerInterface {
    private static LeadTriggerHandler instance;
    public static LeadTriggerHandler getInstance() {
        if (instance == null) {
            instance = new LeadTriggerHandler();
        }
        return instance;
    }

    public void beforeInsert() {
        campaignDates((List<Lead>) Trigger.new);
        setPersonator((List<Lead>) Trigger.new);
    }

    public void beforeUpdate() {
        campaignDates((Map<Id, Lead>) Trigger.newMap, (Map<Id, Lead>) Trigger.oldMap);
        updateLocation((Map<Id, Lead>) Trigger.newMap, (Map<Id, Lead>) Trigger.oldMap);
        updatePersonator((Map<Id, Lead>) Trigger.newMap, (Map<Id, Lead>) Trigger.oldMap);
    }

    public void beforeDelete() {
    }

    public void afterInsert() {
        mellisaInsert((List<Lead>) Trigger.new);
        wave6((List<Lead>) Trigger.new);
    }

    public void afterUpdate() {
        updateInteractionsDuringConversion((Map<Id, Lead>) Trigger.newMap, (Map<Id, Lead>) Trigger.oldMap);
        convertLeadAtRating((List<Lead>) Trigger.new);
        updateConvertedContacts((List<Lead>) Trigger.new);
    }

    public void afterDelete() {
        moveTasks((List<Lead>) Trigger.old);
    }

    public void finish() {
    }

    private static void updateInteractionsDuringConversion(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap) {
        Set<Id> updateSet = new Set<Id>();
        //check if it was just converted
        for (Id key : newLeadMap.keySet()) {
            if (newLeadMap.get(key).IsConverted && !oldLeadMap.get(key).IsConverted) {
                updateSet.add(key);
            }
        }

        if (updateSet.size() > 0 && System.isBatch() == false) {
            InteractionWithoutSharing.futureUpdateInteractions(updateSet);
        }
    }

    private static void convertLeadAtRating(List<Lead> newLeads) {
        List<Lead_Convert__e> events = new List<Lead_Convert__e>();
        List<User> defaultUser = [SELECT Id FROM USER WHERE Alias = :Properties__c.getOrgDefaults().Default_Contact_Owner__c LIMIT 1];
        Id invalidLeadTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Invalid Lead').getRecordTypeId();
        //TriggerFactory.RUN_TRIGGER_LOGIC = false;
        List<Lead> leadsToConvert = new List<Lead>();
        for (Lead l : newLeads) {
            if (
                ((l.Request_Meeting__c == 'Yes' && (l.Demographic_Rating__c == 'A' || l.Demographic_Rating__c == 'B')) || l.PRFT_Rating__c == 'A') &&
                l.isConverted == false &&
                l.RecordTypeId != invalidLeadTypeId
            ) {
                Lead_Convert__e event = new Lead_Convert__e();
                event.Lead_Id__c = l.Id;
                if (l.ownerId.getSObjectType().getDescribe().getName() == 'User') {
                    event.Owner_Id__c = l.OwnerId;
                } else if (l.WEGP1_LeadChase__c != null) {
                    event.Owner_Id__c = l.WEGP1_LeadChase__c;
                } else if (!defaultUser.isEmpty()) {
                    event.Owner_Id__c = defaultUser[0].Id;
                }
                events.add(event);
                //leadsToConvert.add(l);
            }

            // if ((l.Request_Meeting__c == 'Yes' && l.WEGP1_NewClientTeamOpportunityAmount__c > 100000) || l.PRFT_Rating__c == 'A') {
            //     leadsToConvert.add(l);
            // }
            // if ((l.PRFT_Rating__c == 'A' || (l.Behavior_Rating__c == 'A' && l.Request_Meeting__c == 'Yes')) && !l.IsConverted) {​​​​
            //     leadsToConvert.add(l);
            // }​​​​
        }
        if (events.size() > 0) {
            EventBus.publish(events);
        }
        // if (leadsToConvert.size() > 0) {
        //     String leadStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1].MasterLabel;

        //     Id ownerUserId = [SELECT Id FROM USER WHERE Alias = :Properties__c.getOrgDefaults().Default_Contact_Owner__c LIMIT 1].Id;
        //     List<Database.LeadConvert> MassLeadconvert = new List<Database.LeadConvert>();
        //     for (lead lead : leadsToConvert) {
        //         Database.LeadConvert Leadconvert = new Database.LeadConvert();
        //         Leadconvert.setLeadId(lead.Id);
        //         Leadconvert.setConvertedStatus(leadStatus);
        //         Leadconvert.setDoNotCreateOpportunity(true);
        //         if (lead.ownerId.getSObjectType().getDescribe().getName() == 'User') {
        //             //do nothing
        //         } else if (lead.WEGP1_LeadChase__c != null) {
        //             Leadconvert.setOwnerId(lead.WEGP1_LeadChase__c);
        //         } else {
        //             Leadconvert.setOwnerId(ownerUserId);
        //         }
        //         MassLeadconvert.add(Leadconvert);
        //     }

        //     if (!MassLeadconvert.isEmpty()) {
        //         Map<Id, Database.LeadConvertResult> leadConvertMap = new Map<Id, Database.LeadConvertResult>();
        //         Database.DMLOptions dml = new Database.DMLOptions();
        //         dml.DuplicateRuleHeader.AllowSave = true;
        //         List<Database.LeadConvertResult> lcr = Database.convertLead(MassLeadconvert, dml);

        //         if (!System.isBatch()) {
        //             for (Database.LeadConvertResult l : lcr) {
        //                 if (l.isSuccess()) {
        //                     leadConvertMap.put(l.getLeadId(), l);
        //                 } else {
        //                     Database.Error[] errors = l.getErrors();
        //                     System.debug(errors);
        //                     for (Database.Error error : errors) {
        //                         System.debug(error.getFields());
        //                         System.debug(error.getMessage());
        //                         System.debug(error.getStatusCode());
        //                         throw new applicationException(error.getMessage() + ' ' + error.getFields());
        //                     }
        //                 }
        //             }
        //             if (leadConvertMap.size() > 0) {
        //                 InteractionWithoutSharing.futureUpdateInteractions(leadConvertMap.keySet());
        //             }
        //         }
        //     }
        // }
        //TriggerFactory.RUN_TRIGGER_LOGIC = true;
    }

    private static void campaignDates(List<Lead> newLeads) {
        for (Lead c : newLeads) {
            if (c.WEG_FirstRespondedCampaign__c != null) {
                c.WEG_FirstRespondedDate__c = Date.today();
            }

            if (c.WEG_LastRespondedCampaign__c != null) {
                c.WEG_LastRespondedDate__c = Date.today();
            }
        }
    }

    private static void campaignDates(Map<Id, Lead> newLead, Map<Id, Lead> oldLead) {
        for (Id key : newLead.keySet()) {
            if (newLead.get(key).WEG_FirstRespondedCampaign__c != oldLead.get(key).WEG_FirstRespondedCampaign__c) {
                newLead.get(key).WEG_FirstRespondedDate__c = Date.today();
            }

            if (newLead.get(key).WEG_LastRespondedCampaign__c != oldLead.get(key).WEG_LastRespondedCampaign__c) {
                newLead.get(key).WEG_LastRespondedDate__c = Date.today();
            }
        }
    }

    //This was taken from WEG_LeadTriggerHandler beforeInsert
    private void setPersonator(List<Lead> newLeads) {
        // iterate the leads
        for (Lead lead : newLeads) {
            // prepare any suspect for validation
            if (lead.WEGP1_Classification__c == 'Suspect') {
                lead.WEGP1_PersonatorResultCodes__c = 'Validating...';
                lead.WEGP1_PersonatorResultText__c = 'Validating...';
            }

            // if the user unsubscribe field is checked, update the user unsubscribe timestamp
            if (lead.WEGP1_UnsubscribeAllEmails__c == 'Unsubscribed') {
                lead.WEGP1_DateUserUnsubscribe__c = DateTime.now();
            }

            // populate the lead chase, if the owner is a user
            if (lead.WEGP1_LeadChase__c == null && lead.OwnerId.getSObjectType() == User.sObjectType) {
                lead.WEGP1_LeadChase__c = lead.OwnerId;
            }
        }
    }

    //This was taken from WEG_LeadTriggerHandler afterInsert
    private void mellisaInsert(List<Lead> newLeads) {
        Set<Id> leadIds = new Set<Id>();
        // iterate the leads
        for (Lead lead : newLeads) {
            // add to the validation list any records prepped for validation
            if (lead.WEGP1_PersonatorResultCodes__c == 'Validating...') {
                leadIds.add(lead.Id);
            }
        }

        // validate select leads through Melissa Data
        if (leadIds.size() > 0) {
            verifyMelissaData_helper(leadIds);
        }
    }

    //This was taken from WEG_LeadTriggerHandler beforeUpdate
    private void updateLocation(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap) {
        List<Lead> updatedLeads = new List<Lead>();

        for (Id key : newLeadMap.keySet()) {
            System.debug('>>>>>>>> lead.Id: ' + key);

            if (newLeadMap.get(key).WEGP1_SalesOffice__c == null && oldLeadMap.get(key).WEGP1_SalesOffice__c != null) {
                System.debug('>>>>>>>> WEGP1_SalesOffice__c is getting blanked out!');
                System.debug('>>>>>>>> Setting from ' + oldLeadMap.get(key).WEGP1_SalesOffice__c + ' to ' + newLeadMap.get(key).WEGP1_SalesOffice__c);
                newLeadMap.get(key).WEGP1_SalesOffice__c = oldLeadMap.get(key).WEGP1_SalesOffice__c;
                System.debug('>>>>>>>> Patch -- Setting it back to the old value.');
            }
            if (newLeadMap.get(key).WEGP1_Region__c == null && oldLeadMap.get(key).WEGP1_Region__c != null) {
                System.debug('>>>>>>>> WEGP1_Region__c is getting blanked out!');
                System.debug('>>>>>>>> Setting from ' + oldLeadMap.get(key).WEGP1_Region__c + ' to ' + newLeadMap.get(key).WEGP1_Region__c);
                newLeadMap.get(key).WEGP1_Region__c = oldLeadMap.get(key).WEGP1_Region__c;
                System.debug('>>>>>>>> Patch -- Setting it back to the old value.');
            }

            // if location was updated, process ONLY the new location
            System.debug('>>>>>>>> Old Latitude: ' + oldLeadMap.get(key).Latitude);
            System.debug('>>>>>>>> Old Longitude: ' + oldLeadMap.get(key).Longitude);
            System.debug('>>>>>>>> Latitude: ' + newLeadMap.get(key).Latitude);
            System.debug('>>>>>>>> Longitude: ' + newLeadMap.get(key).Longitude);
            if (newLeadMap.get(key).Latitude != oldLeadMap.get(key).Latitude || newLeadMap.get(key).Longitude != oldLeadMap.get(key).Longitude) {
                System.debug('>>>>>>>> Lat/Long changed!');
                updatedLeads.add(newLeadMap.get(key));
            }
        }

        // calculate nearest office only where location was updated
        if (updatedLeads.size() > 0) {
            System.debug('>>>>>>>> prepping for set nearest');
            setNearestOffice_helper(updatedLeads);
        }
    }

    //This was taken from WEG_LeadTriggerHandler beforeUpdate
    private void updatePersonator(Map<Id, Lead> newMap, Map<Id, Lead> oldMap) {
        List<Lead> updateLeads = new List<Lead>();
        // get lead record types
        Id generalLeadTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('WEG General').getRecordTypeId();
        Id invalidLeadTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Invalid Lead').getRecordTypeId();

        for (Id key : newMap.keySet()) {
            // if personator result codes were updated, process ONLY the new result codes
            if (
                String.isNotBlank(newMap.get(key).WEGP1_PersonatorResultCodes__c) &&
                newMap.get(key).WEGP1_PersonatorResultCodes__c != oldMap.get(key).WEGP1_PersonatorResultCodes__c
            ) {
                updateLeads.add(newMap.get(key));
            } else if (
                newMap.get(key).RecordTypeId == invalidLeadTypeId &&
                (newMap.get(key).Street != oldMap.get(key).Street ||
                newMap.get(key).City != oldMap.get(key).City ||
                newMap.get(key).State != oldMap.get(key).State ||
                newMap.get(key).PostalCode != oldMap.get(key).PostalCode ||
                newMap.get(key).Email != oldMap.get(key).Email ||
                newMap.get(key).Phone != oldMap.get(key).Phone ||
                newMap.get(key).FirstName != oldMap.get(key).FirstName ||
                newMap.get(key).LastName != oldMap.get(key).LastName)
            ) {
                newMap.get(key).WEGP1_PersonatorResultCodes__c = 'Validating...';
                newMap.get(key).WEGP1_PersonatorResultText__c = 'Validating...';
            } else if (oldMap.get(key).WEGP1_Classification__c == 'Target' && newMap.get(key).WEGP1_Classification__c == 'Suspect') {
                newMap.get(key).WEGP1_PersonatorResultCodes__c = 'Validating...';
                newMap.get(key).WEGP1_PersonatorResultText__c = 'Validating...';
            }

            // if a change was made to the user unsubscribe field, update the user unsubscribe timestamp
            if (newMap.get(key).WEGP1_UnsubscribeAllEmails__c != oldMap.get(key).WEGP1_UnsubscribeAllEmails__c) {
                newMap.get(key).WEGP1_DateUserUnsubscribe__c = DateTime.now();
            }

            if (newMap.get(key).RecordTypeId == generalLeadTypeId && oldMap.get(key).RecordTypeId == invalidLeadTypeId) {
                newMap.get(key).WEGP1_ContactState__c = 'Valid';
            }

            // update the lead chase, if the owner was updated
            if (
                newMap.get(key).OwnerId != oldMap.get(key).OwnerId &&
                (newMap.get(key).WEGP1_LeadChase__c == null || (newMap.get(key).WEGP1_LeadChase__c == oldMap.get(key).OwnerId))
            ) {
                //lead.WEGP1_PreferredName__c = lead.OwnerId;
                if (newMap.get(key).OwnerId.getSObjectType() == User.sObjectType) {
                    newMap.get(key).WEGP1_LeadChase__c = newMap.get(key).OwnerId;
                }
            }
        }

        // update contact state only where the personator result codes were updated
        if (updateLeads.size() > 0) {
            setMelissaDataContactState_helper(updateLeads);
        }
    }

    //This was taken from WEG_LeadTriggerHandler afterUpdate
    private void updateConvertedContacts(List<Lead> newLeads) {
        Id invalidLeadTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Invalid Lead').getRecordTypeId();
        Map<Id, List<Lead>> leadToContactMapping = new Map<Id, List<Lead>>();
        Set<Id> updateIds = new Set<Id>();

        for (Lead lead : newLeads) {
            if (lead.ConvertedContactId != null) {
                if (!leadToContactMapping.containsKey(lead.ConvertedContactId)) {
                    leadToContactMapping.put(lead.ConvertedContactId, new List<lead>{ lead });
                } else {
                    leadToContactMapping.get(lead.ConvertedContactId).add(lead);
                }
            }
            // add to the validation list any records prepped for validation
            if (lead.WEGP1_PersonatorResultCodes__c == 'Validating...') {
                updateIds.add(lead.Id);
            }
        }

        // process reparented tasks during a lead to contact merge/conversion
        if (leadToContactMapping.size() > 0)
            processConvertedContactTasks_helper(leadToContactMapping);

        // validate select leads through Melissa Data
        if (updateIds.size() > 0)
            verifyMelissaData_helper(updateIds);
    }

    //This was taken from WEG_LeadTriggerHandler afterDelete
    private void moveTasks(List<Lead> oldLeads) {
        Map<Id, List<Lead>> leadToLeadMapping = new Map<Id, List<Lead>>();
        System.debug('>>>>>>>>>> Lead - After Delete');

        // iterate the leads
        for (Lead lead : oldLeads) {
            //
            if (lead.MasterRecordId != null) {
                System.debug('>>>>>>>>>> Lead ' + lead.LastName + ' with Id ' + lead.Id + ' was deleted in a merge.');
                System.debug('>>>>>>>>>> MasterRecordId is: ' + lead.MasterRecordId);

                //
                List<Lead> deletedLeads = leadToLeadMapping.get(lead.MasterRecordId);

                if (deletedLeads == null) {
                    deletedLeads = new List<Lead>();
                    leadToLeadMapping.put(lead.MasterRecordId, deletedLeads);
                }

                deletedLeads.add(lead);
            }
        }

        // process reparented tasks during a lead to lead merge
        if (leadToLeadMapping.size() > 0)
            processMergedLeadTasks_helper(leadToLeadMapping);
    }

    //This was taken from Wave6_LeadTrigger afterInsert
    //TODO CONVERTED
    private void wave6(List<Lead> newLeads) {
        list<string> convertedAccIds = new List<String>();
        for (Lead lead : newLeads) {
            if (lead.IsConverted) {
                convertedAccIds.add(lead.ConvertedAccountId);
            }
        }

        Id indRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        Map<Id, Account> indAccountMap = new Map<Id, Account>(
            [
                SELECT Id, Name, RecordTypeId, WEGP1_Is_Converted__c, WEGP1_Region__c, WEGP1_Office__c
                FROM Account
                WHERE Id IN :convertedAccIds AND RecordTypeId = :indRecordTypeId
            ]
        );

        for (Account acc : indAccountMap.Values()) {
            acc.WEGP1_Is_Converted__c = true;
        }

        try {
            update indAccountMap.Values();
        } catch (exception ex) {
            system.debug('Error Occurred while updating Accounts.');
        }
    }

    private void setMelissaDataContactState_helper(List<Lead> updateLeads) {
        Id generalLeadTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('WEG General').getRecordTypeId();
        Id invalidLeadTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Invalid Lead').getRecordTypeId();
        // instantiate exception lists
        List<String> nameExceptions = new List<String>{ 'NE01', 'NE02', 'NE03', 'NE04', 'NE06' };
        List<String> addressExceptions = new List<String>{
            'AE01',
            'AE02',
            'AE03',
            'AE04',
            'AE08',
            'AE09',
            'AE10',
            'AE11',
            'AE12',
            'AE13',
            'AE14',
            'AS02',
            'AS09',
            'AS16',
            'AS17',
            'AS18',
            'AS22'
        };
        List<String> emailExceptions = new List<String>{ 'ES02', 'ES03', 'ES06', 'ES20', 'EE01', 'EE02', 'EE03', 'EE04' };
        List<String> phoneExceptions = new List<String>{ 'PE01', 'PE02', 'PE03', 'PE04', 'PE05', 'PE06', 'PE08', 'PE09', 'PE10' };

        // review the codes for each lead
        for (Lead lead : updateLeads) {
            // reset the flags for each lead
            Boolean invalidName = false;
            Boolean invalidAddress = false;
            Boolean invalidEmail = false;
            Boolean invalidPhone = false;
            Boolean rejected = false;

            // iterate name exception codes
            for (String exceptionString : nameExceptions) {
                if (lead.WEGP1_PersonatorResultCodes__c.contains(exceptionString))
                    invalidName = true;
            }

            // iterate address exception codes
            for (String exceptionString : addressExceptions) {
                if (lead.WEGP1_PersonatorResultCodes__c.contains(exceptionString))
                    invalidAddress = true;
            }

            // iterate email exception codes
            for (String exceptionString : emailExceptions) {
                if (lead.WEGP1_PersonatorResultCodes__c.contains(exceptionString))
                    invalidEmail = true;
            }

            // iterate phone exception codes
            for (String exceptionString : phoneExceptions) {
                if (lead.WEGP1_PersonatorResultCodes__c.contains(exceptionString))
                    invalidPhone = true;
            }

            // validation rules require First & Last Name as well as one other piece of information (Phone, Mobile, Email, Full Address)
            // if the name is invalid, the lead is rejected
            if (invalidName) {
                // update the result text
                lead.WEGP1_PersonatorResultText__c = 'Invalid Name';

                // set the record type to invalid and contact state to reject
                lead.RecordTypeId = invalidLeadTypeId;
                lead.WEGP1_ContactState__c = 'Rejected';
            } else if (invalidAddress || invalidEmail || invalidPhone) {
                // if anything is invalid, we will need to check for invalid vs reject
                // check for invalid email
                if (invalidEmail) {
                    lead.WEGP1_PersonatorResultText__c = 'Invalid Email';

                    // if nothing else populated and valid, reject the lead
                    if ((String.isBlank(lead.Street) || invalidAddress) && (String.isBlank(lead.Phone) || invalidPhone))
                        rejected = true;
                }

                // then address
                if (invalidAddress) {
                    if (invalidEmail)
                        lead.WEGP1_PersonatorResultText__c += ' & Address';
                    else
                        lead.WEGP1_PersonatorResultText__c = 'Invalid Address';

                    // if nothing else populated and valid, reject the lead
                    if ((String.isBlank(lead.Email) || invalidEmail) && (String.isBlank(lead.Phone) || invalidPhone))
                        rejected = true;
                }

                // then phone
                if (invalidPhone) {
                    if (invalidAddress || invalidEmail)
                        lead.WEGP1_PersonatorResultText__c += ' & Phone';
                    else
                        lead.WEGP1_PersonatorResultText__c = 'Invalid Phone';

                    // if nothing else populated and valid, reject the lead
                    if ((String.isBlank(lead.Email) || invalidEmail) && (String.isBlank(lead.Street) || invalidAddress))
                        rejected = true;
                }

                // change the lead record type to invalid
                lead.RecordTypeId = invalidLeadTypeId;

                // update the contact state to either invalid or reject
                if (rejected)
                    lead.WEGP1_ContactState__c = 'Rejected';
                else
                    lead.WEGP1_ContactState__c = 'Invalid';
            } else {
                // otherwise the lead is valid
                // initially set state and record type to valid
                lead.WEGP1_ContactState__c = 'Valid';
                lead.RecordTypeId = generalLeadTypeId;
                lead.WEGP1_PersonatorResultText__c = '';
            }
        }
    }

    private void setNearestOffice_helper(List<Lead> updateLeads) {
        System.debug('>>>>>>>>>>>>> Lat/Long was updated.');

        // query all office locations
        List<WEGP1_Office__c> offices = [
            SELECT Id, Name, WEGP1_Location__c, WEGP1_GeographicRegion__c, WEGP1_NationalRadius__c
            FROM WEGP1_Office__c
            WHERE WEGP1_Location__latitude__s != NULL AND WEGP1_Location__longitude__s != NULL AND WEGP1_NationalRadius__c != NULL
        ];

        // query the National office
        WEGP1_Office__c nationalOffice = [SELECT Id, Name, WEGP1_GeographicRegion__c FROM WEGP1_Office__c WHERE Name = 'National'];
        if (nationalOffice == null) {
            System.debug('>>>>>>>>>>>>> National Office is NULL.');
            return;
        }

        // instantiate helper variables
        Double nearestOfficeDistance = null;
        WEGP1_Office__c nearestOffice = null;
        Double distance = null;

        for (Lead lead : updateLeads) {
            // null the nearest fields if no latitude or longitude exist
            if (lead.Latitude == null || lead.Longitude == null) {
                lead.WEGP1_DistanceNearestOffice__c = null;
                lead.WEGP1_NearestOffice__c = null;
                lead.WEGP1_GeographicalRegion__c = null;
                System.debug('>>>>>>>>>>>>> Lead location is NULL.');
                continue;
            }

            // instantiate the location based on latitude and longitude
            Location leadLocation = Location.newInstance(lead.Latitude, lead.Longitude);
            System.debug('>>>>>>>>>>>>> Lead Location = ' + leadLocation);

            // reset nearest office and determine nearest office
            nearestOffice = null;
            for (WEGP1_Office__c office : offices) {
                // hardcode rule for Meehan contract :: for any lead in Illinois, skip the office if it's not an Illinois office
                if (lead.State == 'IL' && office.WEGP1_GeographicRegion__c != 'IL')
                    continue;

                // calculate the distance between the lead and office
                distance = Location.getDistance(leadLocation, office.WEGP1_Location__c, 'mi');
                System.debug('>>>>>>>>>>>>> Distance to ' + office.WEGP1_Location__c + ' is ' + distance);

                // if nearest office isn't set, set it to the first office
                if (nearestOffice == null) {
                    nearestOffice = office;
                    nearestOfficeDistance = distance;
                } else if (distance < nearestOfficeDistance) {
                    // else, compare the current office distance to the closest
                    // update the nearest if closer
                    nearestOffice = office;
                    nearestOfficeDistance = distance;
                }
            }

            // iteration of all offices complete
            System.debug('>>>>>>>> nearestOffice is ' + nearestOffice + '.');

            // update the nearest office and distance to
            lead.WEGP1_NearestOffice__c = nearestOffice.Name;
            lead.WEGP1_DistanceNearestOffice__c = nearestOfficeDistance;

            // determine if nearest office should be National based on National Radius
            // hardcode rule for Meehan contract :: National doesn't apply
            if (lead.State != 'IL' && nearestOfficeDistance > nearestOffice.WEGP1_NationalRadius__c)
                nearestOffice = nationalOffice;

            // set the geographical region after national has been applied (if found necessary)
            lead.WEGP1_GeographicalRegion__c = nearestOffice.WEGP1_GeographicRegion__c;

            // only set the sales office and regions if they aren't currently set (initial population)
            System.debug('>>>>>>>> nearestOffice.Id: ' + nearestOffice.Id);
            System.debug('>>>>>>>> lead.WEGP1_SalesOffice__c: ' + lead.WEGP1_SalesOffice__c);
            if (lead.WEGP1_SalesOffice__c == null) {
                System.debug('>>>>>>>> setting sales office from ' + lead.WEGP1_SalesOffice__c + ' to ' + nearestOffice.Id);
                lead.WEGP1_SalesOffice__c = nearestOffice.Id;
            }
            if (lead.WEGP1_Region__c == null) {
                System.debug('>>>>>>>> setting region from ' + lead.WEGP1_Region__c + ' to ' + nearestOffice.WEGP1_GeographicRegion__c);
                lead.WEGP1_Region__c = nearestOffice.WEGP1_GeographicRegion__c;
            }
        }
    }

    private void verifyMelissaData_helper(Set<Id> leadIds) {
        System.debug('>>>>>>>> Calling personator.');
        if (!Test.isRunningTest()) {
            try {
                MDPERSONATOR.MD_PersonatorWSExt.doBatchVerify(leadIds);
            } catch (Exception ex) {
                System.debug('>>>>>>>> Issue occured.' + ex);
            }
        }
    }

    private void processConvertedContactTasks_helper(Map<Id, List<Lead>> leadMap) {
        User sfAdmin = [SELECT Id FROM User WHERE LastName = 'Admin' AND FirstName = 'Salesforce'];
        // lists to track tasks being reassigned/deleted
        List<Task> reassignedTasks = new List<Task>();
        List<Task> deletedTasks = new List<Task>();

        System.debug('>>>>>>>> LeadTrigger > Getting the converted contacts. ');

        // get the master contacts and corresponding tasks
        for (Contact contact : [
            SELECT
                Id,
                OwnerId,
                LastName,
                WEGP1_ContactStatus__c,
                Classification__c,
                New_Client_Team_Opportunity_Amount__c,
                WEGP1_Lead_Chase__c,
                (SELECT Id, OwnerId, Subject, WEGP1_OriginalLeadID__c, Description FROM Tasks)
            FROM Contact
            WHERE Id IN :leadMap.keySet()
        ]) {
            System.debug('>>>>>>>> LeadTrigger > Master Contact ' + contact.LastName + ' has Id ' + contact.Id + '. ');

            //if (!leadToContactMapping.containsKey(contact.Id))
            //continue;

            // get the converted lead
            for (Lead convertedLead : leadMap.get(contact.Id)) {
                System.debug('>>>>>>>> LeadTrigger > Lead Id was ' + convertedLead.Id + '.');

                // iterate the master contact's tasks
                for (Task t : contact.Tasks) {
                    System.debug('>>>>>>>> LeadTrigger > Contact has task with Subject ' + t.Subject + '.');
                    System.debug('>>>>>>>> LeadTrigger > Contact has task with Original Lead ID ' + t.WEGP1_OriginalLeadID__c + '.');

                    // only reassign tasks with an original lead id
                    if (t.WEGP1_OriginalLeadID__c != null) {
                        Id taskOriginalLeadId = Id.valueOf(t.WEGP1_OriginalLeadID__c);
                        System.debug('>>>>>>>> Id is not NULL and is ' + taskOriginalLeadId + '.');

                        // the original lead id on the task must match the Id of the converted lead
                        if (taskOriginalLeadId == convertedLead.Id) {
                            System.debug('>>>>>>>> Task matches original lead id.');

                            // if the master contact is not active, delete the merged tasks
                            if (contact.WEGP1_ContactStatus__c != 'Active') {
                                System.debug('Master contact is not Active. Task will be deleted.');

                                // add the task to the list for deletion
                                deletedTasks.add(t);
                            } else if (contact.Classification__c != 'Prospect') {
                                // if the master contact is not a prospect, delete the merged tasks
                                System.debug('Master contact is not a Prospect. Task will be deleted.');

                                // add the task to the list for deletion
                                deletedTasks.add(t);
                            } else if (
                                contact.New_Client_Team_Opportunity_Amount__c == 0 ||
                                (contact.New_Client_Team_Opportunity_Amount__c == null &&
                                convertedLead.WEGP1_NewClientTeamOpportunityAmount__c == 0)
                            ) {
                                // if the master contact has no NCT opportunity amount, delete the merged tasks
                                System.debug('Master contact has no NCT Opportunity Amount. Task will be deleted.');

                                // add the task to the list for deletion
                                deletedTasks.add(t);
                            } else {
                                // update the owner to match the contact's lead chase
                                // SF Admin if no lead chase is on the contact
                                if (contact.WEGP1_Lead_Chase__c != null)
                                    t.OwnerId = contact.WEGP1_Lead_Chase__c;
                                else {
                                    t.OwnerId = sfAdmin.Id;
                                }

                                // add the task to the list for reassignment
                                reassignedTasks.add(t);
                            }
                        }
                    }
                }
            }
        }

        // update the tasks
        if (reassignedTasks.size() > 0) {
            try {
                update reassignedTasks;
            } catch (DmlException ex) {
                System.debug('An unexpected error has occurred: ' + ex.getMessage());
            }
        }

        // delete the tasks
        if (deletedTasks.size() > 0) {
            try {
                delete deletedTasks;
            } catch (DmlException ex) {
                System.debug('An unexpected error has occurred: ' + ex.getMessage());
            }
        }
    }

    private void processMergedLeadTasks_helper(Map<Id, List<Lead>> leadToLeadMapping) {
        // lists to track tasks being reassigned/deleted
        List<Task> reassignedTasks = new List<Task>();
        List<Task> deletedTasks = new List<Task>();

        // get the master leads and corresponding tasks
        for (Lead lead : [
            SELECT
                Id,
                OwnerId,
                Owner.Type,
                LastName,
                Status,
                WEGP1_NewClientTeamOpportunityAmount__c,
                WEGP1_Age__c,
                (SELECT Id, OwnerId, Subject, WEGP1_OriginalLeadID__c, Description FROM Tasks)
            FROM Lead
            WHERE Id IN :leadToLeadMapping.keySet()
        ]) {
            System.debug('>>>>>>>>>> Original/Master lead name is ' + lead.LastName + ' with Id ' + lead.Id + '.');
            System.debug('>>>>>>>>>> Original/Master lead owner type is ' + lead.Owner.Type + '.');

            // iterate deleted leads in case multiple leads were merged
            for (Lead deletedLead : leadToLeadMapping.get(lead.Id)) {
                System.debug('>>>>>>>>>> Deleted Lead Id is ' + deletedLead.Id);

                // iterate the master lead's tasks
                for (Task t : lead.Tasks) {
                    System.debug('>>>>>>>>>> Lead has task with Subject ' + t.Subject + '.');
                    System.debug('>>>>>>>>>> Lead has task with Original Lead ID ' + t.WEGP1_OriginalLeadID__c + '.');

                    // only reassign tasks with an original lead id
                    if (t.WEGP1_OriginalLeadID__c != null) {
                        Id taskOriginalLeadId = Id.valueOf(t.WEGP1_OriginalLeadID__c);
                        System.debug('>>>>>>>>>> Converted originalLeadId is ' + taskOriginalLeadId + '.');

                        // the original lead id on the task must match the deleted lead id
                        if (taskOriginalLeadId == deletedLead.Id) {
                            System.debug('>>>>>>>>>> Task matches original lead id.');

                            // if the master lead is unqualified, delete the merged tasks
                            if (lead.Status == 'Unqualified' || (lead.Status == null && deletedLead.Status == 'Unqualified')) {
                                System.debug('Master lead is Unqualified. Task will be deleted.');

                                // add the task to the list for deletion
                                deletedTasks.add(t);
                            } else if (
                                lead.WEGP1_NewClientTeamOpportunityAmount__c == 0 ||
                                (lead.WEGP1_NewClientTeamOpportunityAmount__c == null &&
                                deletedLead.WEGP1_NewClientTeamOpportunityAmount__c == 0)
                            ) {
                                // if the master lead has no NCT opportunity amount, delete the merged tasks
                                System.debug('Master lead has zero NCT Opportunity Amount. Task will be deleted.');

                                // add the task to the list for deletion
                                deletedTasks.add(t);
                            } else if (lead.WEGP1_Age__c == '75 or Older' || (lead.WEGP1_Age__c == null && deletedLead.WEGP1_Age__c == '75 or Older')) {
                                //
                                System.debug('Master lead has zero NCT Opportunity Amount. Task will be deleted.');

                                // add the task to the list for deletion
                                deletedTasks.add(t);
                            } else if (lead.Owner.Type == 'User') {
                                // only if the owner of the original lead is a User will the task owner be reassigned
                                // update the owner to match the new lead owner
                                t.OwnerId = lead.OwnerId;

                                // add the task to the list for reassignment
                                reassignedTasks.add(t);
                            }
                        }
                    }
                }
            }
        }

        // update the tasks
        if (reassignedTasks.size() > 0) {
            try {
                update reassignedTasks;
            } catch (DmlException ex) {
                System.debug('An unexpected error has occurred: ' + ex.getMessage());
            }
        }

        // delete the tasks
        if (deletedTasks.size() > 0) {
            try {
                delete deletedTasks;
            } catch (DmlException ex) {
                System.debug('An unexpected error has occurred: ' + ex.getMessage());
            }
        }
    }

    private class applicationException extends Exception {
    }
}