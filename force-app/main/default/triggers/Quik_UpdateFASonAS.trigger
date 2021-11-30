//Test class : QuikFormHandler_TEST
trigger Quik_UpdateFASonAS on Financial_Account_Servicing__c (after insert, before delete)  { 
    List<Financial_Account_Servicing__c> fasIterateList = new List<Financial_Account_Servicing__c> ();
    Map<Id, List<Financial_Account_Servicing__c>> asAndRelatedFas = new Map<Id, List<Financial_Account_Servicing__c>> ();
    List<Account_Servicing__c> asRecordsToUpdate = new List<Account_Servicing__c>();
    Set<Id> asRecordIds = new Set<Id>();
    Set<Id> fasRecordIds = new Set<Id>();
    List<Financial_Account_Servicing__c> fasRecordsDeleted = new List<Financial_Account_Servicing__c>();
    if (Trigger.isinsert) {
        fasIterateList = Trigger.new;
    }
    if (Trigger.isdelete) {
        fasIterateList = Trigger.old;
    }
    
    for(Financial_Account_Servicing__c fas : fasIterateList) {
        asRecordIds.add(fas.Account_Servicing__c);
        fasRecordIds.add(fas.Id);
    }

    if(asRecordIds.size() > 0) {
        String query = 'SELECT ';
        if(Trigger.isInsert) {
            query = query+ ' (Select Id, RecordType.Name, WEG_New_Account_Type__c, Financial_Account__c, Financial_Account__r.WEGP1_IsWEAS__c FROM Financial_Account_Servicing__r ORDER BY CreatedDate ASC)';
        }
        if(Trigger.isDelete) {
            query = query+ ' (Select Id, RecordType.Name, WEG_New_Account_Type__c, Financial_Account__c, Financial_Account__r.WEGP1_IsWEAS__c FROM Financial_Account_Servicing__r WHERE Id not in : fasRecordIds ORDER BY CreatedDate ASC)';
        }
        query = query+' FROM Account_Servicing__c WHERE id in: asRecordIds';
        for (Account_Servicing__c asRecord : database.query(query)) {
            integer i = 1;
            integer totalFields = Integer.ValueOf(system.Label.TotalFasLookupsOnAS);
            for(integer j = 1; j<=totalFields; j++) {
                asRecord.put('WEG_FAS_'+j+'__c','');
            }
            for (Financial_Account_Servicing__c fas : asRecord.Financial_Account_Servicing__r) {
                if((fas.WEG_New_Account_Type__c == 'Advisory') ||
                    (fas.RecordType.Name == 'Maintenance' && 
                     fas.Financial_Account__c != null && 
                     fas.Financial_Account__r.WEGP1_IsWEAS__c == True) ||
                     (fas.RecordType.Name == 'Update Fee' && 
                     fas.Financial_Account__c != null && 
                     fas.Financial_Account__r.WEGP1_IsWEAS__c == True)) {
                        asRecord.put('WEG_FAS_'+i+'__c',fas.id);
                        i++;
                }
            }
            asRecordsToUpdate.add(asRecord);
        }
    }
    if(asRecordsToUpdate.size() > 0) {
        update asRecordsToUpdate;
    }
}