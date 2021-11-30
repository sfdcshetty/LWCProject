public class WEG_RepCodeTriggerHandler {
    public static void dummy() {
        return;
    }
    
    /*
    //private Set<string> repCodes = new Set<string>();
    private Map<Id, string> reps = new Map<Id, string>();
    private Map<Id, WEGP1_Office__c> offices = new Map<Id, WEGP1_Office__c>();
    
    public void beforeInsert() {
        // get all supporting data first
        getSupportingData();
        
        // iterate the inserted rep codes
        for (SkienceFinSln__Rep_Alias__c rc : (List<SkienceFinSln__Rep_Alias__c>)Trigger.new) {
            // ensure the rep code is unique
            List<string> repCodes = reps.values();
            if (repCodes.contains(rc.SkienceFinSln__rep_code__c.toLowerCase())) {
                rc.addError('Error :: Rep Code ' + rc.SkienceFinSln__rep_code__c + ' already exists. Rep Codes must be unique.');
            }
            else {
                // set the rep code type based on entity
                rc.SkienceFinSln__RepCodeType__c = rc.WEG_BusinessEntity__c;
                
                // set applies to branches to the office name
                WEGP1_Office__c office = offices.get(rc.WEG_Branch__c);
                rc.SkienceFinSln__Applies_To_Branches__c = office.Name;
            }
        }
    }
    
    public void beforeUpdate() {
        // get all supporting data first
        getSupportingData();
        
        // iterate the updated rep codes
        for (SkienceFinSln__Rep_Alias__c rc : (List<SkienceFinSln__Rep_Alias__c>)Trigger.new) {
            // ensure the rep code is unique only if it was updated
            if (rc.SkienceFinSln__rep_code__c != ((SkienceFinSln__Rep_Alias__c)Trigger.oldMap.get(rc.Id)).SkienceFinSln__rep_code__c) {
                // loop through the rep codes
                for (Id key : reps.keySet()) {
                    // exclude the rep code currently assigned to the record
                    if (key != rc.Id) {
                        // compare the records updated rep code against each existing rep code
                        string repCode = reps.get(key);
                        if (repCode == rc.SkienceFinSln__rep_code__c.toLowerCase())
                            rc.addError('Error :: Rep Code ' + rc.SkienceFinSln__rep_code__c + ' already exists. Rep Codes must be unique.');
                    }
                }
            }
            
            // set the rep code type based on entity
            rc.SkienceFinSln__RepCodeType__c = rc.WEG_BusinessEntity__c;
            
            // set applies to branches to the office name
            WEGP1_Office__c office = offices.get(rc.WEG_Branch__c);
            rc.SkienceFinSln__Applies_To_Branches__c = office.Name;
        }
    }
    
    private void getSupportingData() {
        // get all existing offices
        offices = new Map<ID, WEGP1_Office__c>([SELECT Id, Name FROM WEGP1_Office__c]);
        
        // get all existing rep codes
        //reps = new Map<Id, SkienceFinSln__Rep_Alias__c>([SELECT Id, SkienceFinSln__rep_code__c FROM SkienceFinSln__Rep_Alias__c]);
        List<SkienceFinSln__Rep_Alias__c> allReps = [SELECT Id, SkienceFinSln__rep_code__c FROM SkienceFinSln__Rep_Alias__c];
        for (SkienceFinSln__Rep_Alias__c rep : allReps) {
            //repCodes.add(rep.SkienceFinSln__rep_code__c.toLowerCase());
            reps.put(rep.Id, rep.SkienceFinSln__rep_code__c.toLowerCase());
        }
    }
	*/
}