public without sharing class x7sLiabilityController {
	
    Public class LiabilityWrapper{
        @AuraEnabled public String Name { get; set; }
        @AuraEnabled public String Type { get; set; }
        @AuraEnabled public Decimal InterestRate { get; set; }
        @AuraEnabled public String Owner { get; set; }
        @AuraEnabled public Date AsOfDate { get; set; }
        @AuraEnabled public Decimal Amount { get; set; }
    }
    
     @AuraEnabled (cacheable=true)
    public static List<FinServ__AssetsAndLiabilities__c > getLiabilityDetails(String accountId){
        
        List<FinServ__AssetsAndLiabilities__c> liabilityList;
        
        if(accountId != null){
            List<Account> accList = [SELECT Id, Name, WEGP1_Primary_Household__c 
                                     From Account 
                                     WHERE Id =: accountId LIMIT 1];
            
            if(accList.size() > 0 && accList != null && accList[0].WEGP1_Primary_Household__c != null){
                //Id houseHoldId = (Id)('0012f00000cWqTTAA0');
                Id houseHoldId = (Id)accList[0].WEGP1_Primary_Household__c;
                // liabilityList = [SELECT Id,Name,FinServ__Description__c, WEGP1_AsOfDate__c, WEGP1_InterestRate__c, FinServ__Amount__c,
                //                   FinServ__AssetsAndLiabilitiesType__c,WEGP1_Owner_Type__c, FinServ__PrimaryOwner__c
                //                   FROM FinServ__AssetsAndLiabilities__c 
                //                   WHERE FinServ__Household__c = :houseHoldId
                //                   AND RecordType.Name IN('Liability') AND FinServ__AssetsAndLiabilitiesType__c IN ('Auto Loan','Credit Card','Mortgage','Personal Loan','Other - Liability')];
                liabilityList = [SELECT Id,Name,FinServ__Description__c, WEGP1_AsOfDate__c, WEGP1_InterestRate__c, FinServ__Amount__c,
                                  FinServ__AssetsAndLiabilitiesType__c,WEGP1_Owner_Type__c, FinServ__PrimaryOwner__c
                                  FROM FinServ__AssetsAndLiabilities__c 
                                  WHERE FinServ__Household__c = :houseHoldId
                                  AND Remove_or_Historic__c = ''
                                  AND Status__c = 'Open'
                                  AND WEGP1_ExcludeFromReview__c = FALSE
                                  AND RecordType.Name IN('Liability')];
            }
        }
        return liabilityList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getLiabilityDescriptionType() {

        List<String> pickListValuesList= new List<String>();
        
        Schema.DescribeFieldResult fieldResult = FinServ__AssetsAndLiabilities__c.FinServ__AssetsAndLiabilitiesType__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
		for(Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getValue());
        }
		return pickListValuesList;
    } 
    
    
    @AuraEnabled
    public static void editLiability(String liabilityId, String accountId,String liabilityInfo) {
        
        List<FinServ__AssetsAndLiabilities__c> liabilityList;
        List<LiabilityWrapper> lstWrap = new List<LiabilityWrapper>();
        LiabilityWrapper newLiability;
        List<Account> accList;
        
        List<RecordType> recType = new List<RecordType>();
        recType = [SELECT Id, Name FROM RecordType Where Name IN('Liability') LIMIT 1];
        
        if(accountId != null){

            accList = [SELECT Id, Name, WEGP1_Primary_Household__c,WEGP1_Primary_Household__r.Name,
                    WEGP1_Primary_Household__r.OwnerId, WEGP1_Primary_Household__r.WEGP1_Secondary_Individual__r.AccountId,
                    WEGP1_Primary_Household__r.Owner.CSChatterGroup__c, WEGP1_Primary_Household__r.WEGP1_Primary_Individual__r.AccountId
            From Account
            WHERE Id =: accountId LIMIT 1];
        }
        //Boolean editResult = false;
        
        if(liabilityInfo != null){
            newLiability = (LiabilityWrapper) JSON.deserialize(liabilityInfo, LiabilityWrapper.class);
            if(newLiability.Amount > 0) {
                newLiability.Amount *= -1;
            }
        }
        liabilityList = [SELECT Id,Name,FinServ__Amount__c, FinServ__PrimaryOwner__c, FinServ__AssetsAndLiabilitiesType__c, WEGP1_InterestRate__c, WEGP1_AsOfDate__c, WEGP1_Owner_Type__c 
                                  FROM FinServ__AssetsAndLiabilities__c 
                           	WHERE Id =:liabilityId LIMIT 1];

        List<Account> origOwner;
        if(liabilityList[0].WEGP1_Owner_Type__c != 'Joint'){
            origOwner = [SELECT Id, Name From Account 
                                    WHERE Id =: liabilityList[0].FinServ__PrimaryOwner__c LIMIT 1];
        }
    
        List<Account> newOwner;
        if( newLiability.Owner != 'Joint' ){
            newOwner = [SELECT Id, Name From Account 
                                WHERE Id =: newLiability.Owner LIMIT 1];
        }

        String chatterBody = 'Portal - Net Worth Update Account ' + accList[0].WEGP1_Primary_Household__r.Name + '\n' + recType[0].Name +'\n';
        
        if((newLiability.Name  != null) && (newLiability.Name  != liabilityList[0].Name)){chatterBody += 'Liability Name: ' + liabilityList[0].Name + ' => ' + newLiability.Name +'\n';}
        if((newLiability.Type  != null) && (newLiability.Type  != liabilityList[0].FinServ__AssetsAndLiabilitiesType__c)){chatterBody += 'Type:' + liabilityList[0].FinServ__AssetsAndLiabilitiesType__c + ' => ' + newLiability.Type +'\n';}
        if((newLiability.InterestRate  != null) && (newLiability.InterestRate  != liabilityList[0].WEGP1_InterestRate__c)){chatterBody += 'Interest Rate: ' + liabilityList[0].WEGP1_InterestRate__c + ' => ' + newLiability.InterestRate +'\n';}
        
            /*if(newLiability.Owner == 'Joint') {
                chatterBody += 'Owner: Joint Ownership \n';
            } else {
                if((newLiability.Owner  != null) && (newLiability.Owner  != liabilityList[0].FinServ__PrimaryOwner__c)){chatterBody += 'Owner: ' + newLiability.Owner +'\n';}
            }*/

            if((newLiability.Owner  != null) && newLiability.Owner != 'Joint') {
                if(liabilityList[0].WEGP1_Owner_Type__c != 'Joint'){
                    chatterBody += 'Owner: ' + origOwner[0].Name + ' => ' + newOwner[0].Name +'\n';
                }else{
                    chatterBody += 'Owner: ' + 'Joint Ownership' + ' => ' + newOwner[0].Name +'\n';
                }
            }
        
        if((newLiability.AsOfDate  != null) && (newLiability.AsOfDate  != liabilityList[0].WEGP1_AsOfDate__c)){chatterBody += 'As Of Date: ' + liabilityList[0].WEGP1_AsOfDate__c + ' => ' + newLiability.AsOfDate +'\n';}
        if((newLiability.Amount  != null) && (newLiability.Amount  != liabilityList[0].FinServ__Amount__c)){chatterBody += 'Amount: ' + liabilityList[0].FinServ__Amount__c + ' => ' + newLiability.Amount +'\n';}
        
                               
        liabilityList[0].Name = newLiability.Name;
        liabilityList[0].FinServ__AssetsAndLiabilitiesType__c = newLiability.Type;
        liabilityList[0].WEGP1_InterestRate__c = newLiability.InterestRate;
        liabilityList[0].WEGP1_AsOfDate__c = newLiability.AsOfDate;
        if(newLiability.Owner == 'Joint') {
            String primary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Primary_Individual__r?.AccountId;
            String secondary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Secondary_Individual__r?.AccountId;
            liabilityList[0].FinServ__PrimaryOwner__c = primary;
            liabilityList[0].FinServ__JointOwner__c = secondary;
        } else {
            liabilityList[0].FinServ__PrimaryOwner__c = newLiability.Owner;
            liabilityList[0].FinServ__JointOwner__c = null;
        }
        liabilityList[0].FinServ__Amount__c = newLiability.Amount;
       
        update liabilityList; 
        
        x7s_ChatterPostUtility.ChatterPostInputs input = new x7s_ChatterPostUtility.ChatterPostInputs();
        input.parentId = accList[0].WEGP1_Primary_Household__r.Owner.CSChatterGroup__c;
        input.userId = UserInfo.getUserId();
        /*String chatterBody = 'Portal - Net Worth Update Account ' + accList[0].WEGP1_Primary_Household__r.Name + '\n' + recType[0].Name +'\n';
        
        if((newLiability.Name  != null) && (newLiability.Name  != liabilityList[0].Name)){chatterBody += 'Liability Name: ' + newLiability.Name +'\n';}
        if((newLiability.Type  != null) && (newLiability.Type  != liabilityList[0].FinServ__AssetsAndLiabilitiesType__c)){chatterBody += 'Type:' + newLiability.Type +'\n';}
        if((newLiability.InterestRate  != null) && (newLiability.InterestRate  != liabilityList[0].WEGP1_InterestRate__c)){chatterBody += 'Interest Rate: ' + newLiability.InterestRate +'\n';}
        if(newLiability.Owner == 'Joint') {
            chatterBody += 'Owner: Joint Ownership \n';
        } else {
            if((newLiability.Owner  != null) && (newLiability.Owner  != liabilityList[0].FinServ__PrimaryOwner__c)){chatterBody += 'Owner: ' + newLiability.Owner +'\n';}
        }

        if((newLiability.AsOfDate  != null) && (newLiability.AsOfDate  != liabilityList[0].WEGP1_AsOfDate__c)){chatterBody += 'As Of Date: ' + newLiability.AsOfDate +'\n';}
        if((newLiability.Amount  != null) && (newLiability.Amount  != liabilityList[0].FinServ__Amount__c)){chatterBody += 'Amount: ' + newLiability.Amount +'\n';}
        */
        input.chatterBody = chatterBody;
        input.url = '/'+liabilityList[0].Id;
        input.urlLabel = liabilityList[0].Name;
        
        x7s_ChatterPostUtility.ChatterFeedItemAction(new List<x7s_ChatterPostUtility.ChatterPostInputs>{(input)});
        
        system.debug('licenseList==='+liabilityList);
    }
    
    @AuraEnabled
    Public static void addLiability(String accountId,String liabilityInfo) {        
        try{
            List<FinServ__AssetsAndLiabilities__c> liabilityList;
            List<LiabilityWrapper> lstWrap = new List<LiabilityWrapper>();
            LiabilityWrapper newLiability;
            List<RecordType> recType = new List<RecordType>();
            
            if(liabilityInfo != null){
                newLiability = (LiabilityWrapper) JSON.deserialize(liabilityInfo, LiabilityWrapper.class);
                if(newLiability.Amount > 0) {
                    newLiability.Amount *= -1;
                }
            }
            recType = [SELECT Id, Name FROM RecordType Where Name IN('Liability') LIMIT 1];
            
            if(accountId != null){
                
                List<Account> accList = [SELECT Id, Name, WEGP1_Primary_Household__c,WEGP1_Primary_Household__r.Name,
                        WEGP1_Primary_Household__r.OwnerId, WEGP1_Primary_Household__r.WEGP1_Secondary_Individual__r.AccountId,
                        WEGP1_Primary_Household__r.Owner.CSChatterGroup__c, WEGP1_Primary_Household__r.WEGP1_Primary_Individual__r.AccountId
                From Account
                WHERE Id =: accountId LIMIT 1];
                
                List<Account> newOwner;
                if( newLiability.Owner != 'Joint' ){
                    newOwner = [SELECT Id, Name From Account 
                                        WHERE Id =: newLiability.Owner LIMIT 1];
                }

                if(accList.size() > 0 && accList != null && accList[0].WEGP1_Primary_Household__c != null){
                    //Id houseHoldId = (Id)('0012f00000cWqTTAA0');
                    Id houseHoldId = (Id)accList[0].WEGP1_Primary_Household__c;
                    FinServ__AssetsAndLiabilities__c liability = new FinServ__AssetsAndLiabilities__c();
                    if(newLiability.Owner == 'Joint') {
                        String primary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Primary_Individual__r?.AccountId;
                        String secondary = accList[0].WEGP1_Primary_Household__r?.WEGP1_Secondary_Individual__r?.AccountId;
                        liability = new FinServ__AssetsAndLiabilities__c(Name = newLiability.Name ,
                                FinServ__PrimaryOwner__c = primary,
                                FinServ__JointOwner__c = secondary,
                                RecordTypeId =  recType[0].Id,
                                FinServ__Household__c = houseHoldId,
                                FinServ__AssetsAndLiabilitiesType__c = newLiability.Type,
                                //FinServ__AssetsAndLiabilitiesType__c = newLiability.Description,
                                //FinServ__AssetsAndLiabilitiesType__c = 'Other',
                                WEGP1_InterestRate__c = newLiability.InterestRate,
                                WEGP1_AsOfDate__c = newLiability.AsOfDate,
                                FinServ__Amount__c = newLiability.Amount,
                                Status__c = 'Open');
                    } else {
                        liability = new FinServ__AssetsAndLiabilities__c(Name = newLiability.Name ,
                                FinServ__PrimaryOwner__c = newLiability.Owner,
                                RecordTypeId =  recType[0].Id,
                                FinServ__Household__c = houseHoldId,
                                FinServ__AssetsAndLiabilitiesType__c = newLiability.Type,
                                //FinServ__AssetsAndLiabilitiesType__c = newLiability.Description,
                                //FinServ__AssetsAndLiabilitiesType__c = 'Other',
                                WEGP1_InterestRate__c = newLiability.InterestRate,
                                WEGP1_AsOfDate__c = newLiability.AsOfDate,
                                FinServ__Amount__c = newLiability.Amount,
                                Status__c = 'Open');
                    }
                     insert liability;
                    
                    x7s_ChatterPostUtility.ChatterPostInputs input = new x7s_ChatterPostUtility.ChatterPostInputs();
                    input.parentId = accList[0].WEGP1_Primary_Household__r.Owner.CSChatterGroup__c;
                    input.userId = UserInfo.getUserId();
                    String chatterBody = 'Portal - Net Worth New Account ' + accList[0].WEGP1_Primary_Household__r.Name + '\n' + recType[0].Name +'\n';
                 
                    if(newLiability.Name  != null){chatterBody += 'Liability Name: ' + newLiability.Name +'\n';}
                    if(newLiability.Type  != null){chatterBody += 'Type:' + newLiability.Type +'\n';}
                    if(newLiability.InterestRate  != null){chatterBody += 'Interest Rate: ' + newLiability.InterestRate +'\n';}
                    if(newLiability.Owner == 'Joint') {
                        chatterBody += 'Owner: Joint Ownership \n';
                    } else {
                        if(newLiability.Owner  != null){chatterBody += 'Owner: ' + newOwner[0].Name +'\n';}
                    }

                    if(newLiability.AsOfDate  != null){chatterBody += 'As Of Date: ' + newLiability.AsOfDate +'\n';}
                    if(newLiability.Amount  != null){chatterBody += 'Amount: ' + newLiability.Amount +'\n';}
                
                    input.chatterBody = chatterBody;
                    input.url = '/'+liability.Id;
                    input.urlLabel = liability.Name;
                    
                    x7s_ChatterPostUtility.ChatterFeedItemAction(new List<x7s_ChatterPostUtility.ChatterPostInputs>{(input)});
                }
            }
            
            
        } catch(Exception e) {
            system.debug('error ::'+e);
        }
        
    }
	
}