({
    getTransactions : function(component, event, helper, filterFields) {        
        var action = component.get("c.getTransactions");
        action.setParams ({
            "filterFields" : filterFields
        });
        action.setCallback(this, function(response) {
            // get the response
            var result = response.getReturnValue();
            // iterate the results, formatting some fields and updating the total amount
            if (!$A.util.isEmpty (result) && !$A.util.isUndefined (result)) {
                for (var i = 0; i < result.length; i++) {
                    var record = result[i];
                    if (record.Financial_Account__c)
                        record.Financial_Account__Name = record.Financial_Account__r.Name;
                    if (record.Household__c)
                        record.Household__Name = record.Household__r.Name;                    
                    record.LinkAddress = '/' + record.Id;
                }
            }
            // add the transactions to the data grid
            component.set("v.transactionRecords", result);
            // processing complete, hide spinner
            component.set("v.Spinner", false);
        });
        $A.enqueueAction(action);
    },
    getTransactionTotals : function(component, event, helper, filterFields) {        
        var action = component.get("c.getTransactionTotals");
        action.setParams ({
            "filterFields" : filterFields
        });
        action.setCallback(this, function(response) {
            // get the response
            var result = response.getReturnValue();
            // get the counts
            var totalCount = 0;
            var totalAmount = 0;
            if (!$A.util.isEmpty (result) && !$A.util.isUndefined (result) && result.length == 1) {
                totalCount = result[0].NoTrans;
                totalAmount = result[0].SumTrans;
            }
            // set the counts
            component.set("v.totalTransCount", totalCount);
            component.set("v.totalTransAmount", totalAmount);
        });
        $A.enqueueAction(action);
    },
    buildTransactionFilterFields : function(component, event) {        
        // instantiate the filter fields object
        var filterFields = {};
        
        // product, status, business entity, weg id are separate field types
        var product = component.find("Id_TransProduct").get("v.value");
        var type = component.get("v.transTypeSelectedValues");
        var status = component.get("v.transStatusSelectedValues"); //component.find("Id_Status").get("v.value");
        var businessEntity = component.find("Id_BusinessEntity").get("v.value");
        var wegID = component.find("Id_WEGID").get("v.value");
        var accountNo = component.find("Id_AccountNo").get("v.value");
        var payee = component.find("Id_TransPayee").get("v.value");
        var billingGroup = component.find("Id_BillingGroup").get("v.value");
        //var invoice = component.find("Id_TransInvoice").get("v.value");
        var invoice = component.get("v.transInvoiceValue");
        var defaultInvoice = component.get("v.transInvoiceDefaultValue");
        
        console.log('Status: ' + status);
        console.log('Business Entity: ' + businessEntity);
        console.log('AccountNo: ' + accountNo);
        console.log('Billing Group: ' + billingGroup);
        console.log('Invoice: ' + invoice);
        console.log('Default Invoice: ' + defaultInvoice);
        
        // populate the filter fields object for only those filters populated
        var eventFields = event.getParam("fields");
        
        if (!$A.util.isEmpty(eventFields['TAV_Billing_Group__c']) && !$A.util.isUndefined(eventFields['TAV_Billing_Group__c']))
        	console.log('TAV Billing Group: ' + eventFields['TAV_Billing_Group__c']);
        
        if (!$A.util.isEmpty(eventFields['Vendor__c']) && !$A.util.isUndefined(eventFields['Vendor__c']))
        	filterFields['Vendor__c'] = eventFields['Vendor__c'];
        if (!$A.util.isEmpty(product) && !$A.util.isUndefined(product))
        	filterFields['Product__c'] = product.toString();
        if (!$A.util.isEmpty(eventFields['Billing_Start__c']) && !$A.util.isUndefined(eventFields['Billing_Start__c']))
        	filterFields['Billing_Start__c'] = eventFields['Billing_Start__c'];
        if (!$A.util.isEmpty(eventFields['Billing_End__c']) && !$A.util.isUndefined(eventFields['Billing_End__c']))
        	filterFields['Billing_End__c'] = eventFields['Billing_End__c'];
        if (!$A.util.isEmpty(type) && !$A.util.isUndefined(type))
            filterFields['Transaction_Type__c'] = type.toString().replace(/,/g, ':');
        if (!$A.util.isEmpty(status) && !$A.util.isUndefined(status))
            filterFields['Status__c'] = status.toString().replace(/,/g, ":");
        if (!$A.util.isEmpty(businessEntity) && !$A.util.isUndefined(businessEntity) && businessEntity != "--None--")
            filterFields['Business_Entity__c'] = businessEntity;
        if (!$A.util.isEmpty(wegID) && !$A.util.isUndefined(wegID))
            filterFields['Household_WEG_ID__c'] = wegID;
        if (!$A.util.isEmpty(accountNo) && !$A.util.isUndefined(accountNo))
            filterFields['Account_Number__c'] = accountNo.toString().replace(/ /g, '').replace(/,/g, ':');
        if (!$A.util.isEmpty(payee) && !$A.util.isUndefined(payee))
        	filterFields['PayeeCode__c'] = payee.toString();
        if (!$A.util.isEmpty(billingGroup) && !$A.util.isUndefined(billingGroup) && billingGroup != "--None--")
            filterFields['TAV_Billing_Group__c'] = billingGroup.replace('--Empty--', '');
        if (!$A.util.isEmpty(invoice) && !$A.util.isUndefined(invoice) && invoice != defaultInvoice)
        	filterFields['Invoice__c'] = invoice.toString();
        
        return filterFields;
    },
    getPayments : function(component, event, helper, filterFields) {
        // 
        var action = component.get("c.getPayments");
        action.setParams ({
            "filterFields" : filterFields
        });
        action.setCallback(this, function(response) {
            // get the response
            var result = response.getReturnValue();
            // initially set the total and selected amounts to zero
            var totalAmount = 0;
            var selectedAmount = 0;
            // iterate the results, updating the total and selected amounts
            if (!$A.util.isEmpty (result) && !$A.util.isUndefined (result)) {
                for (var i = 0; i < result.length; i++) {
                    var record = result[i];
                    if (!$A.util.isEmpty (record.WEG_Amount__c) && !$A.util.isUndefined (record.WEG_Amount__c))
                        totalAmount += record.WEG_Amount__c;
                    
                    record.LinkAddress = '/' + record.Id;
                }
            }
            // add the payments to the data grid
            component.set("v.paymentRecords", result);
            // remove all selected rows
            component.set('v.paymentSelectedRows', []);
            // add the total and selected amounts to the application
            component.set("v.totalPaymentAmount", totalAmount);
            component.set("v.selectedPaymentAmount", 0);
            // processing complete, hide spinner
            component.set("v.Spinner", false);
        });
        $A.enqueueAction(action);
    },
    populateFieldOptions : function(component, objName, fieldName, attributeName) {
        var action = component.get("c.getPicklistValues");
        action.setParams ({
            "objName" : objName,
            "fieldName" : fieldName
        });
        action.setCallback(this, function (response){
            var result = response.getReturnValue();
            var options = [];
            
            // 
            if (fieldName == 'WEG_BusinessEntity__c' || fieldName == 'TAV_Billing_Group__c')
                options.push({"label" : '--None--',"value" : '--None--'});
            if (fieldName == 'TAV_Billing_Group__c')
                options.push({"label" : '--Empty Billing Group--',"value" : '--Empty--'});
            
            // insert the remaining options
            for (var i = 0; i < result.length; i++) {
                var item = {
                    "label" : result[i],
                    "value" : result[i],
                };
            	options.push(item);
            }
            
            component.set(attributeName, options);
        });
        $A.enqueueAction(action);
    },
    updateStatus :function (component, event, helper, paymentId) {
        // get the filter fields from the component to apply during reconciliation
        var filterFields = component.get("v.filterFields");
        if (filterFields && filterFields[0]) {
            console.log('filterFields: '); console.log(filterFields[0]);
            
            // 
            var action = component.get("c.updateTransactionStatus");
            action.setParams ({
                "filterFields" : filterFields[0],
                "paymentId" : paymentId
            });
            action.setCallback(this, function (response){
                var result = response.getReturnValue();
                
                helper.showToast (component, event, helper, 'Success!', result, 'success');
                // processing complete, hide spinner
                component.set("v.Spinner", false);
            });
            $A.enqueueAction(action);
        }
    },
    showToast : function(component, event, helper, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : type,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    },
    getDefaultInvoice : function(component) {
        var action = component.get("c.getDefaultInvoice");
        
        action.setCallback(this, function (response){
            var result = response.getReturnValue();
            if (result) {
                component.set('v.transInvoiceValue', result);
                component.set('v.transInvoiceDefaultValue', result);
            }
            else
                alert('ERROR :: Default invoice not found.');
        });
        $A.enqueueAction(action);
    }
})