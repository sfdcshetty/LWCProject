/**
 * Created by tricia.igoe on 6/17/21.
 */

public without sharing class x7sWEGUtilities {

    @AuraEnabled
    public static String getRelatedAccountID(){
        try{
            User currentUser = [SELECT Id, ContactId, Contact.AccountId, Contact.Account.WEGP1_Primary_Household__c FROM User WHERE Id =: UserInfo.getUserId()];
            System.debug(currentUser);
            return currentUser.ContactID;
        } catch(Exception e) {
            return e.getMessage();
        }

    }

    @AuraEnabled
    public static String getHouseholdAccountID(){
        try{
            User currentUser = [SELECT Id, ContactId, Contact.AccountId, Contact.Account.WEGP1_Primary_Household__c FROM User WHERE Id =: UserInfo.getUserId()];
            System.debug(currentUser);
            return currentUser.Contact.Account.WEGP1_Primary_Household__c;
        } catch(Exception e) {
            return e.getMessage();
        }

    }

    @AuraEnabled
    public static User getUserInfo(){
        try{
            User currentUser = [SELECT Id, ContactId, Contact.AccountId, Contact.Account.WEGP1_Primary_Household__c, Contact.Account.Name, Contact.Account.OwnerId, Contact.Account.WEG_Informal_Household_Mailing_Name__c FROM User WHERE Id =: UserInfo.getUserId()];
            return currentUser;
        }catch(Exception e) {
            return null;
        }
           
    }

    @AuraEnabled
    public static Account getAccountInfo(String accountId){
        try{
            Account currentAccount = [SELECT Name FROM Account WHERE Id =: accountId];
            return currentAccount;
        }catch(Exception e) {
            return null;
        }
    }

}