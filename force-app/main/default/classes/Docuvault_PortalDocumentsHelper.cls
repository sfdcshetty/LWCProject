public class Docuvault_PortalDocumentsHelper {
    @AuraEnabled
    public static String getRelatedAccountID () {
        try {
            User userRec = [SELECT ContactId FROM User 
                            WHERE Id = :UserInfo.getUserID () 
                            LIMIT 1];
            Contact con = new Contact ();
            con = [SELECT AccountID, Account.WEGP1_Primary_Household__c FROM Contact 
                   WHERE ID =: userRec.contactID 
                   LIMIT 1];
            Document__c doc = new Document__c ();
            doc = [SELECT ID FROM Document__c 
                   WHERE Account__c =: con.Account.WEGP1_Primary_Household__c 
                   Order By LastModifiedDate Desc 
                   LIMIT 1];
            System.Debug (doc.ID);
            return String.valueOf(doc.ID);
        }
        catch (Exception e) {
            return String.valueOf(e.getMessage());
        }
    }
    
    @AuraEnabled
    public Static ID getPortalDocumentId (String recordId) {
        ID portalDocId = NULL;
        System.Debug (recordId);
        if (recordId.startsWithIgnoreCase('001')) {
            Document__c doc = new Document__c ();
            doc = [SELECT ID FROM Document__c 
                   WHERE Account__c =: recordId
                   Order By LastModifiedDate Desc 
                   LIMIT 1];
            portalDocId = doc.ID;
        }
        
        return portalDocId;
    }
    
    @AuraEnabled
    public Static List <String> getPickListOptions (String objectName, String fieldName) {
        List <String> pickListMap = NEW List <String> ();
        Schema.sObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        list<Schema.PicklistEntry> values =
            fieldMap.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry entry : values) { 
            pickListMap.add(entry.getValue()); 
        }
        return pickListMap;
    }
    @AuraEnabled 
    public static Boolean checkPortalUser (Id recId) {
        Set<Id> contactIds = New Set<Id> ();
        Boolean returnString = false;
        System.Debug(recId);
        TVA_CFB__Cloud_Files__c cloudFile = [SELECT TVA_CFB__Parent_Id__c, WEGP1_Household__c FROM TVA_CFB__Cloud_Files__c WHERE Id =: recId];
        ID accountId = null;
        if (cloudFile.WEGP1_Household__c != NULL) {
                accountId = cloudFile.WEGP1_Household__c;
        }
        for (Account acc : [SELECT WEGP1_Primary_Individual__c, WEGP1_Secondary_Individual__c FROM Account WHERE Id =: accountId]) {
            if(acc.WEGP1_Primary_Individual__c != null) {
                contactIds.add(acc.WEGP1_Primary_Individual__c);
            }
            if(acc.WEGP1_Secondary_Individual__c != null) { 
              contactIds.add(acc.WEGP1_Secondary_Individual__c);
            }
        }
        System.Debug(contactIds);
        List<User> usr = New List<User> ();
        usr = [SELECT Id, ContactId, isActive FROM User WHERE isActive = TRUE AND ContactId IN: contactIds ];
        if(usr.size() > 0) {
            returnString =  true;
        }else {
            returnString = false;
        }
        return returnString;    
    }
}