public class WEG_CloudFileTriggerHandler {
    
    public void beforeInsert(List<TVA_CFB__Cloud_Files__c> newCloudFiles) {        
        for (TVA_CFB__Cloud_Files__c cf : newCloudFiles) {
            // sync household/business to a single WEG Account field
            if (cf.WEGP1_Household__c != null)
                cf.WEG_Account__c = cf.WEGP1_Household__c;
            else if (cf.Business__c != null)
                cf.WEG_Account__c = cf.Business__c;
            else
                cf.WEG_Account__c = cf.TVA_CFB__Account__c;
        }
    }
    
    public void beforeUpdate(List<TVA_CFB__Cloud_Files__c> newCloudFiles, Map<Id, TVA_CFB__Cloud_Files__c> oldCloudFileMap) {
        for (TVA_CFB__Cloud_Files__c cf : newCloudFiles) {
            TVA_CFB__Cloud_Files__c oldCF = oldCloudFileMap.get(cf.Id);
            
            // sync household/business to a single WEG Account field
            if (cf.WEGP1_Household__c != oldCF.WEGP1_Household__c || cf.Business__c != oldCF.Business__c || cf.TVA_CFB__Account__c != oldCF.TVA_CFB__Account__c) {
                if (cf.WEGP1_Household__c != null)
                    cf.WEG_Account__c = cf.WEGP1_Household__c;
                else if (cf.Business__c != null)
                    cf.WEG_Account__c = cf.Business__c;
                else
                	cf.WEG_Account__c = cf.TVA_CFB__Account__c;
            }
        }
    }
    
    public void afterInsert(List<TVA_CFB__Cloud_Files__c> newCloudFiles) {
        Map<Id, Date> householdDateMap = new Map<Id, Date>();
        
        for (TVA_CFB__Cloud_Files__c cf : newCloudFiles) {
            
            // collect up the households for any cloud files that are signed and in good order
            if (cf.WEG_Signed_Date__c != null && cf.WEGP1_Principal_Review_Final_Status__c == 'Approved (In Good Order)'
               && UserInfo.getUserName() != 'api@wealthenhancement.com') {
                if (!householdDateMap.containsKey(cf.WEGP1_Household__c))
                    householdDateMap.put(cf.WEGP1_Household__c, cf.WEG_Signed_Date__c);
            }
        }
        
        // grab and process any households
        if (!householdDateMap.isEmpty())
            updateHouseholds(householdDateMap);
    }
    
    public void afterUpdate(List<TVA_CFB__Cloud_Files__c> newCloudFiles, Map<Id, TVA_CFB__Cloud_Files__c> oldCloudFileMap) {
        Map<Id, Date> householdDateMap = new Map<Id, Date>();
        Map<Id, string> cloudFilePublicNoteMap = new Map<Id, string>();
        
        for (TVA_CFB__Cloud_Files__c cf : newCloudFiles) {
            TVA_CFB__Cloud_Files__c oldCF = oldCloudFileMap.get(cf.Id);
            
            // check if signed date or principal review final status was changed
            if (cf.WEG_Signed_Date__c != oldCF.WEG_Signed_Date__c || cf.WEGP1_Principal_Review_Final_Status__c != oldCF.WEGP1_Principal_Review_Final_Status__c
               && UserInfo.getUserName() != 'api@wealthenhancement.com') {
                // collect up the households for any cloud files that are signed and in good order
                if (cf.WEG_Signed_Date__c != null && cf.WEGP1_Principal_Review_Final_Status__c == 'Approved (In Good Order)') {
                    if (!householdDateMap.containsKey(cf.WEGP1_Household__c))
                        householdDateMap.put(cf.WEGP1_Household__c, cf.WEG_Signed_Date__c);
                }
            }
            
            // determine if the public review note needs to be updated
            if (cf.WEGP1_Principal_Review_Final_Status__c != oldCF.WEGP1_Principal_Review_Final_Status__c || cf.WEGP1_RIACompliant__c != oldCF.WEGP1_RIACompliant__c
               && UserInfo.getUserName() != 'api@wealthenhancement.com') {
                   cloudFilePublicNoteMap.put(cf.Id, oldCF.WEGP1_Principal_Review_Public_Note__c);
            }
        }
        
        // grab and process any households
        if (!householdDateMap.isEmpty())
            updateHouseholds(householdDateMap);
        
        // update review public note (as necessary)
        if (!cloudFilePublicNoteMap.isEmpty())
            updatePublicReviewNote(cloudFilePublicNoteMap);
    }
    
    private void updatePublicReviewNote(Map<Id, string> cloudFilePublicNoteMap) {
        // query the cloud files to update
        List<TVA_CFB__Cloud_Files__c> cloudFiles = [SELECT Id, WEGP1_Principal_Review_Public_Note__c, WEGP1_Stage_Change_Note__c, LastModifiedBy.Alias
                                                    FROM TVA_CFB__Cloud_Files__c
                                                    WHERE Id IN :cloudFilePublicNoteMap.keySet()];
        
        for (TVA_CFB__Cloud_Files__c cf : cloudFiles) {
            // get the old review public note
            string oldReviewPublicNote = cloudFilePublicNoteMap.get(cf.Id);
            // update the Public Note field
            // set to "Status Change Note – Last Modified By Alias – Today // Previous Principal Review Public Note"
            // cf.LastModifiedBy.Alias
            if (oldReviewPublicNote == null)
                cf.WEGP1_Principal_Review_Public_Note__c = cf.WEGP1_Stage_Change_Note__c + ' - ' + cf.LastModifiedBy.Alias + ' - ' + String.valueOf(Date.today());
            else
                cf.WEGP1_Principal_Review_Public_Note__c = cf.WEGP1_Stage_Change_Note__c + ' - ' + cf.LastModifiedBy.Alias + ' - ' + String.valueOf(Date.today()) + ' // ' + oldReviewPublicNote;
        }
        
        update cloudFiles;
        
        // clear the Status Change Note field
        // now being handled in the Cloud Files Communication process builder - 20190220
        //cf.WEGP1_Stage_Change_Note__c = '';
    }
    
    private void updateHouseholds(Map<Id, Date> householdDateMap) {
        // need the Classification, Status, Anniversary Date and Comp Plan
        List<Account> households = [SELECT Id, Type, FinServ__Status__c, WEGP1_ClientAnniversaryDate__c, WEG_Compensation_Plan__c
                                    FROM Account
                                    WHERE Id IN :householdDateMap.keySet()];
        
        // get the general comp plan
        List<WEG_Compensation_Plan__c> generalPlans = [SELECT Id FROM WEG_Compensation_Plan__c WHERE Name = 'WEG Matrix'];
        Id generalCompPlanId = null;
        if (generalPlans.size() == 1)
            generalCompPlanId = generalPlans.get(0).Id;
        
        // iterate the households
        for (Account hh : households) {
            // set the Classification to Client if it's not
            if (hh.Type != 'Client')
                hh.Type = 'Client';
            // set the Status to Active if it's not
            if (hh.FinServ__Status__c != 'Active')
                hh.FinServ__Status__c = 'Active';
            // set the Anniversary Date to the Signed Date if it's not populated
            if (hh.WEGP1_ClientAnniversaryDate__c == null)
                hh.WEGP1_ClientAnniversaryDate__c = householdDateMap.get(hh.Id);
            // set the General Comp Plan if it's not populated
            if (hh.WEG_Compensation_Plan__c == null)
                hh.WEG_Compensation_Plan__c = generalCompPlanId;
        }
        
        // update the households
        update households;
    }
}