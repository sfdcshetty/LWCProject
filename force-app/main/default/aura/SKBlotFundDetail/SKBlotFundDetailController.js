({
	doInit : function(component, event, helper) {
        // show the Fund Details
        helper.showFundDetails(component, event);
	},
    doHideModalFD : function(component, event, helper) {
		// hide the Fund Detail popup
        helper.hideModalFD(component, event);
	},
    doHideModalDelete : function(component, event, helper) {
		// hide the Fund Detail popup
        helper.hideModalDelete(component, event);
	},
    doSaveFD : function(component, event, helper) {
		// validate the Fund Detail
        helper.validateFundDetail(component, event);
        
        // if there are no errors, proceed to save
        if(!component.get("v.valError")){
        	// save the Fund Detail
            helper.saveFundDetail(component, event);
            
            // hide the Fund Detail popup
            helper.hideModalFD(component, event);    
        }
	},
    doConfirmDeleteFD : function(component, event, helper) {
		// delete the Fund Detail
        helper.deleteFundDetail(component, event);
        
        // hide the Fund Detail popup
        helper.hideModalDelete(component, event);
	},
    doNewFD : function(component, event, helper) {
        // set the id of the selected Fund Detail to null
        component.set("v.selectedRecordId", null);
        
        // retrieve the Fund Detail
        helper.showFundDetail(component, event);
        
		// show the Fund Detail popup
        helper.showModalFD(component, event);
	},
    doEditFD : function(component, event, helper) {
        // retrieve the id of the Fund Detail and set it
        var clickedLink = event.currentTarget;
        var selectedId = clickedLink.dataset.recordid;
        component.set("v.selectedRecordId", selectedId);
        
        // retrieve the Fund Detail
        helper.showFundDetail(component, event);
        
		// show the Fund Detail popup
        helper.showModalFD(component, event);
	},
    doDeleteFD : function(component, event, helper) {
        // retrieve the id of the Fund Detail and set it
        var clickedLink = event.currentTarget;
        var selectedId = clickedLink.dataset.recordid;
        component.set("v.selectedRecordId", selectedId);
        
        // retrieve the Fund Detail
        helper.showModalDelete(component, event);
	}
    
})