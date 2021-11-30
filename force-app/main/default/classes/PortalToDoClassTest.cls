/**
 * Created by 7Summits on 6/1/21.
 */

@IsTest
private class PortalToDoClassTest {
    @IsTest
    static void testToDo() {
        List<ToDo__c> todoList = PortalToDoClass.getTodos();

        User testUser = [Select Id From User Where Email ='test12345portaltdo@testuser1.com'];
        Test.startTest();
        System.runAs(testUser){
            todoList = PortalToDoClass.getTodos();
            PortalToDoClass.updateTodo(todoList[0].Id, true);
            todoList = PortalToDoClass.getTodos();
            PortalToDoClass.updateTodo(todoList[0].Id, false);
        }
        Test.stopTest();
    }
    
    @testSetup
    public static void setup() {
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
		system.debug('portalRole is ' + portalRole);

        Profile profile1 = [Select Id from Profile where name = 'System Administrator' Limit 1];
        
        User portalAccountOwner1 = new User(
                                            UserRoleId = portalRole.Id,
                                            ProfileId = profile1.Id,
                                            Username = System.now().millisecond() + 'testportaltoso@test.com',
                                            Alias = 'test',
                                            Email='bruce.testportaltoso@portalAccountOwner1.com',
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
            primaryCon.LastName = 'Test Contact';
            primaryCon.WEG_PortalUser__c = portalAccountOwner1.Id;
            primaryCon.RecordTypeId =  Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
            insert primaryCon;

            //Create account
        	Account houseAcc = new Account();
            houseAcc.name = 'Test Account';
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
            houseAcc.WEGP1_Primary_Individual__c = primaryCon.Id;
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
            acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
            acc.WEGP1_Primary_Household__c = houseAcc.Id;
            acc.WEGP1_Primary_Individual__c = primaryCon.Id;
            insert acc;

            // Create Test Contact
            Contact con = new Contact();
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
            insert con;
            
            ToDo__c newTodo = new ToDo__c();
            //newTodo.Assigned_To_Individual__c = con.Id;
            newTodo.Assigned_To_Individual__c = primaryCon.Id;
            insert newTodo;

            //Create user
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'WEG Customer Community Plus' Limit 1];
            
            User user1 = new User(Username = System.now().millisecond() + 'test12345@test.com',
                                    ContactId = con.Id,
                                    ProfileId = portalProfile.Id,
                                    Alias = 'test123',
                                    Email = 'test12345portaltdo@testuser1.com',
                                    EmailEncodingKey = 'UTF-8',
                                    LastName = 'McTesty',
                                    CommunityNickname = 'test12345',
                                    TimeZoneSidKey = 'America/Los_Angeles',
                                    LocaleSidKey = 'en_US',
                                    LanguageLocaleKey = 'en_US',
                                    Photo_URL__c = '/clientportal/profilephoto/005/M');
           	Database.insert(user1);
            
        }
    }
}