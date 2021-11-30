/******************************************************************************************************************************
* @class name    : Wave6_WEGAccountSharingBatch
* @description   : This class used to process account and recalculate sharing for account team members for Financial Accounts,
*                  Assets and Liabilities, Trade Requests, Plan and Review Requests, Cloud Files and Financial Goal objects.
*
* @steps to run batch : 1) Open Developer Console
*                       2) Press Ctrl+E
*                       3) Enter following apex code
*                           - For Account Team Member INSERT/EDIT Mode:
*                            Wave6_WEGAccountSharingBatch editModeBatch = new Wave6_WEGAccountSharingBatch(false);
*                            database.executebatch(editModeBatch,1);
*
*                           - For Account Team Member DELETE/FULL:
*                            Wave6_WEGAccountSharingBatch editModeBatch = new Wave6_WEGAccountSharingBatch(true);
*                            database.executebatch(editModeBatch,1);
*                       4) Click Execute
*                       5) We can track batch processing job at Setup-->Jobs -->Apex Jobs
* @test class    : Wave6_WEGAccountSharingTest
* @author        : Ganesh Ekhande
* @date          : 07/05/2017
*
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              07/05/2017             Created.
* Ganesh Ekhande              08/17/2017             Moved AccountTeamId update logic from Finish method to Execute method.
* Ganesh Ekhande              11/16/2017             Added Business Account record type to the recTypeIds.
* Ganesh Ekhande              01/11/2018             Added logic to update Primary Advisor,Secondary Advisor and Primary CSM on Household Account
* Ganesh Ekhande              02/13/2018             Removed logic which were updating Primary Advisor,Secondary Advisor and Primary CSM on Household Account
******************************************************************************************************************************/
public class Wave6_WEGAccountSharingBatch implements Database.Batchable<sObject>, Database.Stateful {

    string qryString='';
    private boolean isFullMode;
    set<string> recTypeIds;

    /*
    * @author       : Ganesh Ekhande
    * @description  : Constructor : It takes flag (EDIT MODE/FULL MODE) and set queryString based on the flag.
    * @created      : 07/05/2017
    * @param        : boolean fullModeFlag
    * @return       : NA
    */
    public Wave6_WEGAccountSharingBatch(boolean fullModeFlag){
        isFullMode = fullModeFlag;
        if (isFullMode) {
            string householdRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
            string businessRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
            string trustRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Trust').getRecordTypeId();
            
            recTypeIds = new set<string>{householdRecTypeId, businessRecTypeId, trustRecTypeId};
            
            qryString = 'SELECT Id, WEGP1_AccountTeamIds__c, RecordType.Name FROM Account WHERE RecordTypeId IN :recTypeIds';
        }
        else {
            qryString = 'SELECT Id, WEGP1_AccountTeamIds__c, RecordType.Name FROM Account WHERE Id IN (SELECT AccountId FROM AccountTeamMember WHERE SystemModstamp > :dT)';
        }
        system.debug('qryString:>>'+qryString);
    }

    /*
    * @author       : Ganesh Ekhande
    * @description  : Mandatory Start method which fatches account records for processing using query string set in the constructor.
    * @created      : 07/05/2017
    * @param        : Database.BatchableContext bc
    * @return       : Database.QueryLocator
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime dT = Datetime.now().addMinutes(-10);
        return Database.getQueryLocator(qryString);
    }

    /*
    * @author       : Ganesh Ekhande
    * @description  : Mandatory Execute method which is used to identify accounts which needs sharing re-calculation and perform sharing recalculation for identified accounts.
    * @created      : 07/05/2017
    * @param        : Database.BatchableContext bc, List<Account> accList
    * @return       : None
    */
    public void execute(Database.BatchableContext bc, List<Account> accList){
        system.debug('accList:>>'+accList);
        map<string,map<string,string>> accountsForProcessing = new map<string,map<string,string>>();
        map<string,Account> updatedAccounts = new map<string,Account>();

        // Identify Accounts which needs sharing recalculations
        accountsForProcessing = Wave6_WEGAccountSharingBatchHelper.identifyAccountsForProcessing(accList);

        // Recalculate Sharing for Account record and update account with current Account Team Members
        for(string accId : accountsForProcessing.keySet()){
           // Recalculate Sharing for Account record
           Wave6_WEGAccountSharingUtility.recalculateSharing(accId,accountsForProcessing.get(accId));

           // Create list of Accounts with updated WEGP1_AccountTeamIds__c field (string of semicolon seperated account Team Member user Ids)
           string newAccountTeamIds = '';
           for(String userId: accountsForProcessing.get(accId).keySet()){
                newAccountTeamIds += userId+':'+accountsForProcessing.get(accId).get(userId)+';';
           }
           updatedAccounts.put(accId,new Account(Id=accId,WEGP1_AccountTeamIds__c = newAccountTeamIds));
        }
        
        // Update Account Team Member Ids on the processed Accounts
        system.debug('updatedAccounts:>>'+updatedAccounts);
        try{
            Database.Update(updatedAccounts.values(),false);
        }catch(exception ex){
            System.debug('ERROR: Exception occurred while updating AccountTeam Ids on Accounts.');
        }
    }

    /*
    * @author       : Ganesh Ekhande
    * @description  : Mandatory Finish method
    * @created      : 07/05/2017
    * @param        : Database.BatchableContext bc
    * @return       : None
    */
    public void finish(Database.BatchableContext bc){
    }
}