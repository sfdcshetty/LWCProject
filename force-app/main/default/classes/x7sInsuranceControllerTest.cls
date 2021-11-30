@IsTest
public class x7sInsuranceControllerTest {

    @testSetup
    public static void setup() {
       
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
		system.debug('portalRole is ' + portalRole);

        Profile profile1 = [Select Id from Profile where name = 'System Administrator' Limit 1];
        
        User portalAccountOwner1 = new User(
                                            UserRoleId = portalRole.Id,
                                            ProfileId = profile1.Id,
                                            Username = System.now().millisecond() + 'InsuranceUser@test.com',
                                            Alias = 'test',
                                            Email='InsuranceUser.wayne@portalAccountOwner1.com',
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
            
            FinServ__FinancialAccount__c insurance = new FinServ__FinancialAccount__c
                (Name = 'Test Insurance 1' ,
                 FinServ__Household__c = houseHoldAccount1.Id,
                 FinServ__PrimaryOwner__c = portalAccount1.Id,
                 FinServ__Status__c = 'Open' );
            
            insert insurance;
            
            List<FinServ__FinancialAccount__c> insuranceList = [SELECT id,Name, WEG_Product_Type__c,WEG_Custodian__c,FinServ__Household__c, FinServ__FinancialAccountNumber__c, 
                             FinServ__Ownership__c, WEGP1_Insured__c, WEG_Insured_Asset__c, WEGP1_PolicyDate__c, SK_Death_Benefit_Loss_Amount__c, 
                             FinServ__InsuredAmount__c, FinServ__Premium__c, WEG_Liability_Coverage__c, WEGP1_AccumulationValue__c,FinServ__RecordTypeName__c 
                             FROM FinServ__FinancialAccount__c];
            
            system.debug('riddhi household insurance = '+insuranceList[0].FinServ__Household__c);
        }
    }
    
    @IsTest
    public static void getInsuranceDetailsTest(){
    	//User user1 = [Select Id From User Where Email ='test12345@testuser1.com'];
        User user1 = [Select Id From User Where Email='InsuranceUser.wayne@portalAccountOwner1.com'];
        Account portalAccount1 = [Select Id, WEGP1_Primary_Household__c From Account Where Name ='Test Portal Account' LIMIT 1];
        System.runAs (user1) {
            Test.startTest();
            system.debug('riddhi household portalAccount1  = '+portalAccount1.WEGP1_Primary_Household__c);
            x7sInsuranceController.getInsuranceDetails(portalAccount1.Id);
            Test.stopTest();            
        }
    }
    
    @IsTest
    public static void getInsuranceRecordTypeTest(){
    	User user1 = [Select Id From User Where Email ='test12345@testuser1.com'];
        System.runAs (user1) {
            Test.startTest();
            x7sInsuranceController.getInsuranceRecordType();
            Test.stopTest();            
        }
    }
    
    @IsTest
    public static void getCustodianTypeTest(){
    	User user1 = [Select Id From User Where Email ='test12345@testuser1.com'];
        System.runAs (user1) {
            Test.startTest();
            x7sInsuranceController.getCustodianType();
            Test.stopTest();            
        }
    }
    
    @IsTest
    public static void getOwnerListTest(){
    	User user1 = [Select Id From User Where Email ='test12345@testuser1.com'];
        Account portalAccount1 = [Select Id From Account Where Name ='Test Portal Account' LIMIT 1];
        System.runAs (user1) {
            Test.startTest();
            x7sInsuranceController.getOwnerList();
            Test.stopTest();            
        }
    }
    
    @IsTest
    public static void getProductTypeTest(){
    	User user1 = [Select Id From User Where Email ='test12345@testuser1.com'];
        Account portalAccount1 = [Select Id From Account Where Name ='Test Portal Account' LIMIT 1];
        System.runAs (user1) {
            Test.startTest();
            x7sInsuranceController.getProductType();
            Test.stopTest();            
        }
    }
    
    @IsTest
    public static void getInsuredListTest(){
    	User user1 = [Select Id From User Where Email ='test12345@testuser1.com'];
        Account portalAccount1 = [Select Id From Account Where Name ='Test Portal Account' LIMIT 1];
        System.runAs (user1) {
            Test.startTest();
            x7sInsuranceController.getInsuredList();
            Test.stopTest();            
        }
    }
    
