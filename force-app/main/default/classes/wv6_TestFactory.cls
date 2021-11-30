@isTest
public class wv6_TestFactory {
    public static User getUser(String email, String profileID,String roleID,String conID) {
        User user1 = new User(); 
        user1.firstName = 'Ganesh Test'; 
        user1.LastName = 'WEG';
        user1.Alias = 'alias';
        user1.Email = email;
        user1.UserName= email;
        if(profileID != NULL)
            user1.ProfileId = profileID;
        user1.CommunityNickname = email;
        user1.EmailEncodingKey ='ISO-8859-1';
        user1.LanguageLocaleKey = 'en_US';
        user1.TimeZoneSidKey ='America/Indiana/Indianapolis';
        user1.LocaleSidKey = 'en_US';
        user1.Country = 'USA';
        if(conID!=NULL)
            user1.ContactId = conID;
        user1.IsActive = true;
        if(roleID != NULL)
            user1.userRoleId = roleID; 
        return user1;
    }
    
    public static Secure_Messaging__c getSecureMessage(String conID){
        Secure_Messaging__c sm = new Secure_Messaging__c();
        sm.Name ='Test Message';
        sm.Message__c ='Test Message';
        system.debug('conID=============>'+conID);
        if(conID!=NULL)
            sm.Contact__c = conID;
        return sm;
    }            
}