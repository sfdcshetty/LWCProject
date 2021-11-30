/******************************************************************************************************************************
* @class name    : Wave6_AccountCardController
* @description   : This is controller class for Lightning component (AccountCard). Lightning component is used to display dedicated icons for account based on the record type.
*                  Also, It displays account details for fields predefined in the field set.
*
* @test class    : Wave6_AccountCardControllerTest
* @author        : Ganesh Ekhande
* @date          : 05/05/2017
*
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande                       05/05/2017             Created.
* Ganesh Ekhande                       01/04/2018             Added getFieldsToQuery method and commented getAccountDetails
*
******************************************************************************************************************************/
public class Wave6_AccountCardController {
  /*
    * @author       : Ganesh Ekhande
    * @description  : This method is used to get list of fields from fields set for current account record type.
    * @created      : 01/04/2018
    * @param        : string recType
    * @return       : list<AccountFieldWrapper>
    */
    @AuraEnabled
    public static list<AccountFieldWrapper> getFieldsToQuery(string recType) {
        list<AccountFieldWrapper> fieldsToQuery = new list<AccountFieldWrapper>();
        // Fetch fields from field sets identified based on the record type.
        List<Schema.FieldSetMember> fields ;
        if(recType == 'Individual'){ // RecordTypeName
            fields = Schema.SObjectType.Account.fieldSets.Individual_Record_Type_FieldSet.getFields();
            System.debug('---- '+fields);
            //fields.add('WEGP1_Primary_Household__c');
        }else if(recType == 'Business' ){
            fields = Schema.SObjectType.Account.fieldSets.Business_Record_Type_FieldSet.getFields();
        }else if(recType == 'Household'){
            fields = Schema.SObjectType.Account.fieldSets.Household_Record_Type_FieldSet.getFields();
        }else if(recType == 'Trust'){
            fields = Schema.SObjectType.Account.fieldSets.Trust_Record_Type_FieldSet.getFields();
        }else if(recType == 'Partner'){
            fields = Schema.SObjectType.Account.fieldSets.Partner_Record_Type_FieldSet.getFields();
        }else if(recType == 'Institution'){
            fields = Schema.SObjectType.Account.fieldSets.Institution_Record_Type_FieldSet.getFields();
        }

        system.debug('fields:>>'+fields);
        if(fields != null){
            for(Schema.FieldSetMember fsm : fields){

                if(fsm.getFieldPath() != 'WEGP1_Primary_Individual__c' && fsm.getFieldPath() != 'WEGP1_Secondary_Individual__c' ){
                  fieldsToQuery.add(new AccountFieldWrapper(fsm.getFieldPath(),fsm.getLabel()));
                }
                if(fsm.getFieldPath() == 'WEGP1_Primary_Individual__c'){
                    fieldsToQuery.add(new AccountFieldWrapper('WEGP1_Primary_Individual__c','Primary Individual Id'));
                    fieldsToQuery.add(new AccountFieldWrapper('WEGP1_Primary_Individual__r.Name','Primary Individual'));
                }
                if(fsm.getFieldPath() == 'WEGP1_Secondary_Individual__c'){
                    fieldsToQuery.add(new AccountFieldWrapper('WEGP1_Secondary_Individual__c','Secondary Individual Id'));
                    fieldsToQuery.add(new AccountFieldWrapper('WEGP1_Secondary_Individual__r.Name','Secondary Individual'));
                }
            }
        }
        return fieldsToQuery;
    }
    
