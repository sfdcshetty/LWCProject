@isTest
private class SubmitForReviewController_TC {
    
    @isTest
    private static void SubmitForReviewController(){
        
        User owner = [SELECT Name FROM User WHERE Profile.Name = 'Advisor' LIMIT 1] ;
        
        Account ParentAccount = insertAccount();
        Contact contactToInsert = insertContact(ParentAccount.Id);
        Account accountToInsert = insertFullAccount(owner.Id, contactToInsert.Id);
        
        Account_Servicing__c AServicing = insertASRTAccSer(accountToInsert.Id, owner.Id, contactToInsert.Id);
        Account_Servicing__c AServicingISTI = insertASRTISTI(accountToInsert.Id, owner.Id);
        Account_Servicing__c AServicingTransfer = insertASRTTransfer(accountToInsert.Id, owner.Id);
        Account_Servicing__c AServicingUpdateFee = insertASRTUpdateFee(accountToInsert.Id, owner.Id);
        Account_Servicing__c AServicingBillExc = insertASRTBillExc(accountToInsert.Id, owner.Id);
        
        FinServ__FinancialAccount__c FAInvestmentAccount = insertFAInvestmentAcc(ParentAccount.Id, False);
        
        //Financial_Account_Servicing__c FinancialASRecord = insertFASNewBrokerage(Aservicing.Id, '', FAInvestmentAccount.Id);
        Financial_Account_Servicing__c FinancialASRecord = insertFASNewBrokerage(Aservicing.Id, '');
        Financial_Account_Servicing__c FinancialASRecordWithNA = insertFASNewAdvisory(Aservicing.Id, 'new', '');
        Financial_Account_Servicing__c FinancialASRecordTransfer = insertFASTransfer(AServicingTransfer.Id, FAInvestmentAccount.Id);
        Financial_Account_Servicing__c FinancialASRecordUF = insertFASUpdateFee(AServicingUpdateFee.Id);
        Financial_Account_Servicing__c FinancialASRecordBE = insertFASBillingExclusion(AServicingBillExc.Id);
        Financial_Account_Servicing__c FinancialASRecordMaintenance = insertFASMaintenance(Aservicing.Id, FAInvestmentAccount.Id);
        
        Test.startTest();
        SubmitForReviewController.checkFieldValues(Aservicing.Id);
        SubmitForReviewController.checkFieldValues(AServicingTransfer.Id);
        SubmitForReviewController.checkFieldValues(AServicingISTI.Id);
        Test.stopTest();
        
        System.assertEquals('New',Aservicing.WEG_Status__c);
    }
    
    @isTest static void FASStatusUpdate(){
        
        User owner = [SELECT Name FROM User WHERE Profile.Name = 'Advisor' LIMIT 1] ;
        
        Account ParentAccount = insertAccount();
        Contact contactToInsert = insertContact(ParentAccount.Id);
        Account accountToInsert = insertFullAccount(owner.Id, contactToInsert.Id);
        
        Account_Servicing__c AServicing = insertASRTAccSer(accountToInsert.Id, owner.Id, contactToInsert.Id);
        Account_Servicing__c AServicingTransfer = insertASRTTransfer(accountToInsert.Id, owner.Id);
        
        //FinServ__FinancialAccount__c FAInvestmentAccount = insertFAInvestmentAcc(accountToInsert.Id, False);
        
        //Financial_Account_Servicing__c FinancialASRecord = insertFASNewBrokerage(Aservicing.Id, 'Approved (In Good Order)', FAInvestmentAccount.Id);
        Financial_Account_Servicing__c FinancialASRecord = insertFASNewBrokerage(Aservicing.Id, 'Approved (In Good Order)');
        Financial_Account_Servicing__c FinancialASRecordWithNA = insertFASNewAdvisory(Aservicing.Id, 'Suitability Review', 'Approved (In Good Order)');
        
        Test.startTest();
        FASStatusUpdate.PushAccountServicing pushAS = new FASStatusUpdate.PushAccountServicing();
        pushAS.parentId = FinancialASRecordWithNA.Account_Servicing__c;
        /* pushAS.status = FinancialASRecordWithNA.Status__c;
		pushAS.principleReviewFinalStatus = FinancialASRecordWithNA.Principal_Review_Final_Status__c;*/
        FASStatusUpdate.automateMessage(new List<FASStatusUpdate.PushAccountServicing>{pushAS});
        Test.stopTest();
        System.assertEquals('Suitability Review',FinancialASRecordWithNA.Status__c);
        
    }
    
