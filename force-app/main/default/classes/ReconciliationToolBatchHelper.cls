global class ReconciliationToolBatchHelper implements Database.Batchable<sObject> {
    global final string query;
    global final String paymentId;
    global final Id paymentPayPeriod;
    //global final String Field;
    //global final String Value;
    
    global ReconciliationToolBatchHelper(string q, string pid, Id ppp) {
        query = q;
        paymentId = pid;
        paymentPayPeriod = ppp;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        // 
        List <WEG_Transaction__c> transactionsToUpdate = new List<WEG_Transaction__c>();
        
        // iterate the transactions, setting them to paid along with the payment applied
        for (sObject s : scope) {
            // identify the scope item as a transaction
            WEG_Transaction__c trans = (WEG_Transaction__c)s;
            
            // set the status, payment, and current pay period
            trans.Status__c = 'Collected';
            if (paymentId != NULL)
                trans.Payment__c = paymentId;
            if (paymentPayPeriod != NULL)
                trans.Pay_Period__c = paymentPayPeriod;
            
            // add the transaction to the list to be updated
            transactionsToUpdate.add(trans);
        }
        
        // update the transactions
        try { update transactionsToUpdate; } catch(Exception ex) { system.debug('>>>>>>>> ERROR :: Update Transactions Failed. :: ' + ex.getMessage()); }
    }
    
    global void finish(Database.BatchableContext BC){
        // get the payment based on payment Id
        List<WEG_Payment__c> payments = [SELECT Id, WEG_Status__c FROM WEG_Payment__c WHERE Id = :paymentId];
        if (payments.size() == 1) {
            // 1 payment was found, extract it
            WEG_Payment__c payment = payments[0];
        
            // set the payment status
            payment.WEG_Status__c = 'Reconciled';
            
            // update the payment
            try { update payment; } catch(Exception ex) { System.debug('ERROR :: Update Payment Failed. :: ' + ex.getMessage()); }
        }
    }
    
}