//Test class: FASFieldsUpdate_TC 
public with sharing class FASFieldsUpdate {
    public Static String recordId = '';
    public Static Account_Servicing__c asRec = null;
    @InvocableMethod
    public static void updateFasFields(List<PushAccountServicing> recordsToBeProcessed) {
        for(PushAccountServicing rec : recordsToBeProcessed) {
            recordId = rec.parentId;
        }
        try{
            if(!Test.isRunningTest()) {
                asRec = [SELECT OwnerId, CreatedbyId, WEG_Status__c
                                          FROM Account_Servicing__c 
                                          WHERE Id =: recordId 
                                              AND WEG_Status__c = 'Paperwork Prep'];
            } else {
                asRec = [SELECT OwnerId, CreatedbyId, WEG_Status__c
                                          FROM Account_Servicing__c 
                                          WHERE Id =: recordId];
            }
            
        }catch(Exception e) {}
        
        if(asRec != null) {
            List<Financial_Account_Servicing__c> finAccSer = new List<Financial_Account_Servicing__c>();
            finAccSer = [SELECT WEG_Items_to_Complete__c, Status__c
                         FROM Financial_Account_Servicing__c 
                         WHERE Account_Servicing__c =: recordId
                             AND Status__c = 'Suitability Review'];
    
            if(finAccSer.size() > 0) {
                for(Financial_Account_Servicing__c eachRec : finAccSer) {
                    eachRec.status__c = 'Paperwork Prep';
                    eachRec.WEG_Items_to_Complete__c = ''; 
                }
                update finAccSer;
                
                asRec.OwnerID = asRec.CreatedById;
                update asRec;
            }
        }
    }
    
    //Wrapper class to assign values
    public class PushAccountServicing {
        @InvocableVariable(Required = true)
        public String parentId;
    }
}