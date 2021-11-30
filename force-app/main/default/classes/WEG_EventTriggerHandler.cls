public class WEG_EventTriggerHandler {
    
    public void afterInsert() {
        
        map<Id, Id> eventOpportunities = new map<Id, Id>();
        
        // iterate the deleted fulfillment requests
        for (Event evt : (List<Event>)Trigger.new) {
            if (evt.WEGP1_MeetingType__c == 'Needs Analysis') {
                eventOpportunities.put(evt.Id, evt.WhatId);
            }
        }
        
        // update the request count if applicable
        if (!eventOpportunities.isEmpty()) {
            assignCampaigns(eventOpportunities);
        }
    }
    
    public void assignCampaigns(map<Id, Id> eventOpportunities) {
        // 
        List<Opportunity> ops = [SELECT Id, Household__c, Household__r.WEGP1_Primary_Individual__c, Household__r.WEGP1_Secondary_Individual__c
                                 FROM Opportunity
                                 WHERE Id IN :eventOpportunities.values()];
        
        // collect up the contact ids of the household individuals
        map<Id, Id> opportunityPrimaryContacts = new map<Id, Id>();
        map<Id, Id> opportunitySecondaryContacts = new map<Id, Id>();
        set<Id> contactIds = new set<Id>();
        for (Opportunity op : ops) {
            
            if (op.Household__r.WEGP1_Primary_Individual__c != null) {
            	opportunityPrimaryContacts.put(op.Id, op.Household__r.WEGP1_Primary_Individual__c);
                contactIds.add(op.Household__r.WEGP1_Primary_Individual__c);
            }
            
            if (op.Household__r.WEGP1_Secondary_Individual__c != null) {
                opportunitySecondaryContacts.put(op.Id, op.Household__r.WEGP1_Secondary_Individual__c);
            	contactIds.add(op.Household__r.WEGP1_Secondary_Individual__c);
            }
        }
        
        // get the contacts and their campaign memberships
        List<Contact> ctcs = [SELECT Id,
                              	(SELECT Id, WEGP1_ResponseDate__c, Campaign.Id
                                 FROM CampaignMembers
                                 WHERE HasResponded = true)
                              FROM Contact
                              WHERE Id IN :contactIds];
        
        // map them
        map<Id, List<CampaignMember>> contactCampaignMembers = new map<Id, List<CampaignMember>>();
        for (Contact ctc : ctcs) {
            contactCampaignMembers.put(ctc.Id, ctc.CampaignMembers);
        }
        
        List<Event> evts = [SELECT Id, WhatId, WEG_Campaign__c, CreatedDate
                            FROM Event
                            WHERE Id IN :eventOpportunities.keySet()];
        
        for (Event evt : evts) {
            DateTime campaignDate = datetime.newInstance(1990, 1, 1);
            
            // get the primary contact id based on the event's opportunity id
            Id primaryContactId = opportunityPrimaryContacts.get(evt.WhatId);
            if (primaryContactId != null) {
                // 
                List<CampaignMember> campaignMembers = contactCampaignMembers.get(primaryContactId);
                for (CampaignMember cm : campaignMembers) {
                    if (cm.WEGP1_ResponseDate__c <= evt.CreatedDate && cm.WEGP1_ResponseDate__c > campaignDate) {
                        evt.WEG_Campaign__c = cm.Campaign.Id;
                        campaignDate = cm.WEGP1_ResponseDate__c;
                    }
                }
            }
            
            // get the secondary contact id based on the event's opportunity id
            Id secondaryContactId = opportunitySecondaryContacts.get(evt.WhatId);
            if (secondaryContactId != null) {
                // 
                List<CampaignMember> campaignMembers = contactCampaignMembers.get(secondaryContactId);
                for (CampaignMember cm : campaignMembers) {
                    if (cm.WEGP1_ResponseDate__c <= evt.CreatedDate && cm.WEGP1_ResponseDate__c > campaignDate) {
                        evt.WEG_Campaign__c = cm.Campaign.Id;
                        campaignDate = cm.WEGP1_ResponseDate__c;
                    }
                }
            }
        }
        
        update evts;
    }
}