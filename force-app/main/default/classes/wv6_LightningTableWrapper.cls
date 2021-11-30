global class wv6_LightningTableWrapper {
    
    @AuraEnabled
    public decimal grandTotal { get;set; }

    @AuraEnabled
    public List<sObjWrapper> sObjectRecords { get;set; }
    
    global class sObjWrapper{
        @AuraEnabled
        public string sObjectId { get;set; }
        
        @AuraEnabled
        public list<FieldInfoWrapper> fieldInfoWrapList { get;set; }
        
    }
    
    public class FieldInfoWrapper{
        @AuraEnabled
        public String fieldAPIName {get; set;}
        @AuraEnabled
        public String fieldLabel {get; set;}
        @AuraEnabled
        public String fieldValue {get; set;}
        @AuraEnabled
        public String fieldType {get; set;}
        @AuraEnabled
        public boolean hyperLink {get; set;}
        
    }
}