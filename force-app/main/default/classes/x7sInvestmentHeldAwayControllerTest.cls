@IsTest
public class x7sInvestmentHeldAwayControllerTest {
	
    @testSetup
    public static void getInvestmentHeldAwayDetailsTest(){        
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
		system.debug('portalRole is ' + portalRole);

        Profile profile1 = [Select Id from Profile where name = 'System Administrator' Limit 1];
        
        User portalAccountOwner1 = new User(
                                            UserRoleId = portalRole.Id,
                                            ProfileId = profile1.Id,
                                            Username = System.now().millisecond() + 'test2@test.com',
                                            Alias = 'test',
                                            Email='bruce.wayne@portalAccountOwner1HeldAway.com',
                                            EmailEncodingKey='UTF-8',
                                            Firstname='Bruce',
                                            Lastname='Wayne',
                                            LanguageLocaleKey='en_US',
                                            LocaleSidKey='en_US',
                                            TimeZoneSidKey='America/Chicago'
                                            );
        Database.insert(portalAccountOwner1);

		//User u1 = [Select ID From User Where Id =: portalAccountOwner1.Id];

        System.runAs (portalAccountOwner1) {
            
            RecordType recType = [SELECT Id, Name, DeveloperName FROM RecordType 
                              Where Name = 'Advisory Investment Account' Limit 1]; 
            
            Account houseHoldAccount1 = new Account(
                        Name = 'TestAccountHeldAwayHouseHold',
                        OwnerId = portalAccountOwner1.Id
                        );
            Database.insert(houseHoldAccount1);
            
            //Create account
            Account portalAccount1 = new Account(
                        Name = 'TestAccountInvestmentHeldAway',
                        OwnerId = portalAccountOwner1.Id,
                		WEGP1_Primary_Household__c = houseHoldAccount1.Id);
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
                                    Email = 'test12345heldaway@test.com',
                                    EmailEncodingKey = 'UTF-8',
                                    LastName = 'McTesty',
                                    CommunityNickname = 'test12345',
                                    TimeZoneSidKey = 'America/Los_Angeles',
                                    LocaleSidKey = 'en_US',
                                    LanguageLocaleKey = 'en_US');
                Database.insert(user1);
            
            FinServ__FinancialAccount__c fa = new FinServ__FinancialAccount__c(Name = 'Test Investment Held Away Account',
                                                                               FinServ__PrimaryOwner__c = portalAccount1.Id,
                                                                              FinServ__FinancialAccountNumber__c = '123456',
                                                                              FinServ__Household__c = houseHoldAccount1.Id,
                                                                              RecordTypeId = recType.Id,
                                                                              Remove_or_Historic__c = '',
                                                                              WEG_External_Rec_ID__c = '');
            
            Database.insert(fa);
            
        }
    }
    
    @IsTest
    public static void getHeldAwayTest(){
    	User user1 = [Select Id From User Where Email ='test12345heldaway@test.com'];
        Account portalAccount1 = [Select Id,Name From Account Where Name = 'TestAccountInvestmentHeldAway'];
        System.runAs (user1) {
            Test.startTest();
            x7sInvestmentHeldAwayController.getInvestmentHeldAwayDetails(portalAccount1.Id);
            Test.stopTest();            
        }
    }
    
    @IsTest
    public static void getPicklistValuesTest(){
    	User user1 = [Select Id From User Where Email ='test12345heldaway@test.com'];
        System.runAs (user1) {
            Test.startTest();
            x7sInvestmentHeldAwayController.getAccountType();
            x7sInvestmentHeldAwayController.getCustodian();
            Test.stopTest();            
        }
    }
    
    @IsTest
    public static void addInvestmentHeldAwayTest(){
        User user1 = [Select Id From User Where Email ='bruce.wayne@portalAccountOwner1HeldAway.com'];
        Account portalAccount1 = [Select Id From Account Where Name ='TestAccountInvestmentHeldAway' LIMIT 1];
        List<String> accountType = x7sInvestmentHeldAwayController.getAccountType();
        List<String> custodian = x7sInvestmentHeldAwayController.getCustodian();

        String heldAwayInfo = '{"AccountName":"Test Account","Custodian":"'+custodian[0]+'","AccountType":"'+accountType[0]+'","Owner":"Joint","AccountNumber":"123455","AsOfDate":"2021-06-01","Amount":"100.00"}';
        String heldAwayInfo1 = '{"AccountName":"Test Account","Custodian":"'+custodian[0]+'","AccountType":"'+accountType[0]+'","Owner":"'+portalAccount1.Id+'","AccountNumber":"123455","AsOfDate":"2021-06-01","Amount":"100.00"}';

        System.runAs (user1) {
            Test.startTest();
            //x7sInvestmentHeldAwayController.addInvestmentHeldAway(portalAccount1.Id, heldAwayInfo);
            x7sInvestmentHeldAwayController.addInvestmentHeldAway(portalAccount1.Id, heldAwayInfo1);
            Test.stopTest();            
        }
    }
    
    @IsTest
    public static void editInvestmentHeldAwayTest(){
        
        FinServ__FinancialAccount__c fa1 = [Select Id,Name From FinServ__FinancialAccount__c Where Name = 'Test Investment Held Away Account'];
        User user1 = [Select Id From User Where Email ='bruce.wayne@portalAccountOwner1HeldAway.com'];
        Account portalAccount1 = [Select Id From Account Where Name ='TestAccountInvestmentHeldAway' LIMIT 1];
        List<String> accountType = x7sInvestmentHeldAwayController.getAccountType();
        List<String> custodian = x7sInvestmentHeldAwayController.getCustodian();

        String heldAwayInfo = '{"AccountName":"Test Account","Custodian":"'+custodian[0]+'","AccountType":"'+accountType[0]+'","Owner":"Joint","AccountNumber":"123455","AsOfDate":"2021-06-01","Amount":"100.00"}';
        String heldAwayInfo1 = '{"AccountName":"Test Account","Custodian":"'+custodian[0]+'","AccountType":"'+accountType[0]+'","Owner":"'+portalAccount1.Id+'","AccountNumber":"12343232255","AsOfDate":"2021-06-01","Amount":"100.00"}';

        System.runAs (user1) {
            Test.startTest();
            //x7sInvestmentHeldAwayController.editInvestmentHeldAway(portalAccount1.Id, heldAwayInfo);
            x7sInvestmentHeldAwayController.editInvestmentHeldAway(fa1.Id, portalAccount1.Id, heldAwayInfo1);
            Test.stopTest();            
        }
    }
}