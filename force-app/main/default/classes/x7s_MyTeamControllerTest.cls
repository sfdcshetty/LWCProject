/**
 * Created by 7Summits on 5/12/21.
 * Requires SeeAllData because x7s_MyTeamController calls out to the ConnectApi to grab photos from CMS
 */

@IsTest
private class x7s_MyTeamControllerTest {
    @IsTest
    static void testGetTeamMembers() {
        User testUser = [Select Id From User Where Email ='test12345@testuser1.com'];
        Test.startTest();
        System.runAs(testUser){
            x7s_MyTeamController.getTeamMembersForCurrentUsersAdvisor();
            x7s_MyTeamController.getTeamMembersForUser(null);
            
             x7s_MyTeamController.getTeamOwnerPhone(testUser.Id);
        	 x7s_MyTeamController.getTeamOwnerPhone(null);
            
            x7s_MyTeamController.getTeamMemberDetailsByUserId(testUser.Id);
        	x7s_MyTeamController.getTeamMemberDetailsByUserId(null);
            
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testGetTeamOwnerPhone() {
        
        User testUser = [Select Id From User Where Email ='test12345@testuser1.com'];
        Test.startTest();
		
        x7s_MyTeamController.getTeamOwnerPhone(testUser.Id);
        x7s_MyTeamController.getTeamOwnerPhone(null);

        Test.stopTest();
    }
    
    @testSetup
    public static void setup() {
        
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
                                            TimeZoneSidKey='America/Chicago',
											Photo_URL__c = '/clientportal/profilephoto/005/M'            			
                                            );
        Database.insert(portalAccountOwner1);

        System.runAs (portalAccountOwner1) {
            //Create account
        	Account houseAcc = new Account();
            houseAcc.name = 'Test Account';
            houseAcc.BillingStreet = 'BillingStreet';
            houseAcc.BillingCity = 'BillingCity';
            houseAcc.BillingPostalCode = 'BillingPostalCode';
            houseAcc.BillingState = 'BillingState';
            houseAcc.BillingCountry = 'BillingCountry';
            houseAcc.ShippingStreet = 'ShippingStreet';
            houseAcc.ShippingCity = 'ShippingCity';
            houseAcc.ShippingPostalCode = 'ShippingPostalCode';
            houseAcc.ShippingState = 'ShippingState';
            houseAcc.ShippingCountry = 'ShippingCountry';
            houseAcc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
            houseAcc.OwnerId = portalAccountOwner1.Id;
            houseAcc.WEGP1_Secondary_Advisor__c = portalAccountOwner1.Id;
            insert houseAcc;
            
            Account acc = new Account();
            acc.name = 'Test Account';
            acc.BillingStreet = 'BillingStreet';
            acc.BillingCity = 'BillingCity';
            acc.BillingPostalCode = 'BillingPostalCode';
            acc.BillingState = 'BillingState';
            acc.BillingCountry = 'BillingCountry';
            acc.ShippingStreet = 'ShippingStreet';
            acc.ShippingCity = 'ShippingCity';
            acc.ShippingPostalCode = 'ShippingPostalCode';
            acc.ShippingState = 'ShippingState';
            acc.ShippingCountry = 'ShippingCountry';
            acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
            acc.WEGP1_Primary_Household__c = houseAcc.Id;
            insert acc;

            // Create Test Contact
            Contact con = new Contact();
            con.LastName = ' Test Contact';
            con.WEGP1_PrimaryAddress__c = 'Work';
            con.WEGP1_PrimaryEmail__c = 'Work';
            con.WEGP1_PrimaryPhone__c = 'Work';
            con.HomePhone = '1111111111';
            con.AssistantPhone = '2222222222';
            con.MobilePhone = '3333333333';
            con.OtherPhone = '4444444444';
            con.WEG_Business_Email__c = 'work_email@weg.com';
            con.WEGP1_OtherEmail__c = 'other_email@weg.com';
            con.WEGP1_PersonalEmail__c = 'test@weg.com';
            con.Email = 'test@weg.com';
            con.OtherStreet = 'OtherStreet';
            con.accountId = acc.Id;
            con.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
            insert con;
            
            Team__c newTeam = new Team__c();
            insert newTeam;

            Team_Member__c member1 = new Team_Member__c();
            member1.Portal_Client_Team__c = newTeam.Id;
            member1.Display_On_Portal__c = true;


            Team_Member__c member2 = new Team_Member__c();
            member2.Portal_Client_Team__c = newTeam.Id;
            member2.Display_On_Portal__c = true;
            

            insert new List<Team_Member__c>{
                    member1, member2
            };

            //Create user
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'WEG Customer Community Plus' Limit 1];
            
            User user1 = new User(Username = System.now().millisecond() + 'test12345@test.com',
                                    ContactId = con.Id,
                                    ProfileId = portalProfile.Id,
                                    Alias = 'test123',
                                    Email = 'test12345@testuser1.com',
                                    EmailEncodingKey = 'UTF-8',
                                    LastName = 'McTesty',
                                    CommunityNickname = 'test12345',
                                    TimeZoneSidKey = 'America/Los_Angeles',
                                    LocaleSidKey = 'en_US',
                                    LanguageLocaleKey = 'en_US',
                                    Photo_URL__c = '/clientportal/profilephoto/005/M');
           	Database.insert(user1);
            
            Team_Member__c tm = new Team_Member__c();
            x7s_MyTeamController.TeamMember tm2 = new x7s_MyTeamController.TeamMember(tm);
            
        }
    }

