public class wv6_FABalanceByTypeController {
    @AuraEnabled
    public static List<AccountBalanceWrapper> getAccountTypeAndBalances(){
        List<AccountBalanceWrapper> accBalanceWrap = new List<AccountBalanceWrapper>();
        List<AggregateResult> aggrResultList = [SELECT WEG_Registration_Type__c accType,  SUM(FinServ__Balance__c) balance
                                                FROM FinServ__FinancialAccount__c 
                                                WHERE WEGP1_Held_Status__c ='WEG Held' AND WEGP1_ExcludeFromReview__c = False AND FinServ__Status__c ='Open'
                                                GROUP BY ROLLUP(WEG_Registration_Type__c)];
        
        system.debug('aggrResultList:>>'+aggrResultList);
                                                             
        for (AggregateResult ar : aggrResultList){
            AccountBalanceWrapper wrap = new AccountBalanceWrapper();   
            wrap.accountType = string.valueof(ar.get('accType'));
            if(ar.get('balance') == null){
                wrap.balance = 0;
            }else{
                wrap.balance = decimal.valueof(string.valueof(ar.get('balance')));
            }
            if(wrap.accountType == '' || wrap.accountType == null){
               wrap.accountType = 'TOTAL'; 
            }
            accBalanceWrap.add(wrap);
        }
        system.debug('accBalanceWrap:>>'+accBalanceWrap);
        return accBalanceWrap;
    }
    
    public class AccountBalanceWrapper {
        @AuraEnabled
        public string accountType;
        @AuraEnabled
        public decimal balance;

    }
}