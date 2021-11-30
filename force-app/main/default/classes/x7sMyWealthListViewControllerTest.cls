@IsTest
public class x7sMyWealthListViewControllerTest {
	@IsTest
    public static void getInvestmentDetailsTest() {
        RecordType recType = [SELECT Id, Name, DeveloperName FROM RecordType 
                              Where Name = 'Advisory Investment Account' Limit 1]; 
        RecordType recType1 = [SELECT Id, Name, DeveloperName FROM RecordType 
                              Where Name = 'Asset' Limit 1]; 
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
		system.debug('portalRole is ' + portalRole);

        Profile profile1 = [Select Id from Profile where name = 'System Administrator' Limit 1];
        
        User portalAccountOwner1 = new User(
                                            UserRoleId = portalRole.Id,
                                            ProfileId = profile1.Id,
                                            Username = System.now().millisecond() + 'test22@test.com',
                                            Alias = 'test',
                                            Email='bruce.wayne2@wayneenterprises.com',
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

            
            //Create Investment Account 
            FinServ__FinancialAccount__c fa = new FinServ__FinancialAccount__c(Name = 'Test Investment Account',
                                                                              FinServ__PrimaryOwner__c = portalAccount1.Id,
                                                                              FinServ__FinancialAccountNumber__c = '123456',
                                                                              FinServ__Household__c = houseHoldAccount1.Id,
                                                                              RecordTypeId = recType.Id,
                                                                              Remove_or_Historic__c = '');
            
            Database.insert(fa);
            
            FinServ__AssetsAndLiabilities__c property = new FinServ__AssetsAndLiabilities__c(Name = 'Test Investment Account',
                                                                               FinServ__AssetsAndLiabilitiesType__c = 'Automobile',
                                                                               FinServ__PrimaryOwner__c = portalAccount1.Id,
                                                                              FinServ__Household__c = houseHoldAccount1.Id,
                                                                              RecordTypeId = recType1.Id,
                                                                              Remove_or_Historic__c = '');
            
            Database.insert(property);
            Test.startTest();
            List<FinServ__FinancialAccount__c> lstFA = x7sMyWealthListViewController.getInvestmentDetails(portalAccount1.Id);
            
            //system.assertEquals(1, lstFA.size());
            List<FinServ__AssetsAndLiabilities__c> lstFA1 = x7sMyWealthListViewController.getPersonalPropertyDetails(portalAccount1.Id);
            Test.stopTest(); 
        }
        
    }
}