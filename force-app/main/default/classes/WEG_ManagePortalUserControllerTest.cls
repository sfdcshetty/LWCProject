@isTest
private class WEG_ManagePortalUserControllerTest {
    
    private static testMethod void testManagePortalUserController() {
        
        Account testPerson1 = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId(),
            Name ='Apex TestOne'
        );
        insert testPerson1;
        
        Contact testContact1 = [SELECT Id FROM Contact WHERE AccountId = :testPerson1.Id];
        
        testContact1.Email = 'apex.testone@weg.com';
        update testContact1;
        
        test.startTest();
        
        // attempt to get a portal user based on contact (expecting failure)
        WEG_ManagePortalUserController.PortalUser portalUser = WEG_ManagePortalUserController.getPortalUser(testContact1.Id);
        
        // attempt to save a bad portal user (expecting failure)
        WEG_ManagePortalUserController.PortalUser portalResponse = WEG_ManagePortalUserController.validateInput(null);
        
        // make a good call, to get the portal user
        portalUser = WEG_ManagePortalUserController.getPortalUser(testPerson1.Id);
        system.assertEquals(testPerson1.Id, portalUser.AccountId);
        
        // attempt to validate without a mobile number
        portalUser = WEG_ManagePortalUserController.validateInput(portalUser);
        
        // add the mobile number and validate
        portalUser.MobilePhone = '1234567890';
        portalUser = WEG_ManagePortalUserController.validateInput(portalUser);
        
        // create the user
        portalUser = WEG_ManagePortalUserController.createUser(portalUser);
        
        // link the user to the contact
        portalUser = WEG_ManagePortalUserController.linkUserOnContact(portalUser);
        
        // update the portal status
        portalUser = WEG_ManagePortalUserController.updatePortalStatus(portalUser);
        
        // update the user
        portalUser.Email = 'apex.testtwo@weg.com';
        portalUser.MobilePhone = '2083157645';
        portalUser = WEG_ManagePortalUserController.updateMobileOnContact(portalUser);
        portalUser = WEG_ManagePortalUserController.updateUser(portalUser);
        
        // deactivate the user
        portalUser = WEG_ManagePortalUserController.deactivateUser(portalUser);
        
        test.stopTest();
    }
}