    @AuraEnabled
    public static IndividualHouseHolds getIndividualRecordsDetails (String recordId, String recType) {
        IndividualHouseHolds returnList = NEW IndividualHouseHolds ();
        if(recType == 'Individual') { // RecordTypeName
            
            Account acc = NEW Account ();
            acc = [SELECT 
                   		WEGP1_Primary_Household__c, WEGP1_Primary_Household__r.WEGP1_Primary_Individual__r.Name, 
                       WEGP1_Primary_Household__r.WEGP1_Primary_Individual__c, WEGP1_Primary_Household__r.Name, 
                       WEGP1_Primary_Household__r.WEGP1_Secondary_Individual__r.Name, 
                       WEGP1_Primary_Household__r.WEGP1_Secondary_Individual__c 
                   FROM 
                   	Account WHERE Id =: recordId];
            if (acc.Id != NULL) {
                returnList.houseHoldId = acc.WEGP1_Primary_Household__c;
                returnList.primaryIndividualId = acc.WEGP1_Primary_Household__r.WEGP1_Primary_Individual__c;
                returnList.secondaryIndividualId = acc.WEGP1_Primary_Household__r.WEGP1_Secondary_Individual__c;
                returnList.houseHoldName = acc.WEGP1_Primary_Household__r.Name;
                returnList.primaryIndividualName = acc.WEGP1_Primary_Household__r.WEGP1_Primary_Individual__r.Name;
                returnList.secondaryIndividualName = acc.WEGP1_Primary_Household__r.WEGP1_Secondary_Individual__r.Name;
                
            }
            
            
        }
        return returnList;
    }
    @AuraEnabled
    public Static PortalUsers PortalUserDetails (String primaryInd, String secondaryInd) {
        PortalUsers returnList = new PortalUsers ();
        returnList.primaryIndividualUser = '';
        returnList.secondaryIndividualUser = '';
        returnList.primaryIndividualAccountId = '';
        returnList.secondaryIndividualAccountId = '';
        returnList.secondaryIndividualContact = '';
        returnList.primaryIndividualContact = '';
        try {
            if (primaryInd != NULL && primaryInd != '') {
                User u = [SELECT contactId, Contact.AccountID FROM USER WHERE ContactID =: primaryInd];
                returnList.primaryIndividualUser = u.ID;
                returnList.primaryIndividualAccountId = u.contact.AccountId;
                returnList.primaryIndividualContact = u.ContactId;
            }
        } catch (Exception e) {}
        try {
            if (secondaryInd != NULL && secondaryInd != '') {
                User u = [SELECT contactId, Contact.AccountID FROM USER WHERE ContactID =: secondaryInd];
                returnList.secondaryIndividualUser = u.ID;
                returnList.secondaryIndividualAccountId = u.contact.AccountId;
                returnList.secondaryIndividualContact = u.ContactId;
            }
            	
        } Catch (Exception e) {}
        return returnList;
    }
    public class PortalUsers {
        @AuraEnabled public String primaryIndividualUser;
        @AuraEnabled public String secondaryIndividualUser;
        @AuraEnabled public String primaryIndividualAccountId;
        @AuraEnabled public String secondaryIndividualAccountId;
        @AuraEnabled public String primaryIndividualContact;
        @AuraEnabled public String secondaryIndividualContact;
    }
        
    
    
    public class IndividualHouseHolds {
    	@auraEnabled public string houseHoldId ;
        @auraEnabled public string primaryIndividualId;
        @auraEnabled public string secondaryIndividualId;
        @auraEnabled public string houseHoldName;
        @auraEnabled public string primaryIndividualName;
        @auraEnabled public string secondaryIndividualName;
        
        @auraEnabled public string primaryIndividualUser;
        @auraEnabled public string secondaryIndividualUser;
        
        public IndividualHouseHolds(){
            houseHoldId = '';
            primaryIndividualId = '';
            secondaryIndividualId = '';
            houseHoldName = '';
            primaryIndividualName = '';
            secondaryIndividualName = '';
            primaryIndividualUser= '';
            secondaryIndividualUser = '';
        }
    }

    // Wrapper class to wrap field label and field value. One record of this class will store data for one field.
    public class AccountFieldWrapper {
        @auraEnabled public string fieldLabel;
        @auraEnabled public string fieldValue;

        public AccountFieldWrapper(){}
        public AccountFieldWrapper(string fldLabel,string fldValue){
            this.fieldLabel = fldLabel;
            this.fieldValue = fldValue;
        }
    }
}