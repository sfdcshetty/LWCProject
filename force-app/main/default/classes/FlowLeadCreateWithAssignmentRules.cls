public with sharing class FlowLeadCreateWithAssignmentRules {
    @InvocableMethod(label='Lead Insert With New Lead Assignment Rule' description='Inserts Leads')
    public static List<Lead> FlowLeadCreateWithAssignmentRules(List<Lead> leads) {
        try {
            Id assignmentruleId = null;
            Id leadrecordtypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('WEG General').getRecordTypeId();
            for (AssignmentRule ar : [SELECT Id FROM AssignmentRule WHERE Name = :'New Lead']) {
                assignmentruleId = ar.Id;
            }
            if (assignmentruleId == null) {
                throw new applicationException('Assignment Rule "New Lead" does not exist');
            }
            for (Lead lead : leads) {
                lead.RecordTypeId = leadrecordtypeId;
            }
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.assignmentRuleId = assignmentruleId;

            Database.SaveResult[] srList = Database.insert(leads, dmo);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    throw new applicationException('Unable to create leads with dml options');
                }
            }
            return leads;
        } catch (Exception ex) {
             insert leads;
             return leads;

        }
    }

    public class applicationException extends Exception {
    }
}