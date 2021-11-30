public class WEG_IntroHeldBatch implements Database.Batchable<sObject> {
    
    public Iterable<sObject> start(Database.BatchableContext info) {
        system.debug('>>>> WEG_IntroHeldBatch.start');
        
        List<Opportunity> opptys =
            [SELECT Id, WEG_Intro_Held_Date__c
             , (SELECT Id, StartDateTime
                FROM Events
                WHERE WEGP1_MeetingType__c = 'Needs Analysis'
                AND StartDateTime < :datetime.now()
                ORDER BY StartDateTime desc LIMIT 1)
            FROM Opportunity];
        
        return opptys;
    }
    
    public void execute(Database.BatchableContext info, List<Opportunity> scope) {
        system.debug('>>>> WEG_IntroHeldBatch.execute');
        
        // identify those opportunities that need updated
        for (Opportunity oppty : scope) {
            
            // get the intro held date for the opportunity
            date introHeld;
            if (!oppty.Events.isEmpty()) {
                datetime evtStart = oppty.Events[0].StartDateTime;
                introHeld = date.newInstance(evtStart.year(), evtStart.month(), evtStart.day());
            }
            
            // set it on the opportunity
            oppty.WEG_Intro_Held_Date__c = introHeld;
        }
        
        update scope;
    }
    
    public void finish(Database.BatchableContext info) {
    }
}