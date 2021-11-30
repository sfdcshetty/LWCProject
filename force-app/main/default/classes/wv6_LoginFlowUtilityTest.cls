/*
 * Author: Wave6
 * Project: Community 2FA 
 * Description: Test methods for wv6_LoginFlowUtility apex class.
 */

@isTest
public class wv6_LoginFlowUtilityTest {
	
    @testSetup static void setup() {
        RecordType accRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'IndustriesIndividual'
                             AND sObjectType = 'Account'];
        
        Account acc = new Account(Name = 'Test', RecordTypeId = accRecordType.Id);
        insert acc;
        
        Contact con = new Contact(FirstName = 'Test', LastName = 'Test', AccountId = acc.Id);
        insert con;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name='WEG Customer Community Plus'];
        User portalUser = new User(ProfileId = portalProfile.Id, FirstName = 'Test', LastName = 'Test', Username = 'test@test.com',
                                  Email = 'test@test.com', ContactId = con.Id, Alias = 'testn', TimeZoneSidKey = 'America/Chicago',
                                  EmailEncodingKey = 'ISO-8859-1', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert portalUser;
        
        Custom_Authentication__c customAuth = new Custom_Authentication__c(LoggedInUserID__c = portalUser.Id, CreatedDate = System.now().addDays(-2));
        insert customAuth;  
        
        insert new Community_Setting__c(SetupOwnerId=portalProfile.Id, Message__c='Some Value', Number_of_Failed_Login_Attempts__c = 10,
                                       User_Suspension_Period__c = 24, Verification_Code_Validity_Period__c = 24);
    }
    
    public static testMethod void testCheckValidity(){
        List<Id> recordIdList = new List<Id>();
        List<Custom_Authentication__c> customAuthList = [SELECT Id FROM Custom_Authentication__c];
        for(Custom_Authentication__c auth: customAuthList)
            recordIdList.add(auth.Id);
        User portalUser = [SELECT Id FROM User WHERE Username = 'test@test.com'];
        System.runAs(portalUser){
        	List<Boolean> results = wv6_LoginFlowUtility.checkValidity(recordIdList);
        	system.assertEquals(false, results[0]);    
            
            results = wv6_LoginFlowUtility.checkValidity(new List<Id>{portalUser.Id});
        	system.assertEquals(false, results[0]);
        }
    }
}