@isTest
private class Wave6_CloudFileValidationExtensionTest {

    private static testMethod void test() {
        test.startTest();
        TVA_CFB__Cloud_Files__c cf1 = New TVA_CFB__Cloud_Files__c(Name='Test CF1', WEGP1_RIACompliant__c='New');
        insert cf1;
        
        PageReference pageRef = Page.Wave6_CloudFileValidationPage;
        pageRef.getParameters().put('Id', String.valueOf(cf1.Id));
        Test.setCurrentPage(pageRef);
      
        Wave6_CloudFileValidationExtension extension = new Wave6_CloudFileValidationExtension(new ApexPages.StandardController(cf1));
        extension.validateData();
        test.stopTest();
    }
}