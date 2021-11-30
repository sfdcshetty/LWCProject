//global with sharing class SkienceLaserAppRemoveDecimal implements SkienceFinSln.LaserAppMultiProcessorInterface {
global with sharing class SkienceLaserAppRemoveDecimal {
    public static void dummy() {
        return;
    }
    
    /*
    public List<SkienceFinSln.LAAppNonStandardFld> processAll(sObject rec, SkienceFinSln__LaserAppConfiguration__c config) {
        List<SkienceFinSln.LAAppNonStandardFld> lst = new List<SkienceFinSln.LAAppNonStandardFld>();
        SkienceFinSln.LAAppNonStandardFld nonStdFld = new SkienceFinSln.LAAppNonStandardFld();
        nonStdFld.value = String.valueof(rec.get(config.SkienceFinSln__Skience_FieldName__c)).split('\\.')[0];
        nonStdFld.afn = config.SkienceFinSln__LaserApp_FieldName__c;
        system.debug('returning percentage value afn:' + nonStdFld.afn + ' value:' + nonStdFld.value);
        lst.add(nonStdFld);
        return lst;
    }
    */
}