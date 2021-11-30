public class Wave6_CloudFileValidationExtension {
    string cfId;
    public Wave6_CloudFileValidationExtension(Apexpages.StandardController stdController){
        cfId = ((TVA_CFB__Cloud_Files__c)stdController.getRecord()).Id;
        
    }    
        
    public PageReference validateData(){
        PageReference pageRef = null;
        try{
            TVA_CFB__Cloud_Files__c cloudfile = [Select Id,WEGP1_RIACompliant__c From TVA_CFB__Cloud_Files__c Where Id =:cfId ]; 
            if(cloudfile!=null){
                if(cloudfile.WEGP1_RIACompliant__c== 'Approved (In Good Order)'){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'When a cloud file is in the Principle Review state of Approved (In Good Order), a Cloud File cannot be deleted'));
                }else{
                    pageRef = new PageReference('/apex/TVA_CFB__DeleteFile');
                    pageRef.setRedirect(false);
                }
            }
        }catch(Exception ex){
            system.debug('Error: '+ex.getMessage());
        }
        return pageRef;
    }
}