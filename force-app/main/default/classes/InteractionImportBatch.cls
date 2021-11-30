global class InteractionImportBatch implements Database.Batchable<sObject>, Database.Stateful {
    Id inboundId = null;
    Set<Id> idSet = new Set<Id>();
    global InteractionImportBatch(Set<Id> idSet) {
        this.inboundId = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = :'Interaction__c' AND DeveloperName = 'Inbound' LIMIT 1].Id;
        this.idSet = idSet;
    }

    global Database.QueryLocator start(Database.BatchableContext info) {
        return DataBase.getQueryLocator([SELECT Id FROM Interaction__c WHERE RecordType.DeveloperName = :'Import' AND Id IN :idSet]);
    }

    public void execute(Database.BatchableContext info, List<Interaction__c> interactions) {
        for (Interaction__c interaction : interactions) {
            interaction.RecordTypeId = inboundId;
        }
        Database.update(interactions);
    }

    public void finish(Database.BatchableContext BC) {
        Database.executeBatch(new InteractionUpdateConvertedLeads());
    }
}