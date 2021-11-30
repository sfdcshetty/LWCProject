global class AssetAndLiabilities_Scheduler implements Schedulable{

    global void execute(SchedulableContext sc) {

        CheckOwnerShipOfAssetAndLiabilities batch = new CheckOwnerShipOfAssetAndLiabilities ();
        ID batchprocessid = Database.executeBatch(batch,50);           
    }
}