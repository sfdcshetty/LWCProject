public with sharing class ReconciliationToolController {

    @AuraEnabled
    public static String updateTransactionStatus (Map <String, String> filterFields, Id paymentId) {        
        // get the payment based on payment Id
        List<WEG_Payment__c> payments = [SELECT Id, WEG_Status__c, WEG_Pay_Period__c FROM WEG_Payment__c WHERE Id = :paymentId];
        if (payments.size() == 1) {
            // begin the transaction query
            string transactionQuery = getTransactionFieldString();
            
            // append the filter criteria
            transactionQuery = appendFilterCriteria(transactionQuery, filterFields);
            
            // get the pay period for the payment
            Id paymentPayPeriod = payments[0].WEG_Pay_Period__c;
            
            // execute the query in batches (avoiding the DML limit)
            Id batchInstanceId = Database.executeBatch(new ReconciliationToolBatchHelper(transactionQuery, paymentId, paymentPayPeriod));
            system.debug('>>>>>>>> Batch Id: ' + batchInstanceId);
            
            return 'Status updated to Collected.';
        }
        else
            return 'ERROR :: A single payment must be supplied.';
    }
    
    @AuraEnabled
    public static List<WEG_Payment__c> getPayments (Map <String, String> filterFields) {
        String query = 'SELECT Name, WEG_Amount__c, WEG_Category__c,'
            +' WEG_Entity__c, WEG_Pay_Period__c, WEG_Status__c '
            +' FROM WEG_Payment__c WHERE Name != NULL';
        if (filterFields != NULL) {
            for (String key :filterFields.keySet()) {
                string value = filterFields.get(key);
                string[] separatedValues = value.split(':');
                if (separatedValues.size() == 1)
                    query += ' AND ' + key + ' = \'' + value + '\'';
                else {
                    query += ' AND ' + key + ' IN (';
                    for (string separateValue : separatedValues)
                        query += '\'' + separateValue + '\',';
                    query = query.removeEnd(',');
                    query += ')';
                }
            }
        }
        query += ' LIMIT 200';
        system.debug('>>>>>>>> Query: ' + query);
        return dataBase.query(query);
    }
    
    private static string appendFilterCriteria(string query, Map<String, String> filterFields) {
        if (filterFields != NULL) {
            for (string key : filterFields.keySet()) {
                if (key != '' && key != NULL && key != 'Billing_Start__c' && key != 'Billing_End__c') {
                    string value = filterFields.get(key);
                    system.debug('>>>>>>>> String Value: ' + value);
                    string[] separatedValues = value.split(':');
                    system.debug('>>>>>>>> Separated: ' + separatedValues);
                    if (separatedValues.size() == 1)
                        query += ' AND ' + key + ' = \'' + value + '\'';
                    else {
                        query += ' AND ' + key + ' IN (';
                        system.debug('>>>>>>>> Showing: ' + query);
                        for (string separateValue : separatedValues) {
                            query += '\'' + separateValue + '\',';
                        }
                        query = query.removeEnd(',');
                        query += ')';
                    }
                }
                //if (key != '' && key != NULL && (key == 'Billing_Start__c' || key == 'Billing_End__c'))
                //    query += ' AND '+ key +' = '+ filterFields.get(key);
                if (key == 'Billing_Start__c')
                    query += ' AND Billing_Date__c >= '+ filterFields.get(key);
                if (key == 'Billing_End__c')
                    query += ' AND Billing_Date__c <= '+ filterFields.get(key);
            }
        }
        
        return query;
    }
    
    private static string getTransactionFieldString() {
        return 'SELECT Name, Transaction_Type__c, Business_Entity__c, Billing_Date__c, Vendor__c, PayeeCode__c'
            + ', Household__c, Household__r.Name, Amount__c, Product__c, Product__r.Name, Pay_Period__c, Status__c, TAV_Billing_Group__c, Invoice__c'
            + ' FROM WEG_Transaction__c WHERE Transaction_Type__c != NULL';
    }
    
    @AuraEnabled
    public static List<WEG_Transaction__c> getTransactions (Map<String, String> filterFields) {
        string query = getTransactionFieldString();
        // append the filter criteria
        query = appendFilterCriteria(query, filterFields);
        // append the limit
        query += ' LIMIT 200';
        // return the query
        system.debug('>>>>>>>> Query: ' + query);
        return dataBase.Query(query);
    }
    
    @AuraEnabled
    public static List<AggregateResult> getTransactionTotals (Map<String, String> filterFields) {
        string query = 'SELECT COUNT(Name) NoTrans, SUM(Amount__c) SumTrans'
            +' FROM WEG_Transaction__c WHERE Transaction_Type__c != NULL';
        // append the filter criteria
        query = appendFilterCriteria(query, filterFields);
        // return the query
        system.debug('>>>>>>>> Query: ' + query);
        return dataBase.Query(query);
    }
    
    @AuraEnabled
    public static List<String> getPicklistValues (string objName, string fieldName) {
        // instantiate the options list
        List<String> options = new List<String>();
        
        // describe the SObject using its object type
        List<Schema.DescribeSobjectResult> objDescribes = Schema.describeSObjects(new List<string>{objName});
        
        // get a map of fields for the SObject
        for(Schema.DescribeSobjectResult objDescribe : objDescribes) {
            Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
            
            // get the list of picklist values for this field
            List<Schema.PicklistEntry> picklistValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
            
            // iterate the entries, adding them to the options list
            for(Schema.PicklistEntry plv : picklistValues) {
                options.add(plv.getValue());
            }
        }
        
        // return the options list
        return options;
    }
    
    @AuraEnabled
    public static Id getDefaultInvoice () {
        // get the default invoice by name
        List<WEG_Invoice__c> defaultInvoices = [SELECT Id FROM WEG_Invoice__c WHERE Name = 'No Selection'];
        // should only be one
        if (defaultInvoices.size() == 1)
            return defaultInvoices[0].Id;
        else
            return null;
    }
}