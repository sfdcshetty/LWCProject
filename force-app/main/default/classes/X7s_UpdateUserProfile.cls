/**
 * Created by 7Summits on 4/15/21.
 */



public with sharing class X7s_UpdateUserProfile {

    @InvocableMethod
    public static void updateUserProfile(List<Id> contactId) {
        if(!System.isFuture()) {
            futureUpdateUserProfile(contactId);
        }

        
        
    }
    @future
    private static void futureUpdateUserProfile(List<Id> contactId) {
        //Profile profileQuery = [SELECT Id, Name FROM Profile WHERE Name = 'WEG Customer Community Plus' OR Name = 'WEG Prospect Community Plus'];
        Id clientProfileId;
        Id prospectProfileId;
        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Name = 'WEG Customer Community Plus' OR Name = 'WEG Prospect Community Plus' LIMIT 2];
        
        for(Profile profile : profileList){
            if(profile.Name == 'WEG Customer Community Plus'){
                clientProfileId = profile.Id;
            } else if (profile.Name == 'WEG Prospect Community Plus') {
                prospectProfileId = profile.Id;
            }
        }

        // Profile clientProfile = [SELECT Id, Name FROM Profile WHERE Name = 'WEG Customer Community Plus'];
        // Profile prospectProfile = [SELECT Id, Name FROM Profile WHERE Name = 'WEG Prospect Community Plus'];
        User user = [SELECT Id, ProfileId, Email, ContactId, Contact.Email FROM User WHERE ContactId =: contactId];
        
        if(user.ProfileId != clientProfileId){
            try {
                // Contact contact = [SELECT Id, Name FROM Contact WHERE Id =: user.ContactId];
                // contact.WEGP1_EmailNote__c = 'original profileid='+user.ProfileId+' '+'current userid='+user.id+' '+'new profileid='+newprofile.Id;
                // update contact;

                // User u = [SELECT Id, Name FROM User WHERE Id = '0052f000001sSS6AAM'];
                user.ProfileId = clientProfileId;
                update user;

            } catch(Exception e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage());
            }
        }
        
    }
}