    private static Account insertAccount() {
        Id RecordTypeIdCustodian = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Custodian').getRecordTypeId();
        Account ParentAccount = new Account();
        ParentAccount.Name = 'TestParentAccount';
        ParentAccount.RecordTypeId = RecordTypeIdCustodian;
        insert ParentAccount;
        return ParentAccount;
    }
    
    private static Contact insertContact(Id parentAccout) {
        Contact contactToInsert = new Contact();
        contactToInsert.LastName = 'TestLastName';
        contactToInsert.AccountId = parentAccout;
        insert contactToInsert;
        return contactToInsert;
    }
    
    private static Account insertFullAccount(Id ownerId, Id contactId) {
        Id RecordTypeIdHouseHold = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Account accountToInsert = new Account();
        accountToInsert.Name = 'TestAccount';
        accountToInsert.OwnerId = ownerId;
        accountToInsert.WEGP1_Primary_Individual__c = contactId;
        accountToInsert.FI_Annual_Income__c = 23;
        accountToInsert.FI_Liquid_Net_Worth__c = 12;
        accountToInsert.FinServ__NetWorth__c = 14;
        accountToInsert.FI_Primary_Source_of_Wealth__c = 'Employment' ;
        accountToInsert.FI_Special_Liquidity_Needs__c = 'Y';
        accountToInsert.FI_Tax_Bracket__c = 2;
        accountToInsert.WEG_MSA_Date__c = Date.today();
        accountToInsert.FI_Year_Began_Investing__c = 2012;
        accountToInsert.WEG_Alternate_Billing__c = 'Y';
        accountToInsert.FinServ__TimeHorizon__c = '1-3 years';
        accountToInsert.FI_Special_Liquidity_Needs_Detail__c = 'SLN Details';
        accountToInsert.WEGP1_Secondary_Individual__c = contactId;
        accountToInsert.RecordTypeId = RecordTypeIdHouseHold;
        accountToInsert.WEG_IM_Special_Instructions__c = 'Y';
        accountToInsert.WEG_IM_Special_Instructions_Detail__c = 'SIR Dtails';
        accountToInsert.WEG_Investment_Variances__c = 'Y';
        accountToInsert.WEG_Investment_Variances_Detail__c = 'IV Details';
        insert accountToInsert;
        return accountToInsert;
    }
    
    private static Account_Servicing__c insertASRTAccSer(Id accId, Id ownerId, Id conId) {
        Id RecordTypeIdAS = Schema.SObjectType.Account_Servicing__c.getRecordTypeInfosByName().get('Account Servicing').getRecordTypeId();
        Account_Servicing__c AServicing = new Account_Servicing__c();
        Aservicing.Related_Account__c = accId;
        Aservicing.OwnerId = ownerId;
        Aservicing.RecordTypeId = RecordTypeIdAS;
        Aservicing.WEGP1_Secondary_Individual__c = conId;
        Aservicing.FI_Primary_Source_of_Wealth__c = 'Employment';
        Aservicing.WEG_Primary_PrimaryEmail__c = 'Personal';
        Aservicing.WEG_Primary_Email__c = 'test@test.com';
        Aservicing.WEG_Secondary_Email__c = 'test@test.com';
        Aservicing.WEG_Secondary_PrimaryEmail__c =  'Personal';
        Aservicing.WEG_Investment_Variances__c ='Y';
        //Aservicing.WEG_Investment_Variances_Detail__c = 'IV Details';
        Aservicing.WEG_IM_Special_Instructions__c = 'Y';
        //Aservicing.WEG_IM_Special_Instructions_Detail__c = 'SIR details';
        Aservicing.FI_Annual_Income__c =23546 ;
        Aservicing.FI_Net_Worth__c = 23;
        Aservicing.FI_Liquid_Net_Worth__c = 25; 
        Aservicing.FI_Tax_Bracket__c = 4;
        Aservicing.FI_Special_Liquidity_Needs__c = 'Y';
        Aservicing.FI_Special_Liquidity_Needs_Detail__c = 'SLN Details';
        Aservicing.FI_Year_Began_Investing__c = 2012;
        Aservicing.WEG_Alternate_Billing__c = 'Y';
        Aservicing.WEG_Status__c = 'New';
        Aservicing.WEG_Items_to_Complete__c = '';
        insert Aservicing;
        return Aservicing;
    }
    
