public with sharing class ProcessDdpsExt {
    public Loop__DDP__c ddp { get; set; }
    public Loop__DDP_Integration_Option__c deliveryOption { get; set; }
    public List<Loop.ProcessDdpParameters> parameters { get; set; }
    public TVA_CFB__Cloud_Files__c cloudFile { get; set; }
    public List <FileInfo> Infos { get; set; }
    
    public ProcessDdpsExt() {
        Id cloudFileId = ApexPages.currentPage().getParameters().get('id');
        string ddpId = ApexPages.currentPage().getParameters().get('ddpId');
        string deliveryOptionId = ApexPages.currentPage().getParameters().get('deliveryOptionId');

        Infos = new List <FileInfo>();
        cloudFile = new TVA_CFB__Cloud_Files__c ();
        parameters = new List<Loop.ProcessDdpParameters>();
        if (cloudFileId != NULL) {
            cloudFile = [ SELECT Name FROM TVA_CFB__Cloud_Files__c WHERE Id =:cloudFileId ];
            if(!Test.isRunningTest()) {
                Loop.ProcessDdpParameters params = new Loop.ProcessDdpParameters(ddpId, deliveryOptionId, cloudFileId, new List<Id>());
                params.theme = Loop.ProcessDdpParameters.ThemeStyle.Bootstrap_3_2;
                
                Infos.add(new FileInfo(cloudFile, params));
            }
        }
        
        if (CloudFileId == NULL) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must specify at least one Cloud file Id via the "id" query string parameter.'));
        }
    }
    
    public class FileInfo {
        public TVA_CFB__Cloud_Files__c cloudFile { get; set; }
        public Loop.ProcessDdpParameters Parameters { get; set; }
        public fileInfo (TVA_CFB__Cloud_Files__c cloudFile, Loop.ProcessDdpParameters parameters) {
            this.cloudFile = cloudFile;
            this.Parameters = parameters;
        }
    }
}