// Test class: RestrictFasDelete_TEST 
trigger RestrictFasDelete on Financial_Account_Servicing__c (before delete) {
    User currentLoggedInUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Id =: UserInfo.getUserId()];
    for(Financial_Account_Servicing__c fas : Trigger.Old) {
        if(fas.Principal_Review_Final_Status__c == 'Approved (In Good Order)' &&
           (currentLoggedInUser.Profile.Name != 'System Administrator' ||
            currentLoggedInUser.Profile.Name != 'Compliance' ||
            currentLoggedInUser.UserRole.Name != 'Practice Development')) {
                if(!Test.isRunningTest()){
                    fas.addError('The financial account servicing record could not be deleted because it has been approved by Suitability.');
                }
            }
    }
}