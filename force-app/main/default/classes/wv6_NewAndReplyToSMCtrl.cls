/******************************************************************************************************************************
 * Class Name    : wv6_NewAndReplyToSMCtrl 
 * Description   : This class contains the utility methods for lightning component wv6_NewAndReplyToSM.
 * Test class    : 
 * Author        : Rohan Lokhande
 * 
 * Modification Log :
 * -----------------------------------------------------------------------------------------------------------------
 * Developer                 Date(MM/DD/YYYY)       Description
 * -----------------------------------------------------------------------------------------------------------------
 * Rohan Lokhande            03/19/2018            Created
 * Wave6					 10/12/2018			   Replaced Account look-up on Secure Message with Contact
******************************************************************************************************************************/
public without sharing class wv6_NewAndReplyToSMCtrl {


    //This method gets the SM recordId from Lightning component, creates new Reply Message, populate the Send To & Account 
    //(basis to whom is we sending the message Advisor, Customer)  into Reply message. Finally it saves the Reply message.
	@AuraEnabled
    public static List<Secure_Messaging__c> getClonedRecordByUser(String recordId, String contactId){
        String user = UserInfo.getUserId();
        User currentUser = [SELECT Id, ContactId, Contact.AccountId, Contact.Account.WEGP1_Primary_Household__c FROM User WHERE Id =: user];

        Secure_Messaging__c newSM= new Secure_Messaging__c();
        /*List<Secure_Messaging__c> smList = [select id, Contact__c, name,Customer_User__c,Message__c,Household_Account__r.Name, 
                                            Household_Account__r.WEGP1_Primary_CSM__c,Household_Account__r.OwnerID, 
                                            OwnerId,Owner.Name,Primary_CSM__c, Household_Account__c, LastModifiedDate, Created_By_Username__c, Created_By__c, CreatedById
                                            from Secure_Messaging__c where Customer_User__c=:user ORDER by LastModifiedDate DESC];*/
        List<Secure_Messaging__c> smList = [select id, Contact__c, name,Customer_User__c,Message__c,Household_Account__r.Name, 
                                            Household_Account__r.WEGP1_Primary_CSM__c,Household_Account__r.OwnerID, 
                                            OwnerId,Owner.Name,Primary_CSM__c, Household_Account__c, LastModifiedDate, Created_By_Username__c, Created_By__c, CreatedById
                                            from Secure_Messaging__c where Contact__c=:currentUser.ContactId ORDER by LastModifiedDate DESC];
        return smList;
    }

    //This method gets the SM recordId from Lightning component, creates new Reply Message, populate the Send To & Account 
    //(basis to whom is we sending the message Advisor, Customer)  into Reply message. Finally it saves the Reply message.
	/*@AuraEnabled
    public static String insertRecordForUser(String Contact__c, String Name, String Customer_User__c, String Message__c, String Owner){
        String user = UserInfo.getUserId();
        Secure_Messaging__c newSM= new Secure_Messaging__c();
        List<Secure_Messaging__c> smList = [select id, Contact__c, name,Customer_User__c,Message__c,Household_Account__r.Name, 
                                            Household_Account__r.WEGP1_Primary_CSM__c,Household_Account__r.OwnerID, 
                                            OwnerId,Owner.Name,Primary_CSM__c, Household_Account__c
                                            from Secure_Messaging__c where Customer_User__c=:user];
        //return someId;
    }*/


    //This method gets the SM recordId from Lightning component, creates new Reply Message, populate the Send To & Account 
    //(basis to whom is we sending the message Advisor, Customer)  into Reply message. Finally it saves the Reply message.
	@AuraEnabled
    public static Secure_Messaging__c getClonedRecord(String recordId){
        Secure_Messaging__c newSM= new Secure_Messaging__c();
        List<Secure_Messaging__c> smList = [select id, Contact__c, name,Customer_User__c,Message__c,Household_Account__r.Name, 
                                            Household_Account__r.WEGP1_Primary_CSM__c,Household_Account__r.OwnerID, 
                                            OwnerId,Owner.Name,Primary_CSM__c, Household_Account__c
                                            from Secure_Messaging__c where id=:recordId];
        if(smList.size()>0){
            Secure_Messaging__c oldrecord = smList[0];
            newSM.name = oldrecord.name;
            
            if(UserInfo.getUserType() == 'CSPLitePortal'){ //Custoemr Reply 
                if(UserInfo.getUserId() ==  oldrecord.OwnerID){ //Customer replies to his own message
                    newSM.Customer_User__c = oldrecord.Customer_User__c;
                }else{ // Customer replies to Advisor Message
                    newSM.Customer_User__c = oldrecord.OwnerID;
                }
                
                newSM.Primary_CSM__c = oldrecord.Household_Account__r.WEGP1_Primary_CSM__c;
                
                if(newSM.Message_Read_Number__c != NULL){
                    newSM.Message_Read_Number__c ++;
                }    
                else{
                    newSM.Message_Read_Number__c = 1;
                }
                newSM.Date_Opened__c = System.Now();
            }else{ // Advisor Reply
                if(UserInfo.getUserId() ==  oldrecord.OwnerID){ // Advisor Reply to own message
                    newSM.Customer_User__c =   oldrecord.Customer_User__c;
                    newSM.Primary_CSM__c =   oldrecord.Primary_CSM__c;
                }else{ // Advisor reply to customer 
                    newSM.Customer_User__c = oldrecord.OwnerID;
                    newSM.Primary_CSM__c =   oldrecord.Primary_CSM__c;
                }
                
            }
            newSM.Household_Account__c = oldrecord.Household_Account__c;
            newSM.Contact__c = oldrecord.Contact__c;
        }
        return newSM;
    }
    
    //This Method saves the secure Message record received from Lightning component
    @AuraEnabled
    public static List<String> saveSMRecord(String SMRecord){
        Secure_Messaging__c smRec = (Secure_Messaging__c) System.JSON.deserialize(SMRecord, Secure_Messaging__c.class);
        System.debug('=======>'+smRec.Customer_User__c);
        System.debug('=======>'+smRec.Primary_CSM__c);
        System.debug('=======>'+smRec.Contact__c);
        List<String> returnList = new List<String>();
        try{
            insert smRec;
            returnList.add('Success');
        } catch(Exception e) {
            returnList.add(e.getMessage());
            returnList.add(e.getStackTraceString());
        }
        return returnList;

    }

    //This Method saves the secure Message record received from Lightning component
    @AuraEnabled
    public static List<String> saveNewSMRecord(Secure_Messaging__c SMRecord){
        System.debug('CUSTOMER=======>'+SMRecord);
        List<String> returnList = new List<String>();
        try{
            insert SMRecord;
            returnList.add('Success');
        } catch(Exception e) {
            returnList.add(e.getMessage());
            returnList.add(e.getStackTraceString());
            returnList.add(JSON.serialize(SMRecord));
        }
        return returnList;
    }
}