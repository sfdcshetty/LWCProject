@isTest
public class UpdateSecondaryOwner_Test {
    public static testMethod void method1 () {
         TVA_CFB__Cloud_Files_Region_Endpoints__c regionEnd = new TVA_CFB__Cloud_Files_Region_Endpoints__c();
            regionEnd.Name = 'us-east-1';
            regionEnd.TVA_CFB__Endpoint_URL__c = 'https://s3.amazonaws.com';
            insert regionEnd;
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        User u1 = [Select ID From User Where Id =:userInfo.getUserID()];
        System.runAs ( u1) {   
           
             
            Profile profile1 = [Select Id from Profile where name = 'System administrator'];
            User portalAccountOwner1 = new User(
                UserRoleId = portalRole.Id,
                ProfileId = profile1.Id,
                Username = System.now().millisecond() + 'test2@test.com',
                Alias = 'batman',
                Email='bruce.wayne@wayneenterprises.com',
                EmailEncodingKey='UTF-8',
                Firstname='Bruce',
                Lastname='Wayne',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                TimeZoneSidKey='America/Chicago'
            );
            Database.insert(portalAccountOwner1);
            //Create account
            Id accRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
            Account portalAccount1 = new Account(
                Name = 'TestAccount',
                RecordTypeId = accRecId,
                OwnerId = portalAccountOwner1.Id
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
            
            Document__c doc = New Document__c ();
            doc.Account__c = portalAccount1.id;
            insert doc;
            
            TVA_CFB__Cloud_Files__c cloudFile = New TVA_CFB__Cloud_Files__c ();
            cloudFile.Name = 'test.jpg';
            cloudFile.Portal_Document__c = doc.id;
            cloudFile.TVA_CFB__File_Type__c = 'jpg';
            cloudFile.TVA_CFB__File_Size_in_Bytes__c = 123;
            cloudFile.TVA_CFB__Parent_ID__c = doc.id;
            cloudFile.TVA_CFB__Region__c = 'us-east-1';
            insert cloudFile;
            
            //Create user
            Profile portalProfile = [SELECT Id FROM Profile where name Like '%WEG Customer Community Plus%' Limit 1];
            User user1 = new User(
                Username = System.now().millisecond() + 'test12345@test.com',
                ContactId = contact1.Id,
                ProfileId = portalProfile.Id,
                Alias = 'test123',
                Email = 'test12345@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'McTesty',
                IsActive = false,
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            Database.insert(user1);
            user1.IsActive = true;
            database.update(user1);
        }
        
    }
}