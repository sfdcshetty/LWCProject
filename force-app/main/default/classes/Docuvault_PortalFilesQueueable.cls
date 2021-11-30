public class Docuvault_PortalFilesQueueable implements Queueable {

    public List <Id> portalSharableFileIds;
    
    public Docuvault_PortalFilesQueueable (List <Id> cloudFileIds) {
        System.Debug ('---- '+cloudFileIds);
        portalSharableFileIds = NEW List <Id> ();
        this.portalSharableFileIds = cloudFileIds;
        System.Debug ('---- '+portalSharableFileIds);
    }
    
    public void execute(QueueableContext context) {
        System.Debug ('---- '+portalSharableFileIds);
        Database.executeBatch(new Docuvault_CreatePortalDocumentBatch (portalSharableFileIds), 50);
    }
}