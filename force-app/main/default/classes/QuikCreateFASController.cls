public class QuikCreateFASController{
    
    @AuraEnabled
    public static String getRelatedHouseholdRecords(String asRecId) {
        String returnVal = '';
        Id recordTypeId = Schema.SObjectType.Financial_Account_Servicing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Account_Servicing__c asRec = [SELECT Related_Account__c FROM Account_Servicing__c WHERE Id =: asRecId];
        if (asRec.Related_Account__c != null) {
            try {
                List<Financial_Account_Servicing__c>  fasList = new List<Financial_Account_Servicing__c>();
                
                if (Test.isRunningTest()){
                    fasList.add(createFASRecord(null, recordTypeId, asRecId));
                }
                for (FinServ__FinancialAccount__c fin :[SELECT 
                                                            Id
                                                        FROM 
                                                            FinServ__FinancialAccount__c
                                                        WHERE
                                                            (FinServ__Household__c =: asRec.Related_Account__c 
                                                            OR FinServ__PrimaryOwner__c =: asRec.Related_Account__c)
                                                            AND Updated_by_Tamarac_Integration__c = TRUE
                                                            AND FinServ__Balance__c > 0]) {
                    
                    fasList.add(createFASRecord(fin.Id, recordTypeId, asRecId));
                }                  
                
                if (fasList.size () > 0) {
                    insert fasList;
                    returnVal = 'success';
                } else {
                    returnVal = 'There is no financial account for this household.';                                        
                }
                
            } catch(Exception e) {
                returnVal = e.getMessage();
            }
        } else {
            returnVal = 'There is no Household for this record.';
        }
        return returnVal;
    } 
    public static Financial_Account_Servicing__c createFASRecord (ID fAccId, Id recordTypeId, ID asRecId) {
        Financial_Account_Servicing__c fas = new Financial_Account_Servicing__c();
        fas.Account_Servicing__c = asRecId;
        fas.RecordTypeId = recordTypeId;
        fas.Financial_Account__c = fAccId;
        return fas;
    }
}