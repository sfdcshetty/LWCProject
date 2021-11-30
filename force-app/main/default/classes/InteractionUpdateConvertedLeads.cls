global class InteractionUpdateConvertedLeads implements Database.Batchable<sObject> {
    global InteractionUpdateConvertedLeads() {
    }

    global Database.QueryLocator start(Database.BatchableContext info) {
        return DataBase.getQueryLocator(
            [
                SELECT
                    ID,
                    Lead__c,
                    Lead__r.ConvertedAccountId,
                    Lead__r.ConvertedAccount.WEGP1_Primary_Household__c,
                    Lead__r.ConvertedContactId,
                    Lead__r.ConvertedOpportunityId
                FROM Interaction__c
                WHERE Lead__r.IsConverted = TRUE
            ]
        );
    }

    public void execute(Database.BatchableContext info, List<Interaction__c> interactions) {
        TriggerFactory.RUN_TRIGGER_LOGIC = false;
        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (Interaction__c interaction : interactions) {
            if (interaction.Lead__r.ConvertedContactId != null) {
                interaction.Contact__c = interaction.Lead__r.ConvertedContactId;
                contactIds.add(interaction.Contact__c);
            }
            if (interaction.Lead__r.ConvertedOpportunityId != null) {
                interaction.opportunity__c = interaction.Lead__r.ConvertedOpportunityId;
            }
            if (interaction.Lead__r.ConvertedAccountId != null) {
                interaction.account__c = interaction.Lead__r.ConvertedAccountId;
                accountIds.add(interaction.Lead__r.ConvertedAccountId);
            }
            try {
                if (interaction.Lead__r.ConvertedAccount.WEGP1_Primary_Household__c != null) {
                    interaction.account__c = interaction.Lead__r.ConvertedAccount.WEGP1_Primary_Household__c;
                }
                interaction.lead__c = null;
            } catch (Exception ex) {
            }
        }
        Database.update(interactions);

        //THIS IS A BANDAID FOR THE VALIDATION RULE WHERE YOU CANNOT UPDATE A CONTACT WHEN THERE IS 2 CONTACTS UNDER AN INDIVIDUAL ACCOUNT.  THIS IS A DATA.COM ISSUE
        Database.delete([SELECT Id FROM CONTACT WHERE AccountId IN :accountIds AND Email = :null AND RecordType.DeveloperName = :'IndustriesIndividual']);

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
        Database.update(updateContacts);
        TriggerFactory.RUN_TRIGGER_LOGIC = true;
    }

    public void finish(Database.BatchableContext BC) {
    }
}