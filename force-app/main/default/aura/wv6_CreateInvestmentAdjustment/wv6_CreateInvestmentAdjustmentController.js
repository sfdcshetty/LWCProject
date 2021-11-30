({
    doInit : function(component, event, helper) {
        var financialAccountId = component.get("v.financialAccountId");
        var investmentAdjustment = component.get("v.investmentAdjustment");
        investmentAdjustment.Financial_Account__c = financialAccountId;
        component.set("v.investmentAdjustment", investmentAdjustment);
        var getAdjustmentTypes = component.get("c.getInvestAdjustmentTypes");
        getAdjustmentTypes.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.adjustmentTypePicklist", response.getReturnValue());
            }
        });
        $A.enqueueAction(getAdjustmentTypes);
    },
    
    cancel : function(component, event, helper){
        helper.closeMe(component, event, helper, false);
    },
    
    saveRecord : function(component, event, helper){
		var isError = false;
        // Check if user has entered search criteria
		var adjustmenttType = component.find("adjustmenttType");
        var adjustmenttTypeValue = adjustmenttType.get("v.value");
        if(!adjustmenttTypeValue){
			isError = true;
            adjustmenttType.set("v.errors", [{message: 'Adjustment Type is required.'}]);
        }else{
            adjustmenttType.set("v.errors", []); 
        }
        
		var amount = component.find("amount");
        var amountValue = amount.get("v.value");
        if(!amountValue){
            isError = true;
            $A.util.addClass(amount, 'erroneousField');
			amount.set("v.errors", [{message: 'Amount is required.'}]);
        }else{
            amount.set("v.errors", []);
            $A.util.removeClass(amount, 'erroneousField');
        }
        
		var dateofAdjustment = component.find("dateofAdjustment");
        var dateofAdjustmentValue = dateofAdjustment.get("v.value");
        if(!dateofAdjustmentValue){
            isError = true;
            $A.util.addClass(dateofAdjustment, 'erroneousField');
			dateofAdjustment.set("v.errors", [{message: 'Date of Adjustment is required.'}]);
        }else{
        	dateofAdjustment.set("v.errors", []);	
            $A.util.removeClass(dateofAdjustment, 'erroneousField');
        }
        
		var reason = component.find("reason");
        var reasonValue = reason.get("v.value");
        if(!reasonValue){
			isError = true;
            reason.set("v.errors", [{message: 'Adjustment Reason is required.'}]);
        }else{
        	reason.set("v.errors", []);    
        }
		
		if(!isError){
            component.set("v.showSpinner", true);
            var adjustment = component.get("v.investmentAdjustment");
            var createAdjustment = component.get("c.createInvestmentAdjustment");
            createAdjustment.setParams({
                "investmentAdjustment": adjustment
            });
            createAdjustment.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    helper.closeMe(component, event, helper, true);
                }else{
                    helper.closeMe(component, event, helper, false);
                }
                component.set("v.showSpinner", false);
            });
            $A.enqueueAction(createAdjustment);
        }
    }
})