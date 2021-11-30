public class WEG_AccountTriggerHandler
{    
    private Map<Id, Account> contactHouseholdMap = new Map<Id, Account>();
    private Set<Id> contactsToSyncStatus = new Set<Id>();
    private Set<Id> contactsToSyncReasonInactive = new Set<Id>();
    private Set<Id> contactsToSyncReasonNoOppty = new Set<Id>();
    private Set<Id> contactsToSyncClassification = new Set<Id>();
    private Set<Id> contactsToSyncLeadSeg = new Set<Id>();
    private Set<Id> contactsToSyncReferredBy = new Set<Id>();
    
    private void addIndividualsToSyncSet(Account acct, Set<Id> contactSet, string setName) {
        System.debug('>>>>>>>> ' + setName + ' updated for Household ' + acct.Id + '.');
        
        // ensure the household has a primary individual
        if (acct.WEGP1_Primary_Individual__c != null) {
            System.debug('>>>>>>>> Primary Individual is ' + acct.WEGP1_Primary_Individual__c);
            
            // add the primary contact to the map if it hasn't been added
            if (contactHouseholdMap.get(acct.WEGP1_Primary_Individual__c) == null)
                contactHouseholdMap.put(acct.WEGP1_Primary_Individual__c, acct);
            
            // add the primary contact to the set
            contactSet.add(acct.WEGP1_Primary_Individual__c);
        }
        // ensure the household has a secondary individual
        if (acct.WEGP1_Secondary_Individual__c != null) {
            System.debug('>>>>>>>> Secondary Individual is ' + acct.WEGP1_Secondary_Individual__c);
            
            // add the secondary contact to the map if it hasn't been added
            if (contactHouseholdMap.get(acct.WEGP1_Secondary_Individual__c) == null)
                contactHouseholdMap.put(acct.WEGP1_Secondary_Individual__c, acct);
            
            // add the secondary contact to the set
            contactSet.add(acct.WEGP1_Secondary_Individual__c);
        }
    }
    
    public void beforeInsert() {
        System.debug('>>>> WEG_AccountTriggerHandler.beforeInsert');
        
        Id householdType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        
        // iterate the inserted accounts
        for (Account acct : (List<Account>)Trigger.new) {
            
            // if a field was updated, process ONLY those accounts that are of type Household
            if (acct.RecordTypeId == householdType) {
                
                // status
                if (acct.FinServ__Status__c == null)
                    acct.FinServ__Status__c = 'Active';
            }
        }
    }
    
    public void afterInsert() {
        System.debug('>>>> WEG_AccountTriggerHandler.afterInsert');
        
        //Id householdType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        List<Id> wetsAccounts = new List<Id>();
        
        // iterate new accounts...
        for (Account acct : (List<Account>)Trigger.new) {
            
            // add any wets members, as necessary
            if (acct.WEG_Trust_Officer__c != null) {
                wetsAccounts.add(acct.Id);
            }
        }
        
        // add any wets members, as necessary
        if (!wetsAccounts.isEmpty()) {
            insertWetsTeamMembers(wetsAccounts);
        }
    }
    
    public void afterUpdate() {
        System.debug('>>>> WEG_AccountTriggerHandler.afterUpdate');
        
        Id householdType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        
        Set<Id> householdIds = new Set<Id>();
        List<Id> wetsAccounts = new List<Id>();
        
        // iterate the updated accounts
        for (Account acct : (List<Account>)Trigger.new) {
            // get the old account
            Account oldAcct = (Account)Trigger.oldMap.get(acct.Id);
            
            // add any wets members, as necessary
            if (acct.WEG_Trust_Officer__c != null && oldAcct.WEG_Trust_Officer__c == null) {
                wetsAccounts.add(acct.Id);
            } else if (acct.OwnerId != oldAcct.OwnerId && acct.WEG_Trust_Officer__c != null) {
                wetsAccounts.add(acct.Id);
            }
            
            // if a field was updated, process ONLY those accounts that are of type Household
            if (acct.RecordTypeId == householdType) {
                System.debug('>>>> Account is a household.');
                
                // status
                if (acct.FinServ__Status__c != oldAcct.FinServ__Status__c)
                    this.addIndividualsToSyncSet(acct, contactsToSyncStatus, 'Status');
                // reason for inactive
                if (acct.WEGP1_ReasonForInactive__c != oldAcct.WEGP1_ReasonForInactive__c)
                    this.addIndividualsToSyncSet(acct, contactsToSyncReasonInactive, 'Reason for Inactive');
                // reason for no opportunity
                if (acct.WEGP1_ReasonForNoOpportunity__c != oldAcct.WEGP1_ReasonForNoOpportunity__c)
                    this.addIndividualsToSyncSet(acct, contactsToSyncReasonNoOppty, 'Reason for No Opportunity');
                // classification
                if (acct.Type != oldAcct.Type)
                    this.addIndividualsToSyncSet(acct, contactsToSyncClassification, 'Classification');
                // lead segmentation
                if (acct.WEGP1_Lead_Type__c != oldAcct.WEGP1_Lead_Type__c
                     || acct.WEGP1_Lead_SubType__c != oldAcct.WEGP1_Lead_SubType__c
                     || acct.WEGP1_Lead_Type_Detail__c != oldAcct.WEGP1_Lead_Type_Detail__c)
                    this.addIndividualsToSyncSet(acct, contactsToSyncLeadSeg, 'Lead Segmentation');
                // referred by
                if (acct.WEG_ReferredBy__c != oldAcct.WEG_ReferredBy__c)
                    this.addIndividualsToSyncSet(acct, contactsToSyncReferredBy, 'Referred By');
            }
        }
        
        // only process individuals if an applicable field was changed
        if (contactHouseholdMap.size() > 0)
            syncIndividualFields();
        
        // add any wets members, as necessary
        if (!wetsAccounts.isEmpty()) {
            insertWetsTeamMembers(wetsAccounts);
        }
    }
    
    @future
    public static void insertWetsTeamMembers(List<Id> accountIds) {
        
        // get the group members
        List<GroupMember> wetsMembers = [SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'WETS_Members'];
        
        // iterate the group members and accounts, creating account team members
        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();
        for (Id acctId : accountIds) {
            for (GroupMember wetsMember : wetsMembers) {
                
                AccountTeamMember atm = new AccountTeamMember(
                    AccountId = acctId,
                    AccountAccessLevel = 'Edit',
                    CaseAccessLevel = 'Edit',
                    ContactAccessLevel = 'Edit',
                    OpportunityAccessLevel = 'Edit',
                    TeamMemberRole = 'Client Service',
                    UserId = wetsMember.UserOrGroupId
                );
                
                accountTeamMembers.add(atm);
            }
        }
        
        // insert them
        insert accountTeamMembers;
    }
    
    private void syncIndividualFields() {
        // grab and update the account portion of the individual as necessary
        if (contactsToSyncStatus.size() > 0 || contactsToSyncReasonInactive.size() > 0 || contactsToSyncReasonNoOppty.size() > 0 || contactsToSyncClassification.size() > 0) {
            
            // get the accounts using the contact-household map
            List<Account> individualAccountsToUpdate = new List<Account>();
            for (Account individual : [SELECT Id, Name, FinServ__PrimaryContact__c, FinServ__Status__c
                                       , WEGP1_ReasonForInactive__c, WEGP1_ReasonForNoOpportunity__c, Type
                                       FROM Account
                                       WHERE FinServ__PrimaryContact__c IN :contactHouseholdMap.keySet()])
            {                
                // get the household of the individual
                Account household = contactHouseholdMap.get(individual.FinServ__PrimaryContact__c);
                if (household != null) {
                    System.debug('>>>>>>>> Individual Account before changes applied: ' + individual);
                    
                    // set the individual fields equal to the household fields as necessary
                    // status
                    if (contactsToSyncStatus.contains(individual.FinServ__PrimaryContact__c))
                        individual.FinServ__Status__c = household.FinServ__Status__c;
                    // reason for inactive
                    if (contactsToSyncReasonInactive.contains(individual.FinServ__PrimaryContact__c))
                        individual.WEGP1_ReasonForInactive__c = household.WEGP1_ReasonForInactive__c;
                    // reason for no opportunity
                    if (contactsToSyncReasonNoOppty.contains(individual.FinServ__PrimaryContact__c))
                        individual.WEGP1_ReasonForNoOpportunity__c = household.WEGP1_ReasonForNoOpportunity__c;
                    // classification
                    if (contactsToSyncClassification.contains(individual.FinServ__PrimaryContact__c))
                        individual.Type = household.Type;
                    
                    System.debug('>>>>>>>> Individual Account after changes applied: ' + individual);
                    
                    // add the individual for update
                    individualAccountsToUpdate.add(individual);
                }
            }// for loop
            
            // update the individual accounts
            if (individualAccountsToUpdate.size() > 0) {
                try { update individualAccountsToUpdate; } catch (Exception ex) { System.debug('>>>>>>>> Issue occured.' + ex); return; }
            }
        }
        // separately grab and update the contact portion of the individual
        if (contactsToSyncLeadSeg.size() > 0 || contactsToSyncReferredBy.size() > 0) {
            
            // get the contacts using the contact-household map
            List<Contact> individualContactsToUpdate = new List<Contact>();
            for (Contact individual : [SELECT Id, Name, WEGP1_Type__c, WEGP1_SubType__c, WEGP1_TypeDetail__c, WEGP1_ReferredBy__c
                                       FROM Contact
                                       WHERE Id IN :contactHouseholdMap.keySet()])
            {                
                // get the household of the individual
                Account household = contactHouseholdMap.get(individual.Id);
                if (household != null) {
                    System.debug('>>>>>>>> Individual Contact before changes applied: ' + individual);
                    
                    // set the individual fields equal to the household fields as necessary
                    // lead segmentation
                    if (contactsToSyncLeadSeg.contains(individual.Id)) {
                        System.debug('>>>>>>>> Updating Type Fields');
                        individual.WEGP1_Type__c = household.WEGP1_Lead_Type__c;
                        individual.WEGP1_SubType__c = household.WEGP1_Lead_SubType__c;
                        individual.WEGP1_TypeDetail__c = household.WEGP1_Lead_Type_Detail__c;
                    }
                    // referred by
                    if (contactsToSyncReferredBy.contains(individual.Id))
                        individual.WEGP1_ReferredBy__c = household.WEG_ReferredBy__c;
                    
                    System.debug('>>>>>>>> Individual Contact after changes applied: ' + individual);
                    
                    // add the individual for update
                    individualContactsToUpdate.add(individual);
                }
            }// for loop
            
            // update the individual contacts
            if (individualContactsToUpdate.size() > 0) {
                try { update individualContactsToUpdate; } catch (Exception ex) { System.debug('>>>>>>>> Issue occured.' + ex); return; }
            }
        }
    }
}