/******************************************************************************************************************************
* @class name    : wv6_SecureMessagingTriggerTest
* @description   : Contains test methods for Trigger wv6_SecureMessagingTrigger
* @test class    : 
* @author        : Rohan Lokhande (Wave6)
* @date          : 4/11/2018
*
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Rohan Lokhande (Wave6)      4/11/2018             Created.
*
******************************************************************************************************************************/
@isTest
private class wv6_SecureMessagingTriggerTest {

    private static testMethod void test() {
        User adminUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        
        UserRole role=new UserRole(Name= 'ABC'); 
        insert role; 
         
        List<Profile> userProfiles1 = [Select id from Profile where Name = 'Advisor' limit 1];
        User advisorUser = wv6_TestFactory.getUser('ganesh@weg.com', userProfiles1[0].Id,role.Id,NULL);
        insert advisorUser;
         
         
        User portalUser;
        Account indAcc; 
        
        Contact con;
        system.runAs(advisorUser) {
            Account hhAcc = new Account(Name='HH Account1', recordTypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('Household').getRecordTypeId(), WEGP1_AccountTeamIds__c='HHDummyValue');
            insert hhAcc;
            
            indAcc= new Account(Name='Ind Account1', WEGP1_Primary_Household__c=hhAcc.Id, recordTypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('Individual').getRecordTypeId(),WEGP1_AccountTeamIds__c='IndDummyValue');
            insert indAcc;

            con = [SELECT Id  FROM Contact WHERE AccountId =: indAcc.Id];
        }
        
        system.runAs(adminUser) {
            List<Profile> userProfiles = [Select id from Profile where Name = 'WEG Customer Community Plus' limit 1];
            system.assertEquals(userProfiles.size(), 1);
            portalUser = wv6_TestFactory.getUser('ganesh1010@weg.com', userProfiles[0].Id,NULL,con.ID);
            insert portalUser;
        }
        
        system.runAs(advisorUser) {
            Secure_Messaging__c sm = wv6_TestFactory.getSecureMessage(con.Id);
            insert sm;
        }    
        
        System.runAs(portalUser){
            Secure_Messaging__c sm = wv6_TestFactory.getSecureMessage(NULL);
            insert sm;
        }
	} 

}