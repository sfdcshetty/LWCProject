@istest
public class CheckOwnerShipOfAssetAndLiabilities_TC{
    static testMethod void method1() {
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        String testLbl = Label.Profile_name;
        Profile p = [SELECT Id FROM Profile WHERE Name=: testLbl]; 
        User u = new User(
            email='coAssetAndLiab@wealthenhancement.com',
            profileid = p.id,
            UserName='coAssetAndLiab@wealthenhancement.com',
            alias='coAAL',
            CommunityNickName='coAAL',
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='ISO-8859-1',
            LanguageLocaleKey='en_US',
            FirstName = 'User',
            LastName = 'Test');
        insert u;
        
        system.runAs(u) {
            Account acc = New Account ();
            acc.recordTypeId = accRecordTypeId;
            acc.Name = 'testAccount';
            acc.owner = u;
            insert acc;
            FinServ__AssetsAndLiabilities__c assetsAndLiabilities = New FinServ__AssetsAndLiabilities__c ();
            assetsAndLiabilities.Name = 'test';
            assetsAndLiabilities.FinServ__PrimaryOwner__c = acc.id;
            assetsAndLiabilities.FinServ__Household__c = acc.id;            
            insert assetsAndLiabilities;
            CheckOwnerShipOfAssetAndLiabilities x = new CheckOwnerShipOfAssetAndLiabilities();
            database.executeBatch(x);
        }
    }
}