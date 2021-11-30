public without sharing class InteractionWithoutSharing {
    @future
    public static void futureUpdateInteractions(Set<Id> leadIds) {
        set<Id> contactIds = new Set<Id>();
        List<Interaction__c> interactions = [
            SELECT
                ID,
                Lead__c,
                Lead__r.ConvertedAccountId,
                Lead__r.ConvertedContactId,
                Lead__r.ConvertedOpportunityId,
                Lead__r.ConvertedAccount.WEGP1_Primary_Household__c,
                RecordType.DeveloperName
            FROM Interaction__c
            WHERE Lead__c IN :leadIds AND Lead__r.IsConverted = TRUE
        ];

        for (Interaction__c interaction : interactions) {
            if (interaction.Lead__r.ConvertedAccountId != null) {
                interaction.Account__c = interaction.Lead__r.ConvertedAccountId;
            }
            if (interaction.Lead__r.ConvertedAccount.WEGP1_Primary_Household__c != null) {
                interaction.Account__c = interaction.Lead__r.ConvertedAccount.WEGP1_Primary_Household__c;
            }
            if (interaction.Lead__r.ConvertedContactId != null) {
                interaction.Contact__c = interaction.Lead__r.ConvertedContactId;
                ContactIds.add(interaction.Lead__r.ConvertedContactId);
            }
            if (interaction.Lead__r.ConvertedOpportunityId != null) {
                interaction.Opportunity__c = interaction.Lead__r.ConvertedOpportunityId;
            }
            interaction.Lead__c = null;

            if (interaction.Contact__c != null) {
                if (interaction.RecordType.DeveloperName == 'Inbound') {
                    interaction.Touchpoint_Contact__c = interaction.Contact__c;
                }
                if (interaction.RecordType.DeveloperName == 'Outbound') {
                    interaction.Touchpoint_Contact__c = interaction.Contact__c;
                }
                if (interaction.RecordType.DeveloperName == 'Event') {
                    interaction.TaskContact__c = interaction.Contact__c;
                }
                if (interaction.RecordType.DeveloperName == 'Milestone') {
                    interaction.Milestone_Contact__c = interaction.Contact__c;
                }
                if (interaction.RecordType.DeveloperName == 'Task') {
                    interaction.TaskContact__c = interaction.Contact__c;
                }
            }
        }

        TriggerFactory.RUN_TRIGGER_LOGIC = false;
        Database.update(interactions);
        TriggerFactory.RUN_TRIGGER_LOGIC = true;

        List<Contact> updateContacts = new List<Contact>();

        for (AggregateResult res : [
            SELECT SUM(Behavior_Score__c), SUM(Demographic_Score__c), contact__c
            FROM Interaction__c
            WHERE contact__c IN :contactIds AND Inactive__c = :false
            GROUP BY Contact__c
        ]) {
            Contact c = new Contact();
            c.Id = (Id) res.get('Contact__c');
            c.Behavior_Score__c = (decimal) res.get('expr0');
            c.Demographic_Score__c = (decimal) res.get('expr1');
            updateContacts.add(c);
        }

        if (updateContacts.size() > 0) {
            TriggerFactory.RUN_TRIGGER_LOGIC = false;
            Database.update(updateContacts);
            TriggerFactory.RUN_TRIGGER_LOGIC = true;
        }
    }
}