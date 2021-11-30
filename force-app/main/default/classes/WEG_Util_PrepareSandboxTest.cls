@isTest
class WEG_Util_PrepareSandboxTest {

    @isTest
    static void testSandboxPrep() {
        // Insert logic here to create records of the objects that the class you’re testing
        // manipulates.

        Test.startTest();

        Test.testSandboxPostCopyScript(
            new WEG_Util_PrepareSandbox(), UserInfo.getOrganizationId(),
                UserInfo.getOrganizationId(), UserInfo.getOrganizationName());

        Test.stopTest();

        // Insert assert statements here to check that the records you created above have
        // the values you expect.
    }
}