({
	doInit : function(component, event, helper) {
        // processing started, show spinner
        component.set("v.Spinner", true);
        
        // set the columns on the two data grids
        component.set('v.transactionColumns',
                      [
                          {label: 'ID', fieldName: 'LinkAddress', type: 'url'
                           , typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
                          {label: 'Type', fieldName: 'Transaction_Type__c', type: 'text'},
                          {label: 'Entity', fieldName: 'Business_Entity__c', type: 'text'},
                          {label: 'Billing Date', fieldName: 'Billing_Date__c', type: 'text'},
                          {label: 'Custodian', fieldName: 'Vendor__c', type: 'text'},
                          {label: 'Household', fieldName: 'Household__Name', type: 'text'},
                          {label: 'Amount', fieldName: 'Amount__c', type: 'currency', fixedWidth: 150}
                      ]);
        component.set('v.paymentColumns',
                      [
                          {label: 'ID', fieldName: 'LinkAddress', type: 'url'
                           , typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
                          {label: 'Category', fieldName: 'WEG_Category__c', type: 'text'},
                          {label: 'Amount', fieldName: 'WEG_Amount__c', type: 'currency', fixedWidth: 150}
                      ]);
        
        // populate the field options for...
        helper.populateFieldOptions(component, 'WEG_Transaction__c', 'Transaction_Type__c', 'v.transTypeOptions');// transaction type
        helper.populateFieldOptions(component, 'WEG_Transaction__c', 'Status__c', 'v.transStatusOptions');// transaction status
        helper.populateFieldOptions(component, 'Product2', 'WEG_BusinessEntity__c', 'v.transEntityOptions');// transaction business entity
        helper.populateFieldOptions(component, 'WEG_Transaction__c', 'TAV_Billing_Group__c', 'v.transBillingGroupOptions');// transaction billing group
        helper.populateFieldOptions(component, 'WEG_Payment__c', 'WEG_Status__c', 'v.payStatusOptions');// payment status
        helper.getDefaultInvoice(component);
        
        // get transactions (and counts) based on default criteria
        var transFilterFields = {};
        transFilterFields['Status__c'] = "Unreconciled";
        
        // set the filter fields on the component
        component.set("v.filterFields", transFilterFields);
        
        helper.getTransactions(component, event, helper, transFilterFields);
        helper.getTransactionTotals(component, event, helper, transFilterFields);
        
        // get payments based on default criteria
        var payFilterFields = {};
        payFilterFields['WEG_Status__c'] = "Unreconciled";
        helper.getPayments(component, event, helper, payFilterFields);
	},
    showTransactionFilter : function (component, event, helper) {
      	var transactionIsOpen = component.get('v.transactionFiltersOpen');
        if (transactionIsOpen) {
            component.set('v.transactionFiltersOpen', false);
        } else {
            component.set('v.transactionFiltersOpen', true);
        }
    },
    showPaymentFilter : function (component, event, helper) {
      	var paymentFilterIsOpen = component.get('v.paymentFiltersOpen');
        if (paymentFilterIsOpen) {
            component.set('v.paymentFiltersOpen', false);
        } else {
            component.set('v.paymentFiltersOpen', true);
        }
    },
    transactionFilterSubmit : function (component, event, helper) {
        event.preventDefault();
        
        // processing started, show spinner
        component.set("v.Spinner", true);
        
        // build out the filter fields object
        var filterFields = helper.buildTransactionFilterFields(component, event);
        console.log('FilterFields: '); console.log(filterFields);
        
        // set the filter fields on the component
        component.set("v.filterFields", filterFields);
        
        // get transactions (and counts) based on filtered criteria
        helper.getTransactions(component, event, helper, filterFields);
        helper.getTransactionTotals(component, event, helper, filterFields);
        
        // close the filter section
        component.set('v.transactionFiltersOpen', false);
    },
    paymentFilterSubmit : function (component, event, helper) {
        event.preventDefault();
        
        // processing started, show spinner
        component.set("v.Spinner", true);
        
        // instantiate the filter fields object
        var filterFields = {};
        
        // status are separate field types
        var status = component.get("v.payStatusSelectedValues"); //component.find("Id_PaymentStatus").get("v.value");
        
        // populate the filter fields object for only those filters populated
        var eventFields = event.getParam("fields");
        if (!$A.util.isEmpty(eventFields['WEG_Category__c']) && !$A.util.isUndefined(eventFields['WEG_Category__c']))
        	filterFields['WEG_Category__c'] = eventFields['WEG_Category__c'];
        if (!$A.util.isEmpty (status) && !$A.util.isUndefined (status))
            filterFields['WEG_Status__c'] = status.toString().replace(/,/g, ":");
        
        // get payments based on filtered criteria
        helper.getPayments(component, event, helper, filterFields);
        
        // close the filter section
        component.set ('v.paymentFiltersOpen', false);
    },
    paymentSelectionSubmit : function (component, event, helper) {
        event.preventDefault();
        
        // processing started, show spinner
        component.set("v.Spinner", true);
        
        // get the payment id and the reconciliation total
        var paymentId = component.get('v.paymentId');
        var totalTransAmount = component.get('v.totalTransAmount');
        var selectedPaymentAmount = component.get('v.selectedPaymentAmount');
        var reconciliationTotal = totalTransAmount - selectedPaymentAmount;
        
        if (!$A.util.isEmpty(paymentId) && !$A.util.isUndefined(paymentId) && reconciliationTotal == 0) {
            console.log('Payment Id: ' + paymentId);
            
            // reconcile the transactions
            helper.updateStatus(component, event, helper, paymentId);
            
            // get transactions (and counts) based on default criteria
            var transFilterFields = {};
            transFilterFields['Status__c'] = 'Unreconciled';
            
            // set the filter fields on the component
            component.set("v.filterFields", transFilterFields);
            
            helper.getTransactions(component, event, helper, transFilterFields);
            helper.getTransactionTotals(component, event, helper, transFilterFields);
            
            // get payments based on default criteria
            var payFilterFields = {};
            payFilterFields['WEG_Status__c'] = 'Unreconciled';
            helper.getPayments(component, event, helper, payFilterFields);
        }
        else if ($A.util.isEmpty(paymentId) || $A.util.isUndefined(paymentId)) {
            // processing started, show spinner
            component.set("v.Spinner", false);
            
            alert("A single payment must be selected.");
        }
        else {//reconciliationTotal != 0
            // processing started, show spinner
            component.set("v.Spinner", false);
            
            alert("Reconciliation Total must be zero.");
        }
    },
    handlePaymentRowSelection : function (component, event, helper) {
        // get the selected rows
        var selectedRows = event.getParam('selectedRows');
        // get the total selected amount
        var rowIds = [];
        var selectedAmount = 0;
        for (var i = 0; i < selectedRows.length; i++) {
            rowIds.push(selectedRows[i].Id);
            selectedAmount += selectedRows[i].WEG_Amount__c;
            //console.log(rowIds);
        }
        // set the total selected amount
        component.set('v.selectedPaymentAmount', selectedAmount);
        // set the payment id when only one payment is selected
        if (selectedRows.length == 1) {
            //console.log(selectedRows[0].Id);
            component.set('v.paymentId', selectedRows[0].Id);
        }
        else {
            //console.log('One row is not selected');
            component.set('v.paymentId', '');
        }
        // set the selected rows in the app
        component.set("v.paymentSelectedRows", rowIds);
    },
    handleTransTypeSelection : function (component, event, helper) {
        // get the child component's values from the event
        // set the values on this (parent) component
        var selectedValues = event.getParam('multiSelectValues');
        //console.log('selectedValues: '); console.log(selectedValues);
        component.set('v.transTypeSelectedValues', selectedValues);
    },
    handleTransStatusSelection : function (component, event, helper) {
        // get the child component's values from the event
        // set the values on this (parent) component
        var selectedValues = event.getParam('multiSelectValues');
        //console.log('selectedValues: '); console.log(selectedValues);
        component.set('v.transStatusSelectedValues', selectedValues);
    },
    handlePayStatusSelection : function (component, event, helper) {
        // get the child component's values from the event
        // set the values on this (parent) component
        var selectedValues = event.getParam('multiSelectValues');
        //console.log('selectedValues: '); console.log(selectedValues);
        component.set('v.payStatusSelectedValues', selectedValues);
    }
})