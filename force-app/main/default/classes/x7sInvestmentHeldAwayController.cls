public without sharing class x7sInvestmentHeldAwayController {

    Public class InvestmentHeldAwayWrapper{
        @AuraEnabled public String AccountName { get; set; }
        @AuraEnabled public String Custodian { get; set; }
        @AuraEnabled public String AccountType { get; set; }
        @AuraEnabled public String Owner { get; set; }
        @AuraEnabled public String AccountNumber { get; set; }
        @AuraEnabled public Date AsOfDate { get; set; }
        @AuraEnabled public Decimal Value { get; set; }
    }

	@AuraEnabled (cacheable=true)
    public static List<FinServ__FinancialAccount__c> getInvestmentHeldAwayDetails(String accountId){
        
        List<FinServ__FinancialAccount__c> invAccList;
        
        if(accountId != null){
            
            List<Account> accList = [SELECT Id, Name, WEGP1_Primary_Household__c 
                                     From Account 
                                     WHERE Id =: accountId LIMIT 1];
            
            if(accList.size() > 0 && accList != null && accList[0].WEGP1_Primary_Household__c != null){

                Id houseHoldId = (Id) accList[0].WEGP1_Primary_Household__c;
               	invAccList = [SELECT Id,Name, FinServ__FinancialAccountNumber__c,FinServ__PrimaryOwner__c, FinServ__JointOwner__c,
                             WEG_Custodian__c, WEGP1_Owner_Type__c, FinServ__FinancialAccountType__c,FinServ__RecordTypeName__c,
                             WEG_As_of_Date__c, FinServ__Balance__c,WEG_Registration_Type__c,
                             FinServ__Household__c, WEG_Account__c, WEGP1_AccumulationValue__c, FinServ__HeldAway__c
                FROM FinServ__FinancialAccount__c
                             WHERE FinServ__Household__c = :houseHoldId
                             AND RecordType.Name IN('Advisory Investment Account','Annuity Investment Account','Brokerage Investment Account','ERP Investment Account','Investment Account', 'Other Investment Account')
                             AND Remove_or_Historic__c = ''
                             AND WEG_External_Rec_ID__c = '' 
                             AND FinServ__HeldAway__c = True //Added By Janavi
                             AND FinServ__Status__c = 'Open'
                             AND WEGP1_ExcludeFromReview__c = false
                             ORDER BY FinServ__HeldAway__c DESC, FinServ__Balance__c DESC];
            }
            
        }
        return invAccList;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getAccountType() {

        List<String> pickListValuesList= new List<String>();
        
        Schema.DescribeFieldResult fieldResult = FinServ__FinancialAccount__c.WEG_Registration_Type__c.getDescribe();
        //Schema.DescribeFieldResult fieldResult = FinServ__FinancialAccount__c.FinServ__FinancialAccountType__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
		for(Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getValue());
        }
		return pickListValuesList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getCustodian() {

        List<String> pickListValuesList= new List<String>();
        
        Schema.DescribeFieldResult fieldResult = FinServ__FinancialAccount__c.WEG_Custodian__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
		for(Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getValue());
        }
		return pickListValuesList;
    }

    @AuraEnabled
    public static void editInvestmentHeldAway(String investmentHeldAwayId,String accountId,String investmentHeldAwayInfo) {
        
        List<FinServ__FinancialAccount__c> invHeldAwayList;
        List<InvestmentHeldAwayWrapper> lstWrap = new List<InvestmentHeldAwayWrapper>();
        InvestmentHeldAwayWrapper newInvHeldAway;
        List<Account> accList;
        //Boolean editResult = false;
        
        List<RecordType> recType = new List<RecordType>();
        
        if(accountId != null){

            accList = [SELECT Id, Name, WEGP1_Primary_Household__c,WEGP1_Primary_Household__r.Name,
                    WEGP1_Primary_Household__r.OwnerId, WEGP1_Primary_Household__r.WEGP1_Secondary_Individual__r.AccountId,
                    WEGP1_Primary_Household__r.Owner.CSChatterGroup__c, WEGP1_Primary_Household__r.WEGP1_Primary_Individual__r.AccountId
            From Account
            WHERE Id =: accountId LIMIT 1];
        }

        if(investmentHeldAwayInfo != null){
            newInvHeldAway = (InvestmentHeldAwayWrapper) JSON.deserialize(investmentHeldAwayInfo, InvestmentHeldAwayWrapper.class);
        }
        invHeldAwayList = [SELECT Id,Name, FinServ__FinancialAccountNumber__c,FinServ__PrimaryOwner__c,
                        WEG_Custodian__c, WEGP1_Owner_Type__c, FinServ__FinancialAccountType__c,
                        WEG_As_of_Date__c, FinServ__Balance__c,FinServ__RecordTypeName__c, WEG_Registration_Type__c,
                        FinServ__Household__c, WEG_Account__c, WEGP1_AccumulationValue__c, FinServ__HeldAway__c
                        FROM FinServ__FinancialAccount__c
                        WHERE Id =:investmentHeldAwayId LIMIT 1];
        

        String prevCustodian = invHeldAwayList[0].WEG_Custodian__c;
        invHeldAwayList[0].WEG_Custodian__c = newInvHeldAway.Custodian;
        String prevAccountType = invHeldAwayList[0].WEG_Registration_Type__c;
        invHeldAwayList[0].WEG_Registration_Type__c = newInvHeldAway.AccountType;

        List<Account> origOwner;
        if(invHeldAwayList[0].WEGP1_Owner_Type__c != 'Joint'){
            origOwner = [SELECT Id, Name From Account 
                                    WHERE Id =: invHeldAwayList[0].FinServ__PrimaryOwner__c LIMIT 1];
        }

        List<Account> newOwner;
        if( newInvHeldAway.Owner != 'Joint' ){
            newOwner = [SELECT Id, Name From Account 
                                WHERE Id =: newInvHeldAway.Owner LIMIT 1];
        }

        String chatterBody = 'Portal - Net Worth Update Account ' + accList[0].WEGP1_Primary_Household__r.Name + '\n' + invHeldAwayList[0].FinServ__RecordTypeName__c +'\n';

        if((newInvHeldAway.Custodian  != null) && (newInvHeldAway.Custodian  != prevCustodian)){chatterBody += 'Custodian: ' + prevCustodian + ' => ' + newInvHeldAway.Custodian +'\n';}
        if((newInvHeldAway.AccountType  != null) && (newInvHeldAway.AccountType  != prevAccountType)){chatterBody += 'Account Type:' + prevAccountType + ' => ' + newInvHeldAway.AccountType +'\n';}
        
        if((newInvHeldAway.Owner  != null) && newInvHeldAway.Owner != 'Joint') {
            if(invHeldAwayList[0].WEGP1_Owner_Type__c != 'Joint'){
                chatterBody += 'Owner: ' + origOwner[0].Name + ' => ' + newOwner[0].Name +'\n';
            }else{
                chatterBody += 'Owner: ' + 'Joint' + ' => ' + newOwner[0].Name +'\n';
            }
        }

                                            // if((newInvHeldAway.Owner  != null) && newInvHeldAway.Owner == 'Joint') {
                                            //     chatterBody += 'Owner: ' + origOwner[0].Name + ' =>  Joint  \n';
                                            // }

        if(newInvHeldAway.Owner == 'Joint') {
            String primary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Primary_Individual__r?.AccountId;
            String secondary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Secondary_Individual__r?.AccountId;
            invHeldAwayList[0].FinServ__PrimaryOwner__c = primary;
            invHeldAwayList[0].FinServ__JointOwner__c = secondary;
        } else {
            invHeldAwayList[0].FinServ__PrimaryOwner__c = newInvHeldAway.Owner;
            invHeldAwayList[0].FinServ__JointOwner__c = null;
        }

        String prevAccountNumber = invHeldAwayList[0].FinServ__FinancialAccountNumber__c;
        if((newInvHeldAway.AccountNumber  != null) && (newInvHeldAway.AccountNumber  != prevAccountNumber)){chatterBody += 'Account Number: ' + prevAccountNumber + ' => ' + newInvHeldAway.AccountNumber +'\n';}
        if((newInvHeldAway.AccountName  != null) && (invHeldAwayList[0].Name  != newInvHeldAway.AccountName)){chatterBody += 'Account Name ' + invHeldAwayList[0].Name + ' => ' + newInvHeldAway.AccountName +'\n';}

        invHeldAwayList[0].Name = newInvHeldAway.AccountName;
        invHeldAwayList[0].FinServ__FinancialAccountNumber__c = newInvHeldAway.AccountNumber;
        DateTime prevAsOfDate = invHeldAwayList[0].WEG_As_of_Date__c;
        if((newInvHeldAway.AsOfDate  != null) && (newInvHeldAway.AsOfDate  != prevAsOfDate)){chatterBody += 'As Of Date: ' + prevAsOfDate + ' => ' + newInvHeldAway.AsOfDate +'\n';}
        invHeldAwayList[0].WEG_As_of_Date__c = newInvHeldAway.AsOfDate;

        Decimal prevValue = invHeldAwayList[0].FinServ__Balance__c;
        if((newInvHeldAway.Value  != null) && (newInvHeldAway.Value  != prevValue)){chatterBody += 'value: ' + prevValue + ' => ' + newInvHeldAway.Value +'\n';}

        invHeldAwayList[0].FinServ__Balance__c = newInvHeldAway.Value;
        
        update invHeldAwayList;
        
        String ownerName = '';
        if(newInvHeldAway.Owner == 'Joint')
            ownerName = 'Joint';
        else{
            if(invHeldAwayList[0].Id != null){
                FinServ__FinancialAccount__c fa = [Select Id,Name, FinServ__PrimaryOwner__c, FinServ__PrimaryOwner__r.Name 
                                                   From FinServ__FinancialAccount__c 
                                                   Where Id = :invHeldAwayList[0].Id LIMIT 1]; 
                ownerName = fa.FinServ__PrimaryOwner__r.Name;
            }
        }
        
        x7s_ChatterPostUtility.ChatterPostInputs input = new x7s_ChatterPostUtility.ChatterPostInputs();
        input.parentId = accList[0].WEGP1_Primary_Household__r.Owner.CSChatterGroup__c;
        input.userId = UserInfo.getUserId();
        input.chatterBody = chatterBody;
        input.url = '/'+invHeldAwayList[0].Id;
        input.urlLabel = invHeldAwayList[0].Name;
        
        x7s_ChatterPostUtility.ChatterFeedItemAction(new List<x7s_ChatterPostUtility.ChatterPostInputs>{(input)});
      
    }

    @AuraEnabled
    Public static void addInvestmentHeldAway(String accountId,String investmentHeldAwayInfo) {
        
        List<FinServ__FinancialAccount__c> invHeldAwayList;
        List<InvestmentHeldAwayWrapper> lstWrap = new List<InvestmentHeldAwayWrapper>();
        List<RecordType> recType = new List<RecordType>();
        InvestmentHeldAwayWrapper newInvHeldAway;
        List<Account> accList;
        
        if(investmentHeldAwayInfo != null){
            newInvHeldAway = (InvestmentHeldAwayWrapper) JSON.deserialize(investmentHeldAwayInfo, InvestmentHeldAwayWrapper.class);
        }

        recType = [SELECT Id, Name FROM RecordType Where Name = 'Investment Account' LIMIT 1];
        
        if(accountId != null){

            accList = [SELECT Id, Name, WEGP1_Primary_Household__c,WEGP1_Primary_Household__r.Name,
                    WEGP1_Primary_Household__r.OwnerId, WEGP1_Primary_Household__r.WEGP1_Secondary_Individual__r.AccountId,
                    WEGP1_Primary_Household__r.Owner.CSChatterGroup__c, WEGP1_Primary_Household__r.WEGP1_Primary_Individual__r.AccountId
            From Account
            WHERE Id =: accountId LIMIT 1];
            
            if(accList.size() > 0 && accList != null && accList[0].WEGP1_Primary_Household__c != null){

                FinServ__FinancialAccount__c invHelAway = new FinServ__FinancialAccount__c();
                if(newInvHeldAway.Owner == 'Joint') {
                    String primary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Primary_Individual__r?.AccountId;
                    String secondary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Secondary_Individual__r?.AccountId;
                    invHelAway = new FinServ__FinancialAccount__c(
                            Name = newInvHeldAway.AccountName,
                            FinServ__PrimaryOwner__c = primary,
                            FinServ__JointOwner__c = secondary,
                            RecordTypeId =  recType[0].Id,
                            FinServ__Household__c = accList[0].WEGP1_Primary_Household__c,
                            WEG_Custodian__c = newInvHeldAway.Custodian,
                            WEG_As_of_Date__c = newInvHeldAway.AsOfDate,
                            FinServ__Balance__c = newInvHeldAway.Value,
                        	WEG_Registration_Type__c = newInvHeldAway.AccountType,
                            //FinServ__FinancialAccountType__c = newInvHeldAway.AccountType,
                            FinServ__FinancialAccountNumber__c = newInvHeldAway.AccountNumber,
                            FinServ__Status__c = 'Open',
                            FinServ__HeldAway__c = True);
                } else {
                    invHelAway = new FinServ__FinancialAccount__c(
                            Name = newInvHeldAway.AccountName,
                            FinServ__PrimaryOwner__c = newInvHeldAway.Owner,
                            RecordTypeId =  recType[0].Id,
                            FinServ__Household__c = accList[0].WEGP1_Primary_Household__c,
                            WEG_Custodian__c = newInvHeldAway.Custodian,
                            WEG_As_of_Date__c = newInvHeldAway.AsOfDate,
                            FinServ__Balance__c = newInvHeldAway.Value,
                            WEG_Registration_Type__c = newInvHeldAway.AccountType,
                            //FinServ__FinancialAccountType__c = newInvHeldAway.AccountType,
                            FinServ__FinancialAccountNumber__c = newInvHeldAway.AccountNumber,
                            FinServ__Status__c = 'Open',
                            FinServ__HeldAway__c = True);
                }

        		 insert invHelAway;
                
                String ownerName = '';
                if(newInvHeldAway.Owner == 'Joint')
                    ownerName = 'Joint';
                else{
                    if(invHelAway.Id != null){
                        FinServ__FinancialAccount__c fa = [Select Id,Name, FinServ__PrimaryOwner__c, FinServ__PrimaryOwner__r.Name 
                            							From FinServ__FinancialAccount__c 
                            							Where Id = :invHelAway.Id LIMIT 1]; 
                        ownerName = fa.FinServ__PrimaryOwner__r.Name;
                    }
                }
                
                x7s_ChatterPostUtility.ChatterPostInputs input = new x7s_ChatterPostUtility.ChatterPostInputs();
                input.parentId = accList[0].WEGP1_Primary_Household__r.Owner.CSChatterGroup__c;
                input.userId = UserInfo.getUserId();
                String chatterBody = 'Portal - Net Worth New Account ' + accList[0].WEGP1_Primary_Household__r.Name + '\n' + recType[0].Name +'\n';
                
                if(newInvHeldAway.Custodian  != null){chatterBody += 'Custodian: ' + newInvHeldAway.Custodian +'\n';}
                if(newInvHeldAway.AccountType  != null){chatterBody += 'Account Type:' + newInvHeldAway.AccountType +'\n';}
                if(newInvHeldAway.Owner  != null){chatterBody += 'Owner: ' + ownerName +'\n';}
                if(newInvHeldAway.AccountNumber  != null){chatterBody += 'Account Number: ' + newInvHeldAway.AccountNumber +'\n';}
                if(newInvHeldAway.AsOfDate  != null){chatterBody += 'As Of Date: ' + newInvHeldAway.AsOfDate +'\n';}
                if(newInvHeldAway.Value  != null){chatterBody += 'value: ' + newInvHeldAway.Value +'\n';}
                
                input.chatterBody = chatterBody;
                input.url = '/'+invHelAway.Id;
                input.urlLabel = invHelAway.Name;
                
                x7s_ChatterPostUtility.ChatterFeedItemAction(new List<x7s_ChatterPostUtility.ChatterPostInputs>{(input)});
                        
            }
        }
        
    }
}