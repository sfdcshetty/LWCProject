@isTest 
private class ProcessDdpsExt_TC {
    static testMethod void ProcessDdpsExtMethods() {
        test.starttest();
        TVA_CFB__Cloud_Files__c cloudfile = NEW TVA_CFB__Cloud_Files__c ();
        cloudfile.name = 'test';
        insert cloudfile;
         
        System.currentPageReference().getParameters().put('id', cloudfile.id);
        System.currentPageReference().getParameters().put('ddpId', cloudfile.id);
        System.currentPageReference().getParameters().put('deliveryOptionId', cloudfile.id);
        ProcessDdpsExt Process = NEW ProcessDdpsExt ();
        ProcessDdpsExt.FileInfo obj = NEW ProcessDdpsExt.FileInfo (cloudfile, null);
        test.stoptest();
    }
    static testMethod void ProcessDdpsExtMethods1() {
        test.starttest();
        TVA_CFB__Cloud_Files__c cloud = NEW TVA_CFB__Cloud_Files__c ();
        cloud.name = 'test';
        insert cloud;
        
        System.currentPageReference().getParameters().put('ddpId', cloud.id);
        System.currentPageReference().getParameters().put('deliveryOptionId', cloud.id);
        ProcessDdpsExt Process = NEW ProcessDdpsExt ();
        Process.ddp = null;
        Process.deliveryOption = null;
        ProcessDdpsExt.FileInfo obj = NEW ProcessDdpsExt.FileInfo (cloud, null);
        test.stoptest();
    }
}