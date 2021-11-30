public without sharing class x7sAccountTypeAllocationController {
	public class AccountTypeWrapper {
        @AuraEnabled public String label{get; set;}
        @AuraEnabled public Decimal amount {get; set;}
        @AuraEnabled public String color {get; set;}
        
        public AccountTypeWrapper(String label, Decimal amount, String color) {
            this.label = label;
            this.amount = amount;
            this.color = color;
        }
    }
    private static Map<String, String> getRegTypeColorMapping(){
        Map<String, String> RegTypeColorMap = new Map<String, String>();  
        //RegTypeColorMap.put('Roth IRA','#3F9C35'); 
        //RegTypeColorMap.put('NULL','#002C5F'); 
        RegTypeColorMap.put('IRA','#3F9C35');
        RegTypeColorMap.put('IRA - Traditional','#3F9C35');
        RegTypeColorMap.put('IRA - Rollover','#3F9C35');
        RegTypeColorMap.put('Roth IRA','#63656a');
        RegTypeColorMap.put('Individual','#33567f');
        RegTypeColorMap.put('JTWROS','#002C5F');
        RegTypeColorMap.put('Joint','#1a416f');
        RegTypeColorMap.put('Transfer On Death','#66809f');
        RegTypeColorMap.put('Revocable Trust','#4d6b8f');
        RegTypeColorMap.put('Trust','#003031');
        RegTypeColorMap.put('Other','#96172E');
        RegTypeColorMap.put('401(k)','#471641');
		RegTypeColorMap.put('403(b)','#6b2161');
        RegTypeColorMap.put('457 Plan','#f1e9f0');
        RegTypeColorMap.put('529 Plan','#c51c72');
        RegTypeColorMap.put('Charitable Fund','#2A38A5');
        RegTypeColorMap.put('Charitable Org (501c3)','#f58764');
        RegTypeColorMap.put('Charitable Remainder Trust','#66adaf');
		RegTypeColorMap.put('Checking','#ccd5df');
        RegTypeColorMap.put('Conservator','#cce4e4');
        RegTypeColorMap.put('Corporation','#f3754e');
        RegTypeColorMap.put('Coverdell ESA','#cb3380');
        RegTypeColorMap.put('Custodian for Minor','#c9e937');
        RegTypeColorMap.put('Deferred Compensation Plan','#a06698');
		RegTypeColorMap.put('Defined Benefit Plan','#925189');
        RegTypeColorMap.put('Estate','#004749');
        RegTypeColorMap.put('Foundation','#f6987a');
        RegTypeColorMap.put('Inherited Roth IRA','#737479');
        RegTypeColorMap.put('IRA - Beneficiary','#2c6d25');
        RegTypeColorMap.put('IRA - Beneficiary Roth','#828488');
		RegTypeColorMap.put('IRA - Inherited','#2c6d25');
        RegTypeColorMap.put('IRA - SEP','#531a4c');
        RegTypeColorMap.put('IRA - SIMPLE','#5f1e56');
        RegTypeColorMap.put('Irrevocable Trust','#003c3d');
        RegTypeColorMap.put('Joint Tenants Community Property','#b3c0cf');
        RegTypeColorMap.put('Limited Partnership','#f05322');
		RegTypeColorMap.put('Living Trust','#99abbf');
        RegTypeColorMap.put('LLC','#f8a991');
        RegTypeColorMap.put('Money Purchase Plan','#77256c');
        RegTypeColorMap.put('Non-Profit Organization','#fbcbbd');
        RegTypeColorMap.put('Partnership','#f9baa7');
        RegTypeColorMap.put('Pension Plan','#ad7ca7');
		RegTypeColorMap.put('Pension Trust','#bb92b6');
        RegTypeColorMap.put('Profit Sharing Plan','#853b7b');
        RegTypeColorMap.put('Roth 401(k)','#c9a8c4');
        RegTypeColorMap.put('Roth 403(b)','#d6bed3');
        RegTypeColorMap.put('SARSEP','#e4d3e2');
        RegTypeColorMap.put('Savings','#e6eaef');
		RegTypeColorMap.put('Sole Proprietorship','#f26438');
        RegTypeColorMap.put('Tenants in Common','#8096af');
        RegTypeColorMap.put('Testamentary Trust)','#00777a');
        RegTypeColorMap.put('Trust – CLAT','#80bbbd');
        RegTypeColorMap.put('Trust - GRAT','#99c9ca');
        RegTypeColorMap.put('Trust – GST','#1a8587');		
		RegTypeColorMap.put('Trust – GST Exempt','#339295');
		RegTypeColorMap.put('Trust – GST Exempt Marital','#4da0a2');
		RegTypeColorMap.put('Trust - ILIT','#005355');
		RegTypeColorMap.put('Trust - Marital','#005f62');
		RegTypeColorMap.put('Trust - Non Exempt Marital','#006b6e');
		RegTypeColorMap.put('Trust - QPRT','#b3d6d7');
		RegTypeColorMap.put('UGMA/UTMA','#c3e721');
		RegTypeColorMap.put('Uncategorized','#BE264E'); 
        
        return RegTypeColorMap;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<AccountTypeWrapper> getAccountTypeData(String userId){
        Map<String, String> RegTypeColorMap=new Map<String, String>();  
		
        RegTypeColorMap = x7sAccountTypeAllocationController.getRegTypeColorMapping();
        System.debug('color map ='+RegTypeColorMap);
        
        List<AccountTypeWrapper> accountTypeWrapperList = new List<AccountTypeWrapper>();
        
        //userId = '0052f000001sMKHAA2';
        List<User> contactList = [Select id,name,contactId from User where Id = :userId LIMIT 1];
        
        if(contactList != null && contactList.size() > 0 && (contactList[0].get('contactId')!= null)) {
            system.debug('contactList contactId= '+contactList[0].get('contactId'));
            
            Id contactId =(Id) contactList[0].get('contactId');
            List<Contact> AccList = [Select Id,name,accountId, Account.WEGP1_Primary_Household__c from Contact where Id = :contactId LIMIT 1];
            
            system.debug('AccList size= '+AccList.size());
            system.debug('AccList[0].AccountId= '+AccList[0].AccountId);
            system.debug('AccList[0].Account.WEGP1_Primary_Household__c= '+AccList[0].Account.WEGP1_Primary_Household__c);
            
            if(AccList != null && AccList.size() > 0 && (AccList[0].AccountId != null) && AccList[0].Account.WEGP1_Primary_Household__c != null) {
                Id houseHoldId = (Id) AccList[0].Account.WEGP1_Primary_Household__c;
                //Id houseHoldId = (Id)('0012f00000cWqTTAA0');
                Decimal balance;
                AccountTypeWrapper wrapper;
                System.debug('houseHoldId = '+houseHoldId);
                List<AggregateResult> accountTypeList = [Select SUM(FinServ__Balance__c) balance, WEG_Registration_Type__c  from FinServ__FinancialAccount__c WHERE FinServ__Household__c = :houseHoldId group by WEG_Registration_Type__c ];
                List<FinServ__FinancialAccount__c> accountTypeListgroup = [Select FinServ__Balance__c, WEG_Registration_Type__c  from FinServ__FinancialAccount__c WHERE FinServ__Household__c = :houseHoldId ];
                System.debug('accountTypeList' + accountTypeList);
                System.debug('accountTypeListgroup' + accountTypeListgroup);
                 for (AggregateResult accountType : accountTypeList) {
                    balance = (Decimal)accountType.get('balance');
                    if(balance != null) {
                        String regType = (String)((accountType.get('WEG_Registration_Type__c') != null) ? accountType.get('WEG_Registration_Type__c') : 'Uncategorized');
                        String color = RegTypeColorMap.get(regType);
                        wrapper = new AccountTypeWrapper(regType,balance,color);
                		accountTypeWrapperList.add(wrapper); 
                    }
                }
                System.debug('accountTypeWrapperList = '+accountTypeWrapperList);
            }            
        }
        return accountTypeWrapperList;
    }
}