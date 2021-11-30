/******************************************************************************************************************************
* @class name    : Wave6_WEGAccountSharingUtility
* @description   : This class is used for recalculating sharing for provided account Id.
*                  Methods from this class are being used in Wave6_WEGAccountSharingBatch, Wave6_WEGAccountSharingController, Wave6_WEGAccountSharingAction classes.
*
* @test class    : Wave6_WEGAccountSharingTest
* @author        : Ganesh Ekhande
* @date          : 07/03/2017
*
* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
* -----------------------------------------------------------------------------------------------------------------
* Ganesh Ekhande              07/03/2017             Created.
* Ganesh Ekhande              09/06/2017             Updated code for newly introduced Cloud File fields: Priamry Individual and Secondary Individual.
* Ganesh Ekhande              10/30/2017             Added code for newly introduced Cloud File field: Business.
* Santosh Rahane              10/11/2018             Added code for newly introduced Secure Message object
******************************************************************************************************************************/

public without sharing class Wave6_WEGAccountSharingUtility {
    private static map<string,string> accTeamMemberIdToAccAccessMap = new map<string,string>();
    private static map<string,string> individualAccountMap = new map<string,string>();

    private static string prrRowCause;
    private static string trRowCause;
    private static string smRowCause;

    /** Methods Used by Wave6_WAEAccountSharingBatch and Wave6_WAEAccountSharingController**/

    /*
    * @author       : Ganesh Ekhande
    * @description  : Re-calculate sharing for child objects based on the current account team and their Account access level.
    * @created      : 07/03/2017
    * @param        : None
    * @return       : None
    */
    public static string recalculateSharing(string accId, map<string,string> UserIdAccTeamMemberMap){
        string result;

        try {
            // Identify Account Record Type & set RowCause based on the record type
            //string accRecType = identifyRowCause(accId, null);
            string accRecType = getAccountRecordType(accId);
            List<String> allowedRecordTypes = new List<String> {'Household','Business','Trust'};
            
            // Create Map of Account Team Member Id to AccountAccessLevel
            accTeamMemberIdToAccAccessMap = UserIdAccTeamMemberMap;
            system.debug('accTeamMemberIdToAccAccessMap:>>'+accTeamMemberIdToAccAccessMap);

            // process each of the child objects separately
            if (allowedRecordTypes.contains(accRecType))
                AssetsAndLiabilities(accRecType, accId);
            
            if (allowedRecordTypes.contains(accRecType))
                FinancialAccounts(accRecType, accId);
            
            if (allowedRecordTypes.contains(accRecType))
                TradeRequests(accRecType, accId);
            
            if (allowedRecordTypes.contains(accRecType))
                PlanReviewRequests(accRecType, accId);
            
            if (allowedRecordTypes.contains(accRecType))
                CloudFiles(accRecType, accId);
            
            if (allowedRecordTypes.contains(accRecType))
                Blots(accRecType, accId);

            if(accRecType == 'Household')
                FinancialGoals(accRecType, accId);
            
            if(accRecType == 'Household')
                SecureMessages(accRecType, accId);

            if(accRecType == 'Household')
                HouseholdIndividuals(accRecType, accId);

            result = 'SUCCESS';
        }
        catch(exception ex) {
            result = 'ERROR';
        }
        
        return result;
    }
    
    
    private static void FinancialAccounts(string accRecType, string accId) {
        List<FinServ__FinancialAccount__c> financialAccountsList;
        
        // get the financial accounts owned by the group
        if(accRecType == 'Household') {
            // use the Household field for households
            financialAccountsList = [SELECT Id ,(Select Id, RowCause From Shares Where RowCause = 'Household_Account_Team__c')
                                     FROM FinServ__FinancialAccount__c
                                     WHERE FinServ__Household__c =: accId];
        }
        else {
            // use the Primary Owner field for businesses and trusts
            financialAccountsList = [SELECT Id ,(Select Id, RowCause From Shares Where RowCause = 'Primary_Owner_Account_Team__c')
                                     FROM FinServ__FinancialAccount__c
                                     WHERE FinServ__PrimaryOwner__c =: accId];
        }
        system.debug('>>>>>>>> Financial Accounts :: ' + financialAccountsList);
        
        // iterate the financial accounts
        List<FinServ__FinancialAccount__Share> currentSharingRecordsToDelete =  new List<FinServ__FinancialAccount__Share>();
        List<FinServ__FinancialAccount__Share> newSharingRecords =  new List<FinServ__FinancialAccount__Share>();
        for(FinServ__FinancialAccount__c fa : financialAccountsList) {
            // collect the old shares for the financial account to be deleted
            currentSharingRecordsToDelete.addAll(fa.Shares);
            
            // instantiate the new shares to be created
            for(string userId : accTeamMemberIdToAccAccessMap.keySet()){
                FinServ__FinancialAccount__Share newSharingRecord = new FinServ__FinancialAccount__Share();
                newSharingRecord.ParentId = fa.Id;
                newSharingRecord.UserOrGroupId = userId;
                newSharingRecord.AccessLevel = accTeamMemberIdToAccAccessMap.get(userId);
                if (accRecType == 'Household')
                    newSharingRecord.RowCause = 'Household_Account_Team__c';
                else
                    newSharingRecord.RowCause = 'Primary_Owner_Account_Team__c';
                newSharingRecords.add(newSharingRecord);
            }
        }
        
        // delete the old shares
        if(!currentSharingRecordsToDelete.isEmpty())
            Database.Delete(currentSharingRecordsToDelete,false);
        
        // create the new shares
        if(!newSharingRecords.isEmpty()) {
            system.debug('>>>>>>>> New Financial Account Sharing Records :: ' + newSharingRecords);
            Database.insert(newSharingRecords,false);
        }
    }
    

    private static void AssetsAndLiabilities(string accRecType, string accId) {
        List<FinServ__AssetsAndLiabilities__c> assetsAndLiabilitiesList;
        
        // get the assets and liabilities owned by the group
        if(accRecType == 'Household') {
            // use the Household field for households
            assetsAndLiabilitiesList = [SELECT Id , (Select Id, RowCause From Shares Where RowCause = 'Household_Account_Team__c')
                                        FROM FinServ__AssetsAndLiabilities__c
                                        WHERE (FinServ__Household__c =: accId)];
        }
        else {
            // use the Primary Owner field for businesses and trusts
            assetsAndLiabilitiesList = [SELECT Id , (Select Id, RowCause From Shares Where RowCause = 'Primary_Owner_Account_Team__c')
                                        FROM FinServ__AssetsAndLiabilities__c
                                        WHERE (FinServ__PrimaryOwner__c =: accId)];
        }
        system.debug('>>>>>>>> Assets and Liabilities :: ' + assetsAndLiabilitiesList);
        
        // iterate the assets and liabilities        
        List<FinServ__AssetsAndLiabilities__Share> currentSharingRecordsToDelete =  new List<FinServ__AssetsAndLiabilities__Share>();
        List<FinServ__AssetsAndLiabilities__Share> newSharingRecords =  new List<FinServ__AssetsAndLiabilities__Share>();
        for(FinServ__AssetsAndLiabilities__c al : assetsAndLiabilitiesList) {
            // collect the old shares for the asset/liability to be deleted
            currentSharingRecordsToDelete.addAll(al.Shares);
            
            // instantiate the new shares to be created
            for(string userId : accTeamMemberIdToAccAccessMap.keySet()){
                FinServ__AssetsAndLiabilities__Share alShareRec = new FinServ__AssetsAndLiabilities__Share();
                alShareRec.ParentId = al.Id;
                alShareRec.UserOrGroupId = userId;
                alShareRec.AccessLevel = accTeamMemberIdToAccAccessMap.get(userId);
                if (accRecType == 'Household')
                    alShareRec.RowCause = 'Household_Account_Team__c';
                else
                    alShareRec.RowCause = 'Primary_Owner_Account_Team__c';
                newSharingRecords.add(alShareRec);
            }
        }
        
        // delete the old shares
        if(!currentSharingRecordsToDelete.isEmpty())
            Database.Delete(currentSharingRecordsToDelete,false);
        
        // create the new shares
        if(!newSharingRecords.isEmpty()) {
            system.debug('>>>>>>>> New Assets and Liabilities Sharing Records :: ' + newSharingRecords);
            Database.insert(newSharingRecords,false);
        }
    }
    
    
    private static void TradeRequests(string accRecType, string accId) {
        // get the trade requests owned by the group
        List<Trade_Request__c> tradeRequestList = new List<Trade_Request__c>();
        tradeRequestList = [SELECT Id, (Select Id, RowCause From Shares Where RowCause = 'Household_Account_Team__c')
                            FROM Trade_Request__c
                            WHERE WEGP1_Household__c = :accId];
        system.debug('>>>>>>>> Trade Requests :: ' + tradeRequestList);
        
        List<Trade_Request__Share> currentSharingRecordsToDelete =  new List<Trade_Request__Share>();
        List<Trade_Request__Share> newSharingRecords =  new List<Trade_Request__Share>();
        for(Trade_Request__c tr : tradeRequestList) {
            // collect the old shares for the trade request to be deleted
            currentSharingRecordsToDelete.addAll(tr.Shares);
            
            // instantiate the new shares to be created
            for(string userId : accTeamMemberIdToAccAccessMap.keySet()){
                Trade_Request__Share shareRec = new Trade_Request__Share();
                shareRec.ParentId = tr.Id;
                shareRec.UserOrGroupId = userId;
                shareRec.AccessLevel = accTeamMemberIdToAccAccessMap.get(userId);
                shareRec.RowCause = 'Household_Account_Team__c';
                newSharingRecords.add(shareRec);
            }
        }
        
        // delete the old shares
        if(!currentSharingRecordsToDelete.isEmpty())
            Database.Delete(currentSharingRecordsToDelete, false);
        
        // create the new shares
        if(!newSharingRecords.isEmpty()) {
            system.debug('>>>>>>>> New Trade Request Sharing Records :: ' + newSharingRecords);
            Database.insert(newSharingRecords, false);
        }
    }
    
    
    private static void PlanReviewRequests(string accRecType, string accId) {
        // get the plan and review requests owned by the group
        List<Plan_Review_Request__c> planReviewList = new List<Plan_Review_Request__c>();
        planReviewList = [SELECT Id, (Select Id, RowCause From Shares Where RowCause = 'Household_Account_Team__c')
                            FROM Plan_Review_Request__c
                            WHERE WEGP1_Household__c = :accId];
        system.debug('>>>>>>>> Plan and Review Requests :: ' + planReviewList);
        
        List<Plan_Review_Request__Share> currentSharingRecordsToDelete =  new List<Plan_Review_Request__Share>();
        List<Plan_Review_Request__Share> newSharingRecords =  new List<Plan_Review_Request__Share>();
        for(Plan_Review_Request__c pr : planReviewList) {
            // collect the old shares for the trade request to be deleted
            currentSharingRecordsToDelete.addAll(pr.Shares);
            
            // instantiate the new shares to be created
            for(string userId : accTeamMemberIdToAccAccessMap.keySet()){
                Plan_Review_Request__Share shareRec = new Plan_Review_Request__Share();
                shareRec.ParentId = pr.Id;
                shareRec.UserOrGroupId = userId;
                shareRec.AccessLevel = accTeamMemberIdToAccAccessMap.get(userId);
                shareRec.RowCause = 'Household_Account_Team__c';
                newSharingRecords.add(shareRec);
            }
        }
        
        // delete the old shares
        if(!currentSharingRecordsToDelete.isEmpty())
            Database.Delete(currentSharingRecordsToDelete, false);
        
        // create the new shares
        if(!newSharingRecords.isEmpty()) {
            system.debug('>>>>>>>> New Plan and Review Request Sharing Records :: ' + newSharingRecords);
            Database.insert(newSharingRecords, false);
        }
    }
    
    
    private static void CloudFiles(string accRecType, string accId) {
        List<TVA_CFB__Cloud_Files__c> cloudFilesList;
        
        // get the cloud files owned by the group
        if(accRecType == 'Household') {
            // use the Household field for households
            cloudFilesList = [SELECT Id, (Select Id, RowCause From Shares Where RowCause = 'Household_Account_Team__c')
                              FROM TVA_CFB__Cloud_Files__c
                              WHERE WEGP1_Household__c = :accId];
        }
        else {
            // use the Business field for businesses and trusts
            cloudFilesList = [SELECT Id, (Select Id, RowCause From Shares Where RowCause = 'Business_Account_Team__c')
                              FROM TVA_CFB__Cloud_Files__c
                              WHERE Business__c = :accId];
        }
        system.debug('>>>>>>>> Cloud Files :: ' + cloudFilesList);
        
        // iterate the cloud files
        List<TVA_CFB__Cloud_Files__Share> currentSharingRecordsToDelete =  new List<TVA_CFB__Cloud_Files__Share>();
        List<TVA_CFB__Cloud_Files__Share> newSharingRecords =  new List<TVA_CFB__Cloud_Files__Share>();
        for(TVA_CFB__Cloud_Files__c record : cloudFilesList) {
            // collect the old shares for the asset/liability to be deleted
            currentSharingRecordsToDelete.addAll(record.Shares);
            
            // instantiate the new shares to be created
            for(string userId : accTeamMemberIdToAccAccessMap.keySet()){
                TVA_CFB__Cloud_Files__Share shareRec = new TVA_CFB__Cloud_Files__Share();
                shareRec.ParentId = record.Id;
                shareRec.UserOrGroupId = userId;
                shareRec.AccessLevel = accTeamMemberIdToAccAccessMap.get(userId);
                if (accRecType == 'Household')
                    shareRec.RowCause = 'Household_Account_Team__c';
                else
                    shareRec.RowCause = 'Business_Account_Team__c';
                newSharingRecords.add(shareRec);
            }
        }
        
        // delete the old shares
        if(!currentSharingRecordsToDelete.isEmpty())
            Database.Delete(currentSharingRecordsToDelete,false);
        
        // create the new shares
        if(!newSharingRecords.isEmpty()) {
            system.debug('>>>>>>>> New Assets and Liabilities Sharing Records :: ' + newSharingRecords);
            Database.insert(newSharingRecords,false);
        }
    }
    
    
    private static void Blots(string accRecType, string accId) {
        // get the blots owned by the group        
        List<Blot__c> blotList = new List<Blot__c>();
        blotList = [SELECT Id, (Select Id, RowCause From Shares Where RowCause = 'Household_Account_Team__c')
                            FROM Blot__c
                            WHERE WEGP1_Household__c = :accId];
        system.debug('>>>>>>>> Blots :: ' + blotList);
        
        List<Blot__Share> currentSharingRecordsToDelete =  new List<Blot__Share>();
        List<Blot__Share> newSharingRecords =  new List<Blot__Share>();
        for(Blot__c record : blotList) {
            // collect the old shares for the trade request to be deleted
            currentSharingRecordsToDelete.addAll(record.Shares);
            
            // instantiate the new shares to be created
            for(string userId : accTeamMemberIdToAccAccessMap.keySet()){
                Blot__Share shareRec = new Blot__Share();
                shareRec.ParentId = record.Id;
                shareRec.UserOrGroupId = userId;
                shareRec.AccessLevel = accTeamMemberIdToAccAccessMap.get(userId);
                shareRec.RowCause = 'Household_Account_Team__c';
                newSharingRecords.add(shareRec);
            }
        }
        
        // delete the old shares
        if(!currentSharingRecordsToDelete.isEmpty())
            Database.Delete(currentSharingRecordsToDelete, false);
        
        // create the new shares
        if(!newSharingRecords.isEmpty()) {
            system.debug('>>>>>>>> New Blot Sharing Records :: ' + newSharingRecords);
            Database.insert(newSharingRecords, false);
        }
    }
    
    
    private static void FinancialGoals(string accRecType, string accId) {
        List<FinServ__FinancialGoal__c> financialGoalsList = new List<FinServ__FinancialGoal__c>();
        
        // get the financial goals owned by the group
        if(accRecType == 'Household') {
            // use the Household field for households
            financialGoalsList = [SELECT Id, (Select Id, RowCause From Shares Where RowCause = 'Household_Account_Team__c')
                                  FROM FinServ__FinancialGoal__c
                                  WHERE FinServ__Household__c = :accId];
        }
        system.debug('>>>>>>>> Financial Goals :: ' + financialGoalsList);
        
        // iterate the financial goals
        List<FinServ__FinancialGoal__Share> currentSharingRecordsToDelete =  new List<FinServ__FinancialGoal__Share>();
        List<FinServ__FinancialGoal__Share> newSharingRecords =  new List<FinServ__FinancialGoal__Share>();
        for(FinServ__FinancialGoal__c record : financialGoalsList) {
            // collect the old shares to be deleted
            currentSharingRecordsToDelete.addAll(record.Shares);
            
            // instantiate the new shares to be created
            for(string userId : accTeamMemberIdToAccAccessMap.keySet()){
                FinServ__FinancialGoal__Share shareRec = new FinServ__FinancialGoal__Share();
                shareRec.ParentId = record.Id;
                shareRec.UserOrGroupId = userId;
                shareRec.AccessLevel = accTeamMemberIdToAccAccessMap.get(userId);
                shareRec.RowCause = 'Household_Account_Team__c';
                newSharingRecords.add(shareRec);
            }
        }
        
        // delete the old shares
        if(!currentSharingRecordsToDelete.isEmpty())
            Database.Delete(currentSharingRecordsToDelete,false);
        
        // create the new shares
        if(!newSharingRecords.isEmpty()) {
            system.debug('>>>>>>>> New Financial Goal Sharing Records :: ' + newSharingRecords);
            Database.insert(newSharingRecords,false);
        }
    }
    
    
    private static void SecureMessages(string accRecType, string accId) {
        List<Secure_Messaging__c> messagingList = new List<Secure_Messaging__c>();
        
        // get the secure messages owned by the group
        if(accRecType == 'Household') {
            // use the Household field for households
            messagingList = [SELECT Id, (Select Id, RowCause From Shares Where RowCause = 'Household_Account_Team__c')
                                  FROM Secure_Messaging__c
                                  WHERE Household_Account__c = :accId];
        }
        system.debug('>>>>>>>> Secure Messages :: ' + messagingList);
        
        // iterate the Secure Messages
        List<Secure_Messaging__Share> currentSharingRecordsToDelete =  new List<Secure_Messaging__Share>();
        List<Secure_Messaging__Share> newSharingRecords =  new List<Secure_Messaging__Share>();
        for(Secure_Messaging__c record : messagingList) {
            // collect the old shares to be deleted
            currentSharingRecordsToDelete.addAll(record.Shares);
            
            // instantiate the new shares to be created
            for(string userId : accTeamMemberIdToAccAccessMap.keySet()){
                Secure_Messaging__Share shareRec = new Secure_Messaging__Share();
                shareRec.ParentId = record.Id;
                shareRec.UserOrGroupId = userId;
                shareRec.AccessLevel = accTeamMemberIdToAccAccessMap.get(userId);
                shareRec.RowCause = 'Household_Account_Team__c';
                newSharingRecords.add(shareRec);
            }
        }
        
        // delete the old shares
        if(!currentSharingRecordsToDelete.isEmpty())
            Database.Delete(currentSharingRecordsToDelete,false);
        
        // create the new shares
        if(!newSharingRecords.isEmpty()) {
            system.debug('>>>>>>>> New Secure Message Sharing Records :: ' + newSharingRecords);
            Database.insert(newSharingRecords,false);
        }
    }
    
    
    private static void HouseholdIndividuals(string accRecType, string accId) {
        // get the individuals owned by the group
        List<Account> individualList = new List<Account>();
        individualList = [SELECT Id, (Select Id, RowCause From Shares Where RowCause = 'Manual')
                          FROM Account
                          WHERE WEGP1_Primary_Household__c = :accId];
        system.debug('>>>>>>>> Individual Accounts :: ' + individualList);
        
        // iterate the Individuals
        List<AccountShare> currentSharingRecordsToDelete =  new List<AccountShare>();
        List<AccountShare> newSharingRecords =  new List<AccountShare>();
        for(Account record : individualList) {
            // collect the old shares to be deleted
            currentSharingRecordsToDelete.addAll(record.Shares);
            
            // instantiate the new shares to be created
            for(string userId : accTeamMemberIdToAccAccessMap.keySet()){
                AccountShare shareRec = new AccountShare();
                shareRec.AccountId = record.Id;
                shareRec.UserOrGroupId = userId;
                shareRec.AccountAccessLevel = accTeamMemberIdToAccAccessMap.get(userId);
                shareRec.OpportunityAccessLevel = accTeamMemberIdToAccAccessMap.get(userId);
                shareRec.CaseAccessLevel = accTeamMemberIdToAccAccessMap.get(userId);
                shareRec.RowCause = 'Manual';
                newSharingRecords.add(shareRec);
            }
        }
        
        // delete the old shares
        if(!currentSharingRecordsToDelete.isEmpty())
            Database.Delete(currentSharingRecordsToDelete,false);
        
        // create the new shares
        if(!newSharingRecords.isEmpty()) {
            system.debug('>>>>>>>> New Individual Account Sharing Records :: ' + newSharingRecords);
            Database.insert(newSharingRecords,false);
        }
    }

    /*
    * @author       : Ganesh Ekhande
    * @description  : Get record type name for provided account Id.
    * @created      : 07/03/2017
    * @param        : string accId
    * @return       : string
    */
    public static string getAccountRecordType(string accId){
        Account acc = [Select Id,RecordType.Name From Account Where Id =: accId Limit 1];
        return acc.RecordType.Name;
    }


    /** Methods Used by Wave6_WAEAccountSharingAction**/

   /*
    * @author       : Ganesh Ekhande
    * @description  : UTILIZED BY WAVE6_WEGACCOUNTSHARINGACTION CLASS
    * @created      : 07/07/2017
    * @param        : string objectType, string objectAPIName,list<Wave6_WEGAccountSharingAction.SharingActionInputWrapper> sharingActionInputList
    * @return       : None
    */
    public static void DeleteSharingRecords(string shareObject, list<Wave6_WEGAccountSharingAction.SharingActionInputWrapper> sharingActionInputList){
        system.debug('sharingActionInputList:>>'+sharingActionInputList);

        string rowCause;
        set<string> recordIds = new set<string>();
        for(Wave6_WEGAccountSharingAction.SharingActionInputWrapper input :  sharingActionInputList){
            recordIds.add(input.recordId);
            rowCause = input.sharingReason;
        }
        xDeleteExistingSharingRecords(shareObject,recordIds,rowCause);
    }


   /*
    * @author       : Ganesh Ekhande
    * @description  : UTILIZED BY WAVE6_WEGACCOUNTSHARINGACTION CLASS
    * @created      : 07/07/2017
    * @param        : string objectType, string objectAPIName,list<Wave6_WEGAccountSharingAction.SharingActionInputWrapper> sharingActionInputList
    * @return       : None
    */
  public static void CreateSharingRecords(string objectAPIName, list<Wave6_WEGAccountSharingAction.SharingActionInputWrapper> sharingActionInputList){

        system.debug('sharingActionInputList:>>'+sharingActionInputList);

        string rowCause;
        list<sObject> sharingRecords  = new list<sObject>();
        set<string> accIds = new set<string>();
        set<string> recordIds = new set<string>();
        list<Account> accList = new list<Account>();
        map<string, list<AccountTeamMember>> atmMap = new map<string, list<AccountTeamMember>>();

        // Seperate out all parent account Ids
        for(Wave6_WEGAccountSharingAction.SharingActionInputWrapper input :  sharingActionInputList){
            accIds.add(input.accountId);
            recordIds.add(input.recordId);
            rowCause = input.sharingReason;
        }

        // Get Accounts along with Account Team Members
        accList = Wave6_WEGAccountSharingBatchHelper.getAccountTeamMembers(accIds);
        system.debug('accList:>>'+accList);

        // Create map of Account Id and list of Account Team Members
        for(Account acc : accList){
            if(acc.AccountTeamMembers != null && acc.AccountTeamMembers.size()>0){
                atmMap.put(acc.Id,acc.AccountTeamMembers);
            }
        }
        system.debug('atmMap:>>'+atmMap);

        //Delete existing sharing records
        xDeleteExistingSharingRecords(objectAPIName, recordIds, rowCause);

        // Create sharing records
        for(Wave6_WEGAccountSharingAction.SharingActionInputWrapper input :  sharingActionInputList){
            if(atmMap.containsKey(input.accountId)){
                for(AccountTeamMember atm : atmMap.get(input.accountId)){
                    sObject shareRecord;
                    if(objectAPIName == 'FinServ__FinancialAccount__Share'){
                        shareRecord = new FinServ__FinancialAccount__Share(ParentId = input.recordId,UserOrGroupId = atm.UserId,AccessLevel = atm.AccountAccessLevel,RowCause = rowCause);
                    }else if(objectAPIName == 'FinServ__AssetsAndLiabilities__Share'){
                        shareRecord = new FinServ__AssetsAndLiabilities__Share(ParentId = input.recordId,UserOrGroupId = atm.UserId,AccessLevel = atm.AccountAccessLevel,RowCause = rowCause);
                    }else if(objectAPIName == 'Trade_Request__Share'){
                        shareRecord = new Trade_Request__Share(ParentId = input.recordId,UserOrGroupId = atm.UserId,AccessLevel = atm.AccountAccessLevel,RowCause = rowCause);
                    }else if(objectAPIName == 'Plan_Review_Request__Share'){
                        shareRecord = new Plan_Review_Request__Share(ParentId = input.recordId,UserOrGroupId = atm.UserId,AccessLevel = atm.AccountAccessLevel,RowCause = rowCause);
                    }else if(objectAPIName == 'TVA_CFB__Cloud_Files__Share'){
                        shareRecord = new TVA_CFB__Cloud_Files__Share(ParentId = input.recordId,UserOrGroupId = atm.UserId,AccessLevel = atm.AccountAccessLevel,RowCause = rowCause);
                    }else if(objectAPIName == 'FinServ__FinancialGoal__Share'){
                        shareRecord = new FinServ__FinancialGoal__Share(ParentId = input.recordId,UserOrGroupId = atm.UserId,AccessLevel = atm.AccountAccessLevel,RowCause = rowCause);
                    }else if(objectAPIName == 'Blot__Share'){
                        shareRecord = new Blot__Share(ParentId = input.recordId,UserOrGroupId = atm.UserId,AccessLevel = atm.AccountAccessLevel,RowCause = rowCause);
                    }else if(objectAPIName == 'Secure_Messaging__Share'){

                        shareRecord = new Secure_Messaging__Share(ParentId = input.recordId, UserOrGroupId = atm.UserId, AccessLevel = atm.AccountAccessLevel,RowCause = rowCause);
                    }else if(objectAPIName == 'AccountShare'){
                        shareRecord = new AccountShare(AccountId = individualAccountMap.get(input.recordId),UserOrGroupId = atm.UserId,AccountAccessLevel = atm.AccountAccessLevel,RowCause = rowCause,OpportunityAccessLevel = atm.AccountAccessLevel,CaseAccessLevel = atm.AccountAccessLevel);
                    }

                    sharingRecords.add(shareRecord);
                }
            }
        }
      
      //system.debug('ExistingsharingRecords:>>'+[select id, UserOrGroupId, AccessLevel from Secure_Messaging__Share ]);
        system.debug('sharingRecords:>>'+sharingRecords);
        Database.SaveResult[] srList = Database.insert(sharingRecords,false);
        for(Database.SaveResult test: srList){
            system.debug('srList:>>'+test);
        }

    }

    /*
    * @author       : Ganesh Ekhande
    * @description  : UTILIZED BY WAVE6_WEGACCOUNTSHARINGACTION CLASS
    * @created      : 07/07/2017
    * @param        : string objectAPIName,set<string> recordIds,string rowCause
    * @return       : None
    */
    private static void xDeleteExistingSharingRecords (string objectAPIName,set<string> recordIds,string rowCause){

        list<sObject> sharingRecordsDelete = new list<sObject>();
        //set<string> sharingReasons = new set<string>{'Household_Account_Team__c','Individual_Account_Team__c'};
        string query;
        if(objectAPIName == 'AccountShare'){
            set<string> indAccIds =  new set<string>();
            for(Account acc : [Select Id, Finserv__IndividualId__c from Account Where Finserv__IndividualId__c IN: recordIds]){
                indAccIds.add(acc.Id);
                individualAccountMap.put(acc.Finserv__IndividualId__c,acc.Id);
            }
            recordIds.clear();
            recordIds.addAll(indAccIds);

            query = 'Select Id,AccountId,RowCause From AccountShare Where AccountId IN:recordIds AND RowCause =: rowCause';
        }else{
            query = 'Select Id,ParentId,RowCause From '+ objectAPIName +' Where ParentId IN:recordIds AND RowCause =: rowCause';
        }
        sharingRecordsDelete = Database.query(query);
        system.debug('sharingRecordsDelete:>>'+sharingRecordsDelete);

        delete sharingRecordsDelete;
    }

    /*
    * @author       : Ganesh Ekhande
    * @description  : Create Map of Account Team Member Id (User Id) and their Account Access level.
    * @created      : 07/03/2017
    * @param        : string accId
    * @return       : map<string,string>
    */
    public static map<string,string> getAccountTeamMemberMap(string accId){
        accTeamMemberIdToAccAccessMap = new map<string,string>();
        for(AccountTeamMember atm : xGetAccountTeamMembers(accId)){
            accTeamMemberIdToAccAccessMap.put(atm.UserId,atm.AccountAccessLevel);
        }
        system.debug('accTeamMemberIdToAccAccessMap:>>'+accTeamMemberIdToAccAccessMap);
        return accTeamMemberIdToAccAccessMap;
    }

    /*
    * @author       : Ganesh Ekhande
    * @description  : Get Account Team Members for provided account Id
    * @created      : 07/03/2017
    * @param        : string accId
    * @return       : list<AccountTeamMember>
    */
    private static List<AccountTeamMember> xGetAccountTeamMembers(string accId){
        return [Select Id, AccountId, UserId, AccountAccessLevel From AccountTeamMember Where AccountId =: accId];
    }

}