    @IsTest
    public static void addInsuranceTest(){
    	User user1 = [Select Id From User Where Email ='InsuranceUser.wayne@portalAccountOwner1.com'];
        
        Account portalAccount1 = [Select Id From Account Where Name ='Test Portal Account' LIMIT 1];
        List<RecordType> types = x7sInsuranceController.getInsuranceRecordType();
        List<String> custodians = x7sInsuranceController.getCustodianType();
        List<String> owners = x7sInsuranceController.getOwnerList();
        String insuranceInfo = '{"Id":"","InsuranceName":"Test Insurance","ProductType":"","Carrier":"'+custodians[0]+'","Policy":"","OwnerName":"'+owners[0]+'","Insured":"","InsuredAsset":"","AsOfDate":"2021-06-01","DeathBenifit":"","BenifitAmount":"200.50","Premium":"10.5","CoverageAmount":"300.50","Amount":"350.20","CashValue":"500.55","RecordType":"'+types[0].Name+'"}';
        String insuranceInfo2 = '{"Id":"","InsuranceName":"Test Insurance","ProductType":"","Carrier":"'+custodians[0]+'","Policy":"","OwnerName":"Joint","Insured":"","InsuredAsset":"","AsOfDate":"2021-06-01","DeathBenifit":"","BenifitAmount":"200.50","Premium":"10.5","CoverageAmount":"300.50","Amount":"350.20","CashValue":"500.55","RecordType":"'+types[0].Name+'"}';

        system.debug('record type = '+types[0]);
        System.runAs (user1) {
            Test.startTest();
            x7sInsuranceController.addInsurance(portalAccount1.Id, insuranceInfo,String.valueOf(types[0].Name));
            x7sInsuranceController.addInsurance(portalAccount1.Id, insuranceInfo2,String.valueOf(types[0].Name));

            Test.stopTest();            
        }
    }
    
    @IsTest
    public static void editInsuranceTest(){
    	User user1 = [Select Id From User Where Email ='test12345@testuser1.com'];
        Account portalAccount1 = [Select Id From Account Where Name ='Test Portal Account' LIMIT 1];
        //String bankAccountInfo = '{"Name":"Test Account","AccountNumber":"12345","Amount":"100.00"}';
        List<RecordType> types = x7sInsuranceController.getInsuranceRecordType();
        List<String> custodians = x7sInsuranceController.getCustodianType();
        List<String> owners = x7sInsuranceController.getOwnerList();
        String insuranceInfo = '{"Id":"","InsuranceName":"Test Insurance 1","ProductType":"","Carrier":"'+custodians[0]+'","Policy":"","OwnerName":"Joint","Insured":"","InsuredAsset":"","AsOfDate":"2021-06-01","DeathBenifit":"","BenifitAmount":"200.50","Premium":"10.5","CoverageAmount":"300.50","Amount":"350.20","CashValue":"500.55","RecordType":"'+types[0].Name+'"}';
        String insuranceInfo2 = '{"Id":"","InsuranceName":"Test Insurance 1","ProductType":"","Carrier":"'+custodians[0]+'","Policy":"","OwnerName":"'+owners[0]+'","Insured":"","InsuredAsset":"","AsOfDate":"2021-06-01","DeathBenifit":"","BenifitAmount":"200.50","Premium":"10.5","CoverageAmount":"300.50","Amount":"350.20","CashValue":"500.55","RecordType":"'+types[0].Name+'"}';
        system.debug('record type = '+types[0]);
        
        FinServ__FinancialAccount__c fa1 = [Select Id, Name 
                                                    From FinServ__FinancialAccount__c 
                                                    Where Name = 'Test Insurance 1' LIMIT 1];
        System.runAs (user1) {
            Test.startTest();
            x7sInsuranceController.editInsurance(fa1.Id, portalAccount1.Id, insuranceInfo2);
            x7sInsuranceController.editInsurance(fa1.Id, portalAccount1.Id, insuranceInfo);
            Test.stopTest();            
        }
    }
}