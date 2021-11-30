({
    createUpload : function(component, event, helper) {
        var obj = {};
        obj['Short_Description__c']  = component.find ('desc').get ('v.value');
        console.log (obj);
        console.log (component.get ('v.parentId'));
        $A.createComponent(
            "TVA_CFB:Docuvault_UploadFiles",
            {
                "recordId" : component.get ('v.parentId'),
                "enableFolder" : false,
                "enableNew" : false,
                "CloudFile": obj
            },
            function (uploadComp, status, errorMessage) {
                console.log ("----");
                console.log(errorMessage);
                if (status === "SUCCESS") {
                    component.set("v.uploadFile", '');
                    var body = component.get("v.uploadFile");
                    body.push (uploadComp);
                    
                    component.set("v.uploadFile", body);
                }
                
            }
        );
    }
})