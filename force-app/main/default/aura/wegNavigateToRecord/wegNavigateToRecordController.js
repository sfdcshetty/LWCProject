({
	invoke : function(component, event, helper) {
		// get the record Id attribute
		var recordId = component.get("v.recordId");
        var acctServId = component.get("v.acctServId");
        
        var redirect;
        if (acctServId) {
            // 
            redirect = $A.get("e.force:navigateToURL");
            
            var hostname = window.location.hostname;
            var redirectURL = 'https://' + hostname + '/lightning/r/Account_Servicing__c/' + acctServId;
            redirectURL += '/view?ws=%2Flightning%2Fr%2FAccount' + recordId + '%2Fview';
            
            redirect.setParams({
                "url": redirectURL
            });
        }
        else {
            // get the Lightning event that opens a record in a new tab
            // pass the record Id to the event
            redirect = $A.get("e.force:navigateToSObject");
            redirect.setParams({
                "recordId": recordId
            });
        }
        
        // open the record
        redirect.fire();
	}
})