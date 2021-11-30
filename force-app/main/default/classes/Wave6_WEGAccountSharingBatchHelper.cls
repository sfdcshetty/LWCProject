/******************************************************************************************************************************
* @class name    : Wave6_WEGAccountSharingBatchHelper
* @description   : This class is used as helper class for Wave6_WEGAccountSharingBatch class. 
*                  
* @test class    : Wave6_WEGAccountSharingTest
* @author        : Ganesh Ekhande
* @date          : 07/06/2017               
*                   
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              07/06/2017             Created.
* Ganesh Ekhande              08/22/2017             Fixed Account Sharing issue which was occurring for last AccountTeamMember deletion scenario.Added else block at line# 59
******************************************************************************************************************************/
public class Wave6_WEGAccountSharingBatchHelper {
    public static map<string,map<string,string>> accountsForProcessing = new map<string,map<string,string>>();
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : This method is used to check if there are any changes to the account Team Members.
    * @created      : 07/06/2017
    * @param        : list<Account> accList
    * @return       : map<string,map<string,string>>
    */
    public static map<string,map<string,string>> identifyAccountsForProcessing(list<Account> accList){
        set<string> accIds = new set<string>();
        for(Account acc : accList){
            accIds.add(acc.Id);    
        }
        system.debug('accIds:>>'+accIds);
        
        for(Account acc : getAccountTeamMembers(accIds)){
            compareAccounTeam(acc);
        }
        system.debug('accountsForProcessing:>>'+accountsForProcessing);
        return accountsForProcessing;
    }
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : This method is used to compare old account team members (stored in WEGP1_AccountTeamIds__c field) with current account team members.
    * @created      : 07/06/2017
    * @param        : Account acc
    * @return       : None
    */
    public static void compareAccounTeam(Account acc){
        
        list<string> oldTeamMemberIds  = new list<string>();
        list<string> currentTeamMemberIds  = new list<string>();
        //string currentTeamMemberIdString = '';
        map<string,string> accTeamMemberIdToAccAccessMap = new map<string,string>();
        
        // Create list of User Ids of old account team members based on WEGP1_AccountTeamIds__c field.
        if(acc.WEGP1_AccountTeamIds__c != null && acc.WEGP1_AccountTeamIds__c !=''){
            system.debug('acc.WEGP1_AccountTeamIds__c:>>'+acc.WEGP1_AccountTeamIds__c);
            if(acc.WEGP1_AccountTeamIds__c.Contains(';')){
                oldTeamMemberIds = acc.WEGP1_AccountTeamIds__c.split(';');
            }else{
                oldTeamMemberIds.add(acc.WEGP1_AccountTeamIds__c);
            }
        }
        oldTeamMemberIds.sort();
        
        // Create list of User Ids of current account team members based on Account Team.
        if(!acc.AccountTeamMembers.isEmpty()){
            for(AccountTeamMember atm : acc.AccountTeamMembers){
                currentTeamMemberIds.add(atm.UserId+':'+atm.AccountAccessLevel); 
                accTeamMemberIdToAccAccessMap.put(atm.UserId,atm.AccountAccessLevel); 
            }
            currentTeamMemberIds.sort();
        }  
        
        system.debug('oldTeamMemberIds:>>'+oldTeamMemberIds);
        system.debug('currentTeamMemberIds:>>'+currentTeamMemberIds);
        
        // Compare old and current Account Team Members, Add Account Id to accForProcessing list if difference found.
        if(!currentTeamMemberIds.equals(oldTeamMemberIds)){
            accountsForProcessing.put(acc.Id,accTeamMemberIdToAccAccessMap);
        }
    }
    
    /*
    * @author       : Ganesh Ekhande
    * @description  : This Method is used to query Account team members for all the provided account Ids.
    * @created      : 07/06/2017
    * @param        : set<string> accIds
    * @return       : list<Account>
    */
    public static list<Account> getAccountTeamMembers(set<string> accIds){
        list<Account> accList = new list<Account>();
        accList = [Select Id, WEGP1_AccountTeamIds__c, (Select Id, AccountId, UserId, AccountAccessLevel From AccountTeamMembers) From Account Where Id IN: accIds];
        system.debug('accList:>>'+accList);
        return accList;
    }
}