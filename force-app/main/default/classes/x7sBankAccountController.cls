public without sharing class x7sBankAccountController {
	
    Public class BankAccountWrapper{
        @AuraEnabled public String Name { get; set; }
        @AuraEnabled public String Type { get; set; }
        //@AuraEnabled public String Custodian { get; set; }
        @AuraEnabled public String AccountNumber { get; set; }
        @AuraEnabled public String Owner { get; set; }
        @AuraEnabled public Date AsOfDate { get; set; }
        @AuraEnabled public Decimal Amount { get; set; }
    }
    
    @AuraEnabled (cacheable=true)
    public static List<FinServ__FinancialAccount__c> getBankAccountDetails(String accountId){
        System.debug(accountId);
        List<FinServ__FinancialAccount__c> bankAccList;
        
        if(accountId != null){
            
            List<Account> accList = [SELECT Id, Name, WEGP1_Primary_Household__c 
                                     From Account 
                                     WHERE Id =: accountId LIMIT 1];
            
            if(accList.size() > 0 && accList != null && accList[0].WEGP1_Primary_Household__c != null){
           		
               bankAccList = [SELECT Id,Name, FinServ__FinancialAccountNumber__c,WEGP1_AccumulationValue__c,
                              		 FinServ__FinancialAccountType__c, FinServ__PrimaryOwner__c,
                                     WEGP1_Owner_Type__c, FinServ__JointOwner__c,
                                     WEG_As_of_Date__c, FinServ__Balance__c,
                                     FinServ__Household__c, WEG_Account__c
                                     FROM FinServ__FinancialAccount__c
                                     WHERE FinServ__Household__c = :accList[0].WEGP1_Primary_Household__c 
                                     AND RecordType.Name IN ('Bank Account') 
                                     AND Remove_or_Historic__c = ''
                                     AND FinServ__Status__c = 'Open'
                                     AND WEGP1_ExcludeFromReview__c = false];
                
            }
        }
        
        return bankAccList;
    }
    
   /* @AuraEnabled(cacheable=true)
    public static List<String> getBankAccountType(String objectType, String recordTypeName, String fieldName) {

        List<String> pickListValuesList= new List<String>();
        
        System.debug('objectType' + objectType);
        System.debug('recordTypeId' + recordTypeName);
        System.debug('fieldName' + fieldName);
        
        //Added By Janavi
        Map<Object, String> mapControllingValueWithIndex = new Map<Object,String>();
        
        if(String.isBlank(objectType) || String.isBlank(fieldName)){
            return pickListValuesList;
        } 
        
      
        String recordTypeId;
        
        recordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();

        if(!String.isBlank(recordTypeName)){
            recordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        }
        if( recordTypeId == null || recordTypeId == '' ){
            recordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Master').getRecordTypeId();
        }

        
        //String objectType = 'FinServ__FinancialAccount__c';
        //String recordTypeId = '01241000000ygDDAAY';
        //String fieldName = 'FinServ__FinancialAccountType__c';
        String endpoint = URL.getSalesforceBaseUrl().toExternalForm();      
        endpoint += '/services/data/v45.0';
        endpoint += '/ui-api/object-info/' + objectType + '/picklist-values/' + recordTypeId + '/' + fieldName;
        
        System.debug('endpoint' + endpoint);
        
        EncodingUtil.urlEncode(endpoint,'UTF-8');
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId()); 
        req.setHeader('Accept', 'application/json '); 
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        if(res.getStatusCode() == 200 ) {
            Map<String,Object> root = (Map<String,Object>) JSON.deserializeUntyped( res.getBody() );            
            List<Object> pValues = (List<Object>) root.get( 'values' );
            for(Object pValue : pValues) {
                Map<String,Object> pValueMap = (Map<String,Object>)pValue;
                pickListValuesList.add((String) pValueMap.get('value'));
            }
            
        }
        System.debug('pickListValuesList'+ pickListValuesList);
        return pickListValuesList; 
                
    } */
    
    // @AuraEnabled(cacheable=true)
    // public static List<String> getCustodian() {

    //     List<String> pickListValuesList= new List<String>();
        
    //     Schema.DescribeFieldResult fieldResult = FinServ__FinancialAccount__c.WEG_Custodian__c.getDescribe();
    //     List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
	// 	for(Schema.PicklistEntry pickListVal : ple){
    //         pickListValuesList.add(pickListVal.getValue());
    //     }
	// 	return pickListValuesList;
    // }
    
    @AuraEnabled
    public static void editBankAccount(String bankAccountId, String accountId, String bankAccountInfo) {

        List<FinServ__FinancialAccount__c> bankAccList;
        List<BankAccountWrapper> lstWrap = new List<BankAccountWrapper>();
        BankAccountWrapper newBankAccount;
        List<Account> accList;
        //Boolean editResult = false;
        
        List<RecordType> recType = new List<RecordType>();
        recType = [SELECT Id, Name FROM RecordType Where Name IN('Bank Account') LIMIT 1];
        
        if(accountId != null){
                
            accList = [SELECT Id, Name, OwnerId, WEGP1_Primary_Household__c,WEGP1_Primary_Household__r.Name,
                       WEGP1_Primary_Household__r.OwnerId, WEGP1_Primary_Household__r.WEGP1_Secondary_Individual__r.AccountId,
                       WEGP1_Primary_Household__r.Owner.CSChatterGroup__c, WEGP1_Primary_Household__r.WEGP1_Primary_Individual__r.AccountId
                       From Account 
                       WHERE Id =: accountId LIMIT 1];
        }

        if(bankAccountInfo != null){
            newBankAccount = (BankAccountWrapper) JSON.deserialize(bankAccountInfo, BankAccountWrapper.class);
        }
        bankAccList = [SELECT Id, Name, FinServ__FinancialAccountNumber__c,
                             WEGP1_Owner_Type__c,  FinServ__PrimaryOwner__c,
                             WEG_As_of_Date__c, FinServ__Balance__c,
                             FinServ__Household__c, WEG_Account__c, FinServ__JointOwner__c, FinServ__FinancialAccountType__c
                             FROM FinServ__FinancialAccount__c
                           	WHERE Id =:bankAccountId LIMIT 1];

        System.debug('BANK ACCOUNT INFO======>'+bankAccList[0]);
        System.debug('NEW BANK ACCOUNT INFO======>'+newBankAccount);

        List<Account> origOwner;
        if(bankAccList[0].WEGP1_Owner_Type__c != 'Joint'){
            origOwner = [SELECT Id, Name From Account 
                                    WHERE Id =: bankAccList[0].FinServ__PrimaryOwner__c LIMIT 1];
        }

        List<Account> newOwner;
        if( newBankAccount.Owner != 'Joint' ){
            newOwner = [SELECT Id, Name From Account 
                                WHERE Id =: newBankAccount.Owner LIMIT 1];
        }

        ////////////////////
        String chatterBody = 'Portal - Net Worth Update Account ' + accList[0].WEGP1_Primary_Household__r.Name + '\n' + recType[0].Name +'\n';
        chatterBody += 'Changes:'+'\n';
        if((newBankAccount.Name  != null) && (newBankAccount.Name  != bankAccList[0].Name)){chatterBody += 'Bank Account Name: ' + bankAccList[0].Name + '=>' + newBankAccount.Name +'\n';}
        if((newBankAccount.Type  != null) && (newBankAccount.Type  != bankAccList[0].FinServ__FinancialAccountType__c)){chatterBody += 'Bank Account Type:' + bankAccList[0].FinServ__FinancialAccountType__c + '=>' + newBankAccount.Type +'\n';}
        //if((newBankAccount.Custodian  != null) && (newBankAccount.Custodian  != bankAccList[0].WEG_Custodian__c)){chatterBody += 'Custodian: ' + bankAccList[0].WEG_Custodian__c + '=>'  + newBankAccount.Custodian +'\n';}
        if((newBankAccount.AccountNumber  != null) && (newBankAccount.AccountNumber  != bankAccList[0].FinServ__FinancialAccountNumber__c)){chatterBody += 'Account Number: ' + bankAccList[0].FinServ__FinancialAccountNumber__c + '=>' + newBankAccount.AccountNumber +'\n';}
        
        if((newBankAccount.Owner  != null) && newBankAccount.Owner != 'Joint') {
            if(bankAccList[0].WEGP1_Owner_Type__c != 'Joint'){
                chatterBody += 'Owner: ' + origOwner[0].Name + '=> ' + newOwner[0].Name +'\n';
            }else{
                chatterBody += 'Owner: ' + 'Joint' + '=> ' + newOwner[0].Name +'\n';
            }
        }

        
        if((newBankAccount.AsOfDate  != null) && (newBankAccount.AsOfDate  != bankAccList[0].WEG_As_of_Date__c)){chatterBody += 'As Of Date: ' + bankAccList[0].WEG_As_of_Date__c + '=>' + newBankAccount.AsOfDate +'\n';}
        if((newBankAccount.Amount  != null) && (newBankAccount.Amount  != bankAccList[0].FinServ__Balance__c)){chatterBody += 'Amount: ' + bankAccList[0].FinServ__Balance__c + '=>' + newBankAccount.Amount + '\n';}
        ////////////////////

        bankAccList[0].Name = newBankAccount.Name;
        bankAccList[0].FinServ__FinancialAccountType__c = newBankAccount.Type;
        //bankAccList[0].WEG_Custodian__c = newBankAccount.Custodian;
        bankAccList[0].WEG_As_of_Date__c = newBankAccount.AsOfDate;
        bankAccList[0].FinServ__Balance__c = newBankAccount.Amount;
        //bankAccList[0].WEGP1_AccumulationValue__c = newBankAccount.Amount;
        bankAccList[0].FinServ__FinancialAccountNumber__c = newBankAccount.AccountNumber;
        System.debug('newBankAccount.Owner======>'+newBankAccount.Owner);
        if(newBankAccount.Owner == 'Joint') {
            String primary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Primary_Individual__r?.AccountId;
            String secondary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Secondary_Individual__r?.AccountId;
            bankAccList[0].FinServ__PrimaryOwner__c = primary;
            bankAccList[0].FinServ__JointOwner__c = secondary;
        } else {
            bankAccList[0].FinServ__PrimaryOwner__c = newBankAccount.Owner;
            bankAccList[0].FinServ__JointOwner__c = null;
        }
        
        update bankAccList; 
        
        x7s_ChatterPostUtility.ChatterPostInputs input = new x7s_ChatterPostUtility.ChatterPostInputs();
        input.parentId = accList[0].WEGP1_Primary_Household__r.Owner.CSChatterGroup__c;
        input.userId = UserInfo.getUserId();
        
        //String chatterBody = 'Portal - Net Worth Update Account ' + accList[0].WEGP1_Primary_Household__r.Name + '\n' + recType[0].Name +'\n';
        //chatterBody += 'Changes:'+'\n';
        
        //if((newBankAccount.Name  != null) && (newBankAccount.Name  != bankAccList[0].Name)){chatterBody += 'Bank Account Name: ' + newBankAccount.Name +'\n';}
        //if((newBankAccount.Type  != null) && (newBankAccount.Type  != bankAccList[0].FinServ__FinancialAccountType__c)){chatterBody += 'Bank Account Type:' + newBankAccount.Type +'\n';}
        //if((newBankAccount.Custodian  != null) && (newBankAccount.Custodian  != bankAccList[0].WEG_Custodian__c)){chatterBody += 'Custodian: ' + newBankAccount.Custodian +'\n';}
        //if((newBankAccount.AccountNumber  != null) && (newBankAccount.AccountNumber  != bankAccList[0].FinServ__FinancialAccountNumber__c)){chatterBody += 'Account Number: ' + newBankAccount.AccountNumber +'\n';}
        //if((newBankAccount.Owner  != null) && newBankAccount.Owner != 'Joint' && (newBankAccount.Owner  != bankAccList[0].FinServ__PrimaryOwner__c)) {chatterBody += 'Owner: ' + accList[0].Name +'\n';}
        //if((newBankAccount.Owner  != null) && newBankAccount.Owner == 'Joint') {chatterBody += 'Owner: Joint Ownership \n';}
        //if((newBankAccount.AsOfDate  != null) && (newBankAccount.AsOfDate  != bankAccList[0].WEG_As_of_Date__c)){chatterBody += 'As Of Date: ' + newBankAccount.AsOfDate +'\n';}
        //if((newBankAccount.Amount  != null) && (newBankAccount.Amount  != bankAccList[0].FinServ__Balance__c)){chatterBody += 'Amount: ' + newBankAccount.Amount +'\n';}
        
        input.chatterBody = chatterBody;
        input.url = '/'+bankAccList[0].Id;
        input.urlLabel = bankAccList[0].Name;
        
        x7s_ChatterPostUtility.ChatterFeedItemAction(new List<x7s_ChatterPostUtility.ChatterPostInputs>{(input)});
    }

    /*
    @AuraEnabled
    public static void editBankAccount(String bankAccountId, String accountId, String bankAccountInfo) {

        List<FinServ__FinancialAccount__c> bankAccList;
        List<BankAccountWrapper> lstWrap = new List<BankAccountWrapper>();
        BankAccountWrapper newBankAccount;
        List<Account> accList;
        //Boolean editResult = false;
        
        List<RecordType> recType = new List<RecordType>();
        recType = [SELECT Id, Name FROM RecordType Where Name IN('Bank Account') LIMIT 1];
        
        if(accountId != null){
                
            accList = [SELECT Id, Name, WEGP1_Primary_Household__c,WEGP1_Primary_Household__r.Name,
                       WEGP1_Primary_Household__r.OwnerId, WEGP1_Primary_Household__r.WEGP1_Secondary_Individual__r.AccountId,
                       WEGP1_Primary_Household__r.Owner.CSChatterGroup__c, WEGP1_Primary_Household__r.WEGP1_Primary_Individual__r.AccountId
                       From Account 
                       WHERE Id =: accountId LIMIT 1];

        }

        if(bankAccountInfo != null){
            newBankAccount = (BankAccountWrapper) JSON.deserialize(bankAccountInfo, BankAccountWrapper.class);
        }
        bankAccList = [SELECT Id, Name, FinServ__FinancialAccountNumber__c,
                             WEG_Custodian__c, WEGP1_Owner_Type__c,  FinServ__PrimaryOwner__c,
                             WEG_As_of_Date__c, FinServ__Balance__c,
                             FinServ__Household__c, WEG_Account__c, FinServ__JointOwner__c, FinServ__FinancialAccountType__c
                             FROM FinServ__FinancialAccount__c
                           	WHERE Id =:bankAccountId LIMIT 1];

        List<Account> origOwner;
        List<Account> newOwner;
        if(bankAccList[0].FinServ__PrimaryOwner__c != newBankAccount.Owner){
                origOwner = [SELECT Id, Name From Account 
                                WHERE Id =: bankAccList[0].FinServ__PrimaryOwner__c LIMIT 1];
            
                newOwner = [SELECT Id, Name From Account 
                                WHERE Id =: newBankAccount.Owner LIMIT 1];
        }
        

        System.debug('BANK ACCOUNT INFO======>'+bankAccList[0]);
        System.debug('NEW BANK ACCOUNT INFO======>'+newBankAccount);

        ////////////////////
        String chatterBody = 'Portal - Net Worth Update Account ' + accList[0].WEGP1_Primary_Household__r.Name + '\n' + recType[0].Name +'\n';
        chatterBody += 'Changes:'+'\n';
        if((newBankAccount.Name  != null) && (newBankAccount.Name  != bankAccList[0].Name)){chatterBody += 'Bank Account Name: ' + bankAccList[0].Name + '=>' + newBankAccount.Name +'\n';}
        if((newBankAccount.Type  != null) && (newBankAccount.Type  != bankAccList[0].FinServ__FinancialAccountType__c)){chatterBody += 'Bank Account Type:' + bankAccList[0].FinServ__FinancialAccountType__c + '=>' + newBankAccount.Type +'\n';}
        if((newBankAccount.Custodian  != null) && (newBankAccount.Custodian  != bankAccList[0].WEG_Custodian__c)){chatterBody += 'Custodian: ' + bankAccList[0].WEG_Custodian__c + '=>'  + newBankAccount.Custodian +'\n';}
        if((newBankAccount.AccountNumber  != null) && (newBankAccount.AccountNumber  != bankAccList[0].FinServ__FinancialAccountNumber__c)){chatterBody += 'Account Number: ' + bankAccList[0].FinServ__FinancialAccountNumber__c + '=>' + newBankAccount.AccountNumber +'\n';}
        //if((newBankAccount.Owner  != null) && newBankAccount.Owner != 'Joint' && (newBankAccount.Owner  != bankAccList[0].FinServ__PrimaryOwner__c)) {chatterBody += 'Owner: ' + bankAccList[0].FinServ__PrimaryOwner__c + '=>' + newBankAccount.Owner +'\n';}
        if((newBankAccount.Owner  != null) && newBankAccount.Owner != 'Joint' && (newBankAccount.Owner  != bankAccList[0].FinServ__PrimaryOwner__c)) {chatterBody += 'Owner: ' + origOwner[0].Name + '=> ' + newOwner[0].Name +'\n';}

        if((newBankAccount.Owner  != null) && newBankAccount.Owner == 'Joint') {chatterBody += 'Owner: ' + newBankAccount.Owner + ' => Joint Ownership \n';}
        if((newBankAccount.AsOfDate  != null) && (newBankAccount.AsOfDate  != bankAccList[0].WEG_As_of_Date__c)){chatterBody += 'As Of Date: ' + bankAccList[0].WEG_As_of_Date__c + '=>' + newBankAccount.AsOfDate +'\n';}
        if((newBankAccount.Amount  != null) && (newBankAccount.Amount  != bankAccList[0].FinServ__Balance__c)){chatterBody += 'Amount: ' + bankAccList[0].FinServ__Balance__c + '=>' + newBankAccount.Amount + '\n';}
        ////////////////////

        bankAccList[0].Name = newBankAccount.Name;
        bankAccList[0].FinServ__FinancialAccountType__c = newBankAccount.Type;
        bankAccList[0].WEG_Custodian__c = newBankAccount.Custodian;
        bankAccList[0].WEG_As_of_Date__c = newBankAccount.AsOfDate;
        bankAccList[0].FinServ__Balance__c = newBankAccount.Amount;
        //bankAccList[0].WEGP1_AccumulationValue__c = newBankAccount.Amount;
        bankAccList[0].FinServ__FinancialAccountNumber__c = newBankAccount.AccountNumber;
        if(newBankAccount.Owner == 'Joint') {
            String primary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Primary_Individual__r?.AccountId;
            String secondary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Secondary_Individual__r?.AccountId;
            bankAccList[0].FinServ__PrimaryOwner__c = primary;
            bankAccList[0].FinServ__JointOwner__c = secondary;
        } else {
            bankAccList[0].FinServ__PrimaryOwner__c = newBankAccount.Owner;
            bankAccList[0].FinServ__JointOwner__c = null;
        }
        
        update bankAccList; 
        
        x7s_ChatterPostUtility.ChatterPostInputs input = new x7s_ChatterPostUtility.ChatterPostInputs();
        input.parentId = accList[0].WEGP1_Primary_Household__r.Owner.CSChatterGroup__c;
        input.userId = UserInfo.getUserId();
        
        //String chatterBody = 'Portal - Net Worth Update Account ' + accList[0].WEGP1_Primary_Household__r.Name + '\n' + recType[0].Name +'\n';
        //chatterBody += 'Changes:'+'\n';
        
        //if((newBankAccount.Name  != null) && (newBankAccount.Name  != bankAccList[0].Name)){chatterBody += 'Bank Account Name: ' + newBankAccount.Name +'\n';}
        //if((newBankAccount.Type  != null) && (newBankAccount.Type  != bankAccList[0].FinServ__FinancialAccountType__c)){chatterBody += 'Bank Account Type:' + newBankAccount.Type +'\n';}
        //if((newBankAccount.Custodian  != null) && (newBankAccount.Custodian  != bankAccList[0].WEG_Custodian__c)){chatterBody += 'Custodian: ' + newBankAccount.Custodian +'\n';}
        //if((newBankAccount.AccountNumber  != null) && (newBankAccount.AccountNumber  != bankAccList[0].FinServ__FinancialAccountNumber__c)){chatterBody += 'Account Number: ' + newBankAccount.AccountNumber +'\n';}
        //if((newBankAccount.Owner  != null) && newBankAccount.Owner != 'Joint' && (newBankAccount.Owner  != bankAccList[0].FinServ__PrimaryOwner__c)) {chatterBody += 'Owner: ' + accList[0].Name +'\n';}
        //if((newBankAccount.Owner  != null) && newBankAccount.Owner == 'Joint') {chatterBody += 'Owner: Joint Ownership \n';}
        //if((newBankAccount.AsOfDate  != null) && (newBankAccount.AsOfDate  != bankAccList[0].WEG_As_of_Date__c)){chatterBody += 'As Of Date: ' + newBankAccount.AsOfDate +'\n';}
        //if((newBankAccount.Amount  != null) && (newBankAccount.Amount  != bankAccList[0].FinServ__Balance__c)){chatterBody += 'Amount: ' + newBankAccount.Amount +'\n';}
        
        input.chatterBody = chatterBody;
        input.url = '/'+bankAccList[0].Id;
        input.urlLabel = bankAccList[0].Name;
        
        x7s_ChatterPostUtility.ChatterFeedItemAction(new List<x7s_ChatterPostUtility.ChatterPostInputs>{(input)});
    }*/
    
    
    @AuraEnabled
    Public static void addBankAccount(String accountId,String bankAccountInfo) {
        
        List<FinServ__FinancialAccount__c> bankAccList;
        List<BankAccountWrapper> lstWrap = new List<BankAccountWrapper>();
        List<RecordType> recType = new List<RecordType>();
        BankAccountWrapper newBankAccount;
        
        if(bankAccountInfo != null){
            newBankAccount = (BankAccountWrapper) JSON.deserialize(bankAccountInfo, BankAccountWrapper.class);
        }
        
        recType = [SELECT Id, Name FROM RecordType Where Name IN('Bank Account') LIMIT 1];
        System.debug('recType' + recType);

        User currentUser = [SELECT Id, ContactId, Contact.AccountId, Contact.Account.WEGP1_Primary_Household__c FROM User WHERE Id =: UserInfo.getUserId()];
        
        if(accountId != null){

            List<Account> accList = [SELECT Id, Name, WEGP1_Primary_Household__c,WEGP1_Primary_Household__r.Name,
                    WEGP1_Primary_Household__r.OwnerId, WEGP1_Primary_Household__r.WEGP1_Secondary_Individual__r.AccountId,
                    WEGP1_Primary_Household__r.Owner.CSChatterGroup__c, WEGP1_Primary_Household__r.WEGP1_Primary_Individual__r.AccountId
                                     From Account 
                                     WHERE Id =: accountId LIMIT 1];
            
            if(accList.size() > 0 && accList != null && accList[0].WEGP1_Primary_Household__c != null){

                FinServ__FinancialAccount__c bankAccount = new FinServ__FinancialAccount__c();
                if(newBankAccount.Owner == 'Joint') {
                    String primary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Primary_Individual__r?.AccountId;
                    String secondary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Secondary_Individual__r?.AccountId;
                    bankAccount = new FinServ__FinancialAccount__c(Name = newBankAccount.Name ,
                            FinServ__PrimaryOwner__c = primary,
                            FinServ__JointOwner__c = secondary,
                            RecordTypeId =  recType[0].Id,
                            FinServ__Household__c = accList[0].WEGP1_Primary_Household__c,
                            //WEG_Custodian__c = newBankAccount.Custodian,
                            WEG_As_of_Date__c = newBankAccount.AsOfDate,
                            FinServ__Balance__c = newBankAccount.Amount,
                            //WEGP1_AccumulationValue__c = newBankAccount.Amount,
                            FinServ__FinancialAccountType__c = newBankAccount.Type,
                            FinServ__FinancialAccountNumber__c = newBankAccount.AccountNumber);
                } else {
                    bankAccount = new FinServ__FinancialAccount__c(
                            Name = newBankAccount.Name ,
                            FinServ__PrimaryOwner__c = newBankAccount.Owner,
                            RecordTypeId =  recType[0].Id,
                            FinServ__Household__c = accList[0].WEGP1_Primary_Household__c,
                            //WEG_Custodian__c = newBankAccount.Custodian,
                            WEG_As_of_Date__c = newBankAccount.AsOfDate,
                            FinServ__Balance__c = newBankAccount.Amount,
                            //WEGP1_AccumulationValue__c = newBankAccount.Amount,
                            FinServ__FinancialAccountType__c = newBankAccount.Type,
                            FinServ__FinancialAccountNumber__c = newBankAccount.AccountNumber
                            );
                }

        		 insert bankAccount;
                
                x7s_ChatterPostUtility.ChatterPostInputs input = new x7s_ChatterPostUtility.ChatterPostInputs();
                input.parentId = accList[0].WEGP1_Primary_Household__r.Owner.CSChatterGroup__c;
                input.userId = UserInfo.getUserId();
                String chatterBody = 'Portal - Net Worth New Account ' + accList[0].WEGP1_Primary_Household__r.Name + '\n' + recType[0].Name +'\n';
                
                if(newBankAccount.Name  != null){chatterBody += 'Bank Account Name: ' + newBankAccount.Name +'\n';}
                if(newBankAccount.Type  != null){chatterBody += 'Bank Account Type:' + newBankAccount.Type +'\n';}
                //if(newBankAccount.Custodian  != null){chatterBody += 'Custodian: ' + newBankAccount.Custodian +'\n';}
                if(newBankAccount.AccountNumber  != null){chatterBody += 'Account Number: ' + newBankAccount.AccountNumber +'\n';}
                if(newBankAccount.Owner  != null){chatterBody += 'Owner: ' + accList[0].Name +'\n';}
                if(newBankAccount.AsOfDate  != null){chatterBody += 'As Of Date: ' + newBankAccount.AsOfDate +'\n';}
                if(newBankAccount.Amount  != null){chatterBody += 'Amount: ' + newBankAccount.Amount +'\n';}

                
                input.chatterBody = chatterBody;
                input.url = '/'+bankAccount.Id;
                input.urlLabel = bankAccount.Name;
                
                x7s_ChatterPostUtility.ChatterFeedItemAction(new List<x7s_ChatterPostUtility.ChatterPostInputs>{(input)});
        
            }
        }
        
    }
}