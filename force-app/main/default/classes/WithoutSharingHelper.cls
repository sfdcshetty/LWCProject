/*
 *	{Purpose}  –  This class is to enable non sharing functions that can be called inside of shared classes..
 *
 *   {Function}  –
 *
 *   {Support}   - Matthew J Lennington (Perficient) matthew.lennington@perficient.com
 *
 *
 *   CHANGE  HISTORY
 *   =============================================================================
 *   Date      Name             				Description
 *   20200324  Matthew J Lennington          Created
 *   =============================================================================
 */
public without sharing class WithoutSharingHelper {
    // public static void deleteRecords(SObject obj) {
    //     Database.delete(obj);
    // }
    // public static void deleteRecords(List<SObject> obj) {
    //     Database.delete(obj);
    // }

    // public static void deleteRecords(Id obj) {
    //     Database.delete(obj);
    // }

    // public static void deleteRecords(List<Id> obj) {
    //     Database.delete(obj);
    // }

    // public static SObject insertRecords(SObject obj) {
    //     Database.insert(obj);
    //     return obj;
    // }
    // public static List<SObject> insertRecords(List<SObject> obj) {
    //     Database.insert(obj);
    //     return obj;
    // }
    public static List<SObject> updateRecords(List<SObject> obj) {
        Database.update(obj);
        return obj;
    }
    // public static SObject updateRecords(SObject obj) {
    //     Database.update(obj);
    //     return obj;
    // }

    // public static List<SObject> getRecords(String query) {
    //     return Database.query(query);
    // }
}