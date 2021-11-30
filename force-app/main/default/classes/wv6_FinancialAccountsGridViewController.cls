/*****************************************************
* Author: Mangesh Honale mangesh.honale@wave6.com
* Developed on: 20 March 2018
* Controller for financial accounts grid view.
* ***************************************************/
public class wv6_FinancialAccountsGridViewController {
    public static List<String> gridfields = new List<String>();
    
    /* Input parameters-
1. objectApiName: API name of object to be queried
2. recordTypes: Comma separeted record type names
3. fields: fields
4. accountId: household or individual account id

Returns an instance of wv6_FinancialAccountsGridViewWrapper containing data needed for grid view.
*/ 
    @AuraEnabled
    public static String getGridRecordsForEditMode(
        String objectName, 
        String recordTypes, 
        String fields, 
        String accountId, 
        String accountType,
        String groupBy, 
        String sortBy,
        String statuses
    ){
        
        wv6_FinancialAccountsGridViewWrapper gridWrapper = new wv6_FinancialAccountsGridViewWrapper();
        gridWrapper.objectApiName = objectName;
        
        if(accountType.equalsIgnoreCase('Individual')){
            gridWrapper.primaryOwnerId = accountId;              
        }else{
            List<Account> accList = [SELECT Id, WEGP1_Primary_Individual__r.AccountId FROM Account WHERE Id=:accountId];
            if(!accList.isEmpty()){
                if(accList[0].WEGP1_Primary_Individual__c != null){
                    gridWrapper.primaryOwnerId = accList[0].WEGP1_Primary_Individual__r.AccountId;
                }
            }
        }
        
        if(fields != '' && fields != null ){
            List<Sobject> recordList = getsObjectList (objectName,recordTypes, fields, accountId,accountType,groupBy,sortBy,statuses); 
            
            if(!recordList.isEmpty()){
                //get record type and picklist value mapping
                Map<string, List<wv6_RecordType_Picklist_Info__mdt>> rtToMetadataMap = new Map<string, List<wv6_RecordType_Picklist_Info__mdt>>();
                for(wv6_RecordType_Picklist_Info__mdt mtd : [SELECT Record_Type_Name__c,Field_Name__c,Picklist_Values__c FROM wv6_RecordType_Picklist_Info__mdt]){
                    if(!rtToMetadataMap.containsKey(mtd.Record_Type_Name__c)){
                        rtToMetadataMap.put(mtd.Record_Type_Name__c+':'+mtd.Field_Name__c,new List<wv6_RecordType_Picklist_Info__mdt>{mtd});
                    }else{
                        rtToMetadataMap.get(mtd.Record_Type_Name__c+':'+mtd.Field_Name__c).add(mtd);
                    }
                }
                String lastRecordCategory = ''; // keeps track of the category of last record processed
                wv6_FinancialAccountsGridViewWrapper.FACategoryWrapper catWrapper = new wv6_FinancialAccountsGridViewWrapper.FACategoryWrapper();
                gridWrapper.listSize = recordList.size();
                
                Integer recordCounter = 0;
                for(Sobject record: recordList){
                    List<wv6_FinancialAccountsGridViewWrapper.FieldInfoWrapper> fieldValuesList = new List<wv6_FinancialAccountsGridViewWrapper.FieldInfoWrapper>();
                    
                    // decide if "Mark for Removal" menu option is to be shown depending upon Held Status
                    string recordTypeName = (String) record.getSobject('RecordType').get('Name');
                    if(objectName.equalsIgnoreCase('FinServ__FinancialAccount__c') && recordTypeName !='Bank Account' &&
                       (String.valueOf(record.get('WEGP1_Held_Status__c')).equalsIgnoreCase('WEG Held') ||
                        String.valueOf(record.get('WEGP1_Held_Status__c')).equalsIgnoreCase('WEG Held Other'))){
                            fieldValuesList.add(new wv6_FinancialAccountsGridViewWrapper.FieldInfoWrapper('Id', 'Id', 'Id', (String)record.get('Id'),recordCounter, false));
                        }else{
                            fieldValuesList.add(new wv6_FinancialAccountsGridViewWrapper.FieldInfoWrapper('Id', 'Id', 'Id', (String)record.get('Id'),recordCounter, true));
                        }
                    
                    // get sobject type using provided object API name
                    Map<String, Schema.SObjectType> sobjectTypeMap = Schema.getGlobalDescribe();
                    Map<String, Schema.SObjectField> fieldMetadataMap = sobjectTypeMap.get(objectName).getDescribe().fields.getMap();
                    Schema.DescribeFieldResult fieldResult;
                    for(String fieldAPIName: gridfields){
                        system.debug('fieldAPIName:>>'+fieldAPIName);
                        fieldResult = fieldMetadataMap.get(fieldAPIName).getDescribe();
                        system.debug('fieldResult:>>'+fieldResult);
                        wv6_FinancialAccountsGridViewWrapper.FieldInfoWrapper objFieldInfoWrapper = new wv6_FinancialAccountsGridViewWrapper.FieldInfoWrapper();
                        objFieldInfoWrapper.apiName = fieldAPIName;
                        objFieldInfoWrapper.label = fieldResult.getLabel();
                        objFieldInfoWrapper.fieldType = String.valueOf(fieldResult.getType());
                        objFieldInfoWrapper.recordNumber = recordCounter;
                        
                        // abbriavate record name to 50 chars 
                        if(objFieldInfoWrapper.apiName.equalsIgnoreCase('NAME')){
                            String name = String.valueOf(record.get('name'));
                            objFieldInfoWrapper.displayLabel = name.abbreviate(50);
                        }
                        if(String.valueOf(fieldResult.getType()).equalsIgnoreCase('DATE') || String.valueOf(fieldResult.getType()).equalsIgnoreCase('DATETIME')) {
                            if(record.get(fieldAPIName) <> null) {
                                String dateValue = String.valueOf(record.get(fieldAPIName)).split(' ')[0];
                                objFieldInfoWrapper.fieldValue = dateValue.split('-')[1] + '/' + 
                                    dateValue.split('-')[2] + '/' + 
                                    dateValue.split('-')[0];
                            }
                        } else if(String.valueOf(fieldResult.getType()).equalsIgnoreCase('CURRENCY') && String.isNotBlank(String.valueOf(record.get(fieldAPIName)))){
                            objFieldInfoWrapper.fieldValue = String.valueOf(record.get(fieldAPIName));
                            system.debug('==============>' + objFieldInfoWrapper.fieldValue);
                        } else {
                            objFieldInfoWrapper.fieldValue = String.valueOf(record.get(fieldAPIName));
                        }
                        
                        
                        // if the field type is picklist then add picklist entries to PicklistEntryWrapper instance
                        if(String.valueOf(fieldResult.getType()).equalsIgnoreCase('PICKLIST')){
                            system.debug('recordType>>'+(String) record.getSobject('RecordType').get('Name'));
                            wv6_FinancialAccountsGridViewWrapper.PicklistEntryWrapper pleWrapper = new wv6_FinancialAccountsGridViewWrapper.PicklistEntryWrapper();
                            
                            if(rtToMetadataMap.containsKey((String) record.getSobject('RecordType').get('Name')+':'+fieldAPIName)){
                                for(wv6_RecordType_Picklist_Info__mdt mtd : rtToMetadataMap.get(((String) record.getSobject('RecordType').get('Name'))+':'+fieldAPIName)) {
                                    if(mtd.Field_Name__c.equalsIgnoreCase(fieldAPIName)){
                                        pleWrapper = new wv6_FinancialAccountsGridViewWrapper.PicklistEntryWrapper();
                                        pleWrapper.plEntryLabel = '--None--';
                                        pleWrapper.plEntryValue = '--None--';
                                        objFieldInfoWrapper.picklistEntries.add(pleWrapper);
                                        for(string ss: mtd.Picklist_Values__c.split(',')){
                                            pleWrapper = new wv6_FinancialAccountsGridViewWrapper.PicklistEntryWrapper();  
                                            pleWrapper.plEntryValue = ss;
                                            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                                            for( Schema.PicklistEntry f : ple)
                                                if(ss.equalsIgnoreCase(f.getValue()))
                                                pleWrapper.plEntryLabel = f.getLabel();
                                            if(ss.equalsIgnoreCase(objFieldInfoWrapper.fieldValue))
                                                objFieldInfoWrapper.displayLabel = pleWrapper.plEntryLabel;
                                            objFieldInfoWrapper.picklistEntries.add(pleWrapper);
                                        }
                                    }
                                }
                            }else{
                                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                                pleWrapper = new wv6_FinancialAccountsGridViewWrapper.PicklistEntryWrapper();
                                pleWrapper.plEntryLabel = '--None--';
                                pleWrapper.plEntryValue = '--None--';
                                objFieldInfoWrapper.picklistEntries.add(pleWrapper);
                                for( Schema.PicklistEntry f : ple){
                                    pleWrapper = new wv6_FinancialAccountsGridViewWrapper.PicklistEntryWrapper();
                                    pleWrapper.plEntryLabel = f.getLabel();
                                    pleWrapper.plEntryValue = f.getValue();
                                    if(f.getValue().equalsIgnoreCase(objFieldInfoWrapper.fieldValue)){
                                        objFieldInfoWrapper.displayLabel = f.getLabel();
                                    }
                                    objFieldInfoWrapper.picklistEntries.add(pleWrapper);
                                }
                            }
                        }
                        
                        // verify if the field can be edited by the current user
                        objFieldInfoWrapper.isUpdatable = fieldResult.isUpdateable();
                        fieldValuesList.add(objFieldInfoWrapper);
                    }
                    String recCategory = '';
                    if(String.isNotBlank(groupBy)) {
                        recCategory = (String)record.get(groupBy);
                    }
                    
                    // if current record cateogry is not same as category of last record then add category wrapper instance to gridWrapper
                    if((String.isBlank(lastRecordCategory) && String.isBlank(recCategory)) || 
                        (String.isNotBlank(lastRecordCategory) && String.isNotBlank(recCategory) && 
                        lastRecordCategory.equalsIgnoreCase(recCategory))){
                           catWrapper.recordFieldValuesList.add(fieldValuesList);          
                           if(!String.isEmpty(groupBy)) {
                               catWrapper.category = (String)record.get(groupBy);
                           }
                       } else{
                           if(!catWrapper.recordFieldValuesList.isEmpty())
                               gridWrapper.categoryWrapperList.add(catWrapper);                                                                               
                           catWrapper = new wv6_FinancialAccountsGridViewWrapper.FACategoryWrapper();
                           catWrapper.recordFieldValuesList.add(fieldValuesList);
                           catWrapper.category = (String)record.get(groupBy);                                                      
                       }

                    if(String.isNotBlank(groupBy)){
                        lastRecordCategory = (String)record.get(groupBy);
                    }
                    fieldValuesList = new List<wv6_FinancialAccountsGridViewWrapper.FieldInfoWrapper>();
                    recordCounter++;
                }
                gridWrapper.categoryWrapperList.add(catWrapper);
            }
        }
        system.debug('gridWrapper:>>' + JSON.serialize(gridWrapper));
        return JSON.serialize(gridWrapper);
    }
    
