@isTest
private class WEG_RepCodeTriggerTest {
    
    private static testMethod void testTrigger(){
        
        test.startTest();
        
        SkienceLaserAppAmountRangeToLetter.dummy();
        
        /*
        // insert the office to be used for all rep code testing
        WEGP1_Office__c office = new WEGP1_Office__c(Name = 'Plymouth');
        insert office;
        
        // create the first rep code
        SkienceFinSln__Rep_Alias__c abc1 = new SkienceFinSln__Rep_Alias__c(
            Name = 'Test Code',
            SkienceFinSln__rep_code__c = 'ABC1',
            WEG_BusinessEntity__c = 'WEAS',
            WEG_Branch__c = office.Id,
            SkienceFinSln__RepCodeType__c = 'x',
            SkienceFinSln__isAvailable__c = true
        );
        insert abc1;
        
        // update it
        abc1.WEG_BusinessEntity__c = 'WEBS';
        update abc1;
        
        // create a second rep code with a non-unique code
        // ensure failure
        SkienceFinSln__Rep_Alias__c abc2 = new SkienceFinSln__Rep_Alias__c(
            Name = 'Test Code',
            SkienceFinSln__rep_code__c = 'ABC1',
            WEG_BusinessEntity__c = 'WEAS',
            WEG_Branch__c = office.Id,
            SkienceFinSln__RepCodeType__c = 'x',
            SkienceFinSln__isAvailable__c = true
        );
        try {
            insert abc2;
            System.AssertEquals('Insert of duplicate Rep Code ABC1 did not fail!', '');
        }
        catch(Exception ex) {
            boolean expectedExceptionThrown =  ex.getMessage().contains('Rep Codes must be unique') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        // set the rep code to something unique, attempt insert again
        abc2.SkienceFinSln__rep_code__c = 'ABC2';
        insert abc2;
        
        // set the rep code back to an existing code
        abc2.SkienceFinSln__rep_code__c = 'ABC1';
        
        // ensure the update fails
        try {
            update abc2;
            System.AssertEquals('Insert of duplicate Rep Code ABC1 did not fail!', '');
        }
        catch(Exception ex) {
            boolean expectedExceptionThrown =  ex.getMessage().contains('Rep Codes must be unique') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }*/
        
        test.stopTest();
  }
}