    /*@TestSetup
    static void setupData(){
        List<Profile> userProfiles = [
                SELECT Id
                FROM Profile
                WHERE Name = 'System Administrator'
                LIMIT 1
        ];

        UserRole role = new UserRole(DeveloperName = 'TestRole', Name = 'Test Role');
        insert role;

        User advisor = new User(
                LastName = 'Advisor',
                Email = 'Advisor@x7sMyTeamControllerTest.com',
                Username = 'advisor@x7sMyTeamControllerTest.com',
                Alias = 'alias',
                CompanyName = 'x7sMyTeamController',
                Title = 'Tester',
                ProfileId = userProfiles[0].Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                UserRoleId = role.Id
        );
        insert advisor;

        System.runAs(advisor) {
            // Create Test Account
            Account houseAcc = new Account();
            houseAcc.name = 'Test Account';
            houseAcc.BillingStreet = 'BillingStreet';
            houseAcc.BillingCity = 'BillingCity';
            houseAcc.BillingPostalCode = 'BillingPostalCode';
            houseAcc.BillingState = 'BillingState';
            houseAcc.BillingCountry = 'BillingCountry';
            houseAcc.ShippingStreet = 'ShippingStreet';
            houseAcc.ShippingCity = 'ShippingCity';
            houseAcc.ShippingPostalCode = 'ShippingPostalCode';
            houseAcc.ShippingState = 'ShippingState';
            houseAcc.ShippingCountry = 'ShippingCountry';
            houseAcc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
            houseAcc.OwnerId = advisor.Id;
            insert houseAcc;

            Account acc = new Account();
            acc.name = 'Test Account';
            acc.BillingStreet = 'BillingStreet';
            acc.BillingCity = 'BillingCity';
            acc.BillingPostalCode = 'BillingPostalCode';
            acc.BillingState = 'BillingState';
            acc.BillingCountry = 'BillingCountry';
            acc.ShippingStreet = 'ShippingStreet';
            acc.ShippingCity = 'ShippingCity';
            acc.ShippingPostalCode = 'ShippingPostalCode';
            acc.ShippingState = 'ShippingState';
            acc.ShippingCountry = 'ShippingCountry';
            acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
            acc.WEGP1_Primary_Household__c = houseAcc.Id;
            insert acc;


            // Create Test Contact
            Contact con = new Contact();
            con.LastName = ' Test Contact';
            con.WEGP1_PrimaryAddress__c = 'Work';
            con.WEGP1_PrimaryEmail__c = 'Work';
            con.WEGP1_PrimaryPhone__c = 'Work';
            con.HomePhone = '1111111111';
            con.AssistantPhone = '2222222222';
            con.MobilePhone = '3333333333';
            con.OtherPhone = '4444444444';
            con.WEG_Business_Email__c = 'work_email@weg.com';
            con.WEGP1_OtherEmail__c = 'other_email@weg.com';
            con.WEGP1_PersonalEmail__c = 'test@weg.com';
            con.Email = 'test@weg.com';
            con.OtherStreet = 'OtherStreet';
            con.accountId = acc.Id;
            con.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
            insert con;


            Team__c newTeam = new Team__c();
            newTeam.Team_Owner__c = UserInfo.getUserId();
            insert newTeam;


            Team_Member__c member1 = new Team_Member__c();
            member1.Portal_Client_Team__c = newTeam.Id;
            member1.Display_On_Portal__c = true;


            Team_Member__c member2 = new Team_Member__c();
            member2.Portal_Client_Team__c = newTeam.Id;
            member2.Display_On_Portal__c = true;
            

            insert new List<Team_Member__c>{
                    member1, member2
            };
        }
    }

    private static User insertTestUsers(){
        List<Contact> contactQuery = [
                SELECT Id
                FROM Contact
                WHERE Email = 'test@weg.com'
        ];

        List<Profile> userProfiles = [
                SELECT id
                FROM Profile
                WHERE Name = 'WEG Customer Community Plus'
                LIMIT 1
        ];

        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];

        User u = new User(
                LastName = 'Test',
                Email = 'x7sMyTeamController@x7sMyTeamControllerControllerTest.com',
                Username = 'x7sMyTeamController@x7sMyTeamControllerControllerTest.com',
                Alias = 'alias',
                CompanyName = 'x7sMyTeamController',
                Title = 'Tester',
                ProfileId = userProfiles[0].Id,
                ContactId = contactQuery[0].Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US'
        );

        System.runAs(adminUser) {
            insert u;
        }

        return u;
    } */
}