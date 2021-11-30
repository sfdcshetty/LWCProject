@isTest
public class CheckOwnerShipofFinacc_TC{
    static testMethod void check(){
        
        profile p = [Select ID,Name from Profile where Name =:System.label.Profile_name];
        User u = [Select id,profileid from user where profileid =: p.id and isactive = true limit 1];
        
        User usr = new User(LastName = 'Bhardwaj',
            FirstName='Pranav',
            Alias = 'pbhar',
            Email = 'Pranav.Bhardwaj@asdf.com',
            Username = 'Pranav.Bhardwaj@asdf.com',
            ProfileId = p.id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
            );
        
        Account household = new Account();
            household.Name = 'test';
            household.ownerid = u.id;
            household.recordtypeid = '012410000012tm4';
        insert household;
    
        FinServ__FinancialAccount__c finacc = New FinServ__FinancialAccount__c();
            finacc.Name = 'test';
            finacc.FinServ__Household__c = household.id;         
            finacc.FinServ__PrimaryOwner__c = household.id;   
        insert finacc;
        Update finacc;
        
        CheckOwnerShipOfFinancialAccounts obj = new CheckOwnerShipOfFinancialAccounts ();
            Database.executebatch(obj);
    
    }
    static testMethod void check2(){
        
        profile p = [Select ID,Name from Profile where Name =:System.label.Profile_name];
        User u = [Select id,profileid from user where profileid =: p.id and isactive = true limit 1];
        
         Account household = new Account();
            household.Name = 'test';
            //household.ownerid = u.id;
            household.recordtypeid = '012410000012tm4';
        insert household;
    
        FinServ__FinancialAccount__c finacc = New FinServ__FinancialAccount__c();
            finacc.Name = 'test';
            finacc.FinServ__PrimaryOwner__c = household.id;
            //finacc.FinServ__PrimaryOwner__r.Owner.Profile.Name = System.Label.Profile_Name;
            //finacc.ownerid = household.ownerid;
        insert finacc;
        Update finacc;
        
        
        CheckOwnerShipOfFinancialAccounts obj = new CheckOwnerShipOfFinancialAccounts ();
            Database.executebatch(obj);
    }
}