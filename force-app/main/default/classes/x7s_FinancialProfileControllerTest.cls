/**
 * Created by 7Summits on 5/18/21.
 */

@IsTest
private class x7s_FinancialProfileControllerTest {    
    
    @IsTest
    static void testStartFinancialProfile() {

        User user1;
        Contact contact1;
        //User user1 = [Select Id From User Where Email ='x7s_FinancialProfile@x7sFinancialProfileControllerTest.com'];
        RecordType recType = [SELECT Id, Name, DeveloperName FROM RecordType 
                              Where Name = 'Bank Account' Limit 1];
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
		system.debug('portalRole is ' + portalRole);

        Profile profile1 = [Select Id from Profile where name = 'System Administrator' Limit 1];
        
        User portalAccountOwner1 = new User(
                                            UserRoleId = portalRole.Id,
                                            ProfileId = profile1.Id,
                                            Username = System.now().millisecond() + 'financialProfileUser1@test.com',
                                            Alias = 'test',
                                            Email='bruce.wayne@portalAccountOwner1.com',
                                            EmailEncodingKey='UTF-8',
                                            Firstname='Bruce',
                                            Lastname='Wayne',
                                            LanguageLocaleKey='en_US',
                                            LocaleSidKey='en_US',
                                            TimeZoneSidKey='America/Chicago',
            								isActive = True
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
            contact1 = new Contact(
                                FirstName = 'Test',
                                Lastname = 'McTesty',
                                AccountId = portalAccount1.Id,
                                Email = System.now().millisecond() + 'test@test.com'
            );
            Database.insert(contact1);

            //Create user
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'WEG Customer Community Plus' Limit 1];
            
            user1 = new User(Username = System.now().millisecond() + 'financialProfileUser2@test.com',
                                    ContactId = contact1.Id,
                                    ProfileId = portalProfile.Id,
                                    Alias = 'testAli',
                                    Email = 'test12345test@testuser1.com',
                                    EmailEncodingKey = 'UTF-8',
                                    LastName = 'McTesty',
                                    CommunityNickname = 'test1112335',
                                    TimeZoneSidKey = 'America/Los_Angeles',
                                    LocaleSidKey = 'en_US',
                                    LanguageLocaleKey = 'en_US',
                                    isActive = True);
           	Database.insert(user1);
            
        } 
        
        /* User user1 = [SELECT Id from User where Email = 'Advisor123@testuser1.com' LIMIT 1];
        Contact contact1 = [SELECT Id from Contact where Name = 'Test Contact' LIMIT 1]; */
        
