//global with sharing class SkienceLaserAppAmountRangeToLetter implements SkienceFinSln.LaserAppMultiProcessorInterface {
global with sharing class SkienceLaserAppAmountRangeToLetter { 

public static void dummy () {
return;
}

/*    public List<SkienceFinSln.LAAppNonStandardFld> processAll(sObject rec, SkienceFinSln__LaserAppConfiguration__c config) {
        List<SkienceFinSln.LAAppNonStandardFld> lst = new List<SkienceFinSln.LAAppNonStandardFld>();
        SkienceFinSln.LAAppNonStandardFld nonStdFld = new SkienceFinSln.LAAppNonStandardFld();
        String value = String.valueof(SkienceFinSln.LAIM_XMLGeneratorController.getFieldValue(rec, config.SkienceFinSln__Skience_FieldName__c));
        nonStdFld.value = transform(value);
        nonStdFld.afn = config.SkienceFinSln__LaserApp_FieldName__c;
        system.debug('returning AmountRangeToLetter value afn:' + nonStdFld.afn + ' value:' + nonStdFld.value);
        lst.add(nonStdFld);
        return lst;
    }
    string transform(string value) {
        if(value == '$1 - $24,999') return 'A';
        if(value == '$25,000 - $49,999') return 'B';
        if(value == '$50,000 - $99,999') return 'C';
        if(value == '$100,000 - $249,999') return 'D';
        if(value == '$250,000 - $499,999') return 'E';
        if(value == '$500,000 - $749,999') return 'F';
        if(value == '$750,000 - $999,999') return 'G';
        if(value == '$1,000,000 and over') return 'H'; else return value;
    }
*/}