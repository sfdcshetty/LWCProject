/*
 SubmitForReviewController_TC is the Test Class 
 */
public with sharing class FASStatusUpdate {

    public Static String recordId = '';
 
    @InvocableMethod
    public static void automateMessage (List<PushAccountServicing> recordsToBeProcessed) {
        for(PushAccountServicing rec : recordsToBeProcessed) {
            recordId = rec.parentId;
        }

        List<Financial_Account_Servicing__c> finAccSer = new List<Financial_Account_Servicing__c>();
        finAccSer = [SELECT Registration_Type__c, Status__c, Principal_Review_Final_Status__c
                     FROM Financial_Account_Servicing__c 
                     WHERE Account_Servicing__c =: recordId];

        if(finAccSer.size() > 0) {
            for(Financial_Account_Servicing__c eachRec : finAccSer) {
                /* eachRec.status__c = 'Ops Processing'; */
                eachRec.Principal_Review_Final_Status__c = 'Approved (In Good Order)'; 
            }
            update finAccSer;
        }
    }
    
    //Wrapper class to assign values
    public class PushAccountServicing {
        @InvocableVariable(Required = true)
        public String parentId;
    }
}