({
	showFundDetails : function(component, event) {
        // retrieve the Questionnaire ID
        var recordId = component.get("v.recordId");
       
        // display the spinner
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, 'hideDiv');
        
        // retrieve the financial accounts
        var action = component.get("c.getFundDetails");
        action.setParams({
            QSID : recordId
        });
        
        // upon returning from getFundDetails call
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // set the list of Fund Details
                component.set("v.fundDetails", action.getReturnValue());
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log("Error message: " + JSON.stringify(response.getError()));
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                }
            }
            // hide the spinner
            $A.util.addClass(spinner, 'hideDiv');
        });
        $A.enqueueAction(action);
	},
    showFundDetail : function(component, event){
        // retrieve the selected record id
        var selectedRecordId = component.get("v.selectedRecordId");
        
        // if selection is made
        if(selectedRecordId != null){
            // display the spinner
            var spinner = component.find("spinner");
            $A.util.removeClass(spinner, 'hideDiv');
            
            // retrieve the financial accounts
            var action = component.get("c.getFundDetail");
            action.setParams({
                fundDetailId : selectedRecordId
            });
            
            // upon returning from getFundDetails call
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    // set the Fund Detail
                    var fundDetail = component.get("v.fundDetail");
                    fundDetail =  action.getReturnValue();
                    
                    // set null values, if needed
                    if(!fundDetail.WEGP1_Amount__c){
                        fundDetail.WEGP1_Amount__c = Null;
                    }
                    
                    component.set("v.fundDetail", fundDetail);
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    console.log("Error message: " + JSON.stringify(response.getError()));
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }
                    }
                }
                // hide the spinner
                $A.util.addClass(spinner, 'hideDiv');
            });
            $A.enqueueAction(action);
        }else{
            component.set("v.fundDetail", {
                sobjectType : 'Fund_Detail__c',
                WEGP1_Amount__c : null                
            })
        }
    },
    showModalFD : function(component, event) {
        // reset validation
        component.set("v.valError", null);
        
        // show the background section
        var backgroundSection = component.find("backgroundSection");
        $A.util.removeClass(backgroundSection, 'hideDiv');
        
        // show the Fund detail modal
    	var modal = component.find("modalFD");
        $A.util.removeClass(modal, 'hideDiv');
    },
    hideModalFD : function(component, event) {
        // hide the background section
        var backgroundSection = component.find("backgroundSection");
        $A.util.addClass(backgroundSection, 'hideDiv');
        
        // hide the Fund Detail modal
    	var modal = component.find("modalFD");
        $A.util.addClass(modal, 'hideDiv');
    },
    showModalDelete : function(component, event) {
        // show the background section
        var backgroundSection = component.find("backgroundSection");
        $A.util.removeClass(backgroundSection, 'hideDiv');
        
        // show the delete modal
    	var modal = component.find("modalDelete");
        $A.util.removeClass(modal, 'hideDiv');
    },
    hideModalDelete : function(component, event) {
        // hide the background section
        var backgroundSection = component.find("backgroundSection");
        $A.util.addClass(backgroundSection, 'hideDiv');
        
        // hide the delete modal
    	var modal = component.find("modalDelete");
        $A.util.addClass(modal, 'hideDiv');
    },
    validateFundDetail : function(component, event) {
        // get the Fund Detail
        var fundDetail = component.get("v.fundDetail");
        
        // validate fields on the Fund Detail popup
        if(!fundDetail.WEGP1_Amount__c){
            var valError = ["Please enter the Amount."];
            component.set("v.valError", valError);
        }else{
            component.set("v.valError", null);
        }
    },
    saveFundDetail : function(component, event) {
        // display the spinner
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, 'hideDiv');
        
        // retrieve the record id and Fund Detail
        var recordId = component.get("v.recordId");
        var fundDetail = component.get("v.fundDetail");
        
        // upsert the fund detail
        var action = component.get("c.upsertFundDetail");
        action.setParams({ 
            fundDetail : fundDetail,
            QSID : recordId          
        });
        
        // upon returning from upsertFundDetail call
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // set the list of Fund Detail
                component.set("v.fundDetails", action.getReturnValue());
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log("Error message: " + JSON.stringify(response.getError()));
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                }
            }
            // hide the spinner
            $A.util.addClass(spinner, 'hideDiv');
            
            // hide the background section
            var backgroundSection = component.find("backgroundSection");
            $A.util.addClass(backgroundSection, 'hideDiv');
            
            // hide the new case modal
            var modal = component.find("modalFD");
            $A.util.addClass(modal, 'hideDiv');
        });
        $A.enqueueAction(action);
    },
    deleteFundDetail : function(component, event) {
        // display the spinner
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, 'hideDiv');
        
        // retrieve the selected record id and record id
        var selectedRecordId = component.get("v.selectedRecordId");
        var recordId = component.get("v.recordId");
        
        // delete the fund detail
        var action = component.get("c.deleteFundDetail");
        action.setParams({ 
            fundDetailId : selectedRecordId,
            QSID : recordId
        });
        
        // upon returning from deleteFundDetail call
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // set the list of fund detail
                component.set("v.fundDetails", action.getReturnValue());
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log("Error message: " + JSON.stringify(response.getError()));
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                }
            }
            // hide the spinner
            $A.util.addClass(spinner, 'hideDiv');
            
            // hide the background section
            var backgroundSection = component.find("backgroundSection");
            $A.util.addClass(backgroundSection, 'hideDiv');
            
            // hide the delete modal
            var modal = component.find("modalDelete");
            $A.util.addClass(modal, 'hideDiv');
        });
        $A.enqueueAction(action);
    }
})