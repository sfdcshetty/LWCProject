public without sharing class x7sAssetAllocationController {
    
    public class AssetWrapper {
        @AuraEnabled public String label{get; set;}
        @AuraEnabled public Decimal amount {get; set;}
        @AuraEnabled public String color {get; set;}
        
        public AssetWrapper(String label, Decimal amount, String color) {
            this.label = label;
            this.amount = amount;
            this.color = color;
        }
    }
    
    public class LiabilityWrapper {
        @AuraEnabled public String label{get; set;}
        @AuraEnabled public Decimal amount {get; set;}
        
        public LiabilityWrapper(String label, Decimal amount) {
            this.label = label;
            this.amount = amount;
        }
    }
    
    public class AssetAndLiabilityWrapper {
        @AuraEnabled public List<AssetWrapper> assets{get; set;}
        @AuraEnabled public LiabilityWrapper liability {get; set;}
        
        public AssetAndLiabilityWrapper(List<AssetWrapper> assets, LiabilityWrapper liability) {
            this.assets = assets;
            this.liability = liability;
        }
    }


    @AuraEnabled(Cacheable=true)
    public static List<Contact> getMyHouseholdInfo(String userId){
        List<Contact> AccList = new List<Contact>();
        AssetAndLiabilityWrapper assetAndLiability;
        LiabilityWrapper liability;
        
        List<User> contactList = [SELECT Id,Name,ContactId FROM User WHERE Id = :userId LIMIT 1];
        
        if(contactList != null && contactList.size() > 0 && (contactList[0].get('contactId')!= null)) {
            //system.debug('contactList contactId= '+contactList[0].get('contactId'));

            Id contactId =(Id) contactList[0].get('contactId');
            AccList = [SELECT Id,Name,AccountId, Account.WEGP1_Primary_Household__c FROM Contact WHERE Id = :contactId LIMIT 1];
        }
        return AccList;
    }

    @AuraEnabled
    public static List<String> getMyHouseholdInfo2(Double myNetWorth){

        Account myHousehold = new Account();
        User currentUser = [SELECT Id,Name,ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        List<String> returnList = new List<String>();

        if(currentUser.ContactId != null) {

            Contact currentContact = [SELECT Id,Name,AccountId, Account.WEGP1_Primary_Household__c FROM Contact WHERE Id = : currentUser.ContactId];

            myHousehold = [SELECT Id, FinServ__NetWorth__c FROM Account WHERE Id = : currentContact.Account.WEGP1_Primary_Household__c];
            myHousehold.FinServ__NetWorth__c = myNetWorth;

            try {
                update myHousehold;
                returnList.add('success');
            } catch (Exception e) {
                returnList.add(e.getMessage());
                returnList.add(e.getStackTraceString());
            }
        }
        return returnList;
    }

    @AuraEnabled
    public static Boolean updateNetWorth(Double myNetWorth){

        Account myAcct = [SELECT Id, FinServ__NetWorth__c FROM Account WHERE WEGP1_Primary_Household__c = :UserInfo.getUserId() LIMIT 1];
        if(myAcct != null) {
			myAcct.FinServ__NetWorth__c = myNetWorth; 
            try {
                update myAcct;
            } catch (DmlException e) {
                // Process exception here
            }  
            return true;            
        }
        return false;
    }


    @AuraEnabled(Cacheable=true)
    public static AssetAndLiabilityWrapper getAssetsAndLiabilities(String userId){
        List<AssetWrapper> assetList = new List<AssetWrapper>();
        AssetAndLiabilityWrapper assetAndLiability;
        LiabilityWrapper liability;
        
        //userId = '0052f000001sMKHAA2';
        //contactId = '0032f00000R50tsAAB';
        //household = '001200000cWqTpAAK';
        List<User> contactList = [SELECT Id,Name,ContactId FROM User WHERE Id = :userId LIMIT 1];
        
        if(contactList != null && contactList.size() > 0 && (contactList[0].get('contactId')!= null)) {
            System.debug('contactList contactId= '+contactList[0].get('contactId'));
            
            Id contactId =(Id) contactList[0].get('contactId');
            List<Contact> AccList = [SELECT Id,Name,AccountId, Account.WEGP1_Primary_Household__c FROM Contact WHERE Id = :contactId LIMIT 1];
            
            System.debug('AccList size= '+AccList.size());
            System.debug('AccList[0].AccountId= '+AccList[0].AccountId);
            System.debug('AccList[0].Account.WEGP1_Primary_Household__c= '+AccList[0].Account.WEGP1_Primary_Household__c);
            if(AccList != null && AccList.size() > 0 && (AccList[0].AccountId != null) && AccList[0].Account.WEGP1_Primary_Household__c != null) {
                
//            	system.debug('AccList accountId= '+AccList[0].get('accountId'));
                System.debug(AccList[0].Account.WEGP1_Primary_Household__c);
                Id houseHoldId = (Id) AccList[0].Account.WEGP1_Primary_Household__c;
                //Id houseHoldId = (Id)('0012f00000cWqTTAA0');
                Decimal balance;
                AssetWrapper wrapper;
                 
                List<AggregateResult> accountList = [SELECT SUM(FinServ__Balance__c) balance FROM FinServ__FinancialAccount__c WHERE FinServ__Household__c = :houseHoldId AND RecordType.Name IN ('Bank Account') AND Remove_or_Historic__c = ''];
                //List<AggregateResult> accountList = [SELECT SUM(WEGP1_AccumulationValue__c) balance FROM FinServ__FinancialAccount__c WHERE FinServ__Household__c = :houseHoldId AND RecordType.Name IN ('Bank Account') AND Remove_or_Historic__c = ''];
                System.debug('account = '+accountList[0].get('balance'));
                balance = (Decimal)accountList[0].get('balance');
                //wrapper = new AssetWrapper('Bank Accounts',((balance != null) ? balance: 0),'#E5AC80');
                 wrapper = new AssetWrapper('Bank Accounts',((balance != null) ? balance: 0),'#63656A');
                assetList.add(wrapper);
                
                //List<AggregateResult> investmentsWithUs = [SELECT SUM(FinServ__Balance__c) balance FROM FinServ__FinancialAccount__c WHERE FinServ__Household__c = :houseHoldId AND RecordType.Name IN('Advisory Investment Account','Annuity Investment Account','Brokerage Investment Account','ERP Investment Account','Investment Account') AND Remove_or_Historic__c = '' AND WEG_External_Rec_ID__c != '' ];
                //Added By Janavi
                List<AggregateResult> investmentsWithUs = [SELECT SUM(FinServ__Balance__c) balance FROM FinServ__FinancialAccount__c WHERE FinServ__Household__c = :houseHoldId AND RecordType.Name IN('Advisory Investment Account','Annuity Investment Account','Brokerage Investment Account','ERP Investment Account','Investment Account','Other Investment Account') AND Remove_or_Historic__c = '' AND FinServ__HeldAway__c = FALSE];

                System.debug('investmentsWithUs = '+investmentsWithUs[0].get('balance'));
                balance = (Decimal)investmentsWithUs[0].get('balance');
                //wrapper = new AssetWrapper('Investments with Us',((balance != null) ? balance: 0),'#DA8A77');
                wrapper = new AssetWrapper('Investments with Us',((balance != null) ? balance: 0),'#3F9C35');
                assetList.add(wrapper);
                
                //List<AggregateResult> investmentsHeldAway = [SELECT SUM(FinServ__Balance__c) balance FROM FinServ__FinancialAccount__c WHERE FinServ__Household__c = :houseHoldId AND RecordType.Name IN('Advisory Investment Account','Annuity Investment Account','Brokerage Investment Account','ERP Investment Account','Investment Account') AND Remove_or_Historic__c = '' AND WEG_External_Rec_ID__c = ''];
                // Added By Janavi
                List<AggregateResult> investmentsHeldAway = [SELECT SUM(FinServ__Balance__c) balance FROM FinServ__FinancialAccount__c WHERE FinServ__Household__c = :houseHoldId AND RecordType.Name IN('Advisory Investment Account','Annuity Investment Account','Brokerage Investment Account','ERP Investment Account','Investment Account', 'Other Investment Account') AND Remove_or_Historic__c = '' AND FinServ__HeldAway__c = True AND WEG_External_Rec_ID__c = '' ];

                System.debug('investmentsHeldAway = '+investmentsHeldAway[0].get('balance'));
                balance = (Decimal)investmentsHeldAway[0].get('balance');
                //wrapper = new AssetWrapper('Investments Held Away',((balance != null) ? balance: 0),'#EED386');
                wrapper = new AssetWrapper('Investments Held Away',((balance != null) ? balance: 0),'#00777A');
                assetList.add(wrapper);
                
                List<AggregateResult> personalProperty = [SELECT SUM(FinServ__Amount__c) amount FROM FinServ__AssetsAndLiabilities__c WHERE FinServ__Household__c = :houseHoldId AND RecordType.Name IN('Asset') AND FinServ__AssetsAndLiabilitiesType__c IN ('Automobile','Jewelry','Real Estate - Personal')];
                System.debug('personalProperty = '+personalProperty[0].get('amount'));
                balance = (Decimal)personalProperty[0].get('amount');
                //wrapper = new AssetWrapper('Personal Property',((balance != null) ? balance: 0),'#35485E');
                wrapper = new AssetWrapper('Personal Property',((balance != null) ? balance: 0),'#002C5F');
                assetList.add(wrapper);
                
                List<AggregateResult> otherAssets = [SELECT SUM(FinServ__Amount__c) amount FROM FinServ__AssetsAndLiabilities__c WHERE FinServ__Household__c = :houseHoldId AND RecordType.Name IN('Asset') AND FinServ__AssetsAndLiabilitiesType__c IN ('Cash','Collection','Equipment','Gold','Other - Asset','Real Estate - Investment','Virtual Currency')];
                System.debug('otherAssets = '+otherAssets[0].get('amount'));
                balance = (Decimal)otherAssets[0].get('amount');
                //wrapper = new AssetWrapper('Other Assets',((balance != null) ? balance: 0),'#07777A');
                wrapper = new AssetWrapper('Other Assets',((balance != null) ? balance: 0),'#77256C');
                assetList.add(wrapper);
                System.debug('assetList = '+assetList);
                
                //List<AggregateResult> liabilities = [SELECT SUM(FinServ__Amount__c) amount FROM FinServ__AssetsAndLiabilities__c WHERE FinServ__Household__c = :houseHoldId AND RecordType.Name IN('Liability') AND FinServ__AssetsAndLiabilitiesType__c IN ('Auto Loan','Credit Card','Mortgage','Personal Loan','Other - Liability')];
                List<AggregateResult> liabilities = [SELECT SUM(FinServ__Amount__c) amount FROM FinServ__AssetsAndLiabilities__c WHERE FinServ__Household__c = :houseHoldId AND RecordType.Name IN('Liability')];
                balance = (Decimal)liabilities[0].get('amount');
                System.debug('liability = '+liabilities[0]);
                liability = new LiabilityWrapper('Liabilities',((balance != null) ? balance: 0));
            }            
        }
        assetAndLiability = new AssetAndLiabilityWrapper(assetList,liability);
        System.debug('assetAndLiability'+assetAndLiability);
        return assetAndLiability;
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<AssetWrapper> getAssetAllocationData(String userId){
        
        List<AssetWrapper> assetList = new List<AssetWrapper>();
        //userId = '0052f000001sMKHAA2';
        List<User> contactList = [SELECT Id,Name,ContactId FROM User WHERE Id = :userId LIMIT 1];
        
        if(contactList != null && contactList.size() > 0 && (contactList[0].get('contactId')!= null)) {
            System.debug('contactList contactId= '+contactList[0].get('contactId'));
            
            Id contactId =(Id) contactList[0].get('contactId');
            List<Contact> AccList = [SELECT Id,Name,AccountId, Account.WEGP1_Primary_Household__c FROM Contact WHERE Id = :contactId LIMIT 1];
            
            if(AccList != null && AccList.size() > 0 && (AccList[0].AccountId != null)) {
                
				//system.debug('AccList accountId= '+AccList[0].get('accountId'));
                System.debug(AccList[0].Account.WEGP1_Primary_Household__c);
                Id houseHoldId = (Id) AccList[0].Account.WEGP1_Primary_Household__c;
                //Id houseHoldId = (Id)('0012f00000cWqTTAA0');
                Decimal balance;
                AssetWrapper wrapper;
                 
                List<Account> accountList = [SELECT Id, Name, WEG_Equity__c,WEG_Fixed_Income__c,WEG_Real_Estate__c,WEG_Alternative_Investment__c,WEG_Cash_and_Equivalents__c,WEG_Other__c FROM Account WHERE Id = :houseHoldId];
                
                System.debug('WEG_Equity__c = '+accountList[0].get('WEG_Equity__c'));
                balance = (Decimal)accountList[0].get('WEG_Equity__c');
                wrapper = new AssetWrapper('Equity',((balance != null) ? balance: 0),'#3F9C35');
                assetList.add(wrapper);
                
                System.debug('WEG_Fixed_Income__c = '+accountList[0].get('WEG_Fixed_Income__c'));
                balance = (Decimal)accountList[0].get('WEG_Fixed_Income__c');
                wrapper = new AssetWrapper('Fixed Income',((balance != null) ? balance: 0),'#002C5F');
                assetList.add(wrapper);
                
                System.debug('WEG_Real_Estate__c = '+accountList[0].get('WEG_Real_Estate__c'));
                balance = (Decimal)accountList[0].get('WEG_Real_Estate__c');
                wrapper = new AssetWrapper('Real Estate',((balance != null) ? balance: 0),'#F05322');
                assetList.add(wrapper);
                
                System.debug('WEG_Alternative_Investment__c = '+accountList[0].get('WEG_Alternative_Investment__c'));
                balance = (Decimal)accountList[0].get('WEG_Alternative_Investment__c');
                wrapper = new AssetWrapper('Alternative Investment',((balance != null) ? balance: 0),'#96172E');
                assetList.add(wrapper);
                
                System.debug('WEG_Cash_and_Equivalents__c = '+accountList[0].get('WEG_Cash_and_Equivalents__c'));
                balance = (Decimal)accountList[0].get('WEG_Cash_and_Equivalents__c');
                wrapper = new AssetWrapper('Cash And Equivalents',((balance != null) ? balance: 0),'#63656A');
                assetList.add(wrapper);
                
                System.debug('WEG_Other__c = '+accountList[0].get('WEG_Other__c'));
                balance = (Decimal)accountList[0].get('WEG_Other__c');
                wrapper = new AssetWrapper('Other',((balance != null) ? balance: 0),'#77256C');
                assetList.add(wrapper);
            }            
        }
        System.debug('assetList'+assetList);
        return assetList;
    }
}