/*
* Author: Wave6
* Project: Community 2FA 
* Description: Contains utility methods needed for login flow.
*/

public class wv6_LoginFlowUtility {

    @InvocableMethod(label='Check Validity Period' description='Returns true if verification generated is within valid time window or user is still in frozen window.')
    public static List<Boolean> checkValidity(List<String> recordIdList) {
        User loggedInUser = [SELECT ProfileId FROM User WHERE Id =: UserInfo.getUserId()];
        Community_Setting__c communitySetting = Community_Setting__c.getInstance(loggedInUser.ProfileId);
         
         // Modified by Sandeesh - Changed the input parameter to List<String> instead of Id. The null value assignment of the variable
             // via flow messes up the logic to check empty ID list
         
        if(communitySetting != NULL && recordIdList != null && recordIdList.size() > 0 && recordIdList.get(0) != '()' && recordIdList.get(0) != ''){
           
            // If recordIdList contains Custom Authentication record ids then check for their verification code validity
            Id recId = Id.valueOf(recordIdList.get(0));
            if(recId.getSobjectType() == Schema.Custom_Authentication__c.SObjectType){
                List<Custom_Authentication__c> customAuthenticationList = [SELECT CreatedDate FROM Custom_Authentication__c WHERE Id IN: recordIdList];
                return checkValidityWindow(customAuthenticationList, Integer.valueof(communitySetting.Verification_Code_Validity_Period__c));
            }
            
            // If recordIdList contains User record ids then check if these users are to be unfrozen or not
            if(recId.getSobjectType() == Schema.User.SObjectType){
                List<User> userList = [SELECT Id, (SELECT CreatedDate FROM Custom_Authentications__r ORDER BY CreatedDate DESC LIMIT 1) FROM User WHERE Id IN: recordIdList];
                List<Custom_Authentication__c> customAuthenticationList = new List<Custom_Authentication__c>();
                for(User usr: userList)
                    customAuthenticationList.addAll(usr.Custom_Authentications__r);
                return checkValidityWindow(customAuthenticationList, Integer.valueof(communitySetting.User_Suspension_Period__c));
            }
        }
    
        return null;
    }

    static List<Boolean> checkValidityWindow(List<Custom_Authentication__c> customAuthenticationList, Integer window){
        List<Boolean> validityList = new List<Boolean>();
        
        for(Custom_Authentication__c customAuth: customAuthenticationList){
            Boolean isValid = (customAuth.CreatedDate >= System.now().addHours(window * -1)) ? true : false;
            validityList.add(isValid);
        }
        return validityList;
    }

}