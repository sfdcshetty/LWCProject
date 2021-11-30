@IsTest(SeeAllData=false) 
public class SkienceLaserAppTest {
    /*
    static testMethod void SkienceLaserAppRemoveDecimalTest () {
        Account acc = new Account();
        acc.AnnualRevenue = 100.1;
        SkienceFinSln__LaserAppConfiguration__c config = new SkienceFinSln__LaserAppConfiguration__c();
        config.SkienceFinSln__LaserApp_FieldName__c = 'laserAppFldName';
        config.SkienceFinSln__Skience_FieldName__c = 'AnnualRevenue';
        List<SkienceFinSln.LAAppNonStandardFld> nonStd = new SkienceLaserAppRemoveDecimal().processAll(acc, config);
        system.debug('nonStd:' + nonStd[0]);
        system.assert(nonStd[0].value == '100');
    }   
    static testMethod void SkienceLaserAppFormatDateTest () {
        Account acc = new Account();
        acc.SkienceFinSln__Last_Review_Date__c = system.Today();
        SkienceFinSln__LaserAppConfiguration__c config = new SkienceFinSln__LaserAppConfiguration__c();
        config.SkienceFinSln__LaserApp_FieldName__c = 'laserAppFldName';
        config.SkienceFinSln__Skience_FieldName__c = 'SkienceFinSln__Last_Review_Date__c';
        List<SkienceFinSln.LAAppNonStandardFld>  nonStd = new SkienceLaserAppFormatDate().processAll(acc, config);
        system.debug('nonStd:' + nonStd[0]);
        system.assert(nonStd[0].value == acc.SkienceFinSln__Last_Review_Date__c.format());
    }    

    static testMethod void SkienceLaserAppAmountRangeToLetterTest () {
        Account acc = new Account();
        acc.name = '$1,000,000 and over';
        acc.SkienceFinSln__Last_Review_Date__c = system.Today();
        SkienceFinSln__LaserAppConfiguration__c config = new SkienceFinSln__LaserAppConfiguration__c();
        config.SkienceFinSln__LaserApp_FieldName__c = 'laserAppFldName';
        config.SkienceFinSln__Skience_FieldName__c = 'name';
        List<SkienceFinSln.LAAppNonStandardFld>  nonStd = new SkienceLaserAppAmountRangeToLetter().processAll(acc, config);
        system.debug('nonStd:' + nonStd[0]);
        system.assert(nonStd[0].value == 'H');
    }  
    
    static testMethod void SkienceLaserAppFieldTransformerTest () {
        DateTime dtm = System.Now();
        String.valueOf(dtm.date());
        SkienceLaserAppFieldTransformer transformer = new SkienceLaserAppFieldTransformer();
        string retvalue = transformer.transform('', 'abcDateToday', String.valueOf(dtm.date()));
        system.assertEquals(dtm.date().format(),retvalue);
        retvalue = transformer.transform('Contact', 'abc', 'blah');
        system.assertEquals('blah', retvalue);
        retvalue = transformer.transform('FinServ__FinancialAccount__c', 'abc', 'blah');
        system.assertEquals('blah', retvalue);
    }  
    */
}