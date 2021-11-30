({
    getsObjectRecords : function(component) {
        var action = component.get("c.getRecords");
        action.setParams({
            objectAPIName : component.get("v.object"),
            filterCriteria : component.get("v.filterCriteria"),
            orderByClause : component.get("v.orderByClause"),
            displayLocation : component.get("v.displayLocation"),
            recordId : component.get("v.recordId")
            
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var responseWrap = response.getReturnValue(); 
                if(responseWrap.sObjectRecords && responseWrap.sObjectRecords != null){
                    if(responseWrap.sObjectRecords.length == 0){
                    	var msg = component.get("v.msg");
                        if(msg != null){
                            if(msg.length>0){
                                component.set("v.showMsg",true);    
                            }
                        }
                    }
                }
                component.set("v.latestRecords",responseWrap.sObjectRecords);
                component.set("v.grandTotal",responseWrap.grandTotal);
            }else if (state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "ERROR:",
                    "message": "Error occurred while fetching Financial Accounts.Please contact your Administrator."
                });
                toastEvent.fire();
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
    }
})