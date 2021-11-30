@isTest
private class wv6_UnreadMessageNumberTest {
    User portalUser;
    Account indAcc;
  
  private static testMethod void unreadMessageNumberTest() {
      UserRole role=new UserRole(Name= 'ABC'); 
        insert role;
      List<Profile> userProfiles1 = [Select id from Profile where Name = 'Advisor' limit 1];
        User advisorUser = wv6_TestFactory.getUser('ganesh@weg.com', userProfiles1[0].Id,role.Id,NULL);
        insert advisorUser;
      
         User adminUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
         
         User portalUser;
         Account indAcc;
        Contact con;
        system.runAs(advisorUser) {
            Account hhAcc = new Account(Name='HH Account1', recordTypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('Household').getRecordTypeId(), WEGP1_AccountTeamIds__c='HHDummyValue');
            insert hhAcc;
            
            indAcc = new Account(Name='Ind Account1', WEGP1_Primary_Household__c=hhAcc.Id, recordTypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('Individual').getRecordTypeId(),WEGP1_AccountTeamIds__c='IndDummyValue');
            insert indAcc;

            con = [SELECT Id  FROM Contact WHERE AccountId =: indAcc.Id];
        }
            
        system.runAs(adminUser) {
            Test.startTest();
            
            List<Profile> userProfiles = [Select id from Profile where Name = 'WEG Customer Community Plus' limit 1];
            system.assertEquals(userProfiles.size(), 1);
            
            portalUser = new User();
            portalUser.firstName = 'Ganesh Test';
            portalUser.LastName = 'WEG';
            portalUser.Alias = 'alias';
            portalUser.Email = 'ganesh1234u@weg.com';
            portalUser.UserName= 'ganesh1234u@weg.com';
            portalUser.ProfileId = userProfiles[0].Id;
            portalUser.CommunityNickname = 'ganesh1234u@weg.com';
            portalUser.EmailEncodingKey ='ISO-8859-1';
            portalUser.LanguageLocaleKey = 'en_US';
            portalUser.TimeZoneSidKey ='America/Indiana/Indianapolis';
            portalUser.LocaleSidKey = 'en_US';
            portalUser.Country = 'USA';
            portalUser.ContactId = con.id;
            portalUser.IsActive = true;
            insert portalUser;
            
        }
        
        System.runAs(portalUser){
            Secure_Messaging__c sm = new Secure_Messaging__c();
          sm.Name ='Test Message';
          sm.Message__c ='Test Message';
          //sm.Account__c = indAcc.Id;
          sm.Contact__c = con.Id;
          sm.Message_Read_Number__c = NULL;
            insert sm;
            
            wv6_UnreadMessageNumber.getUnreadMessageCount();
            wv6_UnreadMessageNumber.incrementSMReadCount(sm.Id);
            Secure_Messaging__c updatedSM = [SELECT Id, Message_Read_Number__c FROM Secure_Messaging__c WHERE Id =:sm.Id ];
            system.assertEquals(1, updatedSM.Message_Read_Number__c);
            wv6_UnreadMessageNumber.incrementSMReadCount(sm.Id);
            updatedSM = [SELECT Id, Message_Read_Number__c FROM Secure_Messaging__c WHERE Id =:sm.Id ];
            system.assertEquals(2, updatedSM.Message_Read_Number__c);
          
        }
  }

}