    @AuraEnabled
    public static List<wv6_FinancialAccountsGridViewWrapper.UpdateResultWrapper> saveChanges(String gridWrapperStr){
        wv6_FinancialAccountsGridViewWrapper gridWrapper = (wv6_FinancialAccountsGridViewWrapper)JSON.deserialize(gridWrapperStr, wv6_FinancialAccountsGridViewWrapper.class);
        List<Sobject> sobjectListToUpdate = new List<Sobject>();
        
        // recontruct sobject records from wrapper instance
        if(!gridWrapper.categoryWrapperList.isEmpty()){
            for(wv6_FinancialAccountsGridViewWrapper.FACategoryWrapper category: gridWrapper.categoryWrapperList){
                for(List<wv6_FinancialAccountsGridViewWrapper.FieldInfoWrapper> recordValuesList: category.recordFieldValuesList){
                    sObject sObj = Schema.getGlobalDescribe().get(gridWrapper.objectApiName).newSObject();
                    for(wv6_FinancialAccountsGridViewWrapper.FieldInfoWrapper fiw: recordValuesList){
                        system.debug('fiw:>>'+fiw);
                        if(fiw.isUpdatable && !String.isEmpty(fiw.fieldValue)){
                            if(fiw.fieldValue.contains('*'))
                                fiw.fieldValue = fiw.fieldValue.remove('*'); 
                            String fieldValue = fiw.fieldValue;
                            if(fiw.fieldType.equalsIgnoreCase('DATE')){
                                if(fieldValue.contains('-')){
                                    List<String> dateNum = fieldValue.split('-');
                                    Integer month = Integer.valueOf(dateNum.get(1));
                                    Integer day = Integer.valueOf(dateNum.get(2));
                                    Integer year = Integer.valueOf(dateNum.get(0));
                                    sObj.put(fiw.apiName, Date.newInstance(year, month, day));      
                                }
                            }
                            else if(fiw.fieldType.equalsIgnoreCase('CURRENCY')){
                                if(fieldValue.contains('$'))
                                    fieldValue = fieldValue.substringAfter('$');
                                sObj.put(fiw.apiName, Decimal.valueof(fieldValue));   
                            }
                            else if(fiw.fieldType.equalsIgnoreCase('PERCENT')){
                                system.debug('fieldValue:>>'+fieldValue);
                                if(fieldValue.contains('%')){
                                    fieldValue = fieldValue.removeEnd('%'); 
                                }
                                sObj.put(fiw.apiName,  Decimal.valueof(fieldValue)); 
                            }
                            else
                                sObj.put(fiw.apiName, fieldValue);   
                        }
                    }
                    sobjectListToUpdate.add(sObj);
                }
            }
            List<wv6_FinancialAccountsGridViewWrapper.UpdateResultWrapper> updateResultList = new List<wv6_FinancialAccountsGridViewWrapper.UpdateResultWrapper>();
            Database.SaveResult[] updateResults = Database.update(sobjectListToUpdate, false);
            for(Integer ind = 0; ind < updateResults.size(); ind++){
                wv6_FinancialAccountsGridViewWrapper.UpdateResultWrapper resultWrapper = new wv6_FinancialAccountsGridViewWrapper.UpdateResultWrapper();
                resultWrapper.record = (Sobject)sobjectListToUpdate[ind];
                resultWrapper.errorMessage = '';
                if(updateResults[ind].isSuccess()){
                    resultWrapper.isSuccess = true;
                }else{
                    for(Database.Error err : updateResults[ind].getErrors()){
                        resultWrapper.isSuccess = false;    
                        resultWrapper.errorMessage += err.getMessage(); 
                    }
                }
                updateResultList.add(resultWrapper);
            }
            return updateResultList;   
        }
        return null;
    }
    
    
    /*@AuraEnabled
    public static void updateFinancialAccount(string recordId, string removeOrHistoric){
        FinServ__FinancialAccount__c finAcc = new FinServ__FinancialAccount__c();
        finAcc.Id = recordId;
        finAcc.Remove_or_Historic__c = removeOrHistoric;
        update finAcc;
    }*/
    
