/**
 * This is the CampaignECIDUpdateBatch class. This class is a batch
 * that will go through all the children campaigns to update the ECID
 * if a parent has been updated.  It calls the next layer of children in the finish.
 *
 * @author Matthew Lennington -- (PERFICIENT)
 * @date 09/2020
 *
 */
global class InteractionInactivationBatch implements Database.Batchable<sObject>, Database.Stateful {
    global Set<Id> objIds = new Set<Id>();
    global Set<Id> excludedSet = new Set<Id>();
    Schema.sObjectType soType = null;

    global InteractionInactivationBatch(Set<Id> objIds, Schema.sObjectType soType, Set<Id> excludedSet) {
        this.objIds = objIds;
        this.soType = soType;
        this.excludedSet = excludedSet;
    }

    global Database.QueryLocator start(Database.BatchableContext info) {
        if (soType == Contact.sObjectType) {
            return DataBase.getQueryLocator(
                [
                    SELECT Id, contact__c
                    FROM Interaction__c
                    WHERE Contact__c IN :objIds AND Id NOT IN :excludedSet AND Inactive__c = :false
                ]
            );
        } else if (soType == Lead.sObjectType) {
            return DataBase.getQueryLocator(
                [
                    SELECT Id, lead__c
                    FROM Interaction__c
                    WHERE lead__c IN :objIds AND Id NOT IN :excludedSet AND Inactive__c = :false
                ]
            );
        } else {
            return null;
        }
    }

    public void execute(Database.BatchableContext info, List<Interaction__c> interactions) {
        //TriggerFactory.RUN_TRIGGER_LOGIC = false;
        for (Interaction__c interaction : interactions) {
            interaction.inactive__c = true;
        }
        Database.update(interactions);
    }

    public void finish(Database.BatchableContext BC) {
    }
}