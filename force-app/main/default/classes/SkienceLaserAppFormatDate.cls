//global with sharing class SkienceLaserAppFormatDate implements SkienceFinSln.LaserAppMultiProcessorInterface {
global with sharing class SkienceLaserAppFormatDate {
    /*
    public List<SkienceFinSln.LAAppNonStandardFld> processAll(sObject rec, SkienceFinSln__LaserAppConfiguration__c config) {
        List<SkienceFinSln.LAAppNonStandardFld> lst = new List<SkienceFinSln.LAAppNonStandardFld>();
        SkienceFinSln.LAAppNonStandardFld nonStdFld = new SkienceFinSln.LAAppNonStandardFld();
        String value = String.valueof(rec.get(config.SkienceFinSln__Skience_FieldName__c));
        Date dt = Date.valueOf(value);
        nonStdFld.value = dt.format(); 
        nonStdFld.afn = config.SkienceFinSln__LaserApp_FieldName__c;
        system.debug('returning Date value afn:' + nonStdFld.afn + ' value:' + nonStdFld.value);
        lst.add(nonStdFld);
        return lst;
    }
	*/
}