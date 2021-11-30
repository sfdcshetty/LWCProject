public without sharing class wv6_EnableDisableUserController {
    
    /*
    * This method performes below tasks:
    * 1. searches whether the User is already exists by
    * comparing Contact's Email with Existing User's
    * Email.
    * 2. If user is alreday present and inactive, then
    * activate that User
    */

    @AuraEnabled
    public static String enableCustomerUser(string accountId){
        //if(isValidUser()) {
        String msg = '';
        Contact relatedCon = new Contact();
        List<User> existingUsers = new List<user>();
        system.debug('accountId---->'+accountId);
        if(!String.isBlank(accountId)) {
            // ASSUMPTION: We will have only one child Contact associated with Individual Account
            for(Contact con : [SELECT Id, FirstName, LastName, Email, Account.Portal_User_Status__c from Contact WHERE AccountId =: accountId]) {
                system.debug('con---->' + con);
                if(con.Email != null) {
                    relatedCon = con;
                } else {
                    msg = 'Email address is blank on contact. Please update email and try again.';
                    return msg;
                }
            }
            
            if(relatedCon != null) {
                User communityUser = getPortalUser(relatedCon.ID,'WEG Customer Community Plus');
                if(communityUser != NULL){ //User already present
                    system.debug('communityUser---->'+communityUser);
                    if(communityUser.isActive == True){ //IF user id already active
                        msg = 'Portal user is already Active';
                        return msg;
                    }else{ // if user is not active then activate it. 
                        communityUser.isActive = True;
                        update communityUser;
                        updateAccount(accountId,true);
                        msg = 'Portal user has been activated successfully';
                    }
                }else{ // if user does not exist 
                    List<User> fetchUserWithSameEmail = [select id from User where username =: relatedCon.email OR email =: relatedCon.email];
                    if(fetchUserWithSameEmail.size()>0){
                        msg = 'Portal user already exist with same username/email address, please change email address on Contact and try again.';
                    }else{
                        msg = createPortalUser(relatedCon);
                        updateAccount(accountId,true);
                        //msg = 'Portal user has been activated successfully';
                    }
                }
            }else{
                msg = 'No Contact is associated with this Account.  Portal User cannot be created without an associated Contact.';
            }    
        }
        return msg;
        //}else{
        //    return 'You are not authorized to enable Client Portal Users at this time.';
        //}
    }
    
    @AuraEnabled
    public static String disableCustomerUser(String accountId){
        //if(isValidUser()){
        String msg = '';
        Contact relatedCon = new Contact();
        List<User> existingUsers = new List<user>();
        List<Contact> contactToUpdate = new List<Contact>();
        
        if(!String.isBlank(accountId)){
            for(Contact con : [SELECT Id, FirstName, LastName, Email, Account.Portal_User_Status__c from Contact WHERE AccountId =: accountId]){
                
                
                if(con.Email != null){
                    relatedCon = con;
                }else{
                    msg = 'Email address is blank on contact. Please update email and try again.';
                    return msg;
                }																					
            }
            if(relatedCon != null){
                User communityUser = getPortalUser(relatedCon.ID,'WEG Customer Community Plus');
                
                if(communityUser != NULL){ //User already present
                    communityUser.isActive = false;
                    update communityUser;
                    updateAccount(accountId,false);
                    msg = 'Poral user has been deactivated successfully';
                }else{
                    msg = 'Portal user does not exist';
                }
            }else{
                msg = 'No Contact is associated with this Account.  Portal User cannot be created without an associated Contact.';
            }
            
        }
        return msg;
        //}else{
        //    return 'You are not authorized to enable Client Portal Users at this time.';
        //}
    }
    
    public static String createPortalUser(Contact newUserInfo){
        String msg = '';
        Profile profileId = [SELECT Id,Name FROM Profile WHERE Name = 'WEG Customer Community Plus' LIMIT 1];
        
        system.debug('ProfileId =====>'+profileId.ID);
        system.debug('ProfileId =====>'+profileId.name);
        
        String randomStr = String.valueOf(Datetime.now().formatGMT('yyyyMMddHH:mm:ss.SSS'));
        User customUser = new user(
            LastName = newUserInfo.LastName,
            FirstName = newUserInfo.FirstName,
            Username = newUserInfo.Email,
            Email = newUserInfo.Email,
            Alias = newUserInfo.Email.left(4) + randomStr.right(4),
            ProfileId = profileId.Id,
            IsActive = true,
            CompanyName = 'Client',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Chicago',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            contactId = newUserInfo.Id
        );
        
        system.debug('ProfileId =====>'+customUser.ProfileId);
        
        try{   
            // insert the user record
            insert customUser;  
            msg = 'Portal user has been activated successfully';
            System.debug('Create User Status: '+msg);
            
        }
        catch(Exception e){
            msg = 'Exception caught on user creation : '+e.getMessage();
            System.debug('Exception: '+msg);
        }
        return msg; 
    }

    //This methoda updates the Account Record for Portal user Activation.Deactivation status. Since we cannot update Account and User in same 
    //transaction, Account update is kept in future method.
    @future   
    public static void updateAccount(string accountId, boolean activated){
        Account acc = new Account(Id = accountId);
        if(activated){
            acc.Portal_User_Status__c = 'Active Portal User';	
        }else{
		    acc.Portal_User_Status__c = 'Inactive Portal User';	
        }
		update acc;
    }
    
    //This method Checks if user exist for given Contact ID and User Profile
    public static User getPortalUser(string contactId, string profileName){
        User usr;
        List<User> users = [SELECT Id, isActive FROM User WHERE ContactId =: contactId AND profile.Name =: profileName];    
        system.debug('users:>>'+users);
        if(!users.isEmpty()){
            usr = users[0];
        }
        
        return usr;
    }    
    
    public static boolean isValidUser(){
        Id userId = UserInfo.getUserId();
        List<GroupMember> gm=  [SELECT Id, group.id,UserOrGroupId, group.name, group.type FROM GroupMember 
                                where group.name= 'Portal Administration Group' and UserOrGroupId = :UserInfo.getUserId()];
        system.debug('count' +gm.size());
        if(gm.size()>0){
            return true;
        }else{
            return false;
        }    
    }
    
    
}