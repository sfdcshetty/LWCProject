/**
 * Created by tricia.igoe on 6/12/21.
 */
@IsTest
public with sharing class x7sPreferencesControllerTest {

    @TestSetup
    static void testSetupData(){
        UserRole portalRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
        System.debug('portalRole is ' + portalRole);

        Profile profile1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        User portalAccountOwner1 = new User(
                UserRoleId = portalRole.Id,
                ProfileId = profile1.Id,
                Username = System.now().millisecond() + 'test2@test.com',
                Alias = 'test',
                Email='bruce.wayne@wayneenterprises.com',
                EmailEncodingKey='UTF-8',
                FirstName='Bruce',
                LastName='Wayne',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                TimeZoneSidKey='America/Chicago'
        );
        Database.insert(portalAccountOwner1);

        //User u1 = [Select ID From User Where Id =: portalAccountOwner1.Id];
        Account portalAccount1, houseHoldAccount1;
        User user1,user2;
        System.runAs (portalAccountOwner1) {

            houseHoldAccount1 = new Account(
                    Name = 'TestAccount',
                    OwnerId = portalAccountOwner1.Id
            );
            Database.insert(houseHoldAccount1);

            //Create account
            portalAccount1 = new Account(
                    Name = 'Test Portal Account',
                    OwnerId = portalAccountOwner1.Id,
                    WEGP1_Primary_Household__c = houseHoldAccount1.Id);
            Database.insert(portalAccount1);
            
            //Create contact
            Contact contact1 = new Contact(
                    FirstName = 'Test',
                    LastName = 'McTesty',
                    AccountId = portalAccount1.Id,
                    Email = System.now().millisecond() + 'test@test.com',
                    WEGP1_EmailPreferencesWETCS__c = 'No News & Updates',
                    Portal_Email_Preferences__c = 'No Profile Updates;No To Do Assignments;',
                    WEGP1_EmailPreferencesWEG__c = 'No News & Updates'
            );
            Database.insert(contact1);
            
            

            //Create user
            //Profile portalProfile = [SELECT Id FROM Profile Limit 1];

            Profile profile2 = [SELECT Id FROM Profile WHERE Name = 'WEG Customer Community Plus' LIMIT 1];
            user1 = new User(Username = System.now().millisecond() + 'test12345678@test.com',
                    ContactId = contact1.Id,
                    ProfileId = profile2.Id,
                    Alias = 'test123',
                    Email = 'test12345@test.com',
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
    static void testGetMethod(){
        User theUser = [SELECT Id FROM User WHERE Email = 'test12345@test.com' LIMIT 1];
        System.runAs(theUser) {
            x7sPreferencesController.Preference notifications =x7sPreferencesController.grabPreferences();

            System.assertEquals(notifications.profileUpdates, false);
            System.assertEquals(notifications.toDos, false);
            System.assertEquals(notifications.newInsights, false);
        }
    }

    @IsTest
    static void savePreferencesTest(){ 
		User theUser = [SELECT Id FROM User WHERE Email = 'test12345@test.com' LIMIT 1];
        System.runAs(theUser) {
            x7sPreferencesController.Preference pf = new x7sPreferencesController.Preference();
            List<String> returnList =x7sPreferencesController.savePreferences(pf);
            pf.newInsights = false;
            List<String> returnList1 =x7sPreferencesController.savePreferences(pf);
            pf.toDos = false;
            pf.profileUpdates = true;
            List<String> returnList2 =x7sPreferencesController.savePreferences(pf);
            pf.toDos = true;
            pf.profileUpdates = false;
            List<String> returnList3 =x7sPreferencesController.savePreferences(pf);
			pf.toDos = false;
            pf.profileUpdates = false;
            List<String> returnList4 =x7sPreferencesController.savePreferences(pf);
        }
    }

}