({	
    /******************************************************************************************************************************
    * @class name    : WEGAccountSharingController
    * @description   : This class serves as client side controller for WEGAccountSharing lightning component
    * @author        : Ganesh Ekhande
    * @date          : 07/04/2017               
    *                   
    * Modification Log :
    * -----------------------------------------------------------------------------------------------------------------
    * Developer                   Date(MM/DD/YYYY)       Description
    * -----------------------------------------------------------------------------------------------------------------
    * Ganesh Ekhande              07/04/2017             Created.
    ******************************************************************************************************************************/
    
	init : function(component, event, helper) {
		component.set("v.msg","Sharing re-calculation is in Progress!");
        helper.sharingRecalcualtion(component, event);
	}
})