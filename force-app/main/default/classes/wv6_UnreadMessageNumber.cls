/******************************************************************************************************************************
 * Class Name    : wv6_UnreadMessageNumber 
 * Description   : This controller class contains utility methods for Lightning Components wv6_ShowUnreadMessageNumber, wv6_IncrementSMReadCounter. 
 * Test class    : 
 * Author        : Rohan Lokhande
 * 
 * Modification Log :
 * -----------------------------------------------------------------------------------------------------------------
 * Developer                 Date(MM/DD/YYYY)       Description
 * -----------------------------------------------------------------------------------------------------------------
 * Rohan Lokhande            03/16/2018            Created
******************************************************************************************************************************/
public class wv6_UnreadMessageNumber {
    
    // This method returns the number of unread message count to Community Portal user.
	@AuraEnabled
    public static integer getUnreadMessageCount(){
        String userID = Userinfo.getUserId(); 
        List<Secure_Messaging__c> numberOfUnreadMsg = [select id from Secure_Messaging__c where Customer_User__c!= NULL and Customer_User__r.ID =: userID and
                                                       Message_Read_Number__c = 0];
        return numberOfUnreadMsg.size();
    } 
    
    // This Method is used to increment Read Counter every time user visits SM Record.
    @AuraEnabled
    public static void incrementSMReadCount(string recordId){
        ID sObjID = (ID)recordId;
        String sObjname = sObjID.getSObjectType().getDescribe().getName();
        system.debug('sObjname------>'+sObjname);
        if(sObjname == 'Secure_Messaging__c'){
    		List<Secure_Messaging__c> SMList = [select Id, Message_Read_Number__c, Date_Opened__c from Secure_Messaging__c where Id=: recordId];
    		if(SMList.size() == 1){
    		    if(SMList[0].Message_Read_Number__c == NULL){
    		        SMList[0].Message_Read_Number__c = 1;
    		    }else{
                    SMList[0].Message_Read_Number__c++;
    		    }    
               SMList[0].Date_Opened__c = System.Now();
               update SMList; 
            }
        }
    } 
}