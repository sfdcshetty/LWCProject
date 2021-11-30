/******************************************************************************************************************************
* @class name    : wv6_LightningDataTableController
* @description   : This apex class is used to return the list of records for the specified object based on the provided information.
* @test class    : wv6_LightningDataTableControllerTest
* @author        : Ganesh Ekhande(Wave6)
* @date          : 03/15/2018
*
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande(Wave6)       03/15/2018             Created.
*
******************************************************************************************************************************/
public class wv6_LightningDataTableController {
   
    
    /**
    * This method is used to return the list of records for the specified object
    * @param ObjectName - Specify the API name of object to get recently view records
    * @param filterCriteria - Filter Criteria for the SOQL
    * @param orderByClause - default sorting on Component Load
    * @param displayLocation -This value should match Display Location picklist values on Custom metadata Type (Lightning Data Table Settings)
    */
    @AuraEnabled
    public static wv6_LightningTableWrapper getRecords(String objectAPIName, String filterCriteria, string orderByClause, string displayLocation,string recordId){
        
        system.debug('recordId:>>'+recordId);
        
        wv6_LightningTableWrapper responseWrap  = new wv6_LightningTableWrapper();
        
        if(objectAPIName != null && objectAPIName!='' ){
            
            string qry = 'SELECT Field_Lable__c, Field_API_Name__c, Column_Order__c, Display_Location__c,Hyperlink_to_Record__c FROM Lightning_Data_Table_Column_Setting__mdt ';
            string whereClause = ' WHERE Object_API_Name__c =:objectAPIName ';
            
            if(displayLocation != null && displayLocation != ''){
                whereClause += ' AND Display_Location__c =: displayLocation ';
            }
            
            
            string orderBy = ' ORDER BY Column_Order__c ASC ';
            qry = qry + whereClause + orderBy;
            
            // Get Custom Metadata Type Records
            Lightning_Data_Table_Column_Setting__mdt[] dataTableSettings ;
            dataTableSettings = database.query(qry);
            system.debug('dataTableSettings:>>'+dataTableSettings);
            
            
            // Form a dynamic query based on the inputs
            list<String> fieldAPINameList = new list<String>();
            list<String> fieldLabelList = new list<String>();
            set<String> hyperLinkFields = new set<String>();
            string queryString = 'SELECT Id, ';
            for(Lightning_Data_Table_Column_Setting__mdt setting : dataTableSettings){
                queryString += ' '+ setting.Field_API_Name__c+' , ';
                fieldLabelList.add(setting.Field_Lable__c);
                fieldAPINameList.add(setting.Field_API_Name__c);
                
                if(setting.Hyperlink_to_Record__c){
                    hyperLinkFields.add(setting.Field_API_Name__c);
                }
            }
            queryString = queryString.trim().removeEnd(',');
            queryString = queryString + ' FROM ' + objectAPIName; 
            
            if(filterCriteria !='' && filterCriteria != null){
                queryString +=   ' WHERE '+filterCriteria;    
            }
            if(recordId != null && displayLocation !='WEG Client Portal' && displayLocation !='Secure Messages on Portal'){
                queryString += ' AND (FinServ__Household__c =: recordId OR FinServ__PrimaryOwner__c =: recordId) ';
            }
            
            if(orderByClause !='' && orderByClause != null){
                queryString +=   ' ORDER BY '+orderByClause;    
            }
            system.debug('queryString:>>'+queryString);
            
            list<sObject> sObjectRecords  = new list<sObject>();
            sObjectRecords = database.query(queryString);
            
            
            // Convert sObject records into sObjWrapper
            responseWrap.sObjectrecords = new List<wv6_LightningTableWrapper.sObjWrapper>(); 
            decimal grandTotal = 0;
            for(sObject sObj : sObjectRecords){
                wv6_LightningTableWrapper.sObjWrapper sObjWrap = new wv6_LightningTableWrapper.sObjWrapper();            
                sObjWrap.fieldInfoWrapList = convertRecordToListofFieldValues(sObj,fieldAPINameList,fieldLabelList,objectAPIName,hyperLinkFields,displayLocation);
                sObjWrap.sObjectId = sObj.Id;
                if(fieldAPINameList.contains('FinServ__Balance__c')){
                    grandTotal = grandTotal + Decimal.valueOf(String.valueOf(sObj.get('FinServ__Balance__c')));
                }
                 system.debug('sObjWrap:>>'+sObjWrap);
                responseWrap.sObjectRecords.add(sObjWrap);        
            }
            system.debug('grandTotal:>>'+grandTotal);
            responseWrap.grandTotal = grandTotal;
        }
        return responseWrap;
    }
    
    /**
    * This method is used to conver sObject record into sObject Wrapper. 
    * @param sObj - sObject record
    * @param fieldAPINameList - List for API Names for fields whish needs to be displayed on the component.
    *
    */
    public static list<wv6_LightningTableWrapper.FieldInfoWrapper> convertRecordToListofFieldValues(sObject sObj, list<String> fieldAPINameList,list<String> fieldLabelList,string objectAPIName,set<String> hyperLinkFields,string displayLocation){
        list<wv6_LightningTableWrapper.FieldInfoWrapper> fieldValueList = new list<wv6_LightningTableWrapper.FieldInfoWrapper>();
        integer i = 0;
        
        for(String fieldName : fieldAPINameList) {
            wv6_LightningTableWrapper.FieldInfoWrapper fieldInfoWrap = new wv6_LightningTableWrapper.FieldInfoWrapper();
            string fieldValue;
            string fieldType = getFieldType(fieldName,objectAPIName ); 
            fieldInfoWrap.fieldType = fieldType;
            if(fieldType == 'CURRENCY'){
                fieldValue = String.valueOf(sObj.get(fieldName));
            }else if(fieldType == 'DATE'){
                fieldValue = String.valueof(Date.valueOf(sObj.get(fieldName)));
            }else if(fieldType == 'DATETIME'){
                fieldValue = String.valueof(DateTime.valueOf(sObj.get(fieldName)));
            }else if(fieldName == 'FinServ__FinancialAccountNumber__c' && displayLocation =='WEG Client Portal'){
                string accNumber =    String.valueOf(sObj.get(fieldName));
                string maskedAccNumber ='';
                if(accNumber != '' && accNumber != null ){
                    integer length = accNumber.length();
                    if(length > 4){
                        for(integer j=1; j<length-4;j++){
                           maskedAccNumber = maskedAccNumber +'X'; 
                        }
                        maskedAccNumber = maskedAccNumber + accNumber.right(4);
                    }
                }
                fieldValue = maskedAccNumber;
                
            }else{
                fieldValue = String.valueOf(sObj.get(fieldName)); 
            }
            fieldInfoWrap.fieldAPIName = fieldName;
            if(fieldValue != null){
                fieldInfoWrap.fieldValue = fieldValue;
            }
            fieldInfoWrap.fieldLabel = fieldLabelList[i];
            i++;
            
            if(hyperLinkFields.contains(fieldName)){
                fieldInfoWrap.hyperLink = TRUE;    
            }
            system.debug('fieldInfoWrap:>>'+fieldInfoWrap);
            fieldValueList.add(fieldInfoWrap);
        }
        return fieldValueList;
    }
    
    
    public static String getFieldType(String fieldName,string sObjectName){
        Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName);
        Schema.DescribeSObjectResult r = t.getDescribe();
        Schema.DescribeFieldResult f = r.fields.getMap().get(fieldName).getDescribe();
        return string.valueof(f.getType());
    }
    
    
}