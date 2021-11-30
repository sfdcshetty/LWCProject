/**
 * Created by jasonmiletta on 5/25/21.
 */

@IsTest
private class x7s_RecentDocumentsControllerTest {
    @IsTest
    static void testGetDocumentList() {
        Test.startTest();
        List<TVA_CFB__Cloud_Files__c> files = x7s_RecentDocumentsController.getListOfDocumentsForCurrentUser();
        x7s_RecentDocumentsController.getDocuvaultFolders();
        x7s_RecentDocumentsController.getListOfFolderNames();
		x7s_RecentDocumentsController.deleteCloudFile(null);
        if(files.size() > 0){
            x7s_RecentDocumentsController.deleteCloudFile(files[0].Id);
        }
        files = x7s_RecentDocumentsController.getListOfDocumentsForCurrentUser();
        System.assert(files.size() > 0);
        System.assert(files[0].TVA_CFB__Folder__c == 'Trash');
        Test.stopTest();
    }

    @TestSetup
    static void setupData(){
        TVA_CFB__Cloud_Files__c file = new TVA_CFB__Cloud_Files__c();
        file.Name='fake pdf.pdf';
        file.TVA_CFB__Folder__c='Tax Returns';
        file.Share_On_Portal__c=false;

        insert file;
    }
}