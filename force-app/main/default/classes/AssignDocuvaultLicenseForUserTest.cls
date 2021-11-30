@isTest
public class AssignDocuvaultLicenseForUserTest{

    public static testMethod void method1() {
        Test.StartTest ();
            Profile profId = [SELECT ID FROM Profile where Name = 'System Administrator' LIMIT 1 ];
            
            user usr = New User ();
                usr.lastName = 'test';
                usr.firstName = 'test1';
                usr.Alias = 't';
                usr.Email ='testDocuvault@gmail.com';
                usr.Username = ' john@Docuvault.com';
                usr.EmailEncodingKey='UTF-8';
                usr.LocaleSidKey='en_US';
                usr.TimeZoneSidKey='America/Los_Angeles';
                usr.ProfileId  = profId.id;
                usr.LanguageLocaleKey='en_US';
            insert usr;
        Test.stopTest ();
    }
}