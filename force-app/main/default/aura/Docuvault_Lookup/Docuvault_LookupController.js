({
    doInit : function(component, event, helper) {
        var objName = component.get("v.objectAPIName");
        if(objName.includes("__c")) {
            component.set("v.IconName", 'custom_notification');
            var customObjName = objName.replace("__c", "");
            component.set("v.objectName", customObjName);
        }
        else {
            var iconName = objName.toLowerCase();
            component.set("v.IconName", iconName);
            component.set("v.objectName", objName);
        }
       
    },
    closelist: function(component, event, helper){
        var showResults = component.find("searchRes");
        $A.util.addClass(showResults, 'slds-is-close');
        $A.util.removeClass(showResults, 'slds-is-open');
       
    },
    onfocus : function(component, event, helper){
        var showResults = component.find("searchRes");
        $A.util.addClass(showResults, 'slds-is-open');
        $A.util.removeClass(showResults, 'slds-is-close');
        helper.searchHelper(component, event, '');
    },
    keyPressController : function(component, event, helper) {
        var getInputkeyWord = component.get("v.SearchKeyWord");
        if (getInputkeyWord.length > 0) {
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component, event, getInputkeyWord);
        }
        else {  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
            
        }
    },
    
    clear :function(component,event,heplper) {
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );
    },
    
    eventHandler : function(component, event, helper) {
        var record = event.getParams ('record');
        component.set("v.selectedRecord" , record.record); 
        if (!$A.util.isEmpty (record.record)) {
            var forclose = component.find("lookup-pill");
            $A.util.addClass(forclose, 'slds-show');
            $A.util.removeClass(forclose, 'slds-hide');
            
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
            
            var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');  
        }
        else {
            var pillTarget = component.find("lookup-pill");
            var lookUpTarget = component.find("lookupField"); 
            
            $A.util.addClass(pillTarget, 'slds-hide');
            $A.util.removeClass(pillTarget, 'slds-show');
            
            $A.util.addClass(lookUpTarget, 'slds-show');
            $A.util.removeClass(lookUpTarget, 'slds-hide');
            
            component.set("v.SearchKeyWord",null);
            component.set("v.listOfSearchRecords", null );
            component.set("v.selectedRecord", {} );
        }
        
    }    
})