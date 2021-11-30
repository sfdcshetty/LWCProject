@IsTest
public class x7sLiabilityControllerTest {
    
    @testSetup
    public static void setup() {
        RecordType recType = [SELECT Id, Name, DeveloperName FROM RecordType 
                              Where Name = 'Liability' Limit 1]; 
        
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
            
          	//Crete Liability Account
            FinServ__AssetsAndLiabilities__c liability = new FinServ__AssetsAndLiabilities__c(Name = 'Test Investment Account',
                                                                               FinServ__AssetsAndLiabilitiesType__c = 'Automobile',
                                                                               FinServ__PrimaryOwner__c = portalAccount1.Id,
                                                                              FinServ__Household__c = houseHoldAccount1.Id,
                                                                              RecordTypeId = recType.Id,
                                                                              Remove_or_Historic__c = '');
            
            Database.insert(liability);
            
        }
    }
    
    @IsTest
    public static void getLiabilityDetailsTest(){
    	User user1 = [Select Id From User Where Email ='test12345@testuser1.com'];
        Account portalAccount1 = [Select Id, WEGP1_Primary_Household__c From Account Where Name ='Test Portal Account' LIMIT 1];
        System.runAs (user1) {
            Test.startTest();
            x7sLiabilityController.getLiabilityDetails(portalAccount1.Id);
            Test.stopTest();            
        }
    }
    
    @IsTest
	public static void getLiabilityDescriptionTypeTest(){
        User user1 = [Select Id From User Where Email ='test12345@testuser1.com'];
        System.runAs (user1) {
            Test.startTest();
            x7sLiabilityController.getLiabilityDescriptionType();
            Test.stopTest();            
        }
    }
    @IsTest
	public static void editLiabilityTest(){
        User user1 = [Select Id From User Where Email ='test12345@testuser1.com'];
        Account portalAccount1 = [Select Id, WEGP1_Primary_Household__c From Account Where Name ='Test Portal Account' LIMIT 1];
        String insuranceInfo = '{"Name":"Test Liability 1 1","Description":"","InterestRate":"10.2","Owner":"'+portalAccount1.Id+'","AsOfDate":"2021-06-01","Amount":"350.20"}';
        
        FinServ__AssetsAndLiabilities__c fa1 = [Select Id, Name 
                                                    From FinServ__AssetsAndLiabilities__c 
                                                    Where Name = 'Test Investment Account' LIMIT 1];
        
        System.runAs (user1) {
            Test.startTest();
            x7sLiabilityController.editLiability(fa1.Id, portalAccount1.Id, insuranceInfo);
            Test.stopTest();            
        }
    }
    
    @IsTest
	public static void addLiabilityTest(){
        User user1 = [Select Id From User Where Email ='test12345@testuser1.com'];
        Account portalAccount1 = [Select Id, WEGP1_Primary_Household__c From Account Where Name ='Test Portal Account' LIMIT 1];
        String insuranceInfo = '{"Name":"Test Liability ","Description":"","InterestRate":"10.2","Owner":"'+portalAccount1.Id+'","AsOfDate":"2021-06-01","Amount":"350.20"}';
        
        System.runAs (user1) {
            Test.startTest();
            x7sLiabilityController.addLiability(portalAccount1.Id, insuranceInfo);
            Test.stopTest();            
        }
    }
}