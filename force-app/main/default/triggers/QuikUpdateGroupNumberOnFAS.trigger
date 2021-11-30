trigger QuikUpdateGroupNumberOnFAS on Financial_Account_Servicing__c(before insert, before update, before delete) {

    List<Financial_Account_Servicing__c> fasIterateList = new List<Financial_Account_Servicing__c> ();
    List<String> custodianValues = new List<String> ();
    Set <Id> asIds = new Set <Id> ();
    Map<String, List<String>> custodianGroups = new Map<String, List<String>> ();
    Map<Id, Map<String, List<Financial_Account_Servicing__c>>> fasWithCustodiansGroupIds = new Map<Id, Map<String, List<Financial_Account_Servicing__c>>> ();
    List<Financial_Account_Servicing__c> fasRecordsWithGroupIds = new List<Financial_Account_Servicing__c> ();
    Map<String, List<Financial_Account_Servicing__c>> custodianGroupsIds = new Map<String, List<Financial_Account_Servicing__c>> ();
    Map<String, List<Financial_Account_Servicing__c>> tempMap = new Map<String, List<Financial_Account_Servicing__c>> ();

    List<Financial_Account_Servicing__c> fasToUpdate = new List<Financial_Account_Servicing__c> ();
    if (Trigger.isInsert) {
        for (Financial_Account_Servicing__c fas : Trigger.new) {
            fas.Quik_Group_Number__c = NULL;
        }
    }
    if ((Trigger.isinsert || Trigger.isUpdate) && Trigger.isBefore) {
        fasIterateList = Trigger.new;
    }
    if (Trigger.isdelete && Trigger.isBefore) {
        fasIterateList = Trigger.old;

    }
    Set <ID> fasIds = new Set <ID> ();
    
    for (Financial_Account_Servicing__c fas : fasIterateList) {

        asIds.add(fas.Account_Servicing__c);
        if (!Trigger.isInsert && !Trigger.isDelete)
            fasIds.add (fas.id);
        custodianValues.add(fas.WEG_Custodian__c);
    }
    if (asIds.size () > 0) {

        fasRecordsWithGroupIds = [SELECT Account_Servicing__c, WEG_Custodian__c, Quik_Group_Number__c
                                  FROM Financial_Account_Servicing__c
                                  WHERE Account_Servicing__c in :asIds
                                  AND WEG_Custodian__c != null
                                  AND ID NOT IN : fasIds
                                  Order by Account_Servicing__c, WEG_Custodian__c, Quik_Group_Number__c];


        for (Financial_Account_Servicing__c ag : fasRecordsWithGroupIds) {
            if (custodianGroupsIds.containsKey((String) ag.get('WEG_Custodian__c'))) {
                custodianGroupsIds.get((String) ag.get('WEG_Custodian__c')).add(ag);
            } else {
                custodianGroupsIds.put((String) ag.get('WEG_Custodian__c'), new List<Financial_Account_Servicing__c> { ag });
            }
            fasWithCustodiansGroupIds.put((ID) ag.get('Account_Servicing__c'), custodianGroupsIds);
        }
    }


    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        
        for (Financial_Account_Servicing__c fas : Trigger.new) {
            if (fas.Quik_Group_Number__c == NULL) {
                String lstCustodian = '';
                if (fas.WEG_Custodian__c != null ) {
                    lstCustodian = '0000';
                    
                    if (!fasWithCustodiansGroupIds.isEmpty()) {
                        if (fasWithCustodiansGroupIds.containsKey(fas.Account_Servicing__c)) {
                            tempMap = fasWithCustodiansGroupIds.get(fas.Account_Servicing__c);
                            if (tempMap.containsKey(fas.WEG_Custodian__c)) {
                                List<String> tempList = new List<String> ();
                                if (tempMap.get(fas.WEG_Custodian__c) != null) {
                                    for (Financial_Account_Servicing__c fs : tempMap.get(fas.WEG_Custodian__c)) {
                                        tempList.add(fs.Quik_Group_Number__c);
                                    }
                                    if (tempList.size() > 0) {
                                        lstCustodian = tempList[tempList.size() - 1];
                                        lstCustodian = String.valueOf(Integer.valueOf(lstCustodian) + 1000);
                                    }
                                }
                            }
                        }
                    }
                    
                    fas.Quik_Group_Number__c = lstCustodian;
                }
            }
            
        }
    }
    
   

    if (Trigger.isBefore && Trigger.isDelete) {
        for (Financial_Account_Servicing__c fas : Trigger.old) {
            Integer groupNumb = NULL;

            if (!fasWithCustodiansGroupIds.isEmpty()) {
                if (fasWithCustodiansGroupIds.containsKey(fas.Account_Servicing__c)) {

                    tempMap = fasWithCustodiansGroupIds.get(fas.Account_Servicing__c);
                    if (tempMap.containsKey(fas.WEG_Custodian__c)) {
                        for (Financial_Account_Servicing__c s : tempMap.get(fas.WEG_Custodian__c)) {
                            
                            if (s.ID == fas.Id && fas.Quik_Group_Number__c != null) {
                                
                                if(Integer.valueOf(fas.Quik_Group_Number__c) != null)
                                    groupNumb = Integer.valueOf(fas.Quik_Group_Number__c);
                            }
                            else {
                                
                                if (s.Quik_Group_Number__c != NULL && groupNumb != NULL && Integer.valueOf(s.Quik_Group_Number__c) > groupNumb) {
                                    groupNumb = Integer.valueOf(s.Quik_Group_Number__c) - 1000;
                                    if (groupNumb == 0) {
                                        s.Quik_Group_Number__c = '0000';
                                    } else {
                                        s.Quik_Group_Number__c = String.valueOf(groupNumb);
                                    }
                                    fasToUpdate.add(s);
                                }
                                
                                
                            }
                        }
                    }
                }
            }
        }
        if (fasToUpdate.size() > 0) {
            update fasToUpdate;
        }
    }
}