    @AuraEnabled
    public static wv6_FinancialAccountsGridViewWrapper.UpdateResultWrapper updatesObject(string recordId, string removeOrHistoric, string objectName){
        
        sObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject() ;
        sObj.put('Remove_or_Historic__c',removeOrHistoric);
        sObj.Id = recordId;
        system.debug('sObj:>>'+sObj);
        Database.SaveResult updateResult = Database.update(sObj, false);
        
        
        wv6_FinancialAccountsGridViewWrapper.UpdateResultWrapper resultWrapper = new wv6_FinancialAccountsGridViewWrapper.UpdateResultWrapper();
        resultWrapper.record = sObj;
        resultWrapper.errorMessage = '';
        if(updateResult.isSuccess()){
            resultWrapper.isSuccess = true;
        }else{
            for(Database.Error err : updateResult.getErrors()){
                resultWrapper.isSuccess = false;    
                resultWrapper.errorMessage += err.getMessage(); 
            }
        }
        system.debug('resultWrapper:>>'+resultWrapper);
        return resultWrapper;   
    }
    
    
    @AuraEnabled 
    public static void createInvestmentAdjustment(Investment_Adjustment__c investmentAdjustment){
        insert investmentAdjustment;
    }
    
    @AuraEnabled
    public static List<String> getInvestAdjustmentTypes(){
        List<String> picklistEntryList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Investment_Adjustment__c.Adjustment_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListEntry : ple){
            picklistEntryList.add(pickListEntry.getValue());
        }  
        return picklistEntryList;
    }
    
    @AuraEnabled
    public static List<wv6_FinancialAccountsGridViewWrapper.RecordTypeInfoWrapper> getRecordTypes(String objectName, String recordTypeIds){
        
        // split recordTypes variable by comma to get list of record type names
        List<String> recordTypeIdList = recordTypeIds.split(',');
        Set<String> recordTypeIdSet = new Set<String>();
        if(!recordTypeIdList.isEmpty()){
            for(String recTypeId: recordTypeIdList){
                recordTypeIdSet.add(recTypeId.trim());
            }
        }
        
        List<wv6_FinancialAccountsGridViewWrapper.RecordTypeInfoWrapper> recordTypeInfoWrapperList = new List<wv6_FinancialAccountsGridViewWrapper.RecordTypeInfoWrapper>();
        List<Schema.RecordTypeInfo> recordTypeInfoList = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfos();
        for(Schema.RecordTypeInfo rtInfo: recordTypeInfoList){
            if(rtInfo.isAvailable() && !rtInfo.isMaster() && recordTypeIdSet.contains(rtInfo.getRecordTypeId())){
                recordTypeInfoWrapperList.add(new wv6_FinancialAccountsGridViewWrapper.RecordTypeInfoWrapper(rtInfo.getRecordTypeId(), rtInfo.getName()));
            }
        }
        return recordTypeInfoWrapperList;
    }
    
    
    @AuraEnabled
    public static String getGridRecordsForReadOnlyMode(
        String objectName, 
        String recordTypes, 
        String fields, 
        String accountId, 
        String accountType,
        String groupBy, 
        String sortBy,
        String statuses,
        String gridTitle
    ){
        
        wv6_FinancialAccountsGridViewWrapper gridWrapper = new wv6_FinancialAccountsGridViewWrapper();
        gridWrapper.objectApiName = objectName;
        
        if(accountType.equalsIgnoreCase('Individual')){
            gridWrapper.primaryOwnerId = accountId;              
        }else{
            List<Account> accList = [SELECT Id, WEGP1_Primary_Individual__r.AccountId FROM Account WHERE Id=:accountId];
            if(!accList.isEmpty()){
                if(accList[0].WEGP1_Primary_Individual__c != null){
                    gridWrapper.primaryOwnerId = accList[0].WEGP1_Primary_Individual__r.AccountId;
                }
            }
        }
        if(fields != '' && fields != null ){
            List<Sobject> recordList = getsObjectList (objectName,recordTypes, fields, accountId,accountType,groupBy,sortBy,statuses); 
            
            if(!recordList.isEmpty()){
                
                String lastRecordCategory = ''; // keeps track of the category of last record processed
                wv6_FinancialAccountsGridViewWrapper.FACategoryWrapper catWrapper = new wv6_FinancialAccountsGridViewWrapper.FACategoryWrapper();
                gridWrapper.listSize = recordList.size();
                
                Integer recordCounter = 0;
                for(Sobject record: recordList){
                    wv6_FinancialAccountsGridViewWrapper.SObjectWrapper sObjWrap  = new wv6_FinancialAccountsGridViewWrapper.SObjectWrapper();
                    sObjWrap.recordId = (String)record.get('Id');
                    sObjWrap.recordNumber = recordCounter;
                    
                    // decide if "Mark for Removal" menu option is to be shown depending upon Held Status
                    string recordTypeName = (String) record.getSobject('RecordType').get('Name');
                    if(objectName.equalsIgnoreCase('FinServ__FinancialAccount__c') && recordTypeName !='Bank Account' &&
                       (String.valueOf(record.get('WEGP1_Held_Status__c')).equalsIgnoreCase('WEG Held') ||
                        String.valueOf(record.get('WEGP1_Held_Status__c')).equalsIgnoreCase('WEG Held Other'))){
                            sObjWrap.showMarkForRemoval = false;
                    }else{
                        sObjWrap.showMarkForRemoval = true;
                    }
                    
                    // Show Adjustment related actions to all the Investment Accounts. 
                    if(objectName.equalsIgnoreCase('FinServ__FinancialAccount__c') && recordTypeName.contains('Investment Account')){
                        sObjWrap.showCreateAdjustmentAction = true;    
                        sObjWrap.showViewAdjustmentAction = true;   
                    }
                    
                    // get sobject type using provided object API name
                    Map<String, Schema.SObjectType> sobjectTypeMap = Schema.getGlobalDescribe();
                    Map<String, Schema.SObjectField> fieldMetadataMap = sobjectTypeMap.get(objectName).getDescribe().fields.getMap();
                    Schema.DescribeFieldResult fieldResult;
                    list<String> fieldLabelList = new list<String>();
                    for(integer i=1 ; i<= gridfields.size(); i++){
                        string fieldAPIName = gridfields[i-1];
                        fieldResult = fieldMetadataMap.get(fieldAPIName).getDescribe();
                        if(gridTitle == 'Additional Income' && fieldAPIName == 'Name'){
                            fieldLabelList.add('Additional Income Name');
                        }else if(gridTitle == 'Insurance' && fieldAPIName == 'Name'){
                            fieldLabelList.add('Insurance Account Name');
                        }else if(gridTitle == 'Assets and Liabilities' && fieldAPIName == 'WEGP1_AsOfDate__c'){
                            fieldLabelList.add('As of Date');
                        }else{
                            fieldLabelList.add(fieldResult.getLabel());   
                        }
                        string fieldValue = '';
                        
                        // abbriavate record name to 50 chars 
                        if(fieldAPIName.equalsIgnoreCase('NAME')){
                            String name = String.valueOf(record.get('name'));
                            fieldValue = name.abbreviate(50);
                        }else if(String.valueOf(fieldResult.getType()).equalsIgnoreCase('DATE') || String.valueOf(fieldResult.getType()).equalsIgnoreCase('DATETIME')) {
                            if(record.get(fieldAPIName) <> null) {
                                String dateValue = String.valueOf(record.get(fieldAPIName)).split(' ')[0];
                                fieldValue = dateValue.split('-')[1] + '/' + dateValue.split('-')[2] + '/' + dateValue.split('-')[0];
                            }
                        } else if(String.valueOf(fieldResult.getType()).equalsIgnoreCase('CURRENCY') && String.isNotBlank(String.valueOf(record.get(fieldAPIName)))){
                            Decimal fieldValueInt = (Decimal)record.get(fieldAPIName);
                            fieldValue = '$' + String.valueOf(fieldValueInt.setscale(2).format());
                        } else if(String.valueOf(fieldResult.getType()).equalsIgnoreCase('PERCENT') && String.isNotBlank(String.valueOf(record.get(fieldAPIName)))){
                            fieldValue = String.valueOf(record.get(fieldAPIName)) + '%';
                        }else {
                            fieldValue = String.valueOf(record.get(fieldAPIName));
                        }
                        
                        if(i == 1){
                            if(fieldValue != null){    
                                sObjWrap.field1Value = fieldValue;
                            }
                            sObjWrap.showField1Value  = true;  
                        }
                        if(i == 2){
                            if(fieldValue != null){
                                sObjWrap.field2Value = fieldValue;
                            }
                            sObjWrap.showField2Value  = true;  
                        }
                        if(i == 3){
                            if(fieldValue != null){
                                sObjWrap.field3Value = fieldValue;
                            }
                            sObjWrap.showField3Value  = true;  
                        }
                        if(i == 4){
                            if(fieldValue != null){
                                sObjWrap.field4Value = fieldValue;
                            }
                            sObjWrap.showField4Value  = true;  
                        }
                        if(i == 5){
                            if(fieldValue != null){
                                sObjWrap.field5Value = fieldValue;
                            }
                            sObjWrap.showField5Value  = true;  
                        }
                        if(i == 6){
                            if(fieldValue != null){
                                sObjWrap.field6Value = fieldValue;
                            }
                            sObjWrap.showField6Value  = true;  
                        }
                        if(i == 7){
                            if(fieldValue != null){
                                sObjWrap.field7Value = fieldValue;
                            }
                            sObjWrap.showField7Value  = true;  
                        }
                        if(i == 8){
                            if(fieldValue != null){
                                sObjWrap.field8Value = fieldValue;
                            }
                            sObjWrap.showField8Value  = true;  
                        }
                        if(i == 9){
                            if(fieldValue != null){
                                sObjWrap.field9Value = fieldValue;
                            }
                            sObjWrap.showField9Value  = true;  
                        }
                        if(i == 10){
                            if(fieldValue != null){
                                sObjWrap.field10Value = fieldValue;
                            }
                            sObjWrap.showField10Value  = true;  
                        }
                        if(i == 11){
                            if(fieldValue != null){
                                sObjWrap.field11Value = fieldValue;
                            }
                            sObjWrap.showField11Value  = true;  
                        }
                        if(i == 12){
                            if(fieldValue != null){
                                sObjWrap.field12Value = fieldValue;
                            }   
                            sObjWrap.showField12Value  = true;  
                        }
                    }
                    system.debug('sObjWrap:>>'+sObjWrap);
                    gridWrapper.fieldLabelList = fieldLabelList; 
                    
                    String recCategory = '';
                    if(String.isNotBlank(groupBy)) {
                        recCategory = (String)record.get(groupBy);
                    }
                    // if current record cateogry is not same as category of last record then add category wrapper instance to gridWrapper
                    if((String.isBlank(lastRecordCategory) && String.isBlank(recCategory)) || 
                       (String.isNotBlank(lastRecordCategory) && String.isNotBlank(recCategory) && 
                       lastRecordCategory.equalsIgnoreCase(recCategory))){
                           catWrapper.sObjects.add(sObjWrap);          
                           if(!String.isEmpty(groupBy)) {
                               catWrapper.category = (String)record.get(groupBy);
                           }
                       } else{
                           if(!catWrapper.sObjects.isEmpty())
                               gridWrapper.categoryWrapperList.add(catWrapper);                                                                               
                           catWrapper = new wv6_FinancialAccountsGridViewWrapper.FACategoryWrapper();
                           catWrapper.sObjects.add(sObjWrap);
                           catWrapper.category = (String)record.get(groupBy);                                                      
                       }
                    
                    if(String.isNotBlank(groupBy)){
                        lastRecordCategory = (String)record.get(groupBy);
                    }
                    sObjWrap = new wv6_FinancialAccountsGridViewWrapper.SObjectWrapper();
                    recordCounter++;
                }
                gridWrapper.categoryWrapperList.add(catWrapper);
            }
        }
        system.debug('gridWrapper:>>' + JSON.serialize(gridWrapper));
        return JSON.serialize(gridWrapper);
    }
    
    /*public static string formatCurrency(Integer yourInteger){
        string regex = '(\\d)(?=(\\d{3})+(?!\\d))';
        Pattern objPt = Pattern.compile('(\\d)(?=(\\d{3})+(?!\\d))');
        Matcher regMatcher = objPt.matcher(String.valueOf(yourInteger));
        String formattedCur;
        if(regMatcher.find()) {
            formattedCur = String.valueOf(yourInteger).replaceAll(regex, '$1,');
        }
        return formattedCur;
    }*/
    
    
    public static list<sObject> getsObjectList (
        String objectName, 
        String recordTypes, 
        String fields, 
        String accountId, 
        String accountType,
        String groupBy, 
        String sortBy,
        String statuses){
            
            
        // get fields from fieldset
        List<String> statusCriteriaList;
        gridfields = new List<String>();
        List<String> fieldsList = new List<String>();
        
        // Convert string of comma separated field API Names into List
        for(String fieldAPIName : fields.split(',')){
            fieldsList.add(fieldAPIName.trim()); 
        }
        
        // Create list of field API Names which needs to be displayed on the Grid
        gridfields.addAll(fieldsList);
        
        // Convert string of comma separated field Record Type Ids into List
        List<String> recordTypeIds = new list<String>();
        for(String recordTypeId : recordTypes.split(',')){
            recordTypeIds.add(recordTypeId.trim()); 
        }
        fieldsList.add('Id');
        fieldsList.add('RecordTypeId');
        fieldsList.add('RecordType.Name');
        
        // if object is FinServ__FinancialAccount__c then records with Held Status of WEG Held or WEG Held Other will not be 
        // shown "Mark for Removal" menu 
        if(objectName.equalsIgnoreCase('FinServ__FinancialAccount__c')){
            fieldsList.add('WEGP1_Held_Status__c');
            // Below two fields will be used to check if there are any contribution or withdrawal adjustment created. 
            // If yes then these fields will have value greater than 0.
            // Ganesh 04252018 : Commented this out as WEG has decided to remove this functionality
            fieldsList.add('Contributions_Adjustment__c');
            fieldsList.add('Withdrawals_Adjustment__c');    
        }
        
        if(objectName.equalsIgnoreCase('FinServ__AssetsAndLiabilities__c')){
            fieldsList.add('WEGP1_RecordType__c');
        }
        
        if(String.isNotBlank(groupBy)) {
            fieldsList.add(groupBy);
        }
        fieldsList = new List<String>(new Set<String>(fieldsList)); //remove duplicate fields from list
        String queryString ='SELECT  ' + String.join(fieldsList, ',') + ' FROM ' + objectName + ' WHERE RecordTypeId IN: recordTypeIds ';
        if(accountType.equalsIgnoreCase('Individual')) {
            queryString += ' AND FinServ__PrimaryOwner__c =: accountId';
        } else {
            queryString += ' AND FinServ__Household__c =: accountId';
        }
        
        if(String.isNotBlank(statuses)){
            statusCriteriaList = statuses.split(',');
            for(Integer index = 0; index < statusCriteriaList.size(); index++)
                statusCriteriaList[index] = statusCriteriaList[index].trim();
            if(objectName.equalsIgnoreCase('FinServ__FinancialAccount__c'))
                queryString += ' AND FinServ__Status__c IN: statusCriteriaList';
            if(objectName.equalsIgnoreCase('FinServ__AssetsAndLiabilities__c'))
                queryString += ' AND Status__c IN: statusCriteriaList';
        }
        list<string> removeOrHistoric = new list<string>{ 'Mark for Removal','Transfer to Historic'};
            queryString += ' AND Remove_or_Historic__c NOT IN :removeOrHistoric ';
        
        if(String.isNotBlank(groupBy)){
            queryString += ' Order by ' + groupBy  + ' DESC NULLs FIRST';
        }
        
        if(String.isNotBlank(sortBy)){
            if(String.isNotBlank(groupBy)){
                queryString += ','+ sortBy + ' DESC';
            }else{
                queryString += ' Order by ' + sortBy + ' DESC';
            }
        }
        // execute the dynamic query and get list of sObject records
        system.debug('queryString:>>' + queryString);
        List<Sobject> recordList = Database.query(queryString);
        return recordList;
    }
}