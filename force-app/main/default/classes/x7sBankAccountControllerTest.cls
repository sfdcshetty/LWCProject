@IsTest
public class x7sBankAccountControllerTest {
    
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
        Account primaryAcc = new Account(
                        Name = 'TestAccount');
            
        Contact primaryCon = new Contact();
        primaryCon.LastName = ' Test Contact';
        primaryCon.WEG_PortalUser__c = portalAccountOwner1.Id;
        primaryCon.AccountId = primaryAcc.Id;
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
            
            FinServ__FinancialAccount__c fa = new FinServ__FinancialAccount__c(Name = 'Test Bank Account',
                                                                               FinServ__PrimaryOwner__c = portalAccount1.Id,
                                                                               FinServ__FinancialAccountNumber__c = '123456',
                                                                               FinServ__Household__c = houseHoldAccount1.Id,
                                                                               RecordTypeId = recType.Id,
                                                                               Remove_or_Historic__c = '');
            
            Database.insert(fa);
        }
    }
    
    @IsTest
    public static void getBankAccountDetailsTest(){
    	User user1 = [Select Id From User Where Email ='test12345@testuser1.com'];
        Account portalAccount1 = [Select Id From Account Where Name ='Test Portal Account' LIMIT 1];
        System.runAs (user1) {
            Test.startTest();
            x7sBankAccountController.getBankAccountDetails(portalAccount1.Id);
            Test.stopTest();            
        }
    }
    
   /* @IsTest
    public static void getBankAccountTypeTest(){
    	User user1 = [Select Id From User Where Email ='test12345@testuser1.com'];
        Account portalAccount1 = [Select Id From Account Where Name ='Test Portal Account' LIMIT 1];
        System.runAs (user1) {
            Test.startTest();
            x7sBankAccountController.getBankAccountType('Case','Bank Account', 'FinServ__FinancialAccountType__c');
            Test.stopTest();            
        }
    }*/
    
    // @IsTest
    // public static void getCustodianTest(){
    // 	User user1 = [Select Id From User Where Email ='test12345@testuser1.com'];
    //     Account portalAccount1 = [Select Id From Account Where Name ='Test Portal Account' LIMIT 1];
    //     System.runAs (user1) {
    //         Test.startTest();
    //         x7sBankAccountController.getCustodian();
    //         Test.stopTest();            
    //     }
    // }
    
    @IsTest
    public static void addBankAccountTest(){
    	//User user1 = [Select Id From User Where Email ='test12345@testuser1.com'];
        User user1 = [Select Id From User Where Email ='bruce.wayne@portalAccountOwner1.com'];
        
        Account portalAccount1 = [Select Id From Account Where Name ='Test Portal Account' LIMIT 1];
        //String bankAccountInfo = '{"Name":"Test Account","AccountNumber":"12345","Amount":"100.00"}';
        //List<String> types = x7sBankAccountController.getBankAccountType('Case','Bank Account', 'FinServ__FinancialAccountType__c');
        //List<String> custodians = x7sBankAccountController.getCustodian();
        String bankAccountInfo2 = '{"Name":"Test Account","Type":"CD","AccountNumber":"12345","Owner":"Joint","AsOfDate":"2021-06-01","Amount":"100.00"}';

        String bankAccountInfo = '{"Name":"Test Account","Type":"CD","AccountNumber":"12345","Owner":"'+portalAccount1.Id+'","AsOfDate":"2021-06-01","Amount":"100.00"}';
        System.runAs (user1) {
            Test.startTest();
            x7sBankAccountController.addBankAccount(portalAccount1.Id, bankAccountInfo2);
            x7sBankAccountController.addBankAccount(portalAccount1.Id, bankAccountInfo);
            Test.stopTest();            
        }
    }
    
    @IsTest
    public static void editBankAccountTest(){
    	User user1 = [Select Id From User Where Email ='test12345@testuser1.com'];
        Account portalAccount1 = [Select Id From Account Where Name ='Test Portal Account' LIMIT 1];
        //String bankAccountInfo = '{"Name":"Test Account","AccountNumber":"12345","Amount":"100.00"}';
        //List<String> types = x7sBankAccountController.getBankAccountType('Case','Bank Account', 'FinServ__FinancialAccountType__c');
        //List<String> custodians = x7sBankAccountController.getCustodian();
        
        //String editBankAccountInfo = '{"Name":"Test Account 1","AccountNumber":"3455","Amount":"200.00"}';
        String editBankAccountInfo2 = '{"Name":"Test Account 1","Type":"CD","AccountNumber":"12345","Owner":"Joint","AsOfDate":"2021-06-01","Amount":"200.00"}';
        String editBankAccountInfo = '{"Name":"Test Account 1","Type":"CD","AccountNumber":"12345","Owner":"'+portalAccount1.Id+'","AsOfDate":"2021-06-01","Amount":"200.00"}';
        FinServ__FinancialAccount__c fa1 = [Select Id, Name 
                                                    From FinServ__FinancialAccount__c 
                                                    Where Name = 'Test Bank Account' LIMIT 1];
            
        System.runAs (user1) {
            Test.startTest();
            x7sBankAccountController.editBankAccount(fa1.Id, portalAccount1.Id, editBankAccountInfo);
            x7sBankAccountController.editBankAccount(fa1.Id, portalAccount1.Id, editBankAccountInfo2);

            Test.stopTest();            
        }
    }
    
    /*@IsTest
    public static void getBankAccountTest(){
        
        String bankAccountInfo = '{"Name":"Test Account","AccountNumber":"12345","Amount":"100.00"}';
        
        String editBankAccountInfo = '{"Name":"Test Account 1","AccountNumber":"3455","Amount":"200.00"}';
           
        RecordType recType = [SELECT Id, Name, DeveloperName FROM RecordType 
                              Where Name = 'Bank Account' Limit 1]; 
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
		system.debug('portalRole is ' + portalRole);

        Profile profile1 = [Select Id from Profile where name = 'System Administrator' Limit 1];
        
        User portalAccountOwner1 = new User(
                                            UserRoleId = portalRole.Id,
                                            ProfileId = profile1.Id,
                                            Username = System.now().millisecond() + 'test2@test.com',
                                            Alias = 'test',
                                            Email='bruce.wayne@wayneenterprises.com',
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
            
            Account houseHoldAccount1 = new Account(
                        Name = 'TestAccount',
                        OwnerId = portalAccountOwner1.Id
                        );
            Database.insert(houseHoldAccount1);
            
            //Create account
            Account portalAccount1 = new Account(
                        Name = 'TestAccount',
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
            Profile portalProfile = [SELECT Id FROM Profile Limit 1];
            
            User user1 = new User(Username = System.now().millisecond() + 'test12345@test.com',
                                    ContactId = contact1.Id,
                                    ProfileId = portalProfile.Id,
                                    Alias = 'test123',
                                    Email = 'test12345@test.com',
                                    EmailEncodingKey = 'UTF-8',
                                    LastName = 'McTesty',
                                    CommunityNickname = 'test12345',
                                    TimeZoneSidKey = 'America/Los_Angeles',
                                    LocaleSidKey = 'en_US',
                                    LanguageLocaleKey = 'en_US');
                Database.insert(user1);
            
            //Create Bank Account 
            FinServ__FinancialAccount__c fa = new FinServ__FinancialAccount__c(Name = 'Test Investment Account',
                                                                               FinServ__PrimaryOwner__c = portalAccount1.Id,
                                                                              FinServ__FinancialAccountNumber__c = '123456',
                                                                              FinServ__Household__c = houseHoldAccount1.Id,
                                                                              RecordTypeId = recType.Id,
                                                                              Remove_or_Historic__c = '');
        
            Database.insert(fa);
            
            Test.startTest();
            x7sBankAccountController.getBankAccountDetails(portalAccount1.Id);
            x7sBankAccountController.addBankAccount(portalAccount1.Id, bankAccountInfo);
            FinServ__FinancialAccount__c fa1 = [Select Id, Name 
                                                    From FinServ__FinancialAccount__c 
                                                    Where Name = 'Test Account' LIMIT 1];
            
            x7sBankAccountController.editBankAccount(fa1.Id, editBankAccountInfo);
            //system.assertEquals(1, lstFA.size());
            Test.stopTest(); 
            
        }
        
    }
    
    @IsTest
    public static void getPickListTest(){
        
        Test.startTest();
        x7sBankAccountController.getBankAccountType();
        x7sBankAccountController.getCustodian();
        Test.stopTest(); 
    }*/

}