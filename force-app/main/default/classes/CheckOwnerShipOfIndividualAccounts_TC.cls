@istest
public class CheckOwnerShipOfIndividualAccounts_TC{
    static testMethod void Check(){
        
        Profile advProf = [SELECT ID, Name FROM Profile WHERE Name = 'Advisor' LIMIT 1];
        Profile adminProf = [SELECT ID, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        ID rectypid = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        
        User advUser = new User(     
             LastName = 'Adv',
             Email = 'advUser001@amamama.com',
             Username = 'advUser001@amamama.com' + System.currentTimeMillis(),
             CompanyName = 'Adv',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US',
             profileid = advProf.Id
        );
        insert advUser;
        
        User adminUser = new User(     
             LastName = 'Admin',
             Email = 'adminUser001@amamama.com',
             Username = 'adminUser001@amamama.com' + System.currentTimeMillis(),
             CompanyName = 'Admin',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US',
             profileid = adminProf.Id
        );
        insert adminUser;
        
        system.runAs(adminUser) {
            Account acc1 = New Account();
            acc1.Name = 'test';
            acc1.OwnerId = advUser.Id;
            insert acc1;
        
        //system.runAs(adminUser) {
            Account testacc = new Account();
            testacc.name = 'test';
            testacc.recordtypeid = rectypid; 
            testacc.WEGP1_Primary_Household__c = acc1.id;
            testacc.OwnerId = adminUser.Id;
            insert testacc; 
        //}
        
            Test.startTest(); 
            
            CheckOwnerShipOfIndividualAccounts obj = new CheckOwnerShipOfIndividualAccounts();
            database.executebatch(obj);           
            
            Test.stopTest();
        }
    }    
        
}