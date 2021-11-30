@isTest(SeeAllData=true)
public class RHX_TEST_FinServ_AssetsAndLiabilities {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM FinServ__AssetsAndLiabilities__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new FinServ__AssetsAndLiabilities__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}