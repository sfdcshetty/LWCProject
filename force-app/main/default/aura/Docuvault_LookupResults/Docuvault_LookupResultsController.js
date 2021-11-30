({
   selectRecord : function(component, event, helper){
       var getSelectedRecord = component.get("v.selectedRecord");
       var appEvent = $A.get("e.c:Docuvault_LookupEvent");
       appEvent.setParams({"record" : getSelectedRecord });  
       appEvent.fire();
    }
})