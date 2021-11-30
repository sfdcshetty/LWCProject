public with sharing class Docuvault_JournalingQueueableController implements Queueable, Database.AllowsCallouts {
	
    public Id journalingCloudFileId;
    Public String journalingEmailTemplate;
    
    public Docuvault_JournalingQueueableController (Id CloudFileId, String EmailTemplate) {
        this.journalingCloudFileId = CloudFileId;
        this.journalingEmailTemplate = EmailTemplate;
        System.Debug ('---- '+journalingCloudFileId);
    }
    
    public void execute(QueueableContext context) {
        System.Debug ('---- '+journalingCloudFileId);
        Docuvault_JournalingEmailController.sendCloudFileAsEmail (journalingCloudFileId, journalingEmailTemplate);
    }
}