/**
 * Created by 7Summits on 6/29/21.
 */

@isTest
public class x7s_EstatePlanningControllerTest {
    
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
                                            TimeZoneSidKey='America/Chicago'
                                            );
        Database.insert(portalAccountOwner1);

        System.runAs (portalAccountOwner1) {
            //Create account
            //
         Contact primaryInd = new Contact(
                FirstName = 'Test',
                Lastname = 'McTesty',
                Email = System.now().millisecond() + 'testPrimary@test.com'
          );
         Database.insert(primaryInd);
            
         Contact secondInd = new Contact(
                FirstName = 'Test',
                Lastname = 'McTesty',
                Email = System.now().millisecond() + 'testSecondary@test.com'
          );
         Database.insert(secondInd);
            
         Account houseHoldAccount1 = new Account(
                        Name = 'TestAccount',
                        OwnerId = portalAccountOwner1.Id,
                		WEG_Equity__c = 10.0,
                		WEG_Fixed_Income__c =  20.0,
                		WEG_Real_Estate__c = 25.0,
                		WEG_Alternative_Investment__c = 13.0,
                		WEG_Cash_and_Equivalents__c = 28.0,
                		WEG_Other__c = 16.0,
             			WEGP1_Primary_Individual__c = primaryInd.Id,
             			WEGP1_Secondary_Individual__c = secondInd.Id
                        );
            Database.insert(houseHoldAccount1);
            
            Account portalAccount1 = new Account(
                        Name = 'TestAccount',
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
        }
        
    }
    
    @IsTest
    static void testGetAndSaveEstateInformation() {
        User portalAccountOwner1 = [Select Id From User Where Email ='bruce.wayne@portalAccountOwner1.com'];
		User testUser = [Select Id From User Where Email ='test12345@testuser1.com'];
        //User testUser = insertTestUser();
        System.runAs(testUser) {

            Test.startTest();
            x7s_EstatePlanningController.EstateWrapper wrapper = x7s_EstatePlanningController.getHouseholdWithEstateInformation();

            wrapper.primaryWillExists = true;
            //wrapper.primaryTrustExists = 'Revocable';
            wrapper.primaryRevocableTrustExists = true;
            wrapper.primaryIrrevocableTrustExists = false;

            wrapper.primaryPowerOfAttorney = true;
            wrapper.primaryLivingWillExists = true;
            wrapper.secondaryWillExists = true;
            //wrapper.secondaryTrustExists = 'Irrevocable';
            wrapper.primaryRevocableTrustExists = false;
            wrapper.primaryIrrevocableTrustExists = true;

            wrapper.secondaryPowerOfAttorney = true;
            wrapper.secondaryLivingWillExists = true;

            x7s_EstatePlanningController.saveEstateInformation(JSON.serialize(wrapper));
            
            x7s_EstatePlanningController.EstateWrapper wrapper1 = x7s_EstatePlanningController.getHouseholdWithEstateInformation();

            wrapper1.primaryWillExists = false;
            //wrapper1.primaryTrustExists = '';
            wrapper.primaryRevocableTrustExists = false;
            wrapper.primaryIrrevocableTrustExists = false;

            wrapper1.primaryPowerOfAttorney = false;
            wrapper1.primaryLivingWillExists = false;
            wrapper1.secondaryWillExists = false;
            //wrapper1.secondaryTrustExists = '';
            wrapper.primaryRevocableTrustExists = false;
            wrapper.primaryIrrevocableTrustExists = false;

            wrapper1.secondaryPowerOfAttorney = false;
            wrapper1.secondaryLivingWillExists = false;

            x7s_EstatePlanningController.saveEstateInformation(JSON.serialize(wrapper1));
            Test.stopTest();
        }

    }
    
    /* @TestSetup
    static void setupData(){

        // Create Test Account
        Account houseAcc = new Account();
        houseAcc.name = 'Test HouseHold Account';
        houseAcc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        insert houseAcc;

        Account acc = new Account();
        acc.name = 'Test Account';
        acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        acc.WEGP1_Primary_Household__c = houseAcc.Id;
        insert acc;


        // Create Test Contact
        Contact con = new Contact();
        con.LastName = ' Test Contact';
        con.Email = 'test@x7sEstatePlanning.com';
        con.accountId = acc.Id;
        con.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        insert con;

        Account secondaryAcc = new Account();
        secondaryAcc.name = 'Test Account 2';
        secondaryAcc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        secondaryAcc.WEGP1_Primary_Household__c = houseAcc.Id;
        insert secondaryAcc;


        // Create Test Contact
        Contact secondaryCon = new Contact();
        secondaryCon.LastName = ' Test Contact 2';
        secondaryCon.Email = 'test2@x7sEstatePlanning.com';
        secondaryCon.accountId = secondaryAcc.Id;
        secondaryCon.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        insert secondaryCon;

        houseAcc.WEGP1_Primary_Individual__c = con.Id;
        houseAcc.WEGP1_Secondary_Individual__c = secondaryCon.Id;
        update houseAcc;

    } */

    /*private static User insertTestUser(){
        
       UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
		system.debug('portalRole is ' + portalRole);
        
        User user1;

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
                        Name = 'TestAccount',
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
            Profile portalProfile = [SELECT Id FROM Profile Limit 1];
            
            user1 = new User(Username = System.now().millisecond() + 'test12345@test.com',
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
        return user1;
    } */
}