    private static Account_Servicing__c insertASRTISTI(Id accId, Id ownerId) {
        Id RecordTypeIdASISTI = Schema.SObjectType.Account_Servicing__c.getRecordTypeInfosByName().get('IO/Special Trading Instructions').getRecordTypeId();
        Account_Servicing__c AServicingISTI = new Account_Servicing__c();
        AServicingISTI.Related_Account__c = accId;
        AServicingISTI.OwnerId = ownerId;
        AServicingISTI.RecordTypeId = RecordTypeIdASISTI;
        AServicingISTI.WEG_IM_Special_Instructions__c = 'Y';
        AServicingISTI.WEG_IM_Special_Instructions_Detail__c = 'Checking';
        AServicingISTI.WEG_Investment_Objective__c = 'Moderate Growth';
        AServicingISTI.WEG_Status__c = 'New';
        insert AServicingISTI;
        return AServicingISTI;
    }
    
    private static Account_Servicing__c insertASRTTransfer(Id accId, Id ownerId) {
        Id RecordTypeIdASTransfer = Schema.SObjectType.Account_Servicing__c.getRecordTypeInfosByName().get('Transfer').getRecordTypeId();
        Account_Servicing__c AServicingTransfer = new Account_Servicing__c();
        AServicingTransfer.Related_Account__c = accId;
        AServicingTransfer.OwnerId = ownerId;
        AServicingTransfer.RecordTypeId = RecordTypeIdASTransfer;
        AServicingTransfer.WEG_Status__c = 'New';
        insert AServicingTransfer;
        return AServicingTransfer;
    }
    
    private static Account_Servicing__c insertASRTBillExc(Id accId, Id ownerId) {
        Id RecordTypeIdASBE = Schema.SObjectType.Account_Servicing__c.getRecordTypeInfosByName().get('Billing Exclusion').getRecordTypeId();
        Account_Servicing__c AServicingBillExc = new Account_Servicing__c();
        AServicingBillExc.Related_Account__c = accId;
        AServicingBillExc.OwnerId = ownerId;
        AServicingBillExc.RecordTypeId = RecordTypeIdASBE;
        AServicingBillExc.WEG_Status__c = 'New';
        insert AServicingBillExc;
        return AServicingBillExc;
    }
    
    private static Account_Servicing__c insertASRTUpdateFee(Id accId, Id ownerId) {
        Id RecordTypeIdASUpdateFee = Schema.SObjectType.Account_Servicing__c.getRecordTypeInfosByName().get('Update Fee').getRecordTypeId();
        Account_Servicing__c AServicingTransfer = new Account_Servicing__c();
        AServicingTransfer.Related_Account__c = accId;
        AServicingTransfer.OwnerId = ownerId;
        AServicingTransfer.RecordTypeId = RecordTypeIdASUpdateFee;
        AServicingTransfer.WEG_Status__c = 'New';
        insert AServicingTransfer;
        return AServicingTransfer;
    }
    
