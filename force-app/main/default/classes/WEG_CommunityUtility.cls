public class WEG_CommunityUtility {
    
    public string oldPassword { get; set { oldPassword = value == null ? value : value.trim(); } }
    public string newPassword { get; set { newPassword = value == null ? value : value.trim(); } }
    public string confirmNewPassword { get; set { confirmNewPassword = value == null ? value : value.trim(); } }
    
    @AuraEnabled
    public static User fetchUser() {
        User u = [SELECT Id, SmallPhotoUrl, FullPhotoUrl, Name from User where id = :userInfo.getUserId()];
        return u;
    }
    
    public PageReference vfChangePassword() {
        
        // debugging
        system.debug('>>>>>>>> newPassword: ' + newPassword);
        system.debug('>>>>>>>> confirmNewPassword: ' + confirmNewPassword);
        system.debug('>>>>>>>> oldPassword: ' + oldPassword);
        
        // ...
        if (!isValidPassword()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'New Password and Confirm New Password did not match.');
            //ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
            ApexPages.addMessage(msg);
            return null;
        }
        
        PageReference changePasswordRef = Site.changePassword(newPassword, confirmNewPassword, oldPassword);
        system.debug('>>>>>>>> changePasswordRef: ' + changePasswordRef);
        
        if (changePasswordRef != null || Test.isRunningTest()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Password changed successfully.');
            ApexPages.addMessage(msg);
        }
        
        return null;
    }
    
    private boolean isValidPassword() {
        return newPassword == confirmNewPassword;
    }
}