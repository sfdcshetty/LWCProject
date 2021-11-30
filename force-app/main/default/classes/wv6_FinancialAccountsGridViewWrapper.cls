/*****************************************************
 * Author: Mangesh Honale mangesh.honale@wave6.com
 * Developed on: 20 March 2018
 * Wrapper class for Financial Accounts rewrite.
 * ***************************************************/

public class wv6_FinancialAccountsGridViewWrapper {
    @AuraEnabled
    public String objectApiName {get; set;}
    @AuraEnabled
    public List<FACategoryWrapper> categoryWrapperList {get; set;}
    @AuraEnabled
    public Integer listSize {get; set;}
    @AuraEnabled
    public list<String> fieldLabelList {get; set; }
    @AuraEnabled
    public String primaryOwnerId {get; set;}
    
    
    public wv6_FinancialAccountsGridViewWrapper(){
        categoryWrapperList = new List<FACategoryWrapper>();
        listSize =0;
        fieldLabelList = new list<String>();
        primaryOwnerId = Null;
    }
    
    
    public class FACategoryWrapper{
        @AuraEnabled
        public String category {get; set; }
        @AuraEnabled
        public List<List<FieldInfoWrapper>> recordFieldValuesList {get; set; }
        @AuraEnabled
        public List<SObjectWrapper> sObjects {get; set; }
        
        public FACategoryWrapper(){
            recordFieldValuesList = new List<List<FieldInfoWrapper>>();
            sObjects = new List<SObjectWrapper>();
        }
    }
    
     public class RecordTypeInfoWrapper{
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set; }
        
        public RecordTypeInfoWrapper(String recordTypeId, String recordTypeName){
			this.value = recordTypeId;
            this.label = recordTypeName;
        }
    }
    
    public class PicklistEntryWrapper{
        @AuraEnabled
        public String plEntryLabel {get; set;}
        @AuraEnabled
        public String plEntryValue {get; set; }
    }
    
    public class UpdateResultWrapper{
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public Sobject record;
        @AuraEnabled
        public String errorMessage;
    }
    public class FieldInfoWrapper{
        @AuraEnabled
        public String apiName {get; set;}
        @AuraEnabled
        public String label { get; set;}
        @AuraEnabled
        public String displayLabel {get; set;}
        @AuraEnabled
        public String fieldType {get; set;}
        @AuraEnabled
        public String fieldValue {get; set;}
        @AuraEnabled
        public Boolean isEdit {get; set;}
        //@AuraEnabled
        //public boolean valueChanged {get; set;}  // Ganesh 04252018 : Commented this out as WEG has decided to remove this functionality
        @AuraEnabled
        public Integer recordNumber {get; set;}
        @AuraEnabled
        public List<PicklistEntryWrapper> picklistEntries {get; set;}
        @AuraEnabled 
        public Boolean isUpdatable { get; set;} // set to true if the user has update permissions on the field
        @AuraEnabled
        public Boolean showMarkForRemoval;
        
        
        public FieldInfoWrapper(String apiName, String labelStr, String fieldType, String value, Integer recordCounter, Boolean markForRemoval){
            this.apiName = apiName;
            this.label = labelStr;
            this.fieldType = fieldType;
            this.fieldValue = value;
            this.isEdit = false;
            this.recordNumber = recordCounter;
            picklistEntries = new List<PicklistEntryWrapper>();
            isUpdatable = true;
            //valueChanged = false;     // Ganesh 04252018 : Commented this out as WEG has decided to remove this functionality
            showMarkForRemoval = markForRemoval;
        }
        
        public FieldInfoWrapper(){
            this.apiName = '';
            this.label = '';
            this.fieldType = '';
            this.fieldValue = '';
            this.displayLabel = '';
            this.isEdit = false;
            this.recordNumber = 0; 
            picklistEntries = new List<PicklistEntryWrapper>();
            isUpdatable = true;
            //valueChanged = false;  // Ganesh 04252018 : Commented this out as WEG has decided to remove this functionality
            showMarkForRemoval = true;
        }
        
    } 

    
    public class SObjectWrapper{
        
        @AuraEnabled
        public String recordId {get; set;}
        @AuraEnabled
        public Integer recordNumber {get; set;}
        @AuraEnabled
        public boolean showMarkForRemoval {get;set;}
        
        @AuraEnabled
        public boolean showCreateAdjustmentAction {get;set;}
        @AuraEnabled
        public boolean showViewAdjustmentAction {get;set;}
        
        
        @AuraEnabled
        public String field1Value {get; set;}
        @AuraEnabled
        public String field2Value {get; set;}
        @AuraEnabled
        public String field3Value {get; set;}
        @AuraEnabled
        public String field4Value {get; set;}
        @AuraEnabled
        public String field5Value {get; set;}
        @AuraEnabled
        public String field6Value {get; set;}
        @AuraEnabled
        public String field7Value {get; set;}
        @AuraEnabled
        public String field8Value {get; set;}
        @AuraEnabled
        public String field9Value {get; set;}
        @AuraEnabled
        public String field10Value {get; set;}
        @AuraEnabled
        public String field11Value {get; set;}
        @AuraEnabled
        public String field12Value {get; set;}
        
        @AuraEnabled
        public boolean showField1Value {get; set;}
        @AuraEnabled
        public boolean showField2Value {get; set;}
        @AuraEnabled
        public boolean showField3Value {get; set;}
        @AuraEnabled
        public boolean showField4Value {get; set;}
        @AuraEnabled
        public boolean showField5Value {get; set;}
        @AuraEnabled
        public boolean showField6Value {get; set;}
        @AuraEnabled
        public boolean showField7Value {get; set;}
        @AuraEnabled
        public boolean showField8Value {get; set;}
        @AuraEnabled
        public boolean showField9Value {get; set;}
        @AuraEnabled
        public boolean showField10Value {get; set;}
        @AuraEnabled
        public boolean showField11Value {get; set;}
        @AuraEnabled
        public boolean showField12Value {get; set;}
        
        public SObjectWrapper(){
            recordId = '';
            recordNumber = 0;
            showMarkForRemoval = false;
            showCreateAdjustmentAction= false;
            showViewAdjustmentAction= false;
            field1Value  = '';        
            field2Value  = '';
            field3Value  = '';
            field4Value  = '';
            field5Value  = '';
            field6Value  = '';
            field7Value  = '';
            field8Value  = '';
            field9Value  = '';
            field10Value  = '';
            field11Value  = '';
            field12Value  = '';   
            
            showField1Value  = false;        
            showField2Value  = false;   
            showField3Value  = false;   
            showField4Value  = false;   
            showField5Value  = false;   
            showField6Value  = false;   
            showField7Value  = false;   
            showField8Value  = false;   
            showField9Value  = false;   
            showField10Value  = false;   
            showField11Value  = false;   
            showField12Value  = false;       
        }
    }
}