    //private static Financial_Account_Servicing__c insertFASNewBrokerage(Id accSerId, String finalReview, Id faId) {
    private static Financial_Account_Servicing__c insertFASNewBrokerage(Id accSerId, String finalReview) {
        Id RecordTypeIdFAS = Schema.SObjectType.Financial_Account_Servicing__c.getRecordTypeInfosByName().get('New Brokerage').getRecordTypeId();
        Financial_Account_Servicing__c FinancialASRecord = new Financial_Account_Servicing__c();
        FinancialASRecord.Account_Servicing__c = accSerId;
        FinancialASRecord.Registration_Type__c = '401(k)';
        FinancialASRecord.WEG_Custodian__c = 'Schwab';
        FinancialASRecord.Approximate_Value__c = 2;
        FinancialASRecord.WEG_No_Model__c = true;
        //FinancialASRecord.WEG_Source_of_Funds__c = '401k';
        FinancialASRecord.WEG_Billing_Exclusions__c = 'Y';
        FinancialASRecord.WEG_Billing_Exclusions_Detail__c = 'Exclude Cash from RIA Fee';
        FinancialASRecord.RecordTypeId = RecordTypeIdFAS;
        FinancialASRecord.WEG_Items_to_Complete__c = '';
        FinancialASRecord.WEG_New_Account_Type__c = 'Brokerage';
        FinancialASRecord.Status__c = 'New';
		FinancialASRecord.Principal_Review_Final_Status__c = finalReview;
        //FinancialASRecord.Financial_Account__c = faId;
        insert FinancialASRecord;
        return FinancialASRecord;
    }
    
    private static Financial_Account_Servicing__c insertFASNewAdvisory(Id accSerId, String status, String reviewFinal) {
        Id RecordTypeIdFASNewAdvisory = Schema.SObjectType.Financial_Account_Servicing__c.getRecordTypeInfosByName().get('New Advisory').getRecordTypeId();
        Financial_Account_Servicing__c FinancialASRecordWithNA = new Financial_Account_Servicing__c();
        FinancialASRecordWithNA.Account_Servicing__c = accSerId;
        FinancialASRecordWithNA.WEG_New_Account_Type__c = 'Advisory';
        FinancialASRecordWithNA.Registration_Type__c = '401(k)';
        FinancialASRecordWithNA.WEG_Custodian__c = 'Schwab';
        FinancialASRecordWithNA.Approximate_Value__c = 2;
        FinancialASRecordWithNA.WEG_Billing_Exclusions__c = 'Y';
        FinancialASRecordWithNa.WEG_No_Model__c = true;
        FinancialASRecordWithNA.WEG_Billing_Exclusions_Detail__c = 'Exclude Cash from RIA Fee';
        FinancialASRecordWithNA.RecordTypeId = RecordTypeIdFASNewAdvisory;
        FinancialASRecordWithNA.WEG_Items_to_Complete__c = '';
        FinancialASRecordWithNA.Account_Number__c = '12345';
        FinancialASRecordWithNA.TIK_Hold__c = 'N';
        FinancialASRecordWithNA.Fee_Type__c = '';
        FinancialASRecordWithNA.Prudent_Process__c = '';
        FinancialASRecordWithNA.WEG_Program__c = '';
        FinancialASRecordWithNA.Status__c = status;
		FinancialASRecordWithNA.Principal_Review_Final_Status__c = reviewFinal;
        insert FinancialASRecordWithNA;
        return FinancialASRecordWithNA;
    }
    
    private static Financial_Account_Servicing__c insertFASTransfer(Id accSerId, Id finAccId) {
        Id RecordTypeIdFASTransfer = Schema.SObjectType.Financial_Account_Servicing__c.getRecordTypeInfosByName().get('Transfer').getRecordTypeId();
        Financial_Account_Servicing__c FinancialASRecordTransfer = new Financial_Account_Servicing__c();
        FinancialASRecordTransfer.Account_Servicing__c = accSerId;
        FinancialASRecordTransfer.Name = 'Transfer Record';
        FinancialASRecordTransfer.Status__c = 'New';
        FinancialASRecordTransfer.Financial_Account__c = finAccId;
        FinancialASRecordTransfer.WEG_New_Account_Type__c = 'Advisory';
        FinancialASRecordTransfer.RecordTypeId = RecordTypeIdFASTransfer;
        insert FinancialASRecordTransfer;
        return FinancialASRecordTransfer;
    }
    
