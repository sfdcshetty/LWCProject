global class JournalingEmailAttachment_Scheduler implements Schedulable{

    global void execute(SchedulableContext sc) {

        JournalingEmailMessageAttachments batch = new JournalingEmailMessageAttachments();
        ID batchprocessid = Database.executeBatch(batch,50);           
    }
}