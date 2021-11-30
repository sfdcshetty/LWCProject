public class Wave6_UserTriggerHelper {
    
    
    public static void updateParentAccount (list<User> userList, map<Id,User> oldUserMap){
        
        list<string> activePortalUserContactIds = new list<string>();
        list<string> inActivePortalUserContactIds = new list<string>();
        
        // collect Contact Ids of active and inactive Users in separate collections
        for(User usr : userList){
            User oldUser = oldUserMap.get(usr.Id);
            if(usr.ContactId != null && usr.UserType == 'CSPLitePortal' && usr.isActive != oldUser.isActive){
                if(usr.isActive){
                    activePortalUserContactIds.add(usr.ContactId);    
                }else{
                    inActivePortalUserContactIds.add(usr.ContactId);
                }
            }
        }
        
        // collect Account Ids of active and inactive Users in separate collections
        list<string> activeAccountIds = new list<string>();
        list<string> inActiveAccountIds = new list<string>();
        if(!activePortalUserContactIds.isEmpty()){
            for(Contact con : [SELECT Id, AccountId FROM Contact WHERE Id =: activePortalUserContactIds]){
                activeAccountIds.add(con.AccountId);
            }
        }
        if(!inActivePortalUserContactIds.isEmpty()){
            for(Contact con : [SELECT Id, AccountId FROM Contact WHERE Id =: inActivePortalUserContactIds]){
                inActiveAccountIds.add(con.AccountId);
            }
        }
        // Update Portal User Status on Accounts
        updateAccounts(activeAccountIds,inActiveAccountIds);
    }
    
    /*Update Portal User Status on Accounts*/
    @future   
    public static void updateAccounts(list<string> activeAccountId, list<string> inActiveAccountId){
        list<Account> accountList =  new list<Account>();
        for(string accId : activeAccountId){
            Account acc = new Account(Id = accId);    
            acc.Portal_User_Status__c = 'Active Portal User';
            accountList.add(acc);   
        }
        
        for(string accId : inActiveAccountId){
            Account acc = new Account(Id = accId);    
            acc.Portal_User_Status__c = 'Inactive Portal User';
            accountList.add(acc);   
        }
        update accountList;	    
    }
}