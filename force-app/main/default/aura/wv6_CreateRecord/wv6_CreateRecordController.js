({	
    doInit : function (component, event, helper) {
    	var buttonAlignment = component.get("v.buttonAlignment");   
        if(buttonAlignment.toLowerCase() === 'right'){            
            component.set("v.buttonCSSClass","slds-float_right margin");   
        }else if(buttonAlignment.toLowerCase() === 'left'){            
            component.set("v.buttonCSSClass","slds-float_left margin");   
        }
    },
    
    handleClick : function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": component.get("v.objectAPIName")
        });
        createRecordEvent.fire();
    }	  
})