    private static Financial_Account_Servicing__c insertFASUpdateFee(Id accSerId) {
        Id RecordTypeIdFASUpdateFee = Schema.SObjectType.Financial_Account_Servicing__c.getRecordTypeInfosByName().get('Update Fee').getRecordTypeId();
        Financial_Account_Servicing__c FinancialASRecordUF = new Financial_Account_Servicing__c();
        FinancialASRecordUF.Account_Servicing__c = accSerId;
        FinancialASRecordUF.Name = 'Update Fee Record';
        FinancialASRecordUF.Status__c = 'New';
        FinancialASRecordUF.WEG_Custodian__c = 'Fidelity';
        FinancialASRecordUF.Fee_Type__c = '2';
        FinancialASRecordUF.WEG_Billing_Status__c = 'New';
        FinancialASRecordUF.WEG_New_Account_Type__c = 'Advisory';
        FinancialASRecordUF.RecordTypeId = RecordTypeIdFASUpdateFee;
        insert FinancialASRecordUF;
        return FinancialASRecordUF;
    }
    
    private static Financial_Account_Servicing__c insertFASBillingExclusion(Id accSerId) {
        Id RecordTypeIdFASBillExc = Schema.SObjectType.Financial_Account_Servicing__c.getRecordTypeInfosByName().get('Billing Exclusion').getRecordTypeId();
        Financial_Account_Servicing__c FinancialASRecordBE = new Financial_Account_Servicing__c();
        FinancialASRecordBE.Account_Servicing__c = accSerId;
        FinancialASRecordBE.RecordTypeId = RecordTypeIdFASBillExc;
        FinancialASRecordBE.Name = 'Billing Exclusion Record';
        FinancialASRecordBE.Status__c = 'New';
        FinancialASRecordBE.WEG_New_Account_Type__c = 'Advisory';
        insert FinancialASRecordBE;
        return FinancialASRecordBE;
    }
    
    private static Financial_Account_Servicing__c insertFASMaintenance(Id accSerId, Id finAccId) {
        Id RecordTypeIdFASMaintenance = Schema.SObjectType.Financial_Account_Servicing__c.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        Financial_Account_Servicing__c FinancialASRecordMain = new Financial_Account_Servicing__c();
        FinancialASRecordMain.Account_Servicing__c = accSerId;
        FinancialASRecordMain.RecordTypeId = RecordTypeIdFASMaintenance;
        FinancialASRecordMain.Name = 'Maintenance Record';
        FinancialASRecordMain.Status__c = 'New';
        //FinancialASRecordMain.WEG_Type__c = 'Existing';
        FinancialASRecordMain.WEG_New_Account_Type__c = 'Advisory';
        FinancialASRecordMain.Financial_Account__c = finAccId;
        insert FinancialASRecordMain;
        return FinancialASRecordMain;
    }
    
    private static FinServ__FinancialAccount__c insertFAInvestmentAcc(Id accId, Boolean weasManaged) {
        Id RecordTypeIdFAInvestmentAcc = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Investment Account').getRecordTypeId();
        FinServ__FinancialAccount__c FAInvestmentAccount = new FinServ__FinancialAccount__c();
        FAInvestmentAccount.Name = 'FA Investment Account';
        FAInvestmentAccount.RecordTypeId = RecordTypeIdFAInvestmentAcc;
        FAInvestmentAccount.FinServ__PrimaryOwner__c = accId;
        FAInvestmentAccount.FinServ__Status__c = 'Draft';
        FAInvestmentAccount.WEGP1_IsWEAS__c = weasManaged;
        FAInvestmentAccount.SK_No_Model__c = False;
        insert FAInvestmentAccount;
        return FAInvestmentAccount;
    }
    
}