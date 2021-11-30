/**
 * Created by 7Summits on 4/12/21.
 */

@IsTest
private class X7S_MaintenanceRequestControllerTest {
    
    
    @testSetup
    public static void setup() {
        RecordType recType = [SELECT Id, Name, DeveloperName FROM RecordType 
                              Where Name = 'Bank Account' Limit 1];
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
		system.debug('portalRole is ' + portalRole);

        Profile profile1 = [Select Id from Profile where name = 'System Administrator' Limit 1];
        
        User portalAccountOwner1 = new User(
                                            UserRoleId = portalRole.Id,
                                            ProfileId = profile1.Id,
                                            Username = System.now().millisecond() + 'test2@maintenancereq.com',
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
            //Create account
        Account houseHoldAccount1 = new Account(
                        Name = 'TestAccount',
                        OwnerId = portalAccountOwner1.Id,
                		WEG_Equity__c = 10.0,
                		WEG_Fixed_Income__c =  20.0,
                		WEG_Real_Estate__c = 25.0,
                		WEG_Alternative_Investment__c = 13.0,
                		WEG_Cash_and_Equivalents__c = 28.0,
                		WEG_Other__c = 16.0
                        );
            Database.insert(houseHoldAccount1);
            
            Account portalAccount1 = new Account(
                        Name = 'Test Portal Account',
                        OwnerId = portalAccountOwner1.Id,
                		WEGP1_Primary_Household__c = houseHoldAccount1.Id
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
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'WEG Customer Community Plus' Limit 1];
            
            User user1 = new User(Username = System.now().millisecond() + 'test12345@maintenancereq.com',
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
            
        }
    }
    
    @IsTest
    static void TestgetRelatedContactsForCurrentUser() {
        User user1 = [Select Id From User Where Email ='test12345@testuser1.com'];
        System.runAs (user1) {
            Test.startTest();
        	X7S_MaintenanceRequestController.getRelatedContactsForCurrentUser();
	        Test.stopTest();       
        }
    }

    @IsTest
    static void testUpdateEmails() {
        
        User user1 = [Select Id From User Where Email ='test12345@testuser1.com'];
        Contact con1 = [Select Id From Contact Where LastName ='McTesty' LIMIT 1];
        System.runAs (user1) {
            Test.startTest();
            X7S_MaintenanceRequestController.updateEmails(con1.Id, 'newPersonalEmail@X7SMaintenanceRequestController.com', 'newWorkEmail@X7SMaintenanceRequestController.com', 'newOtherEmail@X7SMaintenanceRequestController.com', 'Work');
	        Test.stopTest();       
        }
    }

    @IsTest
    static void testUpdateNames() {
        
        User user1 = [Select Id From User Where Email ='test12345@testuser1.com'];
        Contact con2 = [Select Id From Contact Where LastName ='McTesty' LIMIT 1];
        System.runAs (user1) {
            Test.startTest();
             X7S_MaintenanceRequestController.updateNames(con2.Id, 'Mr.', 'newFirstName', 'newMiddleName', '', '', 'newPreferredName');
	        Test.stopTest();       
        }       
    }

    @IsTest
    static void testUpdatePhones() {
        
        User user1 = [Select Id From User Where Email ='test12345@testuser1.com'];
        Contact con3 = [Select Id From Contact Where LastName ='McTesty' LIMIT 1];
        System.runAs (user1) {
            Test.startTest();
            X7S_MaintenanceRequestController.updatePhones(con3.Id, '1234567890', '1234567890', '1234567890', '1234567890', 'Work');
	        Test.stopTest();       
        }           
    }

    @IsTest
    static void testUpdateAddresses() {
        
        User user1 = [Select Id From User Where Email ='test12345@testuser1.com'];
        Contact con4 = [Select Id From Contact Where LastName ='McTesty' LIMIT 1];
        System.runAs (user1) {
            Test.startTest();
            X7S_MaintenanceRequestController.updateAddresses(con4.Id, '123 Street', 'Milwaukee', 'WI', '53202', false,
                        '','','','',false,
                        '','','','',false,
                        false,'Work',false);	        
                                                           
            Test.stopTest();       
        }     
    }
}