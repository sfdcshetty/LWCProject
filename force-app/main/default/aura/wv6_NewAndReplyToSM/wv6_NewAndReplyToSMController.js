({
	doInit : function(component, event, helper) {
		helper.getClonedRecord(component);
	},
    sendMessage : function(component, event, helper) {
    	helper.saveSMRecord(component);
	},
    closeModal : function(component, event, helper) {
    	helper.closeReplyModal(component);
	}
})