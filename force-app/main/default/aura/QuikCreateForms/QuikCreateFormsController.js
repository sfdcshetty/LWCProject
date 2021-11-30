({
    doInit : function(component, event, helper) {
        component.set('v.showSpinner', true);
        setTimeout(function() { 
            component.set('v.showSpinner', false);
        }, 5000);
        component.set('v.selectedCategory', '');
        component.set('v.selectedDealer', '');
        component.set('v.formNameKeyword', '');
        component.set('v.searchFormResults', {});
        component.set('v.selectedBundleGroup', '');
        component.set('v.bundleFormResults', {});
        // To fetch the AS, FAS to display in the dropdown
        var action = component.get("c.getRecords");
        action.setParams({asRecordId : component.get('v.recordId')});
        action.setCallback(this, function(result) {
            var result = result.getReturnValue();
            var options = [];
            for(var key = 0; key < result.length; key++) {
                var record = result[key];
                if(record.Name.startsWith ('AS-')) {
                    record.Name = 'Household / Business';
                    record.WEG_Custodian__c = 'AS';
                }
                options.push({label : record.Name, value : record.Id, custodian: record.WEG_Custodian__c});
            }
            component.set("v.records", options);
        });
        $A.enqueueAction(action);
        // To get the bundle groups and display in the drop down
        action = component.get("c.getBundleGroups");
        action.setCallback(this, function(result) {
            var result = result.getReturnValue();
            component.set('v.selectedBundleGroup', '');
            var options = [];
            for(var key = 0; key < result.length; key++) {
                var record = result[key];
                options.push({label : record.Name, value : record.Id});
            }
            component.set("v.bundleGroups", options);
        });
        $A.enqueueAction(action);
        // To get the Categories from QuikForms and display as dropdown
        action = component.get("c.getCategories");
        action.setCallback(this, function(result) {
            var result = result.getReturnValue();
            var options = [];
            for(var key = 0; key < result.length; key++) {
                var record = result[key];
                options.push({label : record.categoryName, value : record.categoryId});
            }
            component.set("v.categories", options);	
        });
        $A.enqueueAction(action);
        // To get the Dealers/Custodians from QuikForms and display as dropdown
        action = component.get("c.getDealers");
        action.setCallback(this, function(result) {
            var result = result.getReturnValue();
            var options = [];
            for(var key = 0; key < result.length; key++) {
                var record = result[key];
                options.push({label : record.dealerName, value : record.dealerId});
            }
            component.set("v.dealers", options);	
            component.set ('v.showSpinner', false);
        });
        $A.enqueueAction(action);
        component.set('v.selectedStep', 'step1');
    },
    
    fetchBundles : function(component, event, helper) {
        var pageSize = component.get("v.bundlePageSize");
        helper.fetchBundledRecords (component, event, helper, 1, pageSize);
    },
    
    handleBundleNext : function(component, event, helper, selectedAccount) {
        var pageNumber = component.get("v.bundlePageNumber");  
        pageNumber++;
        var pageSize = component.get("v.bundlePageSize");
        helper.fetchBundledRecords (component, event, helper, pageNumber, pageSize);
    },
    
    handleBundlePrev : function(component, event, helper, selectedAccount) {
        var pageNumber = component.get("v.bundlePageNumber");  
        pageNumber--;
        var pageSize = component.get("v.bundlePageSize");
        helper.fetchBundledRecords (component, event, helper, pageNumber, pageSize);
    },
    
    selectStep1 : function(component, event, helper) {
        component.set('v.selectedStep2', false);
        var step1Id = component.find("step1Id");
        var step2Id = component.find("step2Id");
        var step3Id = component.find("step3Id");
        $A.util.removeClass(step1Id, ('disableCls'));
        $A.util.removeClass(step2Id, ('disableCls'));
        $A.util.removeClass(step3Id, ('disableCls'));
        component.set("v.selectedStep", "step1");        
    },
    
    searchFormsHandler : function(Component, event, helper) {
        Component.set("v.searchSubFormResults", {});
        Component.set ('v.showSpinner', true);
        helper.searchForms(Component, event, helper, '');
    },
    
    closeOpenSection : function(component, event, helper) {
        var id = event.currentTarget.name;
        var section = document.getElementById(id);
        var downId = 'down' + id;
        var rightId = 'right' + id;
        if(section.classList.contains("slds-is-open")) {
            section.classList.remove("slds-is-open");
            document.getElementById('down' + id).style.display = "none";
            document.getElementById('right' + id).style.display = "block";
        } else {
            section.classList.add("slds-is-open");
            document.getElementById('down' + id).style.display = "block";
            document.getElementById('right' + id).style.display = "none";
        }
    },
    
    typeChangeHandler : function (component, event, helper) {
        var selectedType = component.get('v.selectedRecord');
        var result = component.get('v.searchFormResults');
        if(!$A.util.isEmpty (result) && !$A.util.isUndefined(result)) {
            var tempResult = [];
            for(var i = 0; i < result.length; i++) {
                var newRes = result[i];
                newRes.iconName = 'utility:add';
                tempResult.push(newRes);
            }
            result = tempResult;
            helper.generateForms(component, event, helper, result, 'search');
        }
        result = component.get("v.bundleFormResults");
        if(!$A.util.isEmpty(result) && !$A.util.isUndefined(result)) {
            tempResult = [];
            for(var i = 0; i < result.length; i++) {
                var newRes = result[i];
                newRes.iconName = 'utility:add';
                tempResult.push(newRes);
            }
            result = tempResult;
            helper.generateForms(component, event, helper, result, 'bundle');
        }
    },
    
    selectStep2 : function(component, event, helper) {
        component.set("v.selectedStep", "step2");
        component.set("v.selectedStep2", true);
        helper.loadReviewScreen(component, event, helper);
    },
    
    selectStep3 : function(component, event, helper) {
        component.set("v.selectedStep", "step3");
        component.set('v.showSpinner', true);
        helper.loadReviewScreen(component, event, helper);
    },
    
    removeForm : function(component, event, helper) {
        var target = event.target;
        var selectedFormId = target.getAttribute("data-Index");
        var selectedRecordVal = target.getAttribute("data-key");
        helper.addOrRemoveForms(component, event, helper, selectedFormId, selectedRecordVal);
    },
    
    formSelectionHandler : function(component, event, helper) {
        var target = event.target;
        var selectedFormId = target.getAttribute("data-Index");
        var selectedRecordVal = component.get('v.selectedRecord');
        if(!$A.util.isEmpty(selectedRecordVal) && !$A.util.isUndefined(selectedRecordVal)) {
            helper.addOrRemoveForms(component, event, helper, selectedFormId, selectedRecordVal);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "",
                "type": "warning",
                "message": "Please choose record type to select forms."
            });
            toastEvent.fire();
        }
    },
    
    generatePreviousForm : function(component, event, helper) {
        var currentFormNumber = component.get('v.formNumber');
        var pageNumber = currentFormNumber - 1;
        helper.formsNavigation(component, event, helper, pageNumber);
    },
    
    generateNextForm : function(component, event, helper) {
        var currentFormNumber = component.get('v.formNumber');
        var pageNumber = currentFormNumber + 1;
        helper.formsNavigation(component, event, helper, pageNumber);
    },
    
    Prev : function(component, event, helper) {
        component.set ('v.showSpinner', true);
        var pageNumber = component.get("v.pageNumberForFormResult");
        component.set("v.pageNumberForFormResult", parseInt(pageNumber) - 1);  
        helper.searchForms(component, event, helper, 'Prev');  
    },
    
    Next : function(component, event, helper) {
        component.set ('v.showSpinner', true);
        var pageNumber = component.get("v.pageNumberForFormResult");
        component.set("v.pageNumberForFormResult", parseInt(pageNumber) + 1);  
        helper.searchForms(component, event, helper, 'Next'); 
    }
})