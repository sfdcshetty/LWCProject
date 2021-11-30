trigger LeadConvertTrigger on Lead_Convert__e (after insert) {
    String leadStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1].MasterLabel;
    List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
    
    
    for (Lead_Convert__e event : Trigger.New) {
        Database.LeadConvert leadConvert = new Database.LeadConvert();
        leadConvert.setLeadId(event.Lead_Id__c);
        leadConvert.setOwnerId(event.Owner_Id__c);
        leadConvert.setConvertedStatus(leadStatus);
        leadConvert.setDoNotCreateOpportunity(true);
        leadsToConvert.add(leadConvert);
    }
    
    if (!leadsToConvert.isEmpty()) {
        Map<Id, Database.LeadConvertResult> leadConvertMap = new Map<Id, Database.LeadConvertResult>();
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        List<Database.LeadConvertResult> lcr = Database.convertLead(leadsToConvert, dml);

        for (Database.LeadConvertResult l : lcr) {
            if (l.isSuccess()) {
                leadConvertMap.put(l.getLeadId(), l);
            } else {
                Database.Error[] errors = l.getErrors();
                for (Database.Error error : errors) {
                    //throw new applicationException(error.getMessage() + ' ' + error.getFields());
                }
            }
        }
        if (leadConvertMap.size() > 0) {
            InteractionWithoutSharing.futureUpdateInteractions(leadConvertMap.keySet());
        }
    }
}