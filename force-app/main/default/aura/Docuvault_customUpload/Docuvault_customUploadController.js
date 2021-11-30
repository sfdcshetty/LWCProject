({
    uploadFile : function(component, event, helper) {
        var filesList = component.find ('inp').get ('v.files');
        helper.uploadHandler (component, event, helper, filesList, 0);
    }
})