        System.runAs(user1) {
            Test.startTest();
            Financial_Profile__c financialProfile = x7s_FinancialProfileController.getFinancialProfilePersonalInfoForCurrentUser();
            List<Financial_Profile__c> financialProfiles = [
                    SELECT Id
                    FROM Financial_Profile__c
            ];
            System.assert(financialProfiles.size() == 1);

            financialProfile = x7s_FinancialProfileController.getFinancialProfilePersonalInfoForCurrentUser();
            System.assert(financialProfiles.size() == 1); 

            financialProfile = x7s_FinancialProfileController.saveFinancialProfile(financialProfile);
            
            x7s_FinancialProfileController.saveFinancialProfileCoClient(contact1);

            Test.stopTest();
        }
    }
    
    @IsTest
    static void testGetEstatePlanningList() {
        Test.startTest();
        x7s_FinancialProfileController.getEstatePlanningList();
        Test.stopTest();
    }
    
    @IsTest
    static void testGetFinancialProfileDependentsForCurrentUser() {
        Test.startTest();
        x7s_FinancialProfileController.getFinancialProfileDependentsForCurrentUser();
        Test.stopTest();
    }
    
    @IsTest
    static void testGetFinancialProfileEmploymentsForCurrentUser() {
        Test.startTest();
        x7s_FinancialProfileController.getFinancialProfileEmploymentsForCurrentUser();
        Test.stopTest();
    }
    
    @IsTest
    static void testGetFinancialProfileEmploymentsForCoClient() {
        Test.startTest();
        x7s_FinancialProfileController.getFinancialProfileEmploymentsForCoClient();
        Test.stopTest();
    }
    
    @IsTest
    static void testGetPlanningObjectivesFields() {
        Test.startTest();
        x7s_FinancialProfileController.getPlanningObjectivesFields();
        Test.stopTest();
    }
    
    @IsTest
    static void testGetPlanningObjectivesList() {
        Test.startTest();
        x7s_FinancialProfileController.getPlanningObjectivesList();
        Test.stopTest();
    }
    
    @IsTest
    static void testGetFinancialProfileGoalsForCurrentUser() {
        Test.startTest();
        x7s_FinancialProfileController.getFinancialProfileGoalsForCurrentUser();
        Test.stopTest();
    }

    @IsTest
    static void testGetOtherTaxFactorsFields() {
        Test.startTest();
        x7s_FinancialProfileController.getOtherTaxFactorsFields();
        Test.stopTest();
    }
    
    @IsTest
    static void testGetOtherTaxFactorsList() {
        Test.startTest();
        x7s_FinancialProfileController.getOtherTaxFactorsList();
        Test.stopTest();
    }
    
    @IsTest
    static void testGetFinancialProfileIncomeExpensesForCurrentUser() {
        Test.startTest();
        x7s_FinancialProfileController.getFinancialProfileIncomeExpensesForCurrentUser();
        Test.stopTest();
    }
    
    @IsTest
    static void testGetFinancialProfileIncomeExpensesForCoClient() {
        Test.startTest();
        x7s_FinancialProfileController.getFinancialProfileIncomeExpensesForCoClient();
        Test.stopTest();
    }
    
    @IsTest
    static void testGetFinancialProfileIncomeExpensesForBoth() {
        Test.startTest();
        x7s_FinancialProfileController.getFinancialProfileIncomeExpensesForBoth();
        Test.stopTest();
    }
    
    @IsTest
    static void testGetFinancialProfileFinancialAccountsForCurrentUser() {
        Test.startTest();
        x7s_FinancialProfileController.getFinancialProfileFinancialAccountsForCurrentUser();
        Test.stopTest();
    }
    
    @IsTest
    static void testGetInsuranceCategoriesFields() {
        Test.startTest();
        x7s_FinancialProfileController.getInsuranceCategoriesFields();
        Test.stopTest();
    }
    
    @IsTest
    static void testGetInsuranceCategoriesList() {
        Test.startTest();
        x7s_FinancialProfileController.getInsuranceCategoriesList();
        Test.stopTest();
    }
    
    @IsTest
    static void testGetFinancialProfileInsurancePoliciesForCurrentUser() {
        Test.startTest();
        x7s_FinancialProfileController.getFinancialProfileInsurancePoliciesForCurrentUser();
        Test.stopTest();
    }
    
    @IsTest
    static void testGetFinancialProfileFinancialGoals() {
        List<X7s_Financial_Goals_Button__mdt> expected = [SELECT Label, Icon_Name__c, Term__c, Order__c FROM X7s_Financial_Goals_Button__mdt ORDER BY Order__c];
        List<X7s_Financial_Goals_Button__mdt> actual =  x7s_FinancialProfileController.getFinancialProfileFinancialGoals();
        System.assertEquals(expected.size(), actual.size());
    }
    
    @IsTest
    static void testSaveFinancialProfileIncomeExpenses() {
        Account acc = [SELECT Id from Account where Name = 'Test HouseHold Account' LIMIT 1];
        User portalAccountOwner1 = [SELECT Id from User where Email = 'Advisor@x7sFinancialProfileTest.com' LIMIT 1];
        Contact con1 = [SELECT Id,Name,AccountId,Account.WEGP1_Primary_Household__c from Contact where Name = 'Test Contact' LIMIT 1];
        
        System.runAs(portalAccountOwner1){
            Financial_Profile__c newFinancialProfile = new Financial_Profile__c();
            newFinancialProfile.ContactId__c = con1.Id;
            newFinancialProfile.Individual_Account__c = con1.AccountId;
            newFinancialProfile.Household_Account__c = con1.Account.WEGP1_Primary_Household__c;
            newFinancialProfile.Name = 'test new Financial Profile';
            insert newFinancialProfile;
            
            String financialProfileInfo = '[{"Name":"Test Financial Profile Income Expense","CreatedDate":"2021-06-01","Description__c":"test description","Amount__c":"100.00","Type__c":"Pension","Financial_Profile__c":"'+newFinancialProfile.Id+'"}]';
            String financialProfileType = 'Pension';
            
            Test.startTest();
            x7s_FinancialProfileController.saveFinancialProfileIncomeExpenses(financialProfileInfo,financialProfileType);
            Test.stopTest();
        }
        /*Account portalAccount1 = new Account(
            Name = 'Test Portal Account',
            OwnerId = portalAccountOwner1.Id,
            WEGP1_Primary_Household__c = acc.Id);
        Database.insert(portalAccount1);
        // Create Test Contact
        Contact con1 = new Contact();
        con1.LastName = ' Test Contact 1';
        con1.WEGP1_PrimaryAddress__c = 'Work';
        con1.WEGP1_PrimaryEmail__c = 'Work';
        con1.WEGP1_PrimaryPhone__c = 'Work';
        con1.HomePhone = '1111111111';
        con1.AssistantPhone = '2222222222';
        con1.MobilePhone = '3333333333';
        con1.OtherPhone = '4444444444';
        con1.WEG_Business_Email__c = 'work_email1@examplefinancialProfile.com';
        con1.WEGP1_OtherEmail__c = 'other_email1@examplefinancialProfile.com';
        con1.WEGP1_PersonalEmail__c = 'test1@examplefinancialProfile.com';
        con1.Email = 'test1@examplefinancialProfile1.com';
        con1.OtherStreet = 'OtherStreet1';
        con1.accountId = portalAccount1.Id;
        con1.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        insert con1;*/
        
        
        
    }
    
    /*@IsTest
    static void testSaveFinancialProfile() {
        Contact con1 = [SELECT Id, AccountId from Contact where Email = 'test@examplefinancialProfile.com' LIMIT 1];
        Account acc = [SELECT Id from Account where Name = 'Test HouseHold Account' LIMIT 1];
		Financial_Profile__c newFinancialProfile = new Financial_Profile__c();
        newFinancialProfile.ContactId__c = con1.Id;
        newFinancialProfile.Individual_Account__c = con1.AccountId;
        newFinancialProfile.Household_Account__c = acc.Id;
        newFinancialProfile.Name = 'test new Financial Profile';
        Test.startTest();
        x7s_FinancialProfileController.saveFinancialProfile(newFinancialProfile);
        Test.stopTest();
    }*/
    
   /* @IsTest
    static void testSaveFinancialProfileCoClient() {
        //Contact con1 = [SELECT Id, AccountId from Contact where Email = 'test@examplefinancialProfile.com' LIMIT 1];
        //Account acc = [SELECT Id from Account where Name = 'Test HouseHold Account' LIMIT 1];
        // Create Test Contact
        Contact con = new Contact();
        con.LastName = ' Test Contact 1';
        con.WEGP1_PrimaryAddress__c = 'Work';
        con.WEGP1_PrimaryEmail__c = 'Work';
        con.WEGP1_PrimaryPhone__c = 'Work';
        con.HomePhone = '1111111111';
        con.AssistantPhone = '2222222222';
        con.MobilePhone = '3333333333';
        con.OtherPhone = '4444444444';
        con.WEG_Business_Email__c = 'work_email@examplefinancialProfile.com';
        con.WEGP1_OtherEmail__c = 'other_email@examplefinancialProfile.com';
        con.WEGP1_PersonalEmail__c = 'test@examplefinancialProfile.com';
        con.Email = 'test@examplefinancialProfile.com';
        con.OtherStreet = 'OtherStreet';
        insert con;
		Test.startTest();
        x7s_FinancialProfileController.saveFinancialProfileCoClient(con);
        Test.stopTest();
    }*/
    
	@IsTest
    static void testSaveFinancialProfileDependents() {
        Account acc = [SELECT Id from Account where Name = 'Test HouseHold Account' LIMIT 1];
        User portalAccountOwner1 = [SELECT Id from User where Email = 'Advisor@x7sFinancialProfileTest.com' LIMIT 1];
        Contact con1 = [SELECT Id,Name,AccountId,Account.WEGP1_Primary_Household__c from Contact where Name = 'Test Contact' LIMIT 1];
        
        System.runAs(portalAccountOwner1){
            Financial_Profile__c newFinancialProfile = new Financial_Profile__c();
            newFinancialProfile.ContactId__c = con1.Id;
            newFinancialProfile.Individual_Account__c = con1.AccountId;
            newFinancialProfile.Household_Account__c = con1.Account.WEGP1_Primary_Household__c;
            newFinancialProfile.Name = 'test new Financial Profile';
            insert newFinancialProfile;
            
            String financialProfileDependentInfo = '[{"Name":"Test Financial Profile Dependent","CreatedDate":"2021-06-01","Financial_Profile__c":"'+newFinancialProfile.Id+'"}]';
            Test.startTest();
            x7s_FinancialProfileController.saveFinancialProfileDependents(financialProfileDependentInfo);
            Test.stopTest();
        }
        /*Account portalAccount1 = new Account(
            Name = 'Test Portal Account',
            OwnerId = portalAccountOwner1.Id,
            WEGP1_Primary_Household__c = acc.Id);
        Database.insert(portalAccount1);
        // Create Test Contact
        Contact con1 = new Contact();
        con1.LastName = ' Test Contact 1';
        con1.WEGP1_PrimaryAddress__c = 'Work';
        con1.WEGP1_PrimaryEmail__c = 'Work';
        con1.WEGP1_PrimaryPhone__c = 'Work';
        con1.HomePhone = '1111111111';
        con1.AssistantPhone = '2222222222';
        con1.MobilePhone = '3333333333';
        con1.OtherPhone = '4444444444';
        con1.WEG_Business_Email__c = 'work_email1@examplefinancialProfile.com';
        con1.WEGP1_OtherEmail__c = 'other_email1@examplefinancialProfile.com';
        con1.WEGP1_PersonalEmail__c = 'test1@examplefinancialProfile.com';
        con1.Email = 'test1@examplefinancialProfile1.com';
        con1.OtherStreet = 'OtherStreet1';
        con1.accountId = portalAccount1.Id;
        con1.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        insert con1;*/
        
        
        
    }
    
    @IsTest
    static void testSaveFinancialProfileEmployments() {
        Account acc = [SELECT Id from Account where Name = 'Test HouseHold Account' LIMIT 1];
        User portalAccountOwner1 = [SELECT Id from User where Email = 'Advisor@x7sFinancialProfileTest.com' LIMIT 1];
        Contact con1 = [SELECT Id,Name,AccountId,Account.WEGP1_Primary_Household__c from Contact where Name = 'Test Contact' LIMIT 1];
        
        System.runAs(portalAccountOwner1){
            Financial_Profile__c newFinancialProfile = new Financial_Profile__c();
            newFinancialProfile.ContactId__c = con1.Id;
            newFinancialProfile.Individual_Account__c = con1.AccountId;
            newFinancialProfile.Household_Account__c = con1.Account.WEGP1_Primary_Household__c;
            newFinancialProfile.Name = 'test new Financial Profile';
            insert newFinancialProfile;
            
            String financialProfileEmploymentInfo = '[{"Name":"Test Financial Profile Employments","CreatedDate":"2021-06-01","Financial_Profile__c":"'+newFinancialProfile.Id+'","Contact_Id__c":"'+con1.Id+'"}]';
            Test.startTest();
            x7s_FinancialProfileController.saveFinancialProfileEmployments(financialProfileEmploymentInfo);
            Test.stopTest();
        }
        /*Account portalAccount1 = new Account(
            Name = 'Test Portal Account',
            OwnerId = portalAccountOwner1.Id,
            WEGP1_Primary_Household__c = acc.Id);
        Database.insert(portalAccount1);
        // Create Test Contact
        Contact con1 = new Contact();
        con1.LastName = ' Test Contact 1';
        con1.WEGP1_PrimaryAddress__c = 'Work';
        con1.WEGP1_PrimaryEmail__c = 'Work';
        con1.WEGP1_PrimaryPhone__c = 'Work';
        con1.HomePhone = '1111111111';
        con1.AssistantPhone = '2222222222';
        con1.MobilePhone = '3333333333';
        con1.OtherPhone = '4444444444';
        con1.WEG_Business_Email__c = 'work_email1@examplefinancialProfile.com';
        con1.WEGP1_OtherEmail__c = 'other_email1@examplefinancialProfile.com';
        con1.WEGP1_PersonalEmail__c = 'test1@examplefinancialProfile.com';
        con1.Email = 'test1@examplefinancialProfile1.com';
        con1.OtherStreet = 'OtherStreet1';
        con1.accountId = portalAccount1.Id;
        con1.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        insert con1;*/
        
        
        
    }
    
    @IsTest
    static void testSaveFinancialProfileGoals() {
        Account acc = [SELECT Id from Account where Name = 'Test HouseHold Account' LIMIT 1];
        User portalAccountOwner1 = [SELECT Id from User where Email = 'Advisor@x7sFinancialProfileTest.com' LIMIT 1];
        Contact con1 = [SELECT Id,Name,AccountId,Account.WEGP1_Primary_Household__c from Contact where Name = 'Test Contact' LIMIT 1];
        
        System.runAs(portalAccountOwner1){
            /*Account portalAccount1 = new Account(
            Name = 'Test Portal Account',
            OwnerId = portalAccountOwner1.Id,
            WEGP1_Primary_Household__c = acc.Id);
            Database.insert(portalAccount1);
            // Create Test Contact
            Contact con1 = new Contact();
            con1.LastName = ' Test Contact 1';
            con1.WEGP1_PrimaryAddress__c = 'Work';
            con1.WEGP1_PrimaryEmail__c = 'Work';
            con1.WEGP1_PrimaryPhone__c = 'Work';
            con1.HomePhone = '1111111111';
            con1.AssistantPhone = '2222222222';
            con1.MobilePhone = '3333333333';
            con1.OtherPhone = '4444444444';
            con1.WEG_Business_Email__c = 'work_email1@examplefinancialProfile.com';
            con1.WEGP1_OtherEmail__c = 'other_email1@examplefinancialProfile.com';
            con1.WEGP1_PersonalEmail__c = 'test1@examplefinancialProfile.com';
            con1.Email = 'test1@examplefinancialProfile1.com';
            con1.OtherStreet = 'OtherStreet1';
            con1.accountId = portalAccount1.Id;
            con1.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
            insert con1;*/
        
        
            Financial_Profile__c newFinancialProfile = new Financial_Profile__c();
            newFinancialProfile.ContactId__c = con1.Id;
            newFinancialProfile.Individual_Account__c = con1.AccountId;
            newFinancialProfile.Household_Account__c = con1.Account.WEGP1_Primary_Household__c;
            newFinancialProfile.Name = 'test new Financial Profile';
            insert newFinancialProfile;
        
            String financialProfileGoalInfo = '[{"Name":"Test Financial Profile Goal","CreatedDate":"2021-06-01","Financial_Profile__c":"'+newFinancialProfile.Id+'"}]';
            Test.startTest();
            x7s_FinancialProfileController.saveFinancialProfileGoals(financialProfileGoalInfo);
            Test.stopTest();
        }
        
    }
    
    @IsTest
    static void testSaveFinancialProfileFinancialAccounts() {
        Account acc = [SELECT Id from Account where Name = 'Test HouseHold Account' LIMIT 1];
        User portalAccountOwner1 = [SELECT Id from User where Email = 'Advisor@x7sFinancialProfileTest.com' LIMIT 1];
        Contact con1 = [SELECT Id,Name,AccountId,Account.WEGP1_Primary_Household__c from Contact where Name = 'Test Contact' LIMIT 1];
        
        System.runAs(portalAccountOwner1){
            Financial_Profile__c newFinancialProfile = new Financial_Profile__c();
            newFinancialProfile.ContactId__c = con1.Id;
            newFinancialProfile.Individual_Account__c = con1.AccountId;
            newFinancialProfile.Household_Account__c = con1.Account.WEGP1_Primary_Household__c;
            newFinancialProfile.Name = 'test new Financial Profile';
            insert newFinancialProfile;
            
            String financialProfileFinancialAccountInfo = '[{"Name":"Test Financial Profile Financial Account","CreatedDate":"2021-06-01","Financial_Profile__c":"'+newFinancialProfile.Id+'","Type__c":"Retirement"}]';
            String fpType ='Retirement';
            Test.startTest();
            x7s_FinancialProfileController.saveFinancialProfileFinancialAccounts(financialProfileFinancialAccountInfo,fpType);
            Test.stopTest();
            
        }
        /*Account portalAccount1 = new Account(
            Name = 'Test Portal Account',
            OwnerId = portalAccountOwner1.Id,
            WEGP1_Primary_Household__c = acc.Id);
        Database.insert(portalAccount1);
        // Create Test Contact
        Contact con1 = new Contact();
        con1.LastName = ' Test Contact 1';
        con1.WEGP1_PrimaryAddress__c = 'Work';
        con1.WEGP1_PrimaryEmail__c = 'Work';
        con1.WEGP1_PrimaryPhone__c = 'Work';
        con1.HomePhone = '1111111111';
        con1.AssistantPhone = '2222222222';
        con1.MobilePhone = '3333333333';
        con1.OtherPhone = '4444444444';
        con1.WEG_Business_Email__c = 'work_email1@examplefinancialProfile.com';
        con1.WEGP1_OtherEmail__c = 'other_email1@examplefinancialProfile.com';
        con1.WEGP1_PersonalEmail__c = 'test1@examplefinancialProfile.com';
        con1.Email = 'test1@examplefinancialProfile1.com';
        con1.OtherStreet = 'OtherStreet1';
        con1.accountId = portalAccount1.Id;
        con1.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        insert con1;*/
        
        
        
    }
    
    @IsTest
    static void testGetFinancialProfileAssetsLiabilitiesForCurrentUser() {
        Test.startTest();
        x7s_FinancialProfileController.getFinancialProfileAssetsLiabilitiesForCurrentUser();
        Test.stopTest();
    }
    
    @IsTest
    static void testSaveFinancialProfileAssets() {
        Account acc = [SELECT Id from Account where Name = 'Test HouseHold Account' LIMIT 1];
        User portalAccountOwner1 = [SELECT Id from User where Email = 'Advisor@x7sFinancialProfileTest.com' LIMIT 1];
        Contact con1 = [SELECT Id,Name,AccountId,Account.WEGP1_Primary_Household__c from Contact where Name = 'Test Contact' LIMIT 1];
        
        System.runAs(portalAccountOwner1){
            /*Account portalAccount1 = new Account(
            Name = 'Test Portal Account',
            OwnerId = portalAccountOwner1.Id,
            WEGP1_Primary_Household__c = acc.Id);
        Database.insert(portalAccount1);
        // Create Test Contact
        Contact con1 = new Contact();
        con1.LastName = ' Test Contact 1';
        con1.WEGP1_PrimaryAddress__c = 'Work';
        con1.WEGP1_PrimaryEmail__c = 'Work';
        con1.WEGP1_PrimaryPhone__c = 'Work';
        con1.HomePhone = '1111111111';
        con1.AssistantPhone = '2222222222';
        con1.MobilePhone = '3333333333';
        con1.OtherPhone = '4444444444';
        con1.WEG_Business_Email__c = 'work_email1@examplefinancialProfile.com';
        con1.WEGP1_OtherEmail__c = 'other_email1@examplefinancialProfile.com';
        con1.WEGP1_PersonalEmail__c = 'test1@examplefinancialProfile.com';
        con1.Email = 'test1@examplefinancialProfile1.com';
        con1.OtherStreet = 'OtherStreet1';
        con1.accountId = portalAccount1.Id;
        con1.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        insert con1;*/
        
        
        Financial_Profile__c newFinancialProfile = new Financial_Profile__c();
        newFinancialProfile.ContactId__c = con1.Id;
        newFinancialProfile.Individual_Account__c = con1.AccountId;
        newFinancialProfile.Household_Account__c = con1.Account.WEGP1_Primary_Household__c;
        newFinancialProfile.Name = 'test new Financial Profile';
        insert newFinancialProfile;
        
        String financialProfileAssetInfo = '[{"Name":"Test Financial Profile Asset","CreatedDate":"2021-06-01","Financial_Profile__c":"'+newFinancialProfile.Id+'","Type__c":"Automobile","Asset_Type__c":"Primary Residence"}]';
        String fpType ='Automobile';
        Test.startTest();
        x7s_FinancialProfileController.saveFinancialProfileAssets(financialProfileAssetInfo,fpType);
        Test.stopTest();
        }

        
    }
    
     @IsTest
    static void testSaveFinancialProfileInsurancePolicies() {
        Account acc = [SELECT Id from Account where Name = 'Test HouseHold Account' LIMIT 1];
        User portalAccountOwner1 = [SELECT Id from User where Email = 'Advisor@x7sFinancialProfileTest.com' LIMIT 1];
        Contact con1 = [SELECT Id,Name,AccountId,Account.WEGP1_Primary_Household__c from Contact where Name = 'Test Contact' LIMIT 1];
        
        System.runAs(portalAccountOwner1){
            Financial_Profile__c newFinancialProfile = new Financial_Profile__c();
            newFinancialProfile.ContactId__c = con1.Id;
            newFinancialProfile.Individual_Account__c = con1.AccountId;
            newFinancialProfile.Household_Account__c = con1.Account.WEGP1_Primary_Household__c;
            newFinancialProfile.Name = 'test new Financial Profile';
            insert newFinancialProfile;
            
            String financialProfileInsurancePoliciesInfo = '[{"Name":"Test Financial Profile Insurance Policies","CreatedDate":"2021-06-01","Financial_Profile__c":"'+newFinancialProfile.Id+'","Cash_Value__c":"100.0","Type__c":"Life"}]';
            String fpType ='Life';
            Test.startTest();
            x7s_FinancialProfileController.saveFinancialProfileInsurancePolicies(financialProfileInsurancePoliciesInfo,fpType);
            Test.stopTest();
        }
        /*Account portalAccount1 = new Account(
            Name = 'Test Portal Account',
            OwnerId = portalAccountOwner1.Id,
            WEGP1_Primary_Household__c = acc.Id);
        Database.insert(portalAccount1);
        // Create Test Contact
        Contact con1 = new Contact();
        con1.LastName = ' Test Contact 1';
        con1.WEGP1_PrimaryAddress__c = 'Work';
        con1.WEGP1_PrimaryEmail__c = 'Work';
        con1.WEGP1_PrimaryPhone__c = 'Work';
        con1.HomePhone = '1111111111';
        con1.AssistantPhone = '2222222222';
        con1.MobilePhone = '3333333333';
        con1.OtherPhone = '4444444444';
        con1.WEG_Business_Email__c = 'work_email1@examplefinancialProfile.com';
        con1.WEGP1_OtherEmail__c = 'other_email1@examplefinancialProfile.com';
        con1.WEGP1_PersonalEmail__c = 'test1@examplefinancialProfile.com';
        con1.Email = 'test1@examplefinancialProfile1.com';
        con1.OtherStreet = 'OtherStreet1';
        con1.accountId = portalAccount1.Id;
        con1.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        insert con1;*/
        
        
        
    }
    
    @testSetup
    public static void setup() {
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
		system.debug('portalRole is ' + portalRole);

        Profile profile1 = [Select Id from Profile where name = 'System Administrator' Limit 1];
        
        User portalAccountOwner1 = new User(
                                            UserRoleId = portalRole.Id,
                                            ProfileId = profile1.Id,
                                            Username = System.now().millisecond() + 'Advisor@test.com',
                                            Alias = 'test',
                                            Email='Advisor@x7sFinancialProfileTest.com',
                                            EmailEncodingKey='UTF-8',
                                            Firstname='Bruce',
                                            Lastname='Wayne',
                                            LanguageLocaleKey='en_US',
                                            LocaleSidKey='en_US',
                                            TimeZoneSidKey='America/Chicago',
											Photo_URL__c = '/clientportal/profilephoto/005/M',
            								isActive = True
                                            );
        Database.insert(portalAccountOwner1);

        System.runAs (portalAccountOwner1) {
            
            Contact primaryCon = new Contact();
            primaryCon.LastName = ' Test Contact';
            primaryCon.WEG_PortalUser__c = portalAccountOwner1.Id;
            primaryCon.RecordTypeId =  Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
            insert primaryCon;
            
            /*Account houseAcc = new Account(
                        Name = 'Test HouseHold Account',
                        OwnerId = portalAccountOwner1.Id,
                		WEG_Equity__c = 10.0,
                		WEG_Fixed_Income__c =  20.0,
                		WEG_Real_Estate__c = 25.0,
                		WEG_Alternative_Investment__c = 13.0,
                		WEG_Cash_and_Equivalents__c = 28.0,
                		WEG_Other__c = 16.0
                        );
            Database.insert(houseAcc);
            
            Account acc = new Account(
                        Name = 'Test Account',
                        OwnerId = portalAccountOwner1.Id,
                		WEGP1_Primary_Household__c = houseAcc.Id
                        );
            Database.insert(acc);

            //Create contact
            Contact con = new Contact(
                                FirstName = 'Test',
                                Lastname = 'McTesty',
                                AccountId = acc.Id,
                                Email = System.now().millisecond() + 'test@test.com'
            );
            Database.insert(con); */

            //Create account
        	Account houseAcc = new Account();
            houseAcc.name = 'Test HouseHold Account';
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
            houseAcc.WEG_Equity__c = 10.0;
            houseAcc.WEG_Fixed_Income__c =  20.0;
            houseAcc.WEG_Real_Estate__c = 25.0;
            houseAcc.WEG_Alternative_Investment__c = 13.0;
            houseAcc.WEG_Cash_and_Equivalents__c = 28.0;
            houseAcc.WEG_Other__c = 16.0;
            //houseAcc.WEGP1_Primary_Individual__c = primaryCon.Id;
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
            acc.OwnerId = portalAccountOwner1.Id;
            //acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
            acc.WEGP1_Primary_Household__c = houseAcc.Id;
            //acc.WEGP1_Primary_Individual__c = primaryCon.Id;
            insert acc;

            Contact con = new Contact(
                                FirstName = 'Test',
                                Lastname = 'McTesty',
                                AccountId = acc.Id,
                                Email = System.now().millisecond() + 'test@test.com'
            );
            Database.insert(con);
            
            // Create Test Contact
            /*Contact con = new Contact();
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
            insert con;*/
            
            ToDo__c newTodo = new ToDo__c();
            //newTodo.Assigned_To_Individual__c = con.Id;
            newTodo.Assigned_To_Individual__c = primaryCon.Id;
            insert newTodo;

            //Create user
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'WEG Customer Community Plus' Limit 1];
            
            User user1 = new User(Username = System.now().millisecond() + 'Advisor123@test.com',
                                    ContactId = con.Id,
                                    ProfileId = portalProfile.Id,
                                    Alias = 'test123',
                                    Email = 'Advisor123@testuser1.com',
                                    EmailEncodingKey = 'UTF-8',
                                    LastName = 'McTesty',
                                    CommunityNickname = 'test12345',
                                    TimeZoneSidKey = 'America/Los_Angeles',
                                    LocaleSidKey = 'en_US',
                                    LanguageLocaleKey = 'en_US',
                                    Photo_URL__c = '/clientportal/profilephoto/005/M',
                                    isActive = True);
           	Database.insert(user1);
            
        }
    }

    /*private static User insertTestUser(){
        List<Contact> contactQuery = [
                SELECT Id
                FROM Contact
                WHERE Email = 'test@examplefinancialProfile.com'
        ];

        List<Profile> userProfiles = [
                SELECT id
                FROM Profile
                WHERE Name = 'WEG Customer Community Plus'
                LIMIT 1
        ];

        User u = new User(
                LastName = 'Test',
                Email = 'x7s_FinancialProfile@x7sFinancialProfileControllerTest.com',
                Username = 'x7s_FinancialProfile@x7sFinancialProfileControllerTest.com',
                Alias = 'alias',
                CompanyName = 'x7s_FinancialProfile',
                Title = 'Tester',
                ProfileId = userProfiles[0].Id,
                ContactId = contactQuery[0].Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US'
        );
        insert u;
        return u;
    }  */
}