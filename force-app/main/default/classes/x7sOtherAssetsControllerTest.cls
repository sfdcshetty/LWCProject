@IsTest
public class x7sOtherAssetsControllerTest {
	@IsTest
    public static void getOtherAssetsDetailsTest(){
           
        RecordType recType = [SELECT Id, Name, DeveloperName FROM RecordType 
                              Where Name = 'Asset' Limit 1]; 
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
		system.debug('portalRole is ' + portalRole);

        Profile profile1 = [Select Id from Profile where name = 'System Administrator' Limit 1];
        
        User portalAccountOwner1 = new User(
                                            UserRoleId = portalRole.Id,
                                            ProfileId = profile1.Id,
                                            Username = System.now().millisecond() + 'test21@test.com',
                                            Alias = 'test',
                                            Email='bruce.wayne11@wayneenterprises.com',
                                            EmailEncodingKey='UTF-8',
                                            Firstname='Bruce',
                                            Lastname='Wayne',
                                            LanguageLocaleKey='en_US',
                                            LocaleSidKey='en_US',
                                            TimeZoneSidKey='America/Chicago'
                                            );
        Database.insert(portalAccountOwner1);

		//User u1 = [Select ID From User Where Id =: portalAccountOwner1.Id];
		Account portalAccount1, houseHoldAccount1;
        User user1;
        System.runAs (portalAccountOwner1) {
            
            houseHoldAccount1 = new Account(
                        Name = 'TestAccount',
                        OwnerId = portalAccountOwner1.Id
                        );
            Database.insert(houseHoldAccount1);
            
            //Create account
            portalAccount1 = new Account(
                        Name = 'TestAccount',
                        OwnerId = portalAccountOwner1.Id,
                		WEGP1_Primary_Household__c = houseHoldAccount1.Id);
            Database.insert(portalAccount1);
            
            String otherAssetInfo = '{"Type":"Bonus","OwnerId":"'+portalAccount1.Id+'","OwnerName":"","Account":"Test Bonus","AsOfDate":"2021-06-01","Amount":"03000"}';
            String otherAssetInfo2 = '{"Type":"Bonus","OwnerId":"Joint","OwnerName":"","Account":"Test Bonus","AsOfDate":"2021-06-01","Amount":"03000"}';

            //Create contact
            Contact contact1 = new Contact(
                                FirstName = 'Test',
                                Lastname = 'McTesty',
                                AccountId = portalAccount1.Id,
                                Email = System.now().millisecond() + 'test@test.com'
            );
            Database.insert(contact1);

            //Create user
            //Profile portalProfile = [SELECT Id FROM Profile Limit 1];
            
            Profile profile2 = [Select Id from Profile where name = 'WEG Customer Community Plus' Limit 1];
            user1 = new User(Username = System.now().millisecond() + 'test12345@test.com',
                                    ContactId = contact1.Id,
                                    ProfileId = profile2.Id,
                                    Alias = 'test123',
                                    Email = 'test12345@test.com',
                                    EmailEncodingKey = 'UTF-8',
                                    LastName = 'McTesty',
                                    CommunityNickname = 'test12345',
                                    TimeZoneSidKey = 'America/Los_Angeles',
                                    LocaleSidKey = 'en_US',
                                    LanguageLocaleKey = 'en_US');
                Database.insert(user1);
        }
        
        System.runAs (user1) {
            
            //Create Investment Account 
            FinServ__AssetsAndLiabilities__c otherAsset = new FinServ__AssetsAndLiabilities__c(Name = 'Test Investment Account',
                                                                               FinServ__AssetsAndLiabilitiesType__c = 'Personal Loan',
                                                                               FinServ__PrimaryOwner__c = portalAccount1.Id,
                                                                              FinServ__Household__c = houseHoldAccount1.Id,
                                                                              RecordTypeId = recType.Id,
                                                                              Remove_or_Historic__c = '');
            
            Database.insert(otherAsset);
            List<FinServ__AssetsAndLiabilities__c> listAss = [SELECT Name,FinServ__AssetsAndLiabilitiesType__c,FinServ__Household__c,RecordTypeId From FinServ__AssetsAndLiabilities__c];
            system.debug('riddhi listAss = '+listAss[0].FinServ__Household__c);
            
            String otherAssetInfo = '{"Type":"Bonus","OwnerId":"'+portalAccount1.Id+'","OwnerName":"","Account":"'+portalAccount1.Id+'","AsOfDate":"2021-06-01","Amount":"03000"}';
        	String otherAssetInfo2 = '{"Type":"Bonus","OwnerId":"Joint","OwnerName":"","Account":"Test Bonus","AsOfDate":"2021-06-01","Amount":"03000"}';
            
            String updatedOtherAssetInfo = '{"Type":"Collection","OwnerId":"'+portalAccount1.Id+'","OwnerName":"","Account":"'+portalAccount1.Id+'","AsOfDate":"2021-06-02","Amount":"05200"}';
            String updatedOtherAssetInfo2 = '{"Type":"Collection","OwnerId":"Joint","OwnerName":"","Account":"Collection","AsOfDate":"2021-06-02","Amount":"05200"}';

            
            Test.startTest();
            x7sOtherAssetsController.getOtherAssetsDetails(portalAccount1.Id);
            x7sOtherAssetsController.addOtherAsset(portalAccount1.Id, otherAssetInfo2);
            x7sOtherAssetsController.addOtherAsset(portalAccount1.Id, otherAssetInfo);
            FinServ__AssetsAndLiabilities__c pro = [Select Id, Name 
                                                    From FinServ__AssetsAndLiabilities__c 
                                                    Where Name = 'Test Investment Account' LIMIT 1];
             x7sOtherAssetsController.editOtherAsset(pro.Id, portalAccount1.Id, updatedOtherAssetInfo2);
            x7sOtherAssetsController.editOtherAsset(pro.Id, portalAccount1.Id, updatedOtherAssetInfo);
            //x7sOtherAssetsController.getOtherAssetsOwnerList(portalAccount1.Id);
            x7sOtherAssetsController.getOtherAssetsOwnerList(houseHoldAccount1.Id);
            x7sOtherAssetsController.getAccountType();
            //system.assertEquals(1, lstFA.size());
            Test.stopTest(); 
        }
    }
    
    @IsTest
    public static void getAccountTypeTest(){
        
        Test.startTest();
        x7sOtherAssetsController.getAccountType();
        Test.stopTest(); 
    }
}