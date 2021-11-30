({	
    /******************************************************************************************************************************
    * @class name    : WEGAccountSharingHelper
    * @description   : This class serves as helper for WEGAccountSharingController 
    * @author        : Ganesh Ekhande
    * @date          : 07/04/2017               
    *                   
    * Modification Log :
    * -----------------------------------------------------------------------------------------------------------------
    * Developer                   Date(MM/DD/YYYY)       Description
    * -----------------------------------------------------------------------------------------------------------------
    * Ganesh Ekhande              07/04/2017             Created.
    ******************************************************************************************************************************/
    
	sharingRecalcualtion : function(component, event) {
        var action = component.get("c.recalculateSharing");
        action.setParams({
            "recordId": component.get("v.recordId") 
        });
        action.setCallback(this, function(a){
            var result = a.getReturnValue();
            console.log('result :>>'+ result);
            
            if(result === "SUCCESS"){
            	component.set("v.msg","Sharing re-calculation is completed successfully!");
                $A.get("e.force:closeQuickAction").fire();    
            }else{
                component.set("v.msg","Error occurred while re-calculating sharing. Please try again!");
            }
        });
        $A.enqueueAction(action);	
	}
})