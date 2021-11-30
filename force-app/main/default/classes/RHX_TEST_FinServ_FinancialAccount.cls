@isTest(SeeAllData=true)
public class RHX_TEST_FinServ_FinancialAccount {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM FinServ__FinancialAccount__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new FinServ__FinancialAccount__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}