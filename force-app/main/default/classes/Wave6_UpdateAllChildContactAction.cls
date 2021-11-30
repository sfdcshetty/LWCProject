/******************************************************************************************************************************
* @class name    : Wave6_UpdateAllChildContactAction
* @description   : This class is used to update Mailing Address fields on the all child contact records for provided accounts. 
*                  
* @test class    : Wave6_PrimaryEmailPhoneAddressActionTest
* @author        : Ganesh Ekhande
* @date          : 07/18/2017               
*                   
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              07/18/2017             Created.

******************************************************************************************************************************/
public without sharing class Wave6_UpdateAllChildContactAction {
    /*
     * @author       : Ganesh Ekhande
     * @description  : This is invokable method to update Mailing Address fields on the all child contact records.
     * @created      : 07/18/2017
     * @param        : list<string> accountIds
     * @return       : void
     */
    @InvocableMethod(label='Wave6_UpdateAllChildContactAction')
    public static void Wave6_WEGAccountSharingAction(list<string> accountIds) {
        system.debug('accountIds:>>' + accountIds);
        list<Contact> contList = new List<Contact>();

        for (Account acc : [
            SELECT
                Id,
                (
                    SELECT
                        Id,
                        OtherStreet,
                        OtherCity,
                        OtherPostalCode,
                        OtherState,
                        OtherCountry,
                        Account.BillingAddress,
                        Account.ShippingAddress,
                        MailingAddress,
                        WEGP1_PrimaryAddress__c,
                        Account.BillingStreet,
                        Account.BillingCity,
                        Account.BillingPostalCode,
                        Account.BillingState,
                        Account.BillingCountry,
                        Account.ShippingStreet,
                        Account.ShippingCity,
                        Account.ShippingPostalCode,
                        Account.ShippingState,
                        Account.ShippingCountry
                    FROM Contacts
                )
            FROM Account
            WHERE ID IN :accountIds
        ]) {
            for (Contact con : acc.Contacts) {
                boolean isChanged = false;
                if (con.WEGP1_PrimaryAddress__c == 'Home') {
                    con.MailingStreet = con.Account.BillingStreet;
                    con.MailingCity = con.Account.BillingCity;
                    con.MailingPostalCode = con.Account.BillingPostalCode;
                    con.MailingState = con.Account.BillingState;
                    con.MailingCountry = con.Account.BillingCountry;
                    isChanged = true;
                } else if (con.WEGP1_PrimaryAddress__c == 'Work') {
                    con.MailingStreet = con.Account.ShippingStreet;
                    con.MailingCity = con.Account.ShippingCity;
                    con.MailingPostalCode = con.Account.ShippingPostalCode;
                    con.MailingState = con.Account.ShippingState;
                    con.MailingCountry = con.Account.ShippingCountry;
                    isChanged = true;
                }

                if (isChanged) {
                    contList.add(con);
                }
            }
        }
        system.debug('contList:>>' + contList);
        Database.update(contList, false);
    }
}