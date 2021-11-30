public class WEG_FulfillmentRequestTriggerHandler
{
    private Set<Id> leadIds = new Set<Id>();
    private Set<Id> requestUpdatedLeads = new Set<Id>();
    private Set<Id> requestUpdatedContacts = new Set<Id>();
    
    public void afterInsert() {
        
        // iterate the inserted fulfillment requests
        for (Fulfillment_Request__c fr : (List<Fulfillment_Request__c>)Trigger.new) {
            if (fr.WEGP1_Status__c == 'Open') {
                leadIds.add(fr.WEGP1_Lead__c);
            }
            
            if (fr.WEGP1_Contact__c != null && !requestUpdatedContacts.contains(fr.WEGP1_Contact__c)) {
                requestUpdatedContacts.add(fr.WEGP1_Contact__c);
            }
            
            else if (fr.WEGP1_Lead__c != null && !requestUpdatedLeads.contains(fr.WEGP1_Lead__c)) {
                requestUpdatedLeads.add(fr.WEGP1_Lead__c);
            }
        }
        
        // update the request count if applicable
        if (!leadIds.isEmpty()) {
            updateFulfillmentRequestCount();
        }
        
        // update the fulfillment items on the contact
        if (requestUpdatedContacts.size() > 0)
            updateContactFulfillmentItems();
        
        // update the fulfillment items on the lead
        if (requestUpdatedLeads.size() > 0)
            updateLeadFulfillmentItems();
    }
    
    public void afterUpdate() {
        
        // iterate the updated fulfillment requests
        for (Fulfillment_Request__c fr : (List<Fulfillment_Request__c>)Trigger.new) {
            // 
            if (fr.WEGP1_Status__c == 'Open') {
                leadIds.add(fr.WEGP1_Lead__c);
            }
            
            if (fr.WEGP1_Contact__c != null && !requestUpdatedContacts.contains(fr.WEGP1_Contact__c)) {
                requestUpdatedContacts.add(fr.WEGP1_Contact__c);
            }
            
            else if (fr.WEGP1_Lead__c != null && !requestUpdatedLeads.contains(fr.WEGP1_Lead__c)) {
                requestUpdatedLeads.add(fr.WEGP1_Lead__c);
            }
        }
        
        for (Fulfillment_Request__c fr : (List<Fulfillment_Request__c>)Trigger.old) {
            if (fr.WEGP1_Status__c == 'Open') {
                leadIds.add(fr.WEGP1_Lead__c);
            }
        }
        
        // update the request count if applicable
        if (!leadIds.isEmpty()) {
            updateFulfillmentRequestCount();
        }
        
        // update the fulfillment items on the contact
        if (requestUpdatedContacts.size() > 0)
            updateContactFulfillmentItems();
        
        // update the fulfillment items on the lead
        if (requestUpdatedLeads.size() > 0)
            updateLeadFulfillmentItems();
    }
    
    public void afterDelete() {
        
        // iterate the deleted fulfillment requests
        for (Fulfillment_Request__c fr : (List<Fulfillment_Request__c>)Trigger.old) {
            if (fr.WEGP1_Status__c == 'Open') {
                leadIds.add(fr.WEGP1_Lead__c);
            }
            
            if (fr.WEGP1_Contact__c != null && !requestUpdatedContacts.contains(fr.WEGP1_Contact__c)) {
                requestUpdatedContacts.add(fr.WEGP1_Contact__c);
            }
            
            else if (fr.WEGP1_Lead__c != null && !requestUpdatedLeads.contains(fr.WEGP1_Lead__c)) {
                requestUpdatedLeads.add(fr.WEGP1_Lead__c);
            }
        }
        
        // update the request count if applicable
        if (!leadIds.isEmpty()) {
            updateFulfillmentRequestCount();
        }
        
        // update the fulfillment items on the contact
        if (requestUpdatedContacts.size() > 0)
            updateContactFulfillmentItems();
        
        // update the fulfillment items on the lead
        if (requestUpdatedLeads.size() > 0)
            updateLeadFulfillmentItems();
    }
    
    private void updateContactFulfillmentItems() {
        
        // instantiate the list of contacts that will be updated
        List<Contact> contacts = [SELECT Id, WEGP1_FulfillmentItems__c, WEGP1_LeadFulfillmentItems__c
                            , (SELECT Id, WEGP1_Fulfillment_Item_1__r.Name, WEGP1_Fulfillment_Item_2__r.Name, WEGP1_Fulfillment_Item_3__r.Name, WEGP1_Fulfillment_Item_4__r.Name FROM Fulfillment_Requests__r)
                            FROM Contact
                            WHERE Id IN :requestUpdatedContacts];
        
        // iterate the contacts associated to the updated fulfillment requests
        for (Contact contact : contacts) {            
            // 
            if (String.isBlank(contact.WEGP1_LeadFulfillmentItems__c))
                contact.WEGP1_FulfillmentItems__c = '';
            else
                contact.WEGP1_FulfillmentItems__c = contact.WEGP1_LeadFulfillmentItems__c;
            
            for(Fulfillment_Request__c fr : contact.Fulfillment_Requests__r) {
                
                // append each fulfillment item where applicable
                if (fr.WEGP1_Fulfillment_Item_1__r.Name != null && !contact.WEGP1_FulfillmentItems__c.contains(fr.WEGP1_Fulfillment_Item_1__r.Name))
                    contact.WEGP1_FulfillmentItems__c += ', ' + fr.WEGP1_Fulfillment_Item_1__r.Name;
                if (fr.WEGP1_Fulfillment_Item_2__r.Name != null && !contact.WEGP1_FulfillmentItems__c.contains(fr.WEGP1_Fulfillment_Item_2__r.Name))
                    contact.WEGP1_FulfillmentItems__c += ', ' + fr.WEGP1_Fulfillment_Item_2__r.Name;
                if (fr.WEGP1_Fulfillment_Item_3__r.Name != null && !contact.WEGP1_FulfillmentItems__c.contains(fr.WEGP1_Fulfillment_Item_3__r.Name))
                    contact.WEGP1_FulfillmentItems__c += ', ' + fr.WEGP1_Fulfillment_Item_3__r.Name;
                if (fr.WEGP1_Fulfillment_Item_4__r.Name != null && !contact.WEGP1_FulfillmentItems__c.contains(fr.WEGP1_Fulfillment_Item_4__r.Name))
                    contact.WEGP1_FulfillmentItems__c += ', ' + fr.WEGP1_Fulfillment_Item_4__r.Name;
            }
            
            contact.WEGP1_FulfillmentItems__c = contact.WEGP1_FulfillmentItems__c.removeStart(', ');
        }
        
        // update the contacts
        if (contacts.size() > 0) {
            try { update contacts; } catch (DmlException ex) { System.debug('An unexpected error has occurred: ' + ex.getMessage()); }
        }
    }
    
    private void updateLeadFulfillmentItems() {
    
        // instantiate the list of leads that will be updated
        List<Lead> leads = [SELECT Id, WEGP1_FulfillmentItems__c
                            , (SELECT Id, WEGP1_Fulfillment_Item_1__r.Name, WEGP1_Fulfillment_Item_2__r.Name, WEGP1_Fulfillment_Item_3__r.Name, WEGP1_Fulfillment_Item_4__r.Name FROM Fulfillment_Requests__r)
                            FROM Lead
                            WHERE Id IN :requestUpdatedLeads];
        
        // iterate the leads associated to the updated fulfillment requests
        for (Lead lead : leads) {
            //if (lead.WEGP1_FulfillmentItems__c == null) {
            lead.WEGP1_FulfillmentItems__c = '';
            
            for(Fulfillment_Request__c fr : lead.Fulfillment_Requests__r) {
                // append each fulfillment item where applicable
                if (fr.WEGP1_Fulfillment_Item_1__r.Name != null && !lead.WEGP1_FulfillmentItems__c.contains(fr.WEGP1_Fulfillment_Item_1__r.Name))
                    lead.WEGP1_FulfillmentItems__c += ', ' + fr.WEGP1_Fulfillment_Item_1__r.Name;
                if (fr.WEGP1_Fulfillment_Item_2__r.Name != null && !lead.WEGP1_FulfillmentItems__c.contains(fr.WEGP1_Fulfillment_Item_2__r.Name))
                    lead.WEGP1_FulfillmentItems__c += ', ' + fr.WEGP1_Fulfillment_Item_2__r.Name;
                if (fr.WEGP1_Fulfillment_Item_3__r.Name != null && !lead.WEGP1_FulfillmentItems__c.contains(fr.WEGP1_Fulfillment_Item_3__r.Name))
                    lead.WEGP1_FulfillmentItems__c += ', ' + fr.WEGP1_Fulfillment_Item_3__r.Name;
                if (fr.WEGP1_Fulfillment_Item_4__r.Name != null && !lead.WEGP1_FulfillmentItems__c.contains(fr.WEGP1_Fulfillment_Item_4__r.Name))
                    lead.WEGP1_FulfillmentItems__c += ', ' + fr.WEGP1_Fulfillment_Item_4__r.Name;
            }
            
            lead.WEGP1_FulfillmentItems__c = lead.WEGP1_FulfillmentItems__c.removeStart(', ');
        }
        
        // update the leads
        if (leads.size() > 0) {
            try { update leads; } catch (DmlException ex) { System.debug('An unexpected error has occurred: ' + ex.getMessage()); }
        }
    }
    
    private void updateFulfillmentRequestCount() {
        
        List<Lead> leadsToUpdate = new List<Lead>();
        
        // get a map of the Leads with the number of Open Fulfillments
        map<Id,Lead> leadMap = new map<Id,Lead>([select Id, WEGP1_No_of_Open_Fulfillments__c from Lead where id IN :leadIds]);
        System.debug('>>>>>>>>>> leadMap is ' + leadMap);

        // query the Leads and the related Fulfillment Request and add the size of the Open Fulfillment Request  to the Lead's WEGP1_No_of_Open_Fulfillments__c
        for (Lead ld : [Select Id, Name, WEGP1_No_of_Open_Fulfillments__c,(Select id from Fulfillment_Requests__r Where WEGP1_Status__c = 'Open') From Lead Where Id IN :leadIds]) {
            leadMap.get(ld.Id).WEGP1_No_of_Open_Fulfillments__c = ld.Fulfillment_Requests__r.size();

            // add the value/Lead in the map to a list so we can update it
            leadsToUpdate.add(leadMap.get(ld.Id));
        }

        try { update leadsToUpdate; } catch (exception ex) { System.debug('Error occurred while updating Leads : ' + ex.getMessage()); }
    }
}