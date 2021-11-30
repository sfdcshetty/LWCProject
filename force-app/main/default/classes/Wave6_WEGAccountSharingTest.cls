/******************************************************************************************************************************
* @class name    : Wave6_WEGAccountSharingTest
* @description   : This class provides unit tests for following classes: Wave6_WEGAccountSharingBatch,Wave6_WEGAccountSharingBatchHelper,
*                  Wave6_WEGAccountSharingController, Wave6_WEGAccountSharingAction and Wave6_WEGAccountSharingUtility.
*
* @author        : Ganesh Ekhande
* @date          : 07/05/2017
*
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              07/05/2017             Created.
* Ganesh Ekhande              11/14/2017             Updated unit test code for newly introduced Blot Account team sharing.
*
******************************************************************************************************************************/
@isTest
private class Wave6_WEGAccountSharingTest {

    @testSetup 
    private static void createTestData(){

        //Create Household and Individual Accounts
        Account hhAcc = new Account(Name='HH Account1', recordTypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('Household').getRecordTypeId(), WEGP1_AccountTeamIds__c='HHDummyValue');
        insert hhAcc;

        Account indAcc= new Account(Name='Ind Account1', recordTypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('Individual').getRecordTypeId(),WEGP1_AccountTeamIds__c='IndDummyValue');
        insert indAcc;

        Account indAcc2= new Account(Name='Ind Account2', recordTypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('Individual').getRecordTypeId(),WEGP1_AccountTeamIds__c='IndDummyValue');
        insert indAcc2;
        
        Account busAcc= new Account(Name='Bus Account1', recordTypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('Business').getRecordTypeId(),WEGP1_AccountTeamIds__c='BusDummyValue');
        insert busAcc;

        // get the contact created from the first individual
        Contact con1 =  [Select Id, Email, FirstName, LastName From Contact Where AccountId =: indAcc.Id];        
        
        // Create Test users
        list<User>users = new list<User>();
        Profile prof = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Profile port = [SELECT Id FROM Profile WHERE Name='WEG Customer Community Plus'];
        users.add(new User(Alias = 'standt1', Email='standarduser1@weg.com', EmailEncodingKey='UTF-8', LastName='User 1', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = port.Id,TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@weg.com', ContactId=con1.Id));
        users.add(new User(Alias = 'standt2', Email='standarduser2@weg.com', EmailEncodingKey='UTF-8', LastName='User 2', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = prof.Id,TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2@weg.com'));
        users.add(new User(Alias = 'standt3', Email='standarduser3@weg.com', EmailEncodingKey='UTF-8', LastName='User 3', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = prof.Id,TimeZoneSidKey='America/Los_Angeles', UserName='standarduser3@weg.com'));
        users.add(new User(Alias = 'standt4', Email='standarduser4@weg.com', EmailEncodingKey='UTF-8', LastName='User 4', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = prof.Id,TimeZoneSidKey='America/Los_Angeles', UserName='standarduser4@weg.com'));
        insert users;
        
        // Create Account Team Members
        list<AccountTeamMember> atmList = new list<AccountTeamMember>();
        atmList.add(new AccountTeamMember(AccountId=hhAcc.Id, userId=users[0].Id,AccountAccessLevel='Read', OpportunityAccessLevel='Read', CaseAccessLevel='Read', ContactAccessLevel='Read'));
        atmList.add(new AccountTeamMember(AccountId=indAcc.Id, userId=users[1].Id,AccountAccessLevel='Edit', OpportunityAccessLevel='Edit', CaseAccessLevel='Edit', ContactAccessLevel='Edit'));
        atmList.add(new AccountTeamMember(AccountId=busAcc.Id, userId=users[2].Id,AccountAccessLevel='Edit', OpportunityAccessLevel='Edit', CaseAccessLevel='Edit', ContactAccessLevel='Edit'));
        atmList.add(new AccountTeamMember(AccountId=indAcc2.Id, userId=users[2].Id,AccountAccessLevel='Edit', OpportunityAccessLevel='Edit', CaseAccessLevel='Edit', ContactAccessLevel='Edit'));
        insert atmList;
        
        
        // Link Individual and household account using ACR
        con1.Email='test@test123213123.com';
        update con1;
        wv6_EnableDisableUserController.enableCustomerUser(indAcc.Id);
        
        //Insert AccountAccountRelation record
        AccountContactRelation acr = new AccountContactRelation();
        acr.accountId = hhAcc.Id;
        acr.contactId = con1.Id;
        acr.FinServ__Primary__c = true;
        acr.FinServ__PrimaryGroup__c = true;
        acr.Roles='Client';
        insert acr;

        // Create Financial Accounts
        list<FinServ__FinancialAccount__c> faList = new list<FinServ__FinancialAccount__c>();
        faList.add(new FinServ__FinancialAccount__c(Name='Test FA 1',FinServ__Household__c = hhAcc.Id, FinServ__PrimaryOwner__c = indAcc.Id, FinServ__JointOwner__c=indAcc2.Id));
        insert faList;

        // Create Trade Requests
        Profile prof1 = [SELECT Id FROM Profile WHERE Name='Advisor'];
        User user = new User(Alias = 'advisor', Email='advisor@weg.com', EmailEncodingKey='UTF-8', LastName='User 4', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = prof1.Id,TimeZoneSidKey='America/Los_Angeles', UserName='advisor@weg.com');
        insert user;
        list<Trade_Request__c> trList = new list<Trade_Request__c>();
        trList.add(new Trade_Request__c(RecordTypeId=Schema.SObjectType.Trade_Request__c.getRecordTypeInfosByName().get('Additional Deposit').getRecordTypeId(),Status__c='New',WEGP1_Household__c= hhAcc.Id, WEGP1_Individual__c = indAcc.Id,WEGP1_FinancialAccount__c = faList[0].Id,Advisor__c = user.Id));
        trList.add(new Trade_Request__c(RecordTypeId=Schema.SObjectType.Trade_Request__c.getRecordTypeInfosByName().get('Additional Deposit').getRecordTypeId(),Status__c='New',WEGP1_Household__c= hhAcc.Id, WEGP1_Individual__c = indAcc.Id,WEGP1_FinancialAccount__c = faList[0].Id,Advisor__c = user.Id));
        insert trList;


        // Create Blot
        list<Blot__c> blotList = new list<Blot__c>();
        blotList.add(new Blot__c(WEGP1_BlotType__c='Plan',WEGP1_Status__c='New',WEGP1_Household__c= hhAcc.Id));
        insert blotList;
        
        // get and update User 1 to associate with Contact 1
        //User u1 = [SELECT Id, ContactId FROM User WHERE UserName = 'standarduser1@weg.com'];
        //u1.ContactId = con1.Id;
        //update u1;

        // Create Secure Message
        list<Secure_Messaging__c> smList = new list<Secure_Messaging__c>();
        smList.add(new Secure_Messaging__c(Name='Plan', contact__c = con1.Id,Household_Account__c= hhAcc.Id));
        insert smList;

        // Create Financial Goals
        list<FinServ__FinancialGoal__c> fgList = new list<FinServ__FinancialGoal__c>();
        fgList.add(new FinServ__FinancialGoal__c(Name='Test Financial Goal', FinServ__Household__c=hhAcc.Id, FinServ__PrimaryOwner__c=indAcc.Id));
        insert fgList;

        // Create Plan Review & Requests
        list<Plan_Review_Request__c> prrList = new list<Plan_Review_Request__c>();
        prrList.add(new Plan_Review_Request__c(Name='Test PRR 1', WEGP1_Household__c =hhAcc.Id , WEGP1_Individual__c = indAcc.Id));
        insert prrList;

        // Create Cloud Files
        list<TVA_CFB__Cloud_Files__c> cfList = new list<TVA_CFB__Cloud_Files__c>();
        cfList.add(new TVA_CFB__Cloud_Files__c(Name='Test File 1', WEGP1_Household__c = hhAcc.Id,WEGP1_FinancialAccount__c = faList[0].Id));
        cfList.add(new TVA_CFB__Cloud_Files__c(Name='Test File 2', Business__c = busAcc.Id));
        cfList.add(new TVA_CFB__Cloud_Files__c(Name='Test File 3', WEGP1PrimaryIndividual__c = IndAcc.Id));
        insert cfList;

        // Create Assets and Liabilities
        //list<FinServ__AssetsAndLiabilities__c> alList = new list<FinServ__AssetsAndLiabilities__c>();
        //Account acc = new Account(Name='Bus Account1', recordTypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('Business').getRecordTypeId(), WEGP1_AccountTeamIds__c='00541000002n7rwAAA:Read; 00541000002oBBkAAM:Edit; 00541000002nbpDAAQ:Edit');
        //insert acc;

        //alList.add(new FinServ__AssetsAndLiabilities__c(Name='Test Asset 1', FinServ__Household__c = hhAcc.Id , FinServ__PrimaryOwner__c = indAcc.Id, FinServ__JointOwner__c=indAcc2.Id));
        //insert alList;
    }

    @isTest static void Wave6_WEGAccountSharingBatchTest1() {
        // 
        test.startTest();
        
        Wave6_WEGAccountSharingBatch batchclass = new Wave6_WEGAccountSharingBatch(false);
        Database.executeBatch(batchClass, 4);
        
        list<FinServ__FinancialAccount__Share> faSharingRecords = [Select Id From FinServ__FinancialAccount__Share Where RowCause IN ('Household_Account_Team__c','Primary_Owner_Account_Team__c','Joint_Owner_Account_Team__c')];
        
        //system.assertEquals(1, faSharingRecords.size());
        
        test.stopTest();
    }
    
    @isTest static void Wave6_WEGAccountSharingBatchTest16() {
        //createTestData();
        test.startTest();
        Wave6_WEGAccountSharingBatch batchclass = new Wave6_WEGAccountSharingBatch(false);
        Database.executeBatch(batchClass,4);
        
        list<AccountShare> accSharingRecords = [Select Id From AccountShare Where RowCause IN('Manual')];
        system.assertEquals(0, accSharingRecords.size());
        test.stopTest();
    }
    
    @isTest static void Wave6_WEGAccountSharingBatchTest17() {
        //createTestData();
        test.startTest();
        Wave6_WEGAccountSharingBatch batchclass = new Wave6_WEGAccountSharingBatch(false);
        Database.executeBatch(batchClass,4);
        
        list<Blot__Share> blotSharingRecords = [ Select Id From Blot__Share Where RowCause IN('Household_Account_Team__c') ];
        system.assertEquals(1, blotSharingRecords.size());
        test.stopTest();
    }
    
    @isTest static void Wave6_WEGAccountSharingBatchTest11() {
        //createTestData();
        test.startTest();
        Wave6_WEGAccountSharingBatch batchclass = new Wave6_WEGAccountSharingBatch(false);
        Database.executeBatch(batchClass,4);
        
        //list<FinServ__AssetsAndLiabilities__Share> alSharingRecords = [ Select Id From FinServ__AssetsAndLiabilities__Share Where RowCause IN('Household_Account_Team__c','Primary_Owner_Account_Team__c','Joint_Owner_Account_Team__c')];
        //system.assertEquals(3, alSharingRecords.size());
        test.stopTest();
    }
    
    @isTest static void Wave6_WEGAccountSharingBatchTest12() {
        //createTestData();
        test.startTest();
        Wave6_WEGAccountSharingBatch batchclass = new Wave6_WEGAccountSharingBatch(false);
        Database.executeBatch(batchClass,4);
        
        list<Trade_Request__Share> trSharingRecords = [ Select Id From Trade_Request__Share Where RowCause IN('Household_Account_Team__c','Individual_Account_Team__c') ];
      //  system.assertEquals(4, trSharingRecords.size());
        test.stopTest();
    }
    
    @isTest static void Wave6_WEGAccountSharingBatchTest13() {
        //createTestData();
        test.startTest();
        Wave6_WEGAccountSharingBatch batchclass = new Wave6_WEGAccountSharingBatch(false);
        Database.executeBatch(batchClass,4);
        
        list<Plan_Review_Request__Share> prrSharingRecords = [Select Id From Plan_Review_Request__Share Where RowCause IN('Household_Account_Team__c','Individual_Account_Team__c') ];
        system.assertEquals(2, prrSharingRecords.size());
        test.stopTest();
    }
    
    @isTest static void Wave6_WEGAccountSharingBatchTest14() {
        //createTestData();
        test.startTest();
        Wave6_WEGAccountSharingBatch batchclass = new Wave6_WEGAccountSharingBatch(false);
        Database.executeBatch(batchClass,4);
        
        list<TVA_CFB__Cloud_Files__Share> cfSharingRecords = [Select Id From TVA_CFB__Cloud_Files__Share Where RowCause IN('Household_Account_Team__c','Primary_Owner_Account_Team__c','Joint_Owner_Account_Team__c','Business_Account_Team__c') ];
        //system.assertEquals(3, cfSharingRecords.size());
        test.stopTest();
    }
    
    @isTest static void Wave6_WEGAccountSharingBatchTest15() {
        //createTestData();
        test.startTest();
        Wave6_WEGAccountSharingBatch batchclass = new Wave6_WEGAccountSharingBatch(false);
        Database.executeBatch(batchClass,4);
        
        list<FinServ__FinancialGoal__Share> fgSharingRecords = [Select Id From FinServ__FinancialGoal__Share Where RowCause IN('Household_Account_Team__c','Primary_Owner_Account_Team__c')];
        system.assertEquals(2, fgSharingRecords.size());
        test.stopTest();
    }

    @isTest static void Wave6_WEGAccountSharingBatchTest2() {
        //createTestData();
        test.startTest();
        Wave6_WEGAccountSharingBatch batchclass = new Wave6_WEGAccountSharingBatch(true);
        Database.executeBatch(batchClass,5);
        

        list<FinServ__FinancialAccount__Share> faSharingRecords = [Select Id From FinServ__FinancialAccount__Share Where RowCause IN ('Household_Account_Team__c','Primary_Owner_Account_Team__c','Joint_Owner_Account_Team__c')];
        //list<FinServ__AssetsAndLiabilities__Share> alSharingRecords = [ Select Id From FinServ__AssetsAndLiabilities__Share Where RowCause IN('Household_Account_Team__c','Primary_Owner_Account_Team__c','Joint_Owner_Account_Team__c')];
        list<Trade_Request__Share> trSharingRecords = [ Select Id From Trade_Request__Share Where RowCause IN('Household_Account_Team__c','Individual_Account_Team__c') ];
        list<Plan_Review_Request__Share> prrSharingRecords = [Select Id From Plan_Review_Request__Share Where RowCause IN('Household_Account_Team__c','Individual_Account_Team__c') ];
        list<TVA_CFB__Cloud_Files__Share> cfSharingRecords = [Select Id From TVA_CFB__Cloud_Files__Share Where RowCause IN('Household_Account_Team__c','Primary_Owner_Account_Team__c','Joint_Owner_Account_Team__c','Business_Account_Team__c') ];
        list<FinServ__FinancialGoal__Share> fgSharingRecords = [Select Id From FinServ__FinancialGoal__Share Where RowCause IN('Household_Account_Team__c','Primary_Owner_Account_Team__c')];
        list<AccountShare> accSharingRecords = [Select Id From AccountShare Where RowCause IN('Manual')];
        list<Blot__Share> blotSharingRecords = [ Select Id From Blot__Share Where RowCause IN('Household_Account_Team__c') ];
        test.stopTest();
        
        //system.assertEquals(1, faSharingRecords.size());
        
        //system.assertEquals(3, alSharingRecords.size());
        system.assertEquals(2, fgSharingRecords.size());
      //  system.assertEquals(4, trSharingRecords.size());
        system.assertEquals(2, prrSharingRecords.size());
        //system.assertEquals(6, cfSharingRecords.size());
       // system.assertEquals(1, accSharingRecords.size());
        //system.assertEquals(1, blotSharingRecords.size());


    }

    @isTest static void Wave6_WEGAccountSharingControllerTest() {
        //createTestData();
        test.startTest();
        Account hhAcc = [Select Id From Account Where recordTypeId !=: Schema.SObjectType.account.getRecordTypeInfosByName().get('Household').getRecordTypeId() limit 1];
        List<Account> indAccList = [Select Id From Account Where recordTypeId !=: Schema.SObjectType.account.getRecordTypeInfosByName().get('Individual').getRecordTypeId() limit 2];
        Account busAcc = [Select Id From Account Where recordTypeId !=: Schema.SObjectType.account.getRecordTypeInfosByName().get('Business').getRecordTypeId() limit 1];
        
        Wave6_WEGAccountSharingController.recalculateSharing(hhAcc.Id);
        //Wave6_WEGAccountSharingController.recalculateSharing(indAccList[0].Id);
        //Wave6_WEGAccountSharingController.recalculateSharing(indAccList[1].Id);
        Wave6_WEGAccountSharingController.recalculateSharing(busAcc.Id);

        AccountTeamMember atm = [Select Id, AccountAccessLevel From AccountTeamMember limit 1];
        atm.AccountAccessLevel = 'Edit';

        // Recalculate sharing after Account Team Member update
        Wave6_WEGAccountSharingController.recalculateSharing(hhAcc.Id);
        //Wave6_WEGAccountSharingController.recalculateSharing(indAccList[0].Id);
        //Wave6_WEGAccountSharingController.recalculateSharing(indAccList[1].Id);
        Wave6_WEGAccountSharingController.recalculateSharing(busAcc.Id);

        

        list<FinServ__FinancialAccount__Share> faSharingRecords = [Select Id From FinServ__FinancialAccount__Share Where RowCause IN ('Household_Account_Team__c','Primary_Owner_Account_Team__c','Joint_Owner_Account_Team__c')];
        //list<FinServ__AssetsAndLiabilities__Share> alSharingRecords = [ Select Id From FinServ__AssetsAndLiabilities__Share Where RowCause IN('Household_Account_Team__c','Primary_Owner_Account_Team__c','Joint_Owner_Account_Team__c')];
        list<Trade_Request__Share> trSharingRecords = [ Select Id From Trade_Request__Share Where RowCause IN('Household_Account_Team__c','Individual_Account_Team__c') ];
        list<Plan_Review_Request__Share> prrSharingRecords = [Select Id From Plan_Review_Request__Share Where RowCause IN('Household_Account_Team__c','Individual_Account_Team__c') ];
        list<TVA_CFB__Cloud_Files__Share> cfSharingRecords = [Select Id From TVA_CFB__Cloud_Files__Share Where RowCause IN('Household_Account_Team__c','Primary_Owner_Account_Team__c','Joint_Owner_Account_Team__c','Business_Account_Team__c') ];
        list<FinServ__FinancialGoal__Share> fgSharingRecords = [Select Id From FinServ__FinancialGoal__Share Where RowCause IN('Household_Account_Team__c','Primary_Owner_Account_Team__c')];
        list<AccountShare> accSharingRecords = [Select Id From AccountShare Where RowCause IN('Manual')];
        list<Blot__Share> blotSharingRecords = [ Select Id From Blot__Share Where RowCause IN('Household_Account_Team__c') ];
        
        // Validate Data
        system.assertEquals(1, faSharingRecords.size());
        //system.assertEquals(3, alSharingRecords.size());
        system.assertEquals(2, fgSharingRecords.size());
    //    system.assertEquals(4, trSharingRecords.size());
        system.assertEquals(2, prrSharingRecords.size());
        //system.assertEquals(6, cfSharingRecords.size());
        system.assertEquals(1, accSharingRecords.size());
        system.assertEquals(1, blotSharingRecords.size());


        // Remove Individual Account from both trade requests
        list<Trade_Request__c> trList = [Select Id, WEGP1_Individual__c From Trade_Request__c Limit 2];
        trList[0].WEGP1_Individual__c = null;
        trList[1].WEGP1_Individual__c = null;
        update trList;

        // Validate Data
        trSharingRecords = new list<Trade_Request__Share>();
        trSharingRecords = [ Select Id From Trade_Request__Share Where RowCause IN('Household_Account_Team__c','Individual_Account_Team__c') ];
        system.assertEquals(2, trSharingRecords.size());
        test.stopTest();
    }


    @isTest static void Wave6_WEGAccountSharingControllerTest2() {    
        test.startTest();
        list<Plan_Review_Request__c> prrList = [Select Id, Name, WEGP1_Household__c , WEGP1_Individual__c From Plan_Review_Request__c Limit 1];
        
        Wave6_WEGAccountSharingController.recalculateSharing(prrList[0].Id);
        // Validate Data
        List<Secure_Messaging__Share> smSharingRecords = new list<Secure_Messaging__Share>();
        smSharingRecords = [ Select Id From Secure_Messaging__Share Where RowCause IN('Household_Account_Team__c') ];
        test.stopTest();
        system.assertEquals(1, smSharingRecords.size());
     }
     
     @isTest static void Wave6_WEGAccountSharingControllerTest21() {  
        test.startTest();
         list<Secure_Messaging__c> smList = [Select Id, Name, Household_Account__c From Secure_Messaging__c Limit 1];
        
        Wave6_WEGAccountSharingController.recalculateSharing(smList[0].Id);
         
        test.stopTest();
        Wave6_WEGAccountSharingDeletes sh1 = new Wave6_WEGAccountSharingDeletes();
        String sch = '0  00 1 3 * ?';
        system.schedule('Test', sch, sh1);

     }
     
     @isTest static void Wave6_WEGAccountSharingControllerTest22() {  
       test.startTest();
         list<Trade_Request__c> trList = [Select Id, WEGP1_Individual__c From Trade_Request__c Limit 2];
        
        Wave6_WEGAccountSharingController.recalculateSharing(trList[0].Id);
        test.stopTest();
        Wave6_WEGAccountSharingUpdate sh1 = new Wave6_WEGAccountSharingUpdate();
        String sch = '0  00 1 3 * ?';
        system.schedule('Test', sch, sh1);
     }
 

    @isTest static void  Wave6_WEGAccountSharingUpdateTest(){
        Test.startTest();

         //Create Household Accounts
        list<Account> accountList = new list<Account>();
        accountList.add(new Account(Name='HH Account1', recordTypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('Household').getRecordTypeId(), WEGP1_AccountTeamIds__c='00541000002n7rwAAA:Read; 00541000002oBBkAAM:Edit; 00541000002nbpDAAQ:Edit'));
        insert accountList;

        // Create Test users
        list<User>users = new list<User>();
        Profile prof = [SELECT Id FROM Profile WHERE Name='Standard User'];
        users.add(new User(Alias = 'standt1', Email='standarduser112@weg.com', EmailEncodingKey='UTF-8', LastName='User 1', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = prof.Id,TimeZoneSidKey='America/Los_Angeles', UserName='standarduser112@weg.com'));
        users.add(new User(Alias = 'standt2', Email='standarduser212@weg.com', EmailEncodingKey='UTF-8', LastName='User 2', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = prof.Id,TimeZoneSidKey='America/Los_Angeles', UserName='standarduser212@weg.com'));
        insert users;

        // Create Account Team Members
        list<AccountTeamMember> atmList = new list<AccountTeamMember>();
        atmList.add(new AccountTeamMember(AccountId=accountList[0].Id, userId=users[0].Id,AccountAccessLevel='Read', OpportunityAccessLevel='Read', CaseAccessLevel='Read', ContactAccessLevel='Read'));
        atmList.add(new AccountTeamMember(AccountId=accountList[0].Id, userId=users[1].Id,AccountAccessLevel='Read', OpportunityAccessLevel='Read', CaseAccessLevel='Read', ContactAccessLevel='Read'));
        insert atmList;

        // Create Plan Review & Requests
        list<Plan_Review_Request__c> prrList = new list<Plan_Review_Request__c>();
        prrList.add(new Plan_Review_Request__c(Name='Test PRR 1', WEGP1_Household__c =accountList[0].Id ));
        insert prrList;

        Wave6_WEGAccountSharingController.recalculateSharing(accountList[0].Id);

        atmList[0].AccountAccessLevel = 'Edit';
        update atmList[0];
        
       Test.stopTest();
    }

    @isTest static void  Wave6_WEGAccountSharingDeletesTest(){
        Test.startTest();

        //Create Household Accounts
        list<Account> accountList = new list<Account>();
        accountList.add(new Account(Name='HH Account1', recordTypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('Household').getRecordTypeId(), WEGP1_AccountTeamIds__c='00541000002n7rwAAA:Read; 00541000002oBBkAAM:Edit; 00541000002nbpDAAQ:Edit'));
        insert accountList;

        // Create Test users
        list<User>users = new list<User>();
        Profile prof = [SELECT Id FROM Profile WHERE Name='Standard User'];
        users.add(new User(Alias = 'standt1', Email='standarduser112@weg.com', EmailEncodingKey='UTF-8', LastName='User 1', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = prof.Id,TimeZoneSidKey='America/Los_Angeles', UserName='standarduser13123@weg.com'));
        users.add(new User(Alias = 'standt2', Email='standarduser2123@weg.com', EmailEncodingKey='UTF-8', LastName='User 2', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = prof.Id,TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2123123@weg.com'));
        insert users;

        // Create Account Team Members
        list<AccountTeamMember> atmList = new list<AccountTeamMember>();
        atmList.add(new AccountTeamMember(AccountId=accountList[0].Id, userId=users[0].Id,AccountAccessLevel='Read', OpportunityAccessLevel='Read', CaseAccessLevel='Read', ContactAccessLevel='Read'));
        atmList.add(new AccountTeamMember(AccountId=accountList[0].Id, userId=users[1].Id,AccountAccessLevel='Read', OpportunityAccessLevel='Read', CaseAccessLevel='Read', ContactAccessLevel='Read'));
        insert atmList;

        // Create Plan Review & Requests
        list<Plan_Review_Request__c> prrList = new list<Plan_Review_Request__c>();
        prrList.add(new Plan_Review_Request__c(Name='Test PRR 1', WEGP1_Household__c =accountList[0].Id ));
        insert prrList;

        Wave6_WEGAccountSharingController.recalculateSharing(accountList[0].Id);
        
        Test.stopTest();
    }
    
   
}