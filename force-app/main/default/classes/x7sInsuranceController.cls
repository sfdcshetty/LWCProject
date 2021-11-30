public without sharing class x7sInsuranceController {
	
    Public class InsuranceWrapper{
        //@AuraEnabled public String Custodian { get; set; }
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public String InsuranceRecordType { get; set; }
        @AuraEnabled public String InsuranceName { get; set; }
        @AuraEnabled public String serviceProvider { get; set; }
        @AuraEnabled public String ProductType { get; set; }
        @AuraEnabled public String Carrier { get; set; }
        @AuraEnabled public String Policy { get; set; }
        @AuraEnabled public String OwnerName { get; set; }
        @AuraEnabled public String Insured { get; set; }
        @AuraEnabled public String InsuredAsset { get; set; }
        @AuraEnabled public Date AsOfDate { get; set; }
        @AuraEnabled public Decimal DeathBenefit { get; set; }
        @AuraEnabled public Decimal BenefitAmount { get; set; }
        @AuraEnabled public Decimal Premium { get; set; }
        @AuraEnabled public Decimal CoverageAmount { get; set; }
        @AuraEnabled public Decimal Amount { get; set; }
        @AuraEnabled public Decimal CashValue { get; set; }
        @AuraEnabled public String RecordType { get; set; }
    }
    
    public class InsuranceListResultWrapper {
        @AuraEnabled public List<InsuranceWrapper> all{get; set;}
        @AuraEnabled public List<InsuranceWrapper> insuranceDisability{get; set;}
        @AuraEnabled public List<InsuranceWrapper> insuranceHealth{get; set;}
        @AuraEnabled public List<InsuranceWrapper> insuranceLife{get; set;}
        @AuraEnabled public List<InsuranceWrapper> insuranceLongTermCare{get; set;}
        @AuraEnabled public List<InsuranceWrapper> insuranceOther{get; set;}
        @AuraEnabled public List<InsuranceWrapper> insurancePropertyAndCasualty{get; set;}
        
        public InsuranceListResultWrapper(List<InsuranceWrapper> all, 
                                        List<InsuranceWrapper> insuranceDisability, 
                                        List<InsuranceWrapper> insuranceHealth, 
                                        List<InsuranceWrapper> insuranceLife, 
                                        List<InsuranceWrapper> insuranceLongTermCare, 
                                        List<InsuranceWrapper> insuranceOther, 
                                        List<InsuranceWrapper> insurancePropertyAndCasualty) {
            this.all = all;
            this.insuranceDisability = insuranceDisability;
            this.insuranceHealth = insuranceHealth;
            this.insuranceLife = insuranceLife;
            this.insuranceLongTermCare = insuranceLongTermCare;
            this.insuranceOther = insuranceOther;
            this.insurancePropertyAndCasualty = insurancePropertyAndCasualty;
                                           
        }
    }
    
    @AuraEnabled (cacheable=true)
    public static InsuranceListResultWrapper getInsuranceDetails(String accountId){
        List<InsuranceWrapper> lstWrap = new List<InsuranceWrapper>();
        List<InsuranceWrapper> lstInsuranceDisability = new List<InsuranceWrapper>();
        List<InsuranceWrapper> lstInsuranceHealth = new List<InsuranceWrapper>();
        List<InsuranceWrapper> lstInsuranceLife = new List<InsuranceWrapper>();
        List<InsuranceWrapper> lstInsuranceLongTermCare = new List<InsuranceWrapper>();
        List<InsuranceWrapper> lstInsuranceOther = new List<InsuranceWrapper>();
        List<InsuranceWrapper> lstInsurancePropertyAndCasualty = new List<InsuranceWrapper>();
        
        //accountId = '0012f00000cWqUiAAK';
        List<Account> accList;
        
        if(accountId != null){
            accList = [SELECT Id, Name, WEGP1_Primary_Household__c 
                                     From Account 
                                     WHERE Id =: accountId LIMIT 1];
        }
        
        List<FinServ__FinancialAccount__c> insuranceList;
        //if(accList.size() > 0 && accList != null && accList[0].WEGP1_Primary_Household__c != null){
            //Id houseHoldId = (Id)('0012f00000cWqTTAA0');
        	//Id houseHoldId = (Id)('0012f00000cWqUaAAK');
        
            //Id houseHoldId = accList[0].WEGP1_Primary_Household__c;
            insuranceList = [SELECT id,Name, WEG_Product_Type__c,WEG_Custodian__c, FinServ__FinancialAccountNumber__c,FinServ__ServiceProvider__c,
                             WEGP1_Owner_Type__c, FinServ__JointOwner__c,FinServ__Ownership__c, FinServ__PrimaryOwner__c, WEGP1_Insured__c, WEG_Insured_Asset__c, FinServ__LastUpdated__c, WEGP1_TotalDeathBenefit__c, 
                             FinServ__InsuredAmount__c, FinServ__Premium__c, WEG_Liability_Coverage__c, WEGP1_AccumulationValue__c,FinServ__RecordTypeName__c 
                             FROM FinServ__FinancialAccount__c 
                             WHERE FinServ__Household__c =: accList[0].WEGP1_Primary_Household__c
                             AND Remove_or_Historic__c = ''
                             AND FinServ__Status__c = 'Open'
                             AND WEGP1_ExcludeFromReview__c = false];
        	system.debug('riddhi household = '+accList[0].WEGP1_Primary_Household__c);
        	system.debug('riddhi insuranceList size = '+insuranceList.size());
        	/*insuranceList = [SELECT id,Name, WEG_Product_Type__c,WEG_Custodian__c, FinServ__FinancialAccountNumber__c, 
                             FinServ__Ownership__c, WEGP1_Insured__c, WEG_Insured_Asset__c, WEGP1_PolicyDate__c, SK_Death_Benefit_Loss_Amount__c, 
                             FinServ__InsuredAmount__c, FinServ__Premium__c, WEG_Liability_Coverage__c, WEGP1_AccumulationValue__c,FinServ__RecordTypeName__c 
                             FROM FinServ__FinancialAccount__c 
                             WHERE FinServ__Household__c =:houseHoldId
                             AND FinServ__RecordTypeName__c LIKE '%Insurance -%'];*/
        
		//}
        for(FinServ__FinancialAccount__c i : insuranceList) {
            InsuranceWrapper insurance = new InsuranceWrapper();
            insurance.Id = i.id;
            insurance.serviceProvider = i.FinServ__ServiceProvider__c;
            insurance.InsuranceName = i.Name;
            insurance.ProductType = i.WEG_Product_Type__c;
            insurance.Carrier = i.WEG_Custodian__c;
            insurance.Policy = i.FinServ__FinancialAccountNumber__c;
            insurance.OwnerName = i.FinServ__Ownership__c;
            //insurance.OwnerName = i.FinServ__PrimaryOwner__c;
            insurance.Insured = i.WEGP1_Insured__c;
            insurance.InsuredAsset = i.WEG_Insured_Asset__c;
            insurance.AsOfDate = i.FinServ__LastUpdated__c;
            insurance.DeathBenefit = i.WEGP1_TotalDeathBenefit__c;
            insurance.BenefitAmount = i.FinServ__InsuredAmount__c;
            insurance.Premium = i.FinServ__Premium__c;
            insurance.CoverageAmount = i.WEG_Liability_Coverage__c;
            insurance.Amount = i.FinServ__InsuredAmount__c;
            insurance.CashValue = i.WEGP1_AccumulationValue__c;
            insurance.RecordType = i.FinServ__RecordTypeName__c;
            
            if(i.FinServ__RecordTypeName__c == 'Insurance - Disability') {
                lstInsuranceDisability.add(insurance);
            } else if(i.FinServ__RecordTypeName__c == 'Insurance - Health') {
                lstInsuranceHealth.add(insurance);
            } else if(i.FinServ__RecordTypeName__c == 'Insurance - Life') {
                lstInsuranceLife.add(insurance);
            } else if(i.FinServ__RecordTypeName__c == 'Insurance - Long Term Care') {
                lstInsuranceLongTermCare.add(insurance);
            } else if(i.FinServ__RecordTypeName__c == 'Insurance - Other') {
                lstInsuranceOther.add(insurance);
            } else if(i.FinServ__RecordTypeName__c == 'Insurance - Property & Casualty') {
                lstInsurancePropertyAndCasualty.add(insurance);
            }
            
            lstWrap.add(insurance);
        }

		InsuranceListResultWrapper insuranceResult = new InsuranceListResultWrapper(lstWrap, 
                                                                                    lstInsuranceDisability, 
                                                                                    lstInsuranceHealth,
                                                                                    lstInsuranceLife,
                                                                                    lstInsuranceLongTermCare,
                                                                                    lstInsuranceOther,
                                                                                    lstInsurancePropertyAndCasualty);        
        System.debug('insuranceList = '+lstWrap);
        System.debug('insuranceList size ='+lstWrap.size());
        //return lstWrap;
        return insuranceResult;
    }
    
    @AuraEnabled (cacheable=true)
    public static List<RecordType> getInsuranceRecordType(){
        return [SELECT Id,Name From RecordType Where Name LIKE '%Insurance -%'];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getCustodianType() {

        List<String> pickListValuesList= new List<String>();
        
        Schema.DescribeFieldResult fieldResult = FinServ__FinancialAccount__c.WEG_Custodian__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
		for(Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getValue());
        }
		return pickListValuesList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getProductType() {

        List<String> pickListValuesList= new List<String>();
        
        Schema.DescribeFieldResult fieldResult = FinServ__FinancialAccount__c.WEG_Product_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
		for(Schema.PicklistEntry pickListVal : ple){
             if(pickListVal.isActive()){
            	pickListValuesList.add(pickListVal.getValue());
             }
        }
		return pickListValuesList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getInsuredList() {

        List<String> pickListValuesList= new List<String>();
        
        Schema.DescribeFieldResult fieldResult = FinServ__FinancialAccount__c.WEGP1_Insured__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
		for(Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getValue());
        }
		return pickListValuesList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getOwnerList() {

        List<String> pickListValuesList= new List<String>();
        
        Schema.DescribeFieldResult fieldResult = FinServ__FinancialAccount__c.FinServ__Ownership__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
		for(Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getValue());
        }
		return pickListValuesList;
    }
    
    @AuraEnabled
    public static void editInsurance(String insuranceId,String accountId,String insuranceInfo) {
        List<FinServ__FinancialAccount__c> insuranceList;
        List<InsuranceWrapper> lstWrap = new List<InsuranceWrapper>();
        List<RecordType> recType = new List<RecordType>();
        InsuranceWrapper newInsurance;
        List<Account> accList;
                
        if(accountId != null){
            
            accList = [SELECT Id, Name, WEGP1_Primary_Household__c, WEGP1_Primary_Household__r.Name,
                WEGP1_Primary_Household__r.OwnerId, WEGP1_Primary_Household__r.WEGP1_Secondary_Individual__r.AccountId, WEGP1_Primary_Household__r.WEGP1_Secondary_Individual__r.Name,
                WEGP1_Primary_Household__r.Owner.CSChatterGroup__c, WEGP1_Primary_Household__r.WEGP1_Primary_Individual__r.AccountId, WEGP1_Primary_Household__r.WEGP1_Primary_Individual__r.Name
                From Account 
                WHERE Id =: accountId LIMIT 1];
        }
        
        if(insuranceInfo != null){
            newInsurance = (InsuranceWrapper) JSON.deserialize(insuranceInfo, InsuranceWrapper.class);
            System.debug('NEW INSURANCE INFO===>'+newInsurance);
        }
        
        insuranceList = [SELECT id,Name, WEG_Product_Type__c,WEG_Custodian__c, FinServ__FinancialAccountNumber__c, FinServ__ServiceProvider__c,
                             FinServ__Ownership__c, WEGP1_Insured__c, WEG_Insured_Asset__c, FinServ__LastUpdated__c, WEGP1_TotalDeathBenefit__c, 
                             FinServ__InsuredAmount__c, FinServ__Premium__c, WEG_Liability_Coverage__c, WEGP1_AccumulationValue__c,FinServ__RecordTypeName__c 
                             FROM FinServ__FinancialAccount__c
                             WHERE Id =: insuranceId];
        
        Decimal amt = 0.00;
        if(insuranceList[0].FinServ__RecordTypeName__c == 'Insurance - Other')
            amt = newInsurance.Amount;
        else
            amt = newInsurance.BenefitAmount;

        
        String chatterBody = 'Portal - Net Worth New Account ' + accList[0].WEGP1_Primary_Household__r.Name + '\n' + insuranceList[0].FinServ__RecordTypeName__c +'\n';
        chatterBody += 'Changes:'+'\n';

        if((newInsurance.ProductType  != null) && (newInsurance.ProductType != insuranceList[0].WEG_Product_Type__c)){chatterBody += 'Insurance Plan Type: ' + insuranceList[0].WEG_Product_Type__c + ' => ' + newInsurance.ProductType +'\n';}
        if((newInsurance.serviceProvider  != null) && (newInsurance.serviceProvider != insuranceList[0].FinServ__ServiceProvider__c)){chatterBody += 'Carrier:' + insuranceList[0].FinServ__ServiceProvider__c + ' => ' + newInsurance.serviceProvider +'\n';}
        //if((newInsurance.Carrier  != null) && (newInsurance.Carrier != insuranceList[0].WEG_Custodian__c)){chatterBody += 'Carrier:' + newInsurance.Carrier +'\n';}
        if((newInsurance.Policy  != null) && (newInsurance.Policy != insuranceList[0].FinServ__FinancialAccountNumber__c)){chatterBody += 'Policy Number: ' + insuranceList[0].FinServ__FinancialAccountNumber__c + ' => ' + newInsurance.Policy +'\n';}
        //if((newInsurance.OwnerName  != null) && (newInsurance.OwnerName != insuranceList[0].FinServ__Ownership__c)){chatterBody += 'Owner: ' + insuranceList[0].FinServ__Ownership__c + ' => ' + newInsurance.OwnerName +'\n';}
        if((newInsurance.Insured  != null) && (newInsurance.Insured != insuranceList[0].WEGP1_Insured__c)){chatterBody += 'Insured: ' + insuranceList[0].WEGP1_Insured__c + ' => ' + newInsurance.Insured +'\n';}
        
        if((newInsurance.InsuredAsset  != null) && (newInsurance.InsuredAsset != insuranceList[0].WEG_Insured_Asset__c)){chatterBody += 'InsuredAsset: ' + insuranceList[0].WEG_Insured_Asset__c + ' => ' + newInsurance.InsuredAsset +'\n';}

        
        if((newInsurance.AsOfDate  != null) && (newInsurance.AsOfDate != insuranceList[0].FinServ__LastUpdated__c)){chatterBody += 'As of Date: ' + insuranceList[0].FinServ__LastUpdated__c + ' => ' + newInsurance.AsOfDate +'\n';}
        if((newInsurance.DeathBenefit  != null) && (newInsurance.DeathBenefit != insuranceList[0].WEGP1_TotalDeathBenefit__c)){chatterBody += 'Death Benefit: ' + insuranceList[0].WEGP1_TotalDeathBenefit__c + ' => ' + newInsurance.DeathBenefit +'\n';}
        if(newInsurance.InsuranceRecordType != 'Other' && (amt != null) && (amt != insuranceList[0].FinServ__InsuredAmount__c)){chatterBody += 'Benefit: ' + insuranceList[0].FinServ__InsuredAmount__c + ' => ' + amt +'\n';}

        if((newInsurance.Premium  != null) && (newInsurance.Premium != insuranceList[0].FinServ__Premium__c)){chatterBody += 'Premium:: ' + insuranceList[0].FinServ__Premium__c + ' => ' +  newInsurance.Premium +'\n';}
        if((newInsurance.CoverageAmount  != null) && (newInsurance.CoverageAmount != insuranceList[0].WEG_Liability_Coverage__c)){chatterBody += 'Coverage Amount: ' + insuranceList[0].WEG_Liability_Coverage__c + ' => ' + newInsurance.CoverageAmount +'\n';}
        if((newInsurance.Amount  != null) && (newInsurance.Amount != insuranceList[0].FinServ__InsuredAmount__c)){chatterBody += 'Amount: ' + insuranceList[0].FinServ__InsuredAmount__c + '=>' + newInsurance.Amount +'\n';}
        if((newInsurance.CashValue  != null)&& (newInsurance.CashValue != insuranceList[0].WEGP1_AccumulationValue__c)){chatterBody += 'Cash Value: ' + insuranceList[0].WEGP1_AccumulationValue__c + ' => ' + newInsurance.CashValue +'\n';}
    

        //ADD LOGIC TO UPDATE Primary and Joint Ownership fields ON JOINT OWNERSHIP
        String primary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Primary_Individual__r?.AccountId;
        String secondary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Secondary_Individual__r?.AccountId;
        String primaryName = accList[0].WEGP1_Primary_Household__r?.WEGP1_Primary_Individual__r?.Name;
        String secondaryName = accList[0].WEGP1_Primary_Household__r?.WEGP1_Secondary_Individual__r?.Name;
        if(newInsurance.OwnerName == 'Joint Ownership') {
            insuranceList[0].FinServ__PrimaryOwner__c = primary;
            insuranceList[0].FinServ__JointOwner__c = secondary;
            insuranceList[0].Name = newInsurance.InsuranceName; 
            insuranceList[0].WEG_Product_Type__c = newInsurance.ProductType; 
            insuranceList[0].FinServ__ServiceProvider__c = newInsurance.serviceProvider;
            insuranceList[0].FinServ__FinancialAccountNumber__c = newInsurance.Policy;  
            insuranceList[0].FinServ__Ownership__c = newInsurance.OwnerName; 
            insuranceList[0].WEGP1_Insured__c = newInsurance.Insured; 
            insuranceList[0].WEG_Insured_Asset__c = newInsurance.InsuredAsset;
            insuranceList[0].FinServ__LastUpdated__c = newInsurance.AsOfDate; 
            insuranceList[0].WEGP1_TotalDeathBenefit__c = newInsurance.DeathBenefit; 
            insuranceList[0].FinServ__Premium__c =  newInsurance.Premium;  
            insuranceList[0].WEG_Liability_Coverage__c = newInsurance.CoverageAmount; 
            insuranceList[0].FinServ__InsuredAmount__c = amt; 
            insuranceList[0].WEGP1_AccumulationValue__c = newInsurance.CashValue; 
            insuranceList[0].FinServ__Status__c = 'Open';
        } else {
            if(newInsurance.OwnerName == secondaryName){
                insuranceList[0].FinServ__PrimaryOwner__c = secondary;
            } else {
                insuranceList[0].FinServ__PrimaryOwner__c = primary;
            }
            insuranceList[0].FinServ__JointOwner__c = null;
            insuranceList[0].Name = newInsurance.InsuranceName; 
            insuranceList[0].WEG_Product_Type__c = newInsurance.ProductType; 
            insuranceList[0].FinServ__ServiceProvider__c = newInsurance.serviceProvider;
            insuranceList[0].FinServ__FinancialAccountNumber__c = newInsurance.Policy;  
            insuranceList[0].FinServ__Ownership__c = newInsurance.OwnerName; 
            insuranceList[0].WEGP1_Insured__c = newInsurance.Insured; 
            insuranceList[0].WEG_Insured_Asset__c = newInsurance.InsuredAsset;
            insuranceList[0].FinServ__LastUpdated__c = newInsurance.AsOfDate; 
            insuranceList[0].WEGP1_TotalDeathBenefit__c = newInsurance.DeathBenefit; 
            insuranceList[0].FinServ__Premium__c =  newInsurance.Premium;  
            insuranceList[0].WEG_Liability_Coverage__c = newInsurance.CoverageAmount; 
            insuranceList[0].FinServ__InsuredAmount__c = amt; 
            insuranceList[0].WEGP1_AccumulationValue__c = newInsurance.CashValue; 
            insuranceList[0].FinServ__Status__c = 'Open';
            
        }
        
        
        System.debug('INSURANCE LIST UPDATE:'+insuranceList);
        update insuranceList;
        
        
        x7s_ChatterPostUtility.ChatterPostInputs input = new x7s_ChatterPostUtility.ChatterPostInputs();
        input.parentId = accList[0].WEGP1_Primary_Household__r.Owner.CSChatterGroup__c;
        input.userId = UserInfo.getUserId();
        
        /*
        String chatterBody = 'Portal - Net Worth New Account ' + accList[0].WEGP1_Primary_Household__r.Name + '\n' + insuranceList[0].FinServ__RecordTypeName__c +'\n';
        
        if((newInsurance.ProductType  != null) && (newInsurance.ProductType != insuranceList[0].WEG_Product_Type__c)){chatterBody += 'Insurance Plan Type: ' + newInsurance.ProductType +'\n';}
        if((newInsurance.serviceProvider  != null) && (newInsurance.serviceProvider != insuranceList[0].FinServ__ServiceProvider__c)){chatterBody += 'Carrier:' + newInsurance.serviceProvider +'\n';}
        //if((newInsurance.Carrier  != null) && (newInsurance.Carrier != insuranceList[0].WEG_Custodian__c)){chatterBody += 'Carrier:' + newInsurance.Carrier +'\n';}
        if((newInsurance.Policy  != null) && (newInsurance.Policy != insuranceList[0].FinServ__FinancialAccountNumber__c)){chatterBody += 'Policy Number: ' + newInsurance.Policy +'\n';}
        if((newInsurance.OwnerName  != null) && (newInsurance.OwnerName != insuranceList[0].FinServ__Ownership__c)){chatterBody += 'Owner: ' + newInsurance.OwnerName +'\n';}
        if((newInsurance.Insured  != null) && (newInsurance.Insured != insuranceList[0].WEGP1_Insured__c)){chatterBody += 'Insured: ' + newInsurance.Insured +'\n';}
        if((newInsurance.AsOfDate  != null) && (newInsurance.AsOfDate != insuranceList[0].WEGP1_PolicyDate__c)){chatterBody += 'As of Date: ' + newInsurance.AsOfDate +'\n';}
        if((newInsurance.DeathBenefit  != null) && (newInsurance.DeathBenefit != insuranceList[0].SK_Death_Benefit_Loss_Amount__c)){chatterBody += 'Death Benefit: ' + newInsurance.DeathBenefit +'\n';}
        if((newInsurance.Premium  != null) && (newInsurance.Premium != insuranceList[0].FinServ__Premium__c)){chatterBody += 'Premium:: ' +  newInsurance.Premium +'\n';}
        if((newInsurance.CoverageAmount  != null) && (newInsurance.CoverageAmount != insuranceList[0].WEG_Liability_Coverage__c)){chatterBody += 'Coverage Amount: ' + newInsurance.CoverageAmount +'\n';}
        if((newInsurance.Amount  != null) && (newInsurance.Amount != insuranceList[0].FinServ__InsuredAmount__c)){chatterBody += 'Amount: ' + newInsurance.Amount +'\n';}
        if((newInsurance.CashValue  != null)&& (newInsurance.CashValue != insuranceList[0].WEGP1_AccumulationValue__c)){chatterBody += 'Cash Value: ' + newInsurance.CashValue +'\n';}
        */
        input.chatterBody = chatterBody;
        
        input.url = '/'+insuranceList[0].Id;
        input.urlLabel = insuranceList[0].Name;
        
        x7s_ChatterPostUtility.ChatterFeedItemAction(new List<x7s_ChatterPostUtility.ChatterPostInputs>{(input)});
    }
    
    @AuraEnabled
    Public static void addInsurance(String accountId,String insuranceInfo, String recordType) {
        System.debug('this logging system is ghetto');
        List<FinServ__FinancialAccount__c> insuranceList;
        List<InsuranceWrapper> lstWrap = new List<InsuranceWrapper>();
        List<RecordType> recType = new List<RecordType>();
        InsuranceWrapper newInsurance;
        
        if(insuranceInfo != null){
            newInsurance = (InsuranceWrapper) JSON.deserialize(insuranceInfo, InsuranceWrapper.class);
            System.debug('NEW INSURANCE INFO===>'+insuranceInfo);
        }
        
        recType = [SELECT Id, Name FROM RecordType Where Name =: recordType LIMIT 1];
        System.debug('New Insuranceeeee===>' + newInsurance);
        System.debug('recType===>' + recType);
        if(accountId != null){
            
            List<Account> accList = [SELECT Id, Name, WEGP1_Primary_Household__c, WEGP1_Primary_Household__r.Name,
                    WEGP1_Primary_Household__r.OwnerId, WEGP1_Primary_Household__r.WEGP1_Secondary_Individual__r.AccountId, WEGP1_Primary_Household__r.WEGP1_Secondary_Individual__r.Name,
                    WEGP1_Primary_Household__r.Owner.CSChatterGroup__c, WEGP1_Primary_Household__r.WEGP1_Primary_Individual__r.AccountId,WEGP1_Primary_Household__r.WEGP1_Primary_Individual__r.Name
                    From Account 
                    WHERE Id =: accountId LIMIT 1];
            
            if(accList.size() > 0 && accList != null && accList[0].WEGP1_Primary_Household__c != null){
                
                Decimal amt = 0.00;
                if(recordType == 'Insurance - Other')
                    amt = newInsurance.Amount;
                else
                    amt = newInsurance.BenefitAmount;

                FinServ__FinancialAccount__c insurance = new FinServ__FinancialAccount__c();    
                    
                if(newInsurance.OwnerName == 'Joint') {
                    String primary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Primary_Individual__r?.AccountId;
                    String secondary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Secondary_Individual__r?.AccountId;

                    insurance = new FinServ__FinancialAccount__c(
                        Name = newInsurance.InsuranceName ,
                        FinServ__PrimaryOwner__c = primary,
                        FinServ__JointOwner__c = secondary,
                        WEG_Product_Type__c = newInsurance.ProductType,
                        FinServ__ServiceProvider__c = newInsurance.serviceProvider,
                        //WEG_Custodian__c = newInsurance.Carrier,
                        FinServ__FinancialAccountNumber__c = newInsurance.Policy, 
                        FinServ__Ownership__c = newInsurance.OwnerName,
                        WEGP1_Insured__c = newInsurance.Insured,
                        FinServ__LastUpdated__c = newInsurance.AsOfDate,
                        WEG_Insured_Asset__c = newInsurance.InsuredAsset,
                        WEGP1_TotalDeathBenefit__c = newInsurance.DeathBenefit,
                        FinServ__Premium__c =  newInsurance.Premium, 
                        WEG_Liability_Coverage__c = newInsurance.CoverageAmount,
                        FinServ__InsuredAmount__c = amt,
                        WEGP1_AccumulationValue__c = newInsurance.CashValue,                         
                        RecordTypeId =  recType[0].Id,
                        //FinServ__Household__c = '0012f00000cWqUaAAK');
                        FinServ__Household__c = accList[0].WEGP1_Primary_Household__c,
                        FinServ__Status__c = 'Open'
                    );
                } else {
                    insurance = new FinServ__FinancialAccount__c(
                        Name = newInsurance.InsuranceName ,
                        FinServ__PrimaryOwner__c = accountId,
                        WEG_Product_Type__c = newInsurance.ProductType,
                        FinServ__ServiceProvider__c = newInsurance.serviceProvider,
                        //WEG_Custodian__c = newInsurance.Carrier,
                        FinServ__FinancialAccountNumber__c = newInsurance.Policy, 
                        FinServ__Ownership__c = newInsurance.OwnerName,
                        WEGP1_Insured__c = newInsurance.Insured,
                        FinServ__LastUpdated__c = newInsurance.AsOfDate,
                        WEG_Insured_Asset__c = newInsurance.InsuredAsset,
                        WEGP1_TotalDeathBenefit__c = newInsurance.DeathBenefit,
                        FinServ__Premium__c =  newInsurance.Premium, 
                        WEG_Liability_Coverage__c = newInsurance.CoverageAmount,
                        FinServ__InsuredAmount__c = amt,
                        WEGP1_AccumulationValue__c = newInsurance.CashValue,                         
                        RecordTypeId =  recType[0].Id,
                        //FinServ__Household__c = '0012f00000cWqUaAAK');
                        FinServ__Household__c = accList[0].WEGP1_Primary_Household__c,
                        FinServ__Status__c = 'Open'
                    );
                }
                insert insurance;
                

                x7s_ChatterPostUtility.ChatterPostInputs input = new x7s_ChatterPostUtility.ChatterPostInputs();
                input.parentId = accList[0].WEGP1_Primary_Household__r.Owner.CSChatterGroup__c;
                input.userId = UserInfo.getUserId();
                String chatterBody = 'Portal - Net Worth New Account ' + accList[0].WEGP1_Primary_Household__r.Name + '\n' + recType[0].Name +'\n';

                if(newInsurance.ProductType  != null){chatterBody += 'Insurance Plan Type: ' + newInsurance.ProductType +'\n';}
                if((newInsurance.serviceProvider  != null)){chatterBody += 'Carrier:' + newInsurance.serviceProvider +'\n';}
                //if(newInsurance.Carrier  != null){chatterBody += 'Carrier:' + newInsurance.Carrier +'\n';}
                if(newInsurance.Policy  != null){chatterBody += 'Policy Number: ' + newInsurance.Policy +'\n';}
                if(newInsurance.OwnerName  != null){chatterBody += 'Owner: ' + newInsurance.OwnerName +'\n';}
                //if( (newInsurance.ProductType != 'Auto') && (newInsurance.ProductType != 'Homeowner\'s') && (newInsurance.ProductType != 'Jewelry') && (newInsurance.ProductType != 'Other') && (newInsurance.ProductType != 'Umbrella') ){

                if( newInsurance.InsuranceRecordType == 'Insurance - Property & Casualty' ){
                    if(newInsurance.Insured  != null){chatterBody += 'Insured Asset: ' + newInsurance.InsuredAsset +'\n';}
                    //if(newInsurance.Insured  != null){chatterBody += 'Insured: ' + newInsurance.Insured +'\n';}
                }else{
                    if(newInsurance.Insured  != null){chatterBody += 'Insured: ' + newInsurance.Insured +'\n';}
                    //if(newInsurance.Insured  != null){chatterBody += 'Insured Asset: ' + newInsurance.InsuredAsset +'\n';}
                }

                if(newInsurance.AsOfDate  != null){chatterBody += 'As of Date: ' + newInsurance.AsOfDate +'\n';}
                if(newInsurance.DeathBenefit  != null && newInsurance.InsuranceRecordType != 'Insurance - Other'){chatterBody += 'Death Benefit: ' + newInsurance.DeathBenefit +'\n';}
                
                if(amt  != null && recordType != 'Insurance - Other'){chatterBody += 'Benefit: ' + amt +'\n';}

                if(newInsurance.Premium  != null){chatterBody += 'Premium:: ' +  newInsurance.Premium +'\n';}
                if(newInsurance.CoverageAmount  != null){chatterBody += 'Coverage Amount: ' + newInsurance.CoverageAmount +'\n';}
                if(newInsurance.Amount  != null){
                    chatterBody += 'Amount: ' + newInsurance.Amount +'\n';
                }
                if(newInsurance.CashValue  != null){chatterBody += 'Cash Value: ' + newInsurance.CashValue +'\n';}

                input.chatterBody = chatterBody;
                input.url = '/'+insurance.Id;
                input.urlLabel = insurance.Name;

                x7s_ChatterPostUtility.ChatterFeedItemAction(new List<x7s_ChatterPostUtility.ChatterPostInputs>{(input)});
            }
        }
        
    }
    
}