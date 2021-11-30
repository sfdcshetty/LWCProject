//global with sharing class SkienceLaserAppFieldTransformer implements SkienceFinSln.LaserAppFieldTransformerInterface {
global with sharing class SkienceLaserAppFieldTransformer {
    /*
    public string transform(string objectname, string fieldname, string value) {
        system.debug('Transformer called with: objectname=' + objectname + ',fieldname=' + fieldname + ',value=' + value);
        // object independent transformations
        if(fieldname.containsIgnoreCase('Date')){
            try {
        		Date dt = Date.valueOf(value);
        		return dt.format(); 
            } catch (Exception ex){
                system.debug('Exeption while converting to date:' + value);
                system.debug('Exeption:' + ex);
            }
        }
        
        if(objectname == 'Contact') 
            return contactTransformation(objectname, fieldname,value);
        if(objectname == 'FinServ__FinancialAccount__c') 
            return faTransformation(objectname, fieldname,value);
        
       return value;
//       return packagetransformer.transform(objectname, fieldname, value);
    }
    
    string faTransformation(string objectname, string fieldname, string value) {
       return value;
//       return packagetransformer.transform(objectname, fieldname, value);
    }
    
    string contactTransformation(string objectname, string fieldname, string value) {
        if(String.isBlank(value)) return value;
       return value;
//       return packagetransformer.transform(objectname, fieldname, value);
    }
	*/
}