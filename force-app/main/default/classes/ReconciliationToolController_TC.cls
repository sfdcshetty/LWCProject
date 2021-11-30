@isTest
public class ReconciliationToolController_TC {
    
    public static testMethod void testRecTool() {
        
        WEG_PayPeriod__c payPeriod = new WEG_PayPeriod__c (
            Name = '201801',
            WEG_PeriodStartDate__c = Date.newInstance(2018, 1, 1),
            WEG_PeriodEndDate__c = Date.newInstance(2018, 1, 15),
            WEG_PeriodPayDate__c = Date.newInstance(2018, 1, 22)
        );
        insert payPeriod;
        
        WEG_Payment__c payment = New WEG_Payment__c ();
            payment.WEG_Category__c = 'Insurance';
            payment.WEG_Entity__c = 'WEAS';
            payment.WEG_Amount__c = 2000;
            payment.WEG_Pay_Period__c = payPeriod.Id;
            payment.WEG_Status__c = 'Unreconciled';
        insert payment;
        
        Account acct = new Account (
            Name = 'Test Vendor'
        );
        insert acct;
        
        WEG_Invoice__c inv = new WEG_Invoice__c (
            Name = 'Test Invoice',
            WEG_BillTo__c = acct.Id,
            WEG_PayPeriod__c = payPeriod.Id
        );
        insert inv;
        
        WEG_Transaction__c trans = New WEG_Transaction__c ();
        trans.Pay_Period__c = payPeriod.Id;
        trans.Transaction_Type__c  = 'Revenue';
        trans.Payment__c  = payment.id;
        trans.Invoice__c = inv.Id;
        trans.Billing_Date__c = Date.newInstance(2018, 1, 12);
        insert trans;
        
        // instantiate the controller
        ReconciliationToolController obj = New ReconciliationToolController();
        
        // create and populate the maps, used in filtering
        Map<String,String> paymentsFieldApiAndValueMap = New Map<String,String>();
        Map<String,String> transFieldApiAndValueMap = New Map<String,String>();
        transFieldApiAndValueMap.put('Transaction_Type__c','Revenue');
        transFieldApiAndValueMap.put('Status__c','Unreconciled:Rejected');
        transFieldApiAndValueMap.put('Billing_Start__c','2018-01-01');
        transFieldApiAndValueMap.put('Billing_End__c','2018-01-15');
        paymentsFieldApiAndValueMap.put('WEG_Category__c','Insurance');
        paymentsFieldApiAndValueMap.put('WEG_Status__c','Unreconciled:Reconciled');
        
        // get picklist values, payments, transactions and totals as if the page was loaded
        ReconciliationToolController.getPicklistValues('WEG_Transaction__c', 'Status__c');
        ReconciliationToolController.getPayments(paymentsFieldApiAndValueMap);
        ReconciliationToolController.getTransactions(transFieldApiAndValueMap);
        ReconciliationToolController.getTransactionTotals(transFieldApiAndValueMap);
        
        // first attempt to update transaction status without a payment
        ReconciliationToolController.updateTransactionStatus(transFieldApiAndValueMap, null);
        
        // then attempt with a payment
        ReconciliationToolController.updateTransactionStatus(transFieldApiAndValueMap, payment.Id);
    }
}