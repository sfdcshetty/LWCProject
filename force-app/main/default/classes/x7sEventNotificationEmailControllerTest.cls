@IsTest
public class x7sEventNotificationEmailControllerTest {
	
    @isTest
    public static void eventNotificationTest() {
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
		system.debug('portalRole is ' + portalRole);

        Profile profile1 = [Select Id from Profile where name = 'System Administrator' Limit 1];
        
        User portalAccountOwner1 = new User(
                                            UserRoleId = portalRole.Id,
                                            ProfileId = profile1.Id,
                                            Username = System.now().millisecond() + 'test2@test.com',
                                            Alias = 'test',
                                            Email='bruce.wayne@portalAccountOwner1.com',
                                            EmailEncodingKey='UTF-8',
                                            Firstname='Bruce',
                                            Lastname='Wayne',
                                            LanguageLocaleKey='en_US',
                                            LocaleSidKey='en_US',
                                            TimeZoneSidKey='America/Chicago'
                                            );
        Database.insert(portalAccountOwner1);

        System.runAs (portalAccountOwner1) {
            
           Account portalAccount1 = new Account(
                        Name = 'Test Portal Account',
                        OwnerId = portalAccountOwner1.Id
                		//WEGP1_Primary_Household__c = houseHoldAccount1.Id
                        );
            Database.insert(portalAccount1);

            //Create contact
            Contact contact1 = new Contact(
                                FirstName = 'Test',
                                Lastname = 'McTesty',
                                AccountId = portalAccount1.Id,
                                Email = System.now().millisecond() + 'test@test.com'
            );
            Database.insert(contact1);

            //Create user
            Profile portalProfile = [SELECT Id FROM Profile Limit 1];
            
            User user1 = new User(Username = System.now().millisecond() + 'test12345@test.com',
                                    ContactId = contact1.Id,
                                    ProfileId = portalProfile.Id,
                                    Alias = 'test123',
                                    Email = 'test12345@testuser1.com',
                                    EmailEncodingKey = 'UTF-8',
                                    LastName = 'McTesty',
                                    CommunityNickname = 'test12345',
                                    TimeZoneSidKey = 'America/Los_Angeles',
                                    LocaleSidKey = 'en_US',
                                    LanguageLocaleKey = 'en_US');
           	Database.insert(user1);
            
           Contact primaryCon = new Contact();
           primaryCon.LastName = ' Test Contact';
           primaryCon.WEG_PortalUser__c = user1.Id;
           primaryCon.RecordTypeId =  Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
           insert primaryCon;
            
           //Create account
           Account houseHoldAccount1 = new Account(
                        Name = 'TestAccount',
                        OwnerId = portalAccountOwner1.Id,
                		WEG_Equity__c = 10.0,
                		WEG_Fixed_Income__c =  20.0,
                		WEG_Real_Estate__c = 25.0,
                		WEG_Alternative_Investment__c = 13.0,
                		WEG_Cash_and_Equivalents__c = 28.0,
                		WEG_Other__c = 16.0,
             			WEGP1_Primary_Individual__c = primaryCon.Id
                        );
            Database.insert(houseHoldAccount1);
               
            Account testAccount1 = new Account(Name = 'TaskMeetingCompleteUnitTest');
			insert testAccount1;
            
            Test.startTest();
            Event eve = new Event();
            eve.RecordTypeId =  Schema.sObjectType.Event.getRecordTypeInfosByName().get('Advisor Event').getRecordTypeId();
            eve.FinServ__Household__c = houseHoldAccount1.Id;
            eve.WhatId = testAccount1.Id;
            eve.IsVisibleInSelfService = true;
            eve.Type = 'Review';
            eve.Subject = 'Test Event Subject';
            eve.Description = 'Test Event Description';
            eve.StartDateTime = System.now();
            eve.EndDateTime = System.now().addDays(2);
            eve.OwnerId = user1.Id;
            eve.WhoId = primaryCon.Id;
            insert eve;
                        
            System.debug('Event Data Test:::' + eve.Id);
            System.debug('Event WhatId Test:::' + eve.WhatId);
            System.debug('Event AccountId Test:::' + eve.AccountId);
            System.debug('Event WhoId Test:::' + eve.WhoId);
            Test.stopTest();
        }
    }
}