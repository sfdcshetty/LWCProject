/******************************************************************************************************************************
 * Class Name    : ChartController 
 * Description   : Contains the login to create Financial Account Chart data and pass it to Lightning component.
 * Test class    : wv6_ChartControllerTest
 * Author        : Pooja Wadhwa 
 * 
 * Modification Log :
 * -----------------------------------------------------------------------------------------------------------------
 * Developer                 Date(MM/DD/YYYY)       Description
 * -----------------------------------------------------------------------------------------------------------------
 * Pooja Wadhwa              03/19/2018            Created
******************************************************************************************************************************/

public with sharing class ChartController {
    @AuraEnabled
    // Method to get the picklist values from Schema
    public static List <string> retrivepicklistvalues(string selectedObject, string selectedfield) {
        Map <string, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe(); // descibe sobjects    
        Map <string, string> Mapofpicklist = new Map<string, string>(); // new map for holding the picklist field values
        List <string> options = new List <string>(); //new list for holding all of the picklist options
        Schema.sObjectType sobjecttype = schemaMap.get(selectedObject);
        Schema.DescribeSObjectResult sobjectdescribe = sobjecttype.getDescribe(); //describe the sobject
        Map <string, Schema.SObjectField> fieldmap = sobjectdescribe.fields.getMap();
        List <Schema.PicklistEntry> picklistvalues = fieldmap.get(selectedfield).getDescribe().getPickListValues(); //get the list of picklist values from field on the sobject
        for (Schema.PicklistEntry a: picklistvalues) { //for all values in the picklist list
            system.debug('whattt ' +a);
            Mapofpicklist.put(a.getValue(), a.getLabel());
        }
        for (string picklistapinames: Mapofpicklist.keyset()) {
            options.add(picklistapinames);
        }
        return options; //return the List of values
    }


    // Method to query the data from SObject
    @AuraEnabled
    public static List<wrapperclass> generateDataa(String selectedObject, String selectedfield) {
        String QueryStr = queryAllFrom(selectedObject); 
        system.debug(QueryStr);
        List<Sobject> groupedResults = Database.query(QueryStr+ ' limit 50'); // Retrive the records from selected object
        List<wrapperclass> lstofwrapperclass = new List<wrapperclass> (); // Wrapper calss to hold records with selected field value 
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe(); // Describing the SObjects
        Map<string, string> Mapofpicklist = new Map<string, string> ();
        List<String> options = new List<String> ();
        Schema.sObjectType sobjecttype = schemaMap.get(selectedObject); // Get SObject type
        Schema.DescribeSObjectResult sobjectdescribe = sobjecttype.getDescribe(); // Describing the selected SObjects
        Map<String, Schema.SObjectField> fieldmap = sobjectdescribe.fields.getMap(); // Holding SObject fields
        for (Sobject sobj: groupedResults) {
            wrapperclass wrap = new wrapperclass();
            for (Schema.SObjectField field: fieldMap.values()) {
                if (string.valueof(field) == selectedfield) { // Checking the selected field 
                    Schema.DescribeFieldResult fieldResult = field.getDescribe();
                    wrap.selectedfield = String.valueof(sobj.get(fieldResult.getName())); // Assigning the selected field value of a record
                    wrap.lstofobj = sobj; // Assigning selected SObject record
                    SYSTEM.DEBUG('wrappp'+wrap);
                }
                if(string.valueof(field) == 'FinServ__Balance__c'){
                    Schema.DescribeFieldResult fieldResult = field.getDescribe();
                    wrap.Amount = Decimal.valueOf(String.valueof(sobj.get(fieldResult.getName())));
                    
                }
            }
            lstofwrapperclass.add(wrap);
        }
        return lstofwrapperclass; // return the wrapper with records and selected field value
    }

    // Wrapper calss to hold the record with selected picklist value
    public class wrapperclass {
        @AuraEnabled
        public string selectedfield;
        @AuraEnabled
        public Sobject lstofobj;
        @AuraEnabled
        public Decimal Amount;
    }

    // Dynamic SOQL 
    public static string queryAllFrom(string sObjectType) {
        String query = 'SELECT Name, WEG_Registration_Type__c, WEG_Custodian__c, WEG_Product_Type__c, FinServ__LastUpdated__c, FinServ__Balance__c ';
        //for (Schema.SObjectField nameAPIfield: Schema.getGlobalDescribe().get(sObjectType).getDescribe().fields.getMap().values()) {
        //    query += query == 'SELECT ' ? String.ValueOf(nameAPIfield) : ', ' + String.ValueOf(nameAPIfield); 
        //}
        string wegHeld='WEG Held';
        string closed='Closed';
        String open = 'Open';
        boolean n= False;
        
        return query + ' FROM ' + sObjectType +' WHERE WEGP1_Held_Status__c = \''+wegHeld+
            '\' AND WEGP1_ExcludeFromReview__c = False AND FinServ__Status__c =\'' +open+'\'';
    }
    
    public class wrapperColorClass {
        @AuraEnabled
        public string AccountType;
        @AuraEnabled
        public string Color;

    }
    
    @AuraEnabled
    public static List<wrapperColorClass> getBrandColors() {
        List<Financial_Account_Color_Branding__mdt> colors = [select Account_Type__c, Color__c from Financial_Account_Color_Branding__mdt];
        List<wrapperColorClass> colorList = new List<wrapperColorClass>();
        if(colors.size()>0){
            
            for(Financial_Account_Color_Branding__mdt color: colors){
                wrapperColorClass wrapColor = new wrapperColorClass();
                wrapColor.AccountType = color.Account_Type__c;
                wrapColor.Color = color.Color__c;
                colorList.add(wrapColor);
            }
           
        }
        return colorList;
    }
}