@istest 
public class UpdateFinancialAccountStatus_TC {
    /*
    static testMethod void Test_UpdateFinanacialAccountStatus(){
         Account household = new Account();
            household.Name = 'test';
            household.recordtypeid = '012410000012tm4';            
        insert household;
        
        FinServ__FinancialAccount__c finacc = New FinServ__FinancialAccount__c();
        finacc.Name = 'Test Fin Acct 1';                   
        finacc.FinServ__PrimaryOwner__c = household.id;
        finacc.FinServ__CloseDate__c = NULL;
        finacc.Finserv__Status__c = 'Closed' ;
        //finacc.FinServ__Balance__c = 2.00;
        finacc.SkienceFinSln__External_Rec_Id__c = '1234';
        insert finacc;
        
        // update the financial account, testing the first scenario
        finacc.FinServ__Balance__c = 2.00;
        update finacc;
        
        // test the second scenario
        finacc.FinServ__CloseDate__c = Date.newInstance(2018, 1, 9);
        finacc.FinServ__Status__c = 'Open';
        finacc.FinServ__Balance__c = 0.00;
        finacc.WEGP1_Closing_Value__c = 2.00;
        update finacc;
        
        FinServ__FinancialAccount__c finacc2 = New FinServ__FinancialAccount__c();
        finacc2.Name = 'Test Fin Acct 2';                   
        finacc2.FinServ__PrimaryOwner__c = household.id;
        finacc2.Finserv__Status__c = 'Open';
        insert finacc2;
        
        // third scenario, status changed
        finacc2.FinServ__CloseDate__c = Date.newInstance(2018, 1, 9);
        finacc2.Finserv__Status__c = 'Closed';
        update finacc2;
        
        FinServ__FinancialAccount__c finacc3 = New FinServ__FinancialAccount__c();
        finacc3.Name = 'Test Fin Acct 3';                   
        finacc3.FinServ__PrimaryOwner__c = household.id;
        finacc3.Finserv__Status__c = 'Open';
        insert finacc3;
        
        // 6th scenario, electronic prospectus
        finacc3.WEG_Electronic_Prospectus_Delivery__c = true;
        update finacc3;
        
        // 4th scenario, 
        finacc3.Remove_or_Historic__c = 'Transfer to Historic';
        update finacc3;
        
        Id insuranceTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Insurance Policy').getRecordTypeId();
        
        FinServ__FinancialAccount__c finacc4 = New FinServ__FinancialAccount__c();
        finacc4.Name = 'Test Fin Acct 4';
        finacc4.RecordTypeId = insuranceTypeId;
        finacc4.FinServ__PrimaryOwner__c = household.id;
        finacc4.Finserv__Status__c = 'Open';
        finacc4.SkienceFinSln__Product_Type__c = 'Advisory';
        insert finacc4;
        
        // 5th scenario, accumulation value
        finacc4.WEGP1_AccumulationValue__c = 2.00;
        update finacc4;
    }
	*/
}