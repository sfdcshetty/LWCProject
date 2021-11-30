/*
SubmitForReviewController_TC is the Test Class 
*/
public class SubmitForReviewController {
    
    @AuraEnabled
    public static String checkFieldValues(String recId) {
        
        String showMessage = '\n';
        Map<Id, String> missingFields = new Map<Id, String>();
        Map<Id, String> recordNames = new Map<Id, String>();
        String accountServicing = 'Account_Servicing__c';
        Boolean suitabilityStatus = false;
        Integer msaStatus = 0;
        Id asIDofFas = null;
        List<String> cloudASList = new List<String>();
        Integer nbCount = 0;
        Integer totalCount = 0;
        Set<Id> fasFARec = new Set<Id>();
        List<FinServ__FinancialAccount__c> FARecords = new List<FinServ__FinancialAccount__c>();
        
        Map<String, List<Account_Servicing_With_AS__mdt>>
            metaDataSettings = new Map<String, List<Account_Servicing_With_AS__mdt>>();
        try {
            for(Account_Servicing_With_AS__mdt mdt:[SELECT Label, Field_API__c, Field_Label__c, Object_Name__c, 
                                                    Record_Type_Name__c FROM Account_Servicing_With_AS__mdt WHERE 
                                                    Object_Name__c != NULL AND Record_Type_Name__c != NULL]) 
            {
                String objectName = mdt.Object_Name__c+'-'+mdt.Record_Type_Name__c;
                if (!metaDataSettings.containsKey(objectName))
                    metaDataSettings.put(objectName, new List<Account_Servicing_With_AS__mdt>{mdt});
                else
                    metaDataSettings.get(objectName).add(mdt);
            }
            
            Account_Servicing__c accServicing = [SELECT Name, OwnerId, WEG_Primary_PrimaryEmail__c, WEG_Primary_Email__c, 
                                                 WEG_Secondary_PrimaryEmail__c, WEG_Secondary_Email__c, FI_Net_Worth__c, 
                                                 WEG_Investment_Policy_Statement__c, WEG_Investment_Variances__c, 
                                                 WEG_Investment_Variances_Detail__c, WEG_IM_Special_Instructions__c, 
                                                 WEG_IM_Special_Instructions_Detail__c, FI_Year_Began_Investing__c,
                                                 FI_Primary_Source_of_Wealth__c, FI_Annual_Income__c, FI_Liquid_Net_Worth__c, 
                                                 FI_Tax_Bracket__c, FI_Time_Horizon__c, FI_Special_Liquidity_Needs__c, 
                                                 FI_Special_Liquidity_Needs_Detail__c, WEG_Alternate_Billing__c, 
                                                 WEGP1_Secondary_Individual__c, WEG_Status__c, RecordTypeId, RecordType.Name, 
                                                 WEG_Items_to_Complete__c, WEG_Investment_Objective__c, WEG_MSA_on_File__c
                                                 FROM Account_Servicing__c WHERE id =: recId];
                                                 
            Integer maintemceRecType = 0;
            Integer totalFasCount = 0;
            for(Financial_Account_Servicing__c finAccSer : [SELECT Id, RecordType.Name, Financial_Account__c, 
                                                            Financial_Account__r.WEGP1_IsWEAS__c FROM 
                                                            Financial_Account_Servicing__c WHERE Account_Servicing__c =: recId]) 
            {
                if(finAccSer.RecordType.Name == 'Maintenance') {
                    maintemceRecType = maintemceRecType + 1;
                }
                totalFasCount = totalFasCount + 1;
            }
            
             //Making as suitabilityStatus to true if all the fas related to it are of Maintenance recordtype
                        
            if(totalFasCount  == maintemceRecType && maintemceRecType != 0) {
                suitabilityStatus = true;
            }
             
            for(Financial_Account_Servicing__c finAccSer : [SELECT Id, RecordType.Name, Financial_Account__c, 
                                                            Financial_Account__r.WEGP1_IsWEAS__c FROM 
                                                            Financial_Account_Servicing__c WHERE Account_Servicing__c =: recId]) 
            {
                if (finAccSer.RecordType.Name == 'Transfer' && finAccSer.Financial_Account__c != null) {
                    fasFARec.add(finAccSer.Financial_Account__c);
                }
                if (finAccSer.RecordType.Name == 'New Brokerage' 
                    || (finAccSer.RecordType.Name == 'Maintenance' 
                        && finAccSer.Financial_Account__r.WEGP1_IsWEAS__c == False)) {
                    nbCount++;
                    totalCount++;
                } else {
                    totalCount++;
                }
            }
            
            List<TVA_CFB__Cloud_Files__c> cloudFiles = new List<TVA_CFB__Cloud_Files__c>();
            cloudFiles = [SELECT Name FROM TVA_CFB__Cloud_Files__c WHERE WEG_Account_Servicing__c =: recId AND 
                          WEGP1_DocumentType__c = 'Document Submission' AND TVA_CFB__E_Tag__c != NULL];
            missingFields.put(accServicing.id, '');
            recordNames.put(accServicing.id, accServicing.Name);
            
            List<String> fieldsChecked = new List<String>();
            fieldsChecked.add('WEG_Investment_Variances_Detail__c');
            fieldsChecked.add('WEG_IM_Special_Instructions_Detail__c');
            fieldsChecked.add('FI_Special_Liquidity_Needs_Detail__c');        
            
            List<String> asNotCheckList = new List<String>();
            asNotCheckList.add('Address Change/Name Change');
            asNotCheckList.add('Beneficiary Update');
            asNotCheckList.add('Billing Exclusion');
            asNotCheckList.add('Distribution');
            asNotCheckList.add('Transfer');
            asNotCheckList.add('Update Fee');
            
            List<String> cloudFileRequired = new List<String>();
            cloudFileRequired.add('IO/Special Trading Instructions');
            cloudFileRequired.add('Account Servicing');
            cloudFileRequired.add('Trust/Business Account Servicing');
            cloudFileRequired.add('Transfer');
            cloudFileRequired.add('Update Fee');
            cloudFileRequired.add('Alternate Billing');
            
            
            for(Account_Servicing_With_AS__mdt mtd :metaDataSettings.get(accountServicing+'-' +accServicing.recordType.Name)) 
            {
                
                if (cloudFileRequired.contains(accServicing.recordType.Name)) {
                    cloudASList.add(accServicing.recordType.Name);
                }
                
                if((nbCount == totalCount && accServicing.recordType.Name == 'Trust/Business Account Servicing' && totalCount != 0) 
                   || (nbCount == totalCount && accServicing.recordType.Name == 'Account Servicing' && totalCount != 0))
                {
                    
                } else if(asNotCheckList.contains(accServicing.recordType.Name)) {
                    
                } else {
                    
                    if((mtd.Field_API__c == 'WEG_Investment_Variances_Detail__c' 
                        && accServicing.WEG_Investment_Variances__c == 'Y' 
                        && accServicing.WEG_Investment_Variances_Detail__c == NULL)
                       || (mtd.Field_API__c == 'WEG_IM_Special_Instructions_Detail__c' 
                           && accServicing.WEG_IM_Special_Instructions__c == 'Y' 
                           && accServicing.WEG_IM_Special_Instructions_Detail__c == NULL)
                       || (mtd.Field_API__c == 'FI_Special_Liquidity_Needs_Detail__c' 
                           && accServicing.FI_Special_Liquidity_Needs__c == 'Y' 
                           && accServicing.FI_Special_Liquidity_Needs_Detail__c == NULL)) 
                    {
                        missingFields.put(accServicing.id, missingFields.get(accServicing.id)+', '+mtd.Field_Label__c);                             
                    }
                    
                    if (accServicing.get(mtd.Field_API__c) == NULL && !fieldsChecked.contains(mtd.Field_API__c)) 
                    {
                        if (!missingFields.containsKey(accServicing.id)) {
                            missingFields.put(accServicing.id, mtd.Field_Label__c);
                        } else {
                            missingFields.put(accServicing.id, missingFields.get(accServicing.id)+', '+mtd.Field_Label__c);
                        }
                    }
                    
                    //Starting of AS added newly
                    if ( accServicing.recordType.Name == 'IO/Special Trading Instructions'
                        && mtd.Field_API__c != 'WEG_Investment_Policy_Statement__c'
                        && mtd.Field_API__c != 'WEG_IM_Special_Instructions__c' && !fieldsChecked.contains(mtd.Field_API__c)) 
                    {
                        cloudASList.add(accServicing.recordType.Name);
                        suitabilityStatus = true;
                        
                        if ( accServicing.get(mtd.Field_API__c) == 'N' && mtd.Field_API__c == 'WEG_MSA_on_File__c' ) {
                            msaStatus = 1;
                        }
                        
                        if ( accServicing.get(mtd.Field_API__c) == NULL ) {
                            if ( !missingFields.containsKey(accServicing.id) ) {
                                missingFields.put(accServicing.Id, mtd.field_Label__c);
                            } else {
                                missingFields.put(accServicing.Id, missingFields.get(accServicing.Id) + ', ' + mtd.field_Label__c);
                            }
                        }
                    }
                    
                    if ( accServicing.recordType.Name == 'Alternate Billing' && !fieldsChecked.contains(mtd.Field_API__c) ) {
                        if ( accServicing.get(mtd.Field_API__c) == 'N' && mtd.Field_API__c == 'WEG_MSA_on_File__c' ) {
                            msaStatus = 1;
                        }
                    }
                    //Ending of AS 
                }
            }
            
            for(FinServ__FinancialAccount__c ffa : [SELECT Id, Name, WEGP1_IsWEAS__c FROM FinServ__FinancialAccount__c 
                                                    WHERE Id IN :fasFARec]) 
            {
                if (ffa.WEGP1_IsWEAS__c == TRUE) {
                    FARecords.add(ffa);
                }
            }
            
            // Checking for Financial Account servicing record fields
            for(Financial_Account_Servicing__c finAccSer : [SELECT Registration_Type__c, WEG_Custodian__c, Account_Servicing__c, 
                                                            WEG_Source_of_Funds__c, Prudent_Process__c, Account_Number__c, 
                                                            TIK_Hold__c, WEG_Billing_Exclusions__c, Fee_Type__c, Fee_Percentage__c, 
                                                            WEG_Alternate_Billing__c, Approximate_Value__c, Status__c, Name,
                                                            WEG_Billing_Exclusions_Detail__c, WEG_Program__c, RecordType.Name,
                                                            WEG_Billing_Exclusion_Instructions__c, WEG_Model__c, RecordTypeId, 
                                                            WEG_Items_to_Complete__c,  WEG_Transfer_Total_Amount__c, 
                                                            WEAS_to_WEAS_Rationale__c, WEG_Type__c, 
                                                            WEG_MSA_on_File__c, WEG_Amount_from_Existing_WEG_Account__c
                                                            FROM Financial_Account_Servicing__c WHERE 
                                                            Account_Servicing__c =: recId]) 
            {
                asIDofFas = finAccSer.Account_Servicing__c;
                recordNames.put(finAccSer.id, finAccSer.Name);
                
                if (!missingFields.containsKey (finAccSer.Id)) {
                    missingFields.put(finAccSer.Id, '');
                }
                
                if (metaDataSettings.containsKey('Financial_Account_Servicing__c-' +finAccSer.RecordType.Name)) {
                    
                    for(Account_Servicing_With_AS__mdt mdt:metaDataSettings.get('Financial_Account_Servicing__c-' +
                                                                                finAccSer.RecordType.Name)) 
                    {
                        if (finAccSer.recordType.Name == 'New Brokerage'){
                            suitabilityStatus = true;
                            
                            if(finAccSer.get(mdt.Field_API__c) == NULL && mdt.Field_API__c != 'Prudent_Process__c') {
                                if (!missingFields.containsKey(finAccSer.id)) {
                                    missingFields.put(finAccSer.id, mdt.Field_Label__c);
                                } else {
                                    missingFields.put(finAccSer.id, missingFields.get(finAccSer.id)+', '+mdt.Field_Label__c);
                                }
                            }
                            
                            if(finAccSer.get(mdt.Field_API__c) == NULL && mdt.Field_API__c == 'Prudent_Process__c' 
                               && finAccSer.WEG_Source_of_Funds__c == '401(k)') 
                            {
                                if (!missingFields.containsKey(finAccSer.id)) {
                                    missingFields.put(finAccSer.id, mdt.Field_Label__c);
                                } else {
                                    missingFields.put(finAccSer.id, missingFields.get(finAccSer.id)+', '+mdt.Field_Label__c);
                                }
                            }
                            
                        }
                        
                        if (finAccSer.recordType.Name == 'New Advisory') {
                            suitabilityStatus = true;
                            
                            if((finAccSer.get(mdt.Field_API__c) == NULL && mdt.Field_API__c != 'Prudent_Process__c' 
                                && mdt.Field_API__c != 'Fee_Percentage__c' && mdt.Field_API__c != 'WEG_Program__c' 
                                && mdt.Field_API__c != 'WEG_Model__c' && mdt.Field_API__c != 'WEG_Billing_Exclusions_Detail__c' 
                                && mdt.Field_API__c != 'WEAS_to_WEAS_Rationale__c')
                               || (finAccSer.get(mdt.Field_API__c) == NULL && mdt.Field_API__c == 'Prudent_Process__c' 
                                   && finAccSer.WEG_Source_of_Funds__c == '401(k)')
                               || (finAccSer.get(mdt.Field_API__c) == NULL && finAccSer.WEG_Billing_Exclusions__c == 'Y'
                                   && mdt.Field_API__c == 'WEG_Billing_Exclusions_Detail__c') 
                               || (finAccSer.get(mdt.Field_API__c) == NULL && mdt.Field_API__c == 'WEAS_to_WEAS_Rationale__c' 
                                   && finAccSer.WEG_Source_of_Funds__c != NULL && finAccSer.WEG_Source_of_Funds__c.contains('WEG Managed'))) 
                            {
                                if (!missingFields.containsKey(finAccSer.id)) {
                                    missingFields.put(finAccSer.id, mdt.Field_Label__c);
                                } else {
                                    missingFields.put(finAccSer.id, missingFields.get(finAccSer.id)+', '+mdt.Field_Label__c);
                                }
                            }
                        }
                        
                        
                       
                        
                        //Starting of FAS added newly
                        if (finAccSer.recordType.Name == 'Transfer') {
                            suitabilityStatus = true;
                            
                            if (finAccSer.get(mdt.Field_API__c) == 'N' && mdt.Field_API__c == 'WEG_MSA_on_File__c' && FARecords.size() > 0) {
                                msaStatus = 1;
                            }
                            
                            if ((finAccSer.get(mdt.Field_API__c) == NULL && mdt.Field_API__c != 'WEAS_to_WEAS_Rationale__c' && FARecords.size() > 0
                                 && mdt.Field_API__c != 'WEG_Amount_from_Existing_WEG_Account__c')
                                || (finAccSer.get(mdt.Field_API__c) == NULL 
                                    && (mdt.Field_API__c == 'WEAS_to_WEAS_Rationale__c' 
                                        || mdt.Field_API__c == 'WEG_Amount_from_Existing_WEG_Account__c') 
                                    && finAccSer.WEG_Source_of_Funds__c != null
                                    && finAccSer.WEG_Source_of_Funds__c.contains('WEG Managed')) 
                                || (finAccSer.get(mdt.Field_API__c) == NULL 
                                    && mdt.Field_API__c == 'WEG_Amount_from_Existing_WEG_Account__c' 
                                    
                                    && (finAccSer.WEG_Source_of_Funds__c != null && finAccSer.WEG_Source_of_Funds__c.contains('WEG Brokerage') 
                                        || (finAccSer.WEG_Source_of_Funds__c != null && finAccSer.WEG_Source_of_Funds__c.contains('WEG Managed VA'))))) 
                            {
                                if (!missingFields.containsKey(finAccSer.Id)) {
                                    missingFields.put(finAccSer.Id, mdt.field_Label__c);
                                } else {
                                    missingFields.put(finAccSer.Id, missingFields.get(finAccSer.Id) + ', ' + mdt.Field_Label__c);
                                }
                            }
                        }
                        
                        if (finAccSer.recordType.Name == 'Update Fee') {
                            suitabilityStatus = true;
                            
                            if ( finAccSer.get(mdt.Field_API__c) == 'N' && mdt.Field_API__c == 'WEG_MSA_on_File__c' ) {
                                msaStatus = 1;
                            }
                            
                            if ( finAccSer.get(mdt.Field_API__c) == NULL ) {
                                if (!missingFields.containsKey(finAccSer.Id)) {
                                    missingFields.put(finAccSer.Id, mdt.field_Label__c);
                                } else {
                                    missingFields.put(finAccSer.Id, missingFields.get(finAccSer.Id) + ', ' + mdt.Field_Label__c);
                                }
                            }
                        }
                        
                        if (finAccSer.recordType.Name == 'Billing Exclusion') {
                            
                            if ( finAccSer.get(mdt.Field_API__c) == 'N' && mdt.Field_API__c == 'WEG_MSA_on_File__c' ) {
                                msaStatus = 1;
                            }
                            
                            if ( finAccSer.get(mdt.Field_API__c) == NULL ) {
                                if (!missingFields.containsKey(finAccSer.Id)) {
                                    missingFields.put(finAccSer.Id, mdt.field_Label__c);
                                } else {
                                    missingFields.put(finAccSer.Id, missingFields.get(finAccSer.Id) + ', ' + mdt.Field_Label__c);
                                }
                            }
                        }
                        //Ending of FAS 
                    }
                }
            } 
            
            List<Sobject> recordsToUpdate = new List<Sobject>();
            String accountServingError = '';
            
            // To Update Finacial Account serving record fields
            for (ID key: missingFields.keySet()) {
                String fields = missingFields.get (key);
                fields = fields.removeEnd(', ').removeStart(', ');
                String sObjName = key.getSObjectType().getDescribe().getName();
                Sobject obj = Schema.getGlobalDescribe().get(sObjName).newSObject() ;
                obj.Id = key;
                
                if (fields != '') {
                    showMessage += recordNames.get(key).toUpperCase()+': '+fields+'\n';
                    accountServingError += '<b>'+recordNames.get(key).toUpperCase()+'</b>: '+fields.replace('\n', '<br>')+'<br>';
                }
                
                if (sObjName == accountServicing) {
                    accountServingError += '<br>';
                    showMessage += '\n';
                }
                
                if (sObjName != accountServicing && fields != '') {
                    obj.put('WEG_Items_to_Complete__c', fields);
                    recordsToUpdate.add(obj);  
                }
                if (sObjName != accountServicing && fields == '') {
                    obj.put('WEG_Items_to_Complete__c', '');
                    recordsToUpdate.add(obj);  
                }
            }
            
            if (cloudFiles.Size() == 0 && cloudASList.contains(accServicing.recordType.Name)) {
                showMessage += '\n'+System.Label.DocumentSubmission;
                accountServingError += '<br>'+System.Label.DocumentSubmission;
            }
            
            if (msaStatus == 1) {
                showMessage += 
                    '\n \nTHERE IS NOT A SIGNED MSA ON FILE. YOU MUST COMPLETE A MSA BEFORE YOU CAN DO ANYTHING FURTHER.';
                accountServingError += '<br>' 
                    + 'THERE IS NOT A SIGNED MSA ON FILE. YOU MUST COMPLETE A MSA BEFORE YOU CAN DO ANYTHING FURTHER.';
            }
            
            if (showMessage == '\n' || String.isBlank(showMessage)) {
                showMessage = '';
            }
            
            // Updating Account service record fields
            Sobject obj = Schema.getGlobalDescribe().get(accountServicing).newSObject() ;
            obj.id = accServicing.id;
            
            if (accountServingError != '') {
                obj.put('WEG_Items_to_Complete__c', accountServingError);
            } 
            
            if (showMessage == '') {
                obj.put('WEG_Items_to_Complete__c', 'Ready for Submission');
                obj.put('WEG_Status__c', 'Suitability Review');
                obj.put('WEG_Suitability_Needed__c', suitabilityStatus);
                //obj.put('OwnerId' , System.Label.Suitability_Review_Queue_ID);
                for (ID key: missingFields.keySet()) {
                    String sObjName = key.getSObjectType().getDescribe().getName();
                    Sobject fasRecord = Schema.getGlobalDescribe().get(sObjName).newSObject() ;
                    
                
                } 
            }
            
            recordsToUpdate.add(obj);
            
            if (recordsToUpdate.size() > 0) {
                System.debug(':::recordsToUpdate:::' + recordsToUpdate);
                update recordsToUpdate;
            }
            
        } catch(Exception e) {
            showMessage = e.getMessage();
        }
        
        return showMessage;
    }
}