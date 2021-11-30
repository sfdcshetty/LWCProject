@isTest
public class SKBlotFundDetailsTest {
	/*
    public static testMethod void SKBlotFundDetailsTest() {
        // retrieve the Business record type id
        RecordType rtIndustriesBusiness = [select Id from RecordType where DeveloperName = 'IndustriesBusiness' limit 1];
        //create a contact
        //Contact con = new Contact();
        //con.LastName = 'ln12345';
        //insert con;
        // create an account
        Account account = new Account();
        //account.FinServ__PrimaryContact__c = con.Id;
        account.Name = 'Sample Name';
        account.RecordTypeId = rtIndustriesBusiness.Id;
        insert account;
                
        // insert questionnaire records
        SkienceFinSln__Questionnaire__c questionnaire = new SkienceFinSln__Questionnaire__c();
        questionnaire.SkienceFinSln__Flow__c = 'SK_NewAccountOpening';
        questionnaire.SkienceFinSln__Primary_Owner_Account__c = account.Id;
        RecordType recordType = [SELECT name,Id from RecordType where developername = 'InvestmentAccount'];
        questionnaire.SkienceFinSln__Financial_Account_Record_Type_Id__c = recordType.Id;
        insert questionnaire;
        
        // retrieve the financial account id
        questionnaire = [Select Id, SkienceFinSln__FSC_Financial_Account__c 
                         from SkienceFinSln__Questionnaire__c 
                         where Id =:questionnaire.id];
        //insert Blot record
        Blot__c blot = new Blot__c();
        blot.WEGP1_BlotType__c = 'Plan';
        blot.WEGP1_Status__c = 'New';
        blot.WEGP1_Household__c = account.id;
        blot.WEGP1_FinancialAccount__c = questionnaire.SkienceFinSln__FSC_Financial_Account__c;
        insert blot;
        
        questionnaire.SK_Blot__c = blot.Id;
        update questionnaire;
        
        //insert Fund Detail
        Fund_Detail__c fund = new Fund_Detail__c();
        fund.Blot__c = blot.Id;
        fund.WEGP1_FinancialAccount__c = questionnaire.SkienceFinSln__FSC_Financial_Account__c;
        fund.WEGP1_Amount__c = 1000;
        fund.WEGP1_SourceofFunds__c = 'Other (note required)';
        
        test.startTest();
        // run the methods in the class
        SKBlotFundDetails.upsertFundDetail(fund,questionnaire.Id); //for Insert
        List<Fund_Detail__c> lsFund = SKBlotFundDetails.getFundDetails(questionnaire.Id);
        Fund_Detail__c fund1 = (Fund_Detail__c)lsFund[0];
        SKBlotFundDetails.getFundDetail(fund1.Id);
        SKBlotFundDetails.upsertFundDetail(fund1,questionnaire.Id); //for Update
        SKBlotFundDetails.deleteFundDetail(fund1.id,questionnaire.Id);
        test.stopTest();
    }
	*/
}