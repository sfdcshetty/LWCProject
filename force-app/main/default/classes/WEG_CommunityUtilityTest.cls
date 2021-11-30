@isTest
private class WEG_CommunityUtilityTest {
    
    private static testMethod void testManagePortalUserController() {
        
        test.startTest();
        
        User currentUser = WEG_CommunityUtility.fetchUser();
        
        WEG_CommunityUtility util = new WEG_CommunityUtility();
        
        util.oldPassword = 'oldPassword';
        util.newPassword = 'newPassword';
        util.confirmNewPassword = 'xNewPassword';
        
        util.vfChangePassword();
        
        util.confirmNewPassword = 'newPassword';
        
        util.vfChangePassword();
        
        test.stopTest();
    }
}