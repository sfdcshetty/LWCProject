public class SKBlotFundDetails {
	/*
    //This method is used to get all the Fund Details information of Financial Account
    @AuraEnabled
    public static List<Fund_Detail__c> getFundDetails(Id QSID)
    {
        // Use below list to store all related FundDetail information of FA
        list<Fund_Detail__c> listOfFundDetails = new list<Fund_Detail__c>();
        ID blotID = getBlotID(QSID);
        listOfFundDetails = [SELECT Id, Name, WEGP1_Amount__c, WEGP1_SourceofFunds__c, Blot__c,
                WEGP1_FinancialAccount__c FROM Fund_Detail__c
                WHERE Blot__c =:blotID];
        return listOfFundDetails;
    }
    
    // This method is used to retrieve a Fund Detail
    @AuraEnabled
    public static Fund_Detail__c getFundDetail(String fundDetailId)
    {
        if(fundDetailId != null){
            return [SELECT Id, Name, WEGP1_Amount__c, WEGP1_SourceofFunds__c, Blot__c, WEGP1_FinancialAccount__c 
                    FROM Fund_Detail__c
                    WHERE Id =:fundDetailId ];
        }
        return null;
    }
    
    // This method is used to upsert Fund Detail
    @AuraEnabled
    public static List<Fund_Detail__c> upsertFundDetail(Fund_Detail__c fundDetail, String QSID)
    {
        // check if update or insert is needed
        if(fundDetail.Id != null){
            List<String> listFieldUpdate = new List<String>{'WEGP1_Amount__c', 'WEGP1_SourceofFunds__c'};
			update fundDetail; 
        }else{
            List<String> listFieldInsert = new List<String>{'WEGP1_Amount__c', 'WEGP1_SourceofFunds__c',
                'Blot__c', 'WEGP1_FinancialAccount__c'};
            // set Financial Account and Blot ID
        	fundDetail.WEGP1_FinancialAccount__c = getFAID(QSID);
        	fundDetail.Blot__c = getBlotId(QSID);
        	
			insert fundDetail;
        }
        return getFundDetails(QSID);
    }
    
    //This method is used to delete the Fund Detail
    @AuraEnabled
    public static List<Fund_Detail__c> deleteFundDetail(String fundDetailId, String QSID)
    {
        Fund_Detail__c fundDetail = [Select Id from Fund_Detail__c where Id =:fundDetailId];
		delete fundDetail;
        return getFundDetails(QSID);        
    }
    
    //This method is used to get FAID
    private static String getFAID(Id QSID)
    {
        string FAID;
        try{
            SkienceFinSln__Questionnaire__c Questionnaire = [SELECT Id, Name, SkienceFinSln__Financial_Account__c
                                                                 FROM SkienceFinSln__Questionnaire__c WHERE Id =:QSID];
            FAID = Questionnaire.SkienceFinSln__Financial_Account__c;
        }catch(exception e){
            return FAID;
        }
        return FAID;
    }
    
    //This method is used to get Blot ID related to FA
    private static String getBlotID(Id QSID)
    {
        string BlotID;
        try{
            SkienceFinSln__Questionnaire__c Questionnaire = [SELECT Id, Name, SK_Blot__c
                                                                 FROM SkienceFinSln__Questionnaire__c WHERE Id =:QSID];
            BlotID = Questionnaire.SK_Blot__c;
       }catch(exception e){
            return BlotID;
       }
       return BlotID;
    }
	*/
}