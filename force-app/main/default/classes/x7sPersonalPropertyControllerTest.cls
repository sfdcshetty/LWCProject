@IsTest
public class x7sPersonalPropertyControllerTest {
    
    @IsTest
    public static void getPersonalPropertyDetailsTest(){
        
       
           
        RecordType recType = [SELECT Id, Name, DeveloperName FROM RecordType 
                              Where Name = 'Asset' Limit 1]; 
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
		system.debug('portalRole is ' + portalRole);

        Profile profile1 = [Select Id from Profile where name = 'System Administrator' Limit 1];
        
        User portalAccountOwner1 = new User(
                                            UserRoleId = portalRole.Id,
                                            ProfileId = profile1.Id,
                                            Username = System.now().millisecond() + 'test2@personalProperty.com',
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
            
            Account ownerAcc = new Account(
                        Name = 'TestAccount1',
                        OwnerId = portalAccountOwner1.Id,
                		WEGP1_Primary_Household__c = houseHoldAccount1.Id);
            Database.insert(ownerAcc);
            
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
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'WEG Customer Community Plus' Limit 1];
            
            User user1 = new User(Username = System.now().millisecond() + 'test12345@personalProperty.com',
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
            
            String ownerId = '"' + ownerAcc.Id + '"';
            String propertyInfo = '{"Name":"Test property","Type":"Real Estate - Personal","Owner":' + ownerId + ',"Amount":"100.00"}';
        
        	String editPropertyInfo = '{"Name":"Test property 1","Type":"Real Estate - Personal","Owner":' + ownerId + ',"Amount":"200.00"}';
            
            //Create Investment Account 
            FinServ__AssetsAndLiabilities__c property = new FinServ__AssetsAndLiabilities__c(Name = 'Test Investment Account',
                                                                               FinServ__AssetsAndLiabilitiesType__c = 'Automobile',
                                                                               FinServ__PrimaryOwner__c = portalAccount1.Id,
                                                                              FinServ__Household__c = houseHoldAccount1.Id,
                                                                              RecordTypeId = recType.Id,
                                                                              Remove_or_Historic__c = '');
            
            Database.insert(property);
            
            Test.startTest();
            x7sPersonalPropertyController.getPersonalPropertyDetails(portalAccount1.Id);
            x7sPersonalPropertyController.addProperty(portalAccount1.Id, propertyInfo);
            FinServ__AssetsAndLiabilities__c pro = [Select Id, Name 
                                                    From FinServ__AssetsAndLiabilities__c 
                                                    Where Name = 'Test property' LIMIT 1];
            
            x7sPersonalPropertyController.editProperty(pro.Id,portalAccount1.Id, editPropertyInfo);
            //system.assertEquals(1, lstFA.size());
            Test.stopTest(); 
        }
    }
    
    @IsTest
    public static void getPropertyTypeTest(){
        
        Test.startTest();
        x7sPersonalPropertyController.getPropertyType();
        Test.stopTest(); 
    }

}