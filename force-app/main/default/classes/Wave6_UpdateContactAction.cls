/******************************************************************************************************************************
* @class name    : Wave6_UpdateContactAction
* @description   : This class is used to update Email, Mailing Address and Primary Phone field on the Contact record.
*                  
* @test class    : Wave6_PrimaryEmailPhoneAddressActionTest
* @author        : Ganesh Ekhande
* @date          : 07/17/2017               
*                   
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              07/17/2017             Created
* Ganesh Ekhande              09/07/2017             Replaced WEGP1_CellPhone__c, WEGP1_HomePhone__c, WEGP1_OtherPhone__c, WEGP1_WorkPhone__c, WEGP1_PrimaryPhone__c, 
*                                                    WEGP1_Primary_Phone__c,WEGP1_WorkEmail__c with HomePhone, OtherPhone, MobilePhone, AssistantPhone, Phone,WEG_Business_Email__c
* Troy Solland				  02/25/2020			 
* 
******************************************************************************************************************************/
public class Wave6_UpdateContactAction {
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : This is invokable method to update Email, Mailing Address and Primary Phone field on the Contact record.
    * @created      : 07/17/2017
    * @param        : list<string> contactIds 
    * @return       : void
    */
    @InvocableMethod(label='Wave6_UpdateContactAction')
    public static void Wave6_WEGAccountSharingAction(list<string> contactIds){
        system.debug('>>>>>>>> Wave6_UpdateContactAction.Wave6_WEGAccountSharingAction');
        system.debug('>>>>>>>> contactIds: ' + contactIds);
        
        List<Contact> contacts =
            [SELECT Id, HomePhone, OtherPhone, MobilePhone, AssistantPhone, Phone,WEGP1_PrimaryPhone__c,
             //Replaced WEGP1_CellPhone__c, WEGP1_HomePhone__c, WEGP1_OtherPhone__c, WEGP1_WorkPhone__c, WEGP1_Primary_Phone__c,WEGP1_WorkEmail__c
             Email, WEGP1_OtherEmail__c,WEG_Business_Email__c, WEGP1_PersonalEmail__c, WEGP1_PrimaryEmail__c, 
             OtherStreet, OtherCity,OtherPostalCode,OtherState,OtherCountry, Account.BillingAddress, Account.ShippingAddress, MailingAddress, WEGP1_PrimaryAddress__c,
             Account.BillingStreet,Account.BillingCity,Account.BillingPostalCode,Account.BillingState,Account.BillingCountry,
             Account.ShippingStreet,Account.ShippingCity,Account.ShippingPostalCode,Account.ShippingState,Account.ShippingCountry
             FROM Contact
             WHERE ID IN: contactIds];
        
        List<Contact> contList = new List<Contact>();
        for(Contact con : contacts){
            
            boolean isChanged = false;
            
            // Phone
            if(con.WEGP1_PrimaryPhone__c == 'Home') {
                con.Phone = con.HomePhone; 
                //isChanged = true;
            } else if(con.WEGP1_PrimaryPhone__c == 'Work') {
                con.Phone = con.AssistantPhone;  
                //isChanged = true;
            } else if(con.WEGP1_PrimaryPhone__c == 'Cell') {
                con.Phone = con.MobilePhone;  
                //isChanged = true;
            } else if(con.WEGP1_PrimaryPhone__c == 'Other') {
                con.Phone = con.OtherPhone;
                //isChanged = true;
            } else
                con.Phone = null;
            
            // Email
            if(con.WEGP1_PrimaryEmail__c == 'Work') {
                con.Email = con.WEG_Business_Email__c ;  
                //isChanged = true;
            } else if(con.WEGP1_PrimaryEmail__c == 'Other') {
                con.Email = con.WEGP1_OtherEmail__c;  
                //isChanged = true;
            } else if(con.WEGP1_PrimaryEmail__c == 'Personal') {
                con.Email = con.WEGP1_PersonalEmail__c;  
                //isChanged = true;
            } else
                con.Email = null;
            
            // Mailing Address
            if(con.WEGP1_PrimaryAddress__c == 'Home') {
                con.MailingStreet = con.Account.BillingStreet;
                con.MailingCity = con.Account.BillingCity;
                con.MailingPostalCode = con.Account.BillingPostalCode;
                con.MailingState = con.Account.BillingState;
                con.MailingCountry = con.Account.BillingCountry;
                //isChanged = true;
            } else if(con.WEGP1_PrimaryAddress__c == 'Work') {
                con.MailingStreet = con.Account.ShippingStreet;
                con.MailingCity = con.Account.ShippingCity;
                con.MailingPostalCode = con.Account.ShippingPostalCode;
                con.MailingState = con.Account.ShippingState;
                con.MailingCountry = con.Account.ShippingCountry;
                //isChanged = true;
            } else if(con.WEGP1_PrimaryAddress__c == 'Other') {
                con.MailingStreet = con.OtherStreet;
                con.MailingCity = con.OtherCity;
                con.MailingPostalCode = con.OtherPostalCode;
                con.MailingState = con.OtherState;
                con.MailingCountry = con.OtherCountry;
                //isChanged = true;
            } else {
                con.MailingStreet = null;
                con.MailingCity = null;
                con.MailingPostalCode = null;
                con.MailingState = null;
                con.MailingCountry = null;
            }
            
            //if(isChanged)
            contList.add(con);
        }
        
        system.debug('>>>>>>>> contList: ' + contList);
        update contList;
    }
}