global class WEG_Util_PrepareSandbox implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        System.debug('Org ID: ' + context.organizationId());
        System.debug('Sandbox ID: ' + context.sandboxId());
        System.debug('Sandbox Name: ' + context.sandboxName());

        // insert logic here to prepare the sandbox for use
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        
        User tsolland = [SELECT Id FROM User WHERE Name = 'Troy Solland'];
        
        tsolland.Email = 'troy.solland@nfusedata.com';
        tsolland.IsActive = true;
        tsolland.ProfileId = adminProfileId;
        tsolland.UserRoleId = null;
        tsolland.UserPermissionsMarketingUser = true;
        
        update tsolland;
    }
}