@isTest
public class x7sAccountTypeAllocationControllerTest {
	@IsTest
    public static void getAccountTypeDataTest() {
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
        //Create account
            Account houseHoldAccount1 = new Account(
                Name = 'TestAccount',
                //OwnerId = portalAccountOwner1.Id,
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
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'WEG Customer Community Plus' Limit 1];
            
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
            
            RecordType recType = [SELECT Id, Name, DeveloperName FROM RecordType 
                              Where Name = 'Advisory Investment Account' Limit 1];
            
           	//Create Investment Account 
            FinServ__FinancialAccount__c fa = new FinServ__FinancialAccount__c(Name = 'Test Investment Account',
                                                                               FinServ__PrimaryOwner__c = portalAccount1.Id,
                                                                              FinServ__FinancialAccountNumber__c = '123456',
                                                                              FinServ__Household__c = houseHoldAccount1.Id,
                                                                              RecordTypeId = recType.Id,
                                                                              Remove_or_Historic__c = '',
                                                                              FinServ__Balance__c = 98.0,
                                                                              WEG_Registration_Type__c = 'Roth IRA');
            
            Database.insert(fa);
            //Id houseHold = fa.FinServ__Household__c;
            System.debug('test FinServ__Household__c = '+houseHoldAccount1.Id);
            //List<FinServ__FinancialAccount__c> accountTypeListgroup = [Select FinServ__Balance__c, WEG_Registration_Type__c  from FinServ__FinancialAccount__c WHERE FinServ__Household__c = :houseHoldAccount1.Id ];
            //List<FinServ__FinancialAccount__c> accountTypeListgroup = [Select FinServ__Balance__c, WEG_Registration_Type__c,  from FinServ__FinancialAccount__c WHERE FinServ__Household__c = :houseHold];
            List<FinServ__FinancialAccount__c> accountTypeListgroup = [Select FinServ__Balance__c, WEG_Registration_Type__c,FinServ__Household__c,FinServ__Household__r.Name  from FinServ__FinancialAccount__c];
            //List<FinServ__FinancialAccount__c> accountTypeListgroup = [Select FinServ__Balance__c, WEG_Registration_Type__c  from FinServ__FinancialAccount__c];
            System.debug('accountTypeListgrouptest' + accountTypeListgroup);
            Test.startTest();
            x7sAccountTypeAllocationController.getAccountTypeData(user1.Id);
            Test.stopTest();            
        }
    }
}