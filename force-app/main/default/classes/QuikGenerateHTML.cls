global class QuikGenerateHTML {
    
    Transient public String attachmentBody { get; set; }
    Transient public String savedFormData { get; set; }
    public String allFormIds = '';
    
    public QuikGenerateHTML() { 
        savedFormData = ''; 
        attachmentBody = '';
    }
    
    public void loadHTML() {
        savedFormData = '';
        reloadForm();
    }
    
    // Method to send the request JSON body to Quik and generate the form preview when load form is clicked.
    public void reloadForm() {
        Id asFormId = ApexPages.currentpage().getparameters().get('id');
        String typeOfForm = ApexPages.currentpage().getparameters().get('type');
        String showAttach = ApexPages.currentpage().getparameters().get('showAttach');
        As_quik_forms__c savedForm = new As_Quik_Forms__c();
        savedForm = [SELECT Account_Servicing__c, Form_Numbers__c, Form_HTML_URL__c, UNID__c, Custodian__c, UniqueId__c , 
                     Financial_Account_Servicing__c, FAS_List__c, FAS_Id_List__c, Custodian_Info__c, Form_No_with_Ids__c 
                     FROM As_Quik_Forms__c 
                     WHERE Id =:asFormId];
        allFormIds = savedForm.Form_Numbers__c;
        Attachment attJSON = [SELECT Body FROM Attachment WHERE ParentId =: asFormId AND Name Like 'QuikForm_%'];
        String htmlSettings = attJSON.body.toString();
        
        if(htmlSettings.contains('"DisableAttachments": true,')) {
            if(showAttach.equals('false')) {
                htmlSettings = htmlSettings.replace('"DisableAttachments": true,', '"DisableAttachments": false,');
            }
        }
        
        htmlSettings = htmlSettings.replace ('"FormPackageRouteStatusID": 0', '"FormPackageRouteStatusID": ' 
                                             + (DateTime.Now().getTime() + '').subString(0, 10));
        htmlSettings = htmlSettings.replace ('"UNID": ""', '"UNID": "' + savedForm.UNID__c + '"');
        Datetime dt = Datetime.now();
        Long l = dt.getTime();
        String uniqueId = userinfo.getUserId() + String.valueOf(l);
        if(savedForm.UniqueId__c != NULL && savedForm.UniqueId__c != '') {
            uniqueId = savedForm.UniqueId__c;
        }
        htmlSettings = htmlSettings.replace('UNIQUEID1', uniqueId);
        htmlSettings = htmlSettings.replace('ENVELOPEID', savedForm.Id);
        
        QuikGenerateFormRequest.doCallOut(savedForm.Account_Servicing__c, '', htmlSettings, savedForm.Form_Numbers__c, 
                                          savedForm.Custodian__c, savedForm.Custodian_Info__c, uniqueId, typeOfForm, 
                                          savedForm.FAS_Id_List__c, savedForm.FAS_List__c, savedForm.Form_No_with_Ids__c);
        try {
            Attachment att = [SELECT Body FROM Attachment WHERE ParentId =: asFormId AND Name Like 'HTML_QuikForm_%'];
            attachmentBody = att.Body.toString();
        } catch (Exception e) {
            QuikErrorLogGeneration.createErrorLog('', '', '', e.getMessage(), 'QuikGenerateHTML', 'reloadForm', e.getlineNumber());
        }
    }
    
    // Method to update the JSON body attachment when save button is pressed on the quik form view.
    public void updateData () {
        String typeOfForm = ApexPages.currentpage().getparameters().get('type');
        Id asFormId = ApexPages.currentpage().getparameters().get('id');
        String showAttach = ApexPages.currentpage().getparameters().get('showAttach');
        Map<String, Integer> uniqueFormsCount = new Map<String, Integer>();
        List<String> formIdsList = allFormIds.split(',');
        for(String str : formIdsList) {
            if(uniqueFormsCount.containsKey(str)) {
                Integer fc = uniqueFormsCount.get(str);
                uniqueFormsCount.put(str, ++fc);
            } else {
                uniqueFormsCount.put(str, 1);
            }
        }
        Integer highestFormCount = 0;
        for(Integer intg : uniqueFormsCount.values()) {
            if(intg > highestFormCount) {
                highestFormCount = intg;
            }
        }
        String saveRecp = '';
        savedFormData = savedFormData.removeEnd('"').removeStart('"');
        String fieldNewMappingJSON = '';
        List <String> values = new List <String> ();
        values = savedFormData.split('&');
        String unId = '';
        String pkgBundleId = '0';
        List<String> emptyFieldNames = new List<String>();
        for(Integer i = 0; i < values.size(); i++) {
            String key = '', value = '';
            key = values[i].split('=')[0];
            try {
                value = values[i].split('=')[1];
            } catch(Exception e) {
            }
            value = EncodingUtil.urlDecode(value, 'UTF-8');
            if('1own.FullName='.equals(values[i])) {
                value = '##1ownfullname##';
            } else if('1own.H.Email='.equals(values[i])) {
                value = '##1ownemail##';
            } else if('1own.H.Phone='.equals(values[i])) {
                value = '##1ownphone##';
            } else if('2own.FullName='.equals(values[i])) {
                value = '##2ownfullname##';
            } else if('2own.H.Email='.equals(values[i])) {
                value = '##2ownemail##';
            } else if('2own.H.Phone='.equals(values[i])) {
                value = '##2ownphone##';
            } else if('1rep.FullName='.equals(values[i])) {
                value = '##1repfullname##';
            } else if('1rep.P.Email='.equals(values[i])) {
                value = '##1repemail##';
            } else if('1rep.P.Phone='.equals(values[i])) {
                value = '##1repphone##';
            }
            for(Integer intg = 1; intg < highestFormCount; intg++) {
                if(('1own.FullName-' + intg + '=').equals(values[i])) {
                    value = '##1ownfullname##';
                } else if(('1own.H.Email-' + intg + '=').equals(values[i])) {
                    value = '##1ownemail##';
                } else if(('1own.H.Phone-' + intg + '=').equals(values[i])) {
                    value = '##1ownphone##';
                } else if(('2own.FullName-' + intg + '=').equals(values[i])) {
                    value = '##2ownfullname##';
                } else if(('2own.H.Email-' + intg + '=').equals(values[i])) {
                    value = '##2ownemail##';
                } else if(('2own.H.Phone-' + intg + '=').equals(values[i])) {
                    value = '##2ownphone##';
                } else if(('1rep.FullName-' + intg + '=').equals(values[i])) {
                    value = '##1repfullname##';
                } else if(('1rep.P.Email-' + intg + '=').equals(values[i])) {
                    value = '##1repemail##';
                } else if(('1rep.P.Phone-' + intg + '=').equals(values[i])) {
                    value = '##1repphone##';
                }
            }
            if(key == 'QFVUNID')
                unId = value;
            if(key.endsWith('\''))
                key = key.removeEnd('\'');
            if(key.startsWith('\''))
                key = key.removeStart('\'');
            if(key.contains('QuikRadio')) {
                if(key.contains('.')) {
                    List<String> quikradioToRemove = key.split('\\.');
                    key = key.replace(quikradioToRemove[0]+'.', '');
                }
            }
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('FieldValue', value);
            gen.writeEndObject();
            value = gen.getAsString();
            value = value.removeStart ('{').removeEnd ('}');
            fieldNewMappingJSON += '{"FieldName" : "' + key + '", ' + value + '},';
            if(key == 'FormPackageRouteStatusID') {
                pkgBundleId = value;
            }
        }
        // Start - Adding of extra fields in htmlsettings form fields
        if(!fieldNewMappingJSON.contains('1own.H.Email')) {
            fieldNewMappingJSON += '{"FieldName" : "1own.H.Email", "FieldValue" : "##1ownemail##"},';
        }
        if(!fieldNewMappingJSON.contains('1own.H.Phone')) {
            fieldNewMappingJSON += '{"FieldName" : "1own.H.Phone", "FieldValue" : "##1ownphone##"},';
        }
        if(!fieldNewMappingJSON.contains('2own.H.Email')) {
            fieldNewMappingJSON += '{"FieldName" : "2own.H.Email", "FieldValue" : "##2ownemail##"},';
        }
        if(!fieldNewMappingJSON.contains('2own.H.Phone')) {
            fieldNewMappingJSON += '{"FieldName" : "2own.H.Phone", "FieldValue" : "##2ownphone##"},';
        }
        if(!fieldNewMappingJSON.contains('1rep.P.Email')) {
            fieldNewMappingJSON += '{"FieldName" : "1rep.P.Email", "FieldValue" : "##1repemail##"},';
        }
        if(!fieldNewMappingJSON.contains('1rep.P.Phone')) {
            fieldNewMappingJSON += '{"FieldName" : "1rep.P.Phone", "FieldValue" : "##1repphone##"},';
        }
        for(Integer intg = 1; intg < highestFormCount; intg++) {
            fieldNewMappingJSON += '{"FieldName" : "1own.FullName-' + intg + '", "FieldValue" : "##1ownfullname##"},';
            if(!fieldNewMappingJSON.contains('1own.H.Email-' + intg)) {
                fieldNewMappingJSON += '{"FieldName" : "1own.H.Email-' + intg + '", "FieldValue" : "##1ownemail##"},';
            }
            if(!fieldNewMappingJSON.contains('1own.H.Phone-' + intg)) {
                fieldNewMappingJSON += '{"FieldName" : "1own.H.Phone-' + intg + '", "FieldValue" : "##1ownphone##"},';
            }
            fieldNewMappingJSON += '{"FieldName" : "2own.FullName-' + intg + '", "FieldValue" : "##2ownfullname##"},';
            if(!fieldNewMappingJSON.contains('2own.H.Email-' + intg)) {
                fieldNewMappingJSON += '{"FieldName" : "2own.H.Email-' + intg + '", "FieldValue" : "##2ownemail##"},';
            }
            if(!fieldNewMappingJSON.contains('2own.H.Phone-' + intg)) {
                fieldNewMappingJSON += '{"FieldName" : "2own.H.Phone-' + intg + '", "FieldValue" : "##2ownphone##"},';
            }
            fieldNewMappingJSON += '{"FieldName" : "1rep.FullName-' + intg + '", "FieldValue" : "##1repfullname##"},';
            if(!fieldNewMappingJSON.contains('1rep.P.Email-' + intg)) {
                fieldNewMappingJSON += '{"FieldName" : "1rep.P.Email-' + intg + '", "FieldValue" : "##1repemail##"},';
            }
            if(!fieldNewMappingJSON.contains('1rep.P.Phone-' + intg)) {
                fieldNewMappingJSON += '{"FieldName" : "1rep.P.Phone-' + intg + '", "FieldValue" : "##1repphone##"},';
            }
        }
        // End - Adding of extra fields in htmlsettings form fields
        fieldNewMappingJSON = fieldNewMappingJSON.removeEnd(',');
        if(test.isRunningTest()) {
            unId = 'UNIDik';
        }
        if(unId != '' && unId != NULL) {
            unId = unId.replace('UNID=', '');
            List<As_Quik_Forms__c> savedForm = new List<As_Quik_Forms__c>();
            savedForm = [SELECT Account_Servicing__c, Form_Numbers__c, Form_HTML_URL__c, UNID__c, Custodian__c, UniqueId__c, 
                         Financial_Account_Servicing__c, FAS_List__c, FAS_Id_List__c, Custodian_Info__c, Form_No_with_Ids__c, 
                         AS_Quik_Forms_Group__r.Id FROM As_Quik_Forms__c WHERE UNID__c =: unId];
            if(savedForm.size() > 0) {
                String checkAsQFG = savedForm[0].AS_Quik_Forms_Group__r.Id;
                if(checkAsQFG != null && checkAsQFG != '') {
                    saveRecp = 'no';
                } else {
                    saveRecp = 'yes';
                }
                Quik_API__mdt mdtSettings = [SELECT HTMLSettings__c FROM Quik_API__mdt WHERE developerName = 'HTMLSettings'];
                String htmlSettings = mdtSettings.HTMLSettings__c;
                htmlSettings = htmlSettings.replace('##EXPIRE_DATE##', DateTime.Now().addDays(180).format());
                htmlSettings = htmlSettings.replace('##QUIK_IDS##', savedForm[0].Form_Numbers__c);
                htmlSettings = htmlSettings.replace ('##UN_ID##', savedForm[0].UNID__c);
                if (pkgBundleId == '0') {
                    pkgBundleId = (DateTime.Now().getTime() + '').subString(0, 10);
                }
                htmlSettings = htmlSettings.replace ('"FormPackageRouteStatusID": 0', '"FormPackageRouteStatusID": '+ pkgBundleId);
                htmlSettings = htmlSettings.replace('##FORM_FIELDS##', '[' + fieldNewMappingJSON + ']');
                String fasIdListC = savedForm[0].FAS_Id_List__c;
                Map<String, String> allFormsInfo = new Map<String, String>();
                String formNowithId = savedForm[0].Form_No_with_Ids__c;
                for(String strForm : formNowithId.split('-')) {
                    List<String> splitString = strForm.split(':');
                    allFormsInfo.put(splitString[0], splitString[1]);
                }
                List<String> fasIdListInQF = new List<String>();
                if(fasIdListC.contains(',')) {
                    for(String str : fasIdListC.split(',')) {
                        String selectedObjectName = Id.valueOf(str).getSObjectType().getDescribe().getName();
                        if(selectedObjectName == 'Financial_Account_Servicing__c') {
                            fasIdListInQF.add(str);
                        }
                    }
                } else {
                    String selectedObjectName = Id.valueOf(fasIdListC).getSObjectType().getDescribe().getName();
                    if(selectedObjectName == 'Financial_Account_Servicing__c') {
                        fasIdListInQF.add(fasIdListC);
                    }
                }
                if(fasIdListInQF.size() > 0) {
                    Map<String, String> fasCustodianIdsMap = new Map<String, String>();
                    Set<String> fasCustodianIds = new Set<String>();
                    for(Financial_Account_Servicing__c fas : [SELECT Name, WEG_Custodian_Info__c FROM Financial_Account_Servicing__c 
                                                              WHERE Id IN :fasIdListInQF]) 
                    {
                        fasCustodianIdsMap.put(fas.Id, fas.WEG_Custodian_Info__c);
                        fasCustodianIds.add(fas.WEG_Custodian_Info__c);
                    }
                    Map<String, Custodian_Info__c> custodianInfoRecMap = new Map<String, Custodian_Info__c>();
                    for(Custodian_Info__c custodianInfoRec : [SELECT Custodian_Name__c, Custodian_Email_1__c, Custodian_Email_2__c, 
                                                              Custodian_Phone__c, WEG_eSign_Authorization_Type__c 
                                                              FROM Custodian_Info__c WHERE Id IN :fasCustodianIds]) 
                    {
                        custodianInfoRecMap.put(custodianInfoRec.Id, custodianInfoRec);
                    }
                    String extraRecpFields = '';
                    Integer recipientNoCount = 1;
                    Integer orderCount = (highestFormCount + 40);
                    for(String str : fasCustodianIdsMap.keySet()) {
                        String formsToBeExcluded = '';
                        for(String excId : fasIdListC.split(',')) {
                            if(!str.equals(excId)) {
                                formsToBeExcluded += allFormsInfo.get(excId) + ',';
                            }
                        }
                        formsToBeExcluded = formsToBeExcluded.removeEnd(',');
                        String fasCusValue = fasCustodianIdsMap.get(str);
                        Custodian_Info__c cusInfo = custodianInfoRecMap.get(fasCusValue);
                        if(cusInfo.Custodian_Email_1__c != '' && cusInfo.Custodian_Email_1__c != null) {
                            extraRecpFields += '{"Order": ' + (orderCount++) + ',';
                            extraRecpFields += '"Email": "' + cusInfo.Custodian_Email_1__c + '",';
                            extraRecpFields += '"Name": "' + cusInfo.Custodian_Name__c + ' CC1",';
                            if(formsToBeExcluded != null && formsToBeExcluded != '') {
                                extraRecpFields += '"ExcludedDocuments": [' + formsToBeExcluded + '],';
                            }
                            if(cusInfo.Custodian_Phone__c != null) {
                                extraRecpFields += '"PhoneNumber": "' + cusInfo.Custodian_Phone__c + '",';
                            }
                            extraRecpFields += '"RecipientNumber": ' + (recipientNoCount++) + '},';
                        }
                        if(cusInfo.Custodian_Email_2__c != '' && cusInfo.Custodian_Email_2__c != null) {
                            extraRecpFields += '{"Order": ' + (orderCount++) + ',';
                            extraRecpFields += '"Email": "' + cusInfo.Custodian_Email_2__c + '",';
                            extraRecpFields += '"Name": "' + cusInfo.Custodian_Name__c + ' CC2",';
                            if(formsToBeExcluded != null && formsToBeExcluded != '') {
                                extraRecpFields += '"ExcludedDocuments": [' + formsToBeExcluded + '],';
                            }
                            if(cusInfo.Custodian_Phone__c != null) {
                                extraRecpFields += '"PhoneNumber": "' + cusInfo.Custodian_Phone__c + '",';
                            }
                            extraRecpFields += '"RecipientNumber": ' + (recipientNoCount++) + '},';
                        }
                    }
                    htmlSettings = htmlSettings.replace('##EXTRA_RECIPIENTS_INFO##', extraRecpFields.removeEnd(','));
                } else {
                    htmlSettings = htmlSettings.replace('##EXTRA_RECIPIENTS_INFO##', '');
                }
                Datetime dt = Datetime.now();
                Long l = dt.getTime();
                String uniqueId = userinfo.getUserId()+String.valueOf(l);
                if(savedForm[0].UniqueId__c != NULL && savedForm[0].UniqueId__c != '') {
                    uniqueId = savedForm[0].UniqueId__c;
                }
                htmlSettings = htmlSettings.replace('UNIQUEID1', uniqueId);
                htmlSettings = htmlSettings.replace('ENVELOPEID', savedForm[0].Id);
                // Start - Editable fields code replace
                List<Quik_Mapping__c> quikMappingList = [SELECT WEG_Role_Name__c, WEG_Field_Name__c, WEG_Editable__c, Required__c 
                                                         FROM Quik_Mapping__c];
                String fieldJson = '';
                for(Quik_Mapping__c qmap : quikMappingList) {
                    if(qmap.WEG_Editable__c == true && qmap.Required__c == true) {
                        fieldJson += '{';
                        fieldJson += '"FieldName":"' + qmap.WEG_Role_Name__c + '.' + qmap.WEG_Field_Name__c + '",';
                        fieldJson += '"Required":true';
                        fieldJson += '},';
                    } else if(qmap.WEG_Editable__c == true && qmap.Required__c == false) {
                        fieldJson += '{';
                        fieldJson += '"FieldName":"' + qmap.WEG_Role_Name__c + '.' + qmap.WEG_Field_Name__c + '",';
                        fieldJson += '"Required":false';
                        fieldJson += '},';
                    }
                    for(Integer intg = 1; intg < highestFormCount; intg++) {
                        if(qmap.WEG_Editable__c == true && qmap.Required__c == true) {
                            fieldJson += '{';
                            fieldJson += '"FieldName":"' + qmap.WEG_Role_Name__c + '.' + qmap.WEG_Field_Name__c + '-' + intg + '",';
                            fieldJson += '"Required":true';
                            fieldJson += '},';
                        } else if(qmap.WEG_Editable__c == true && qmap.Required__c == false) {
                            fieldJson += '{';
                            fieldJson += '"FieldName":"' + qmap.WEG_Role_Name__c + '.' + qmap.WEG_Field_Name__c + '-' + intg + '",';
                            fieldJson += '"Required":false';
                            fieldJson += '},';
                        }
                    }  
                }
                fieldJson = fieldJson.removeEnd(',');
                htmlSettings = htmlSettings.replace ('##ENABLE_ESIGN_EDITS##', 'true');
                htmlSettings = htmlSettings.replace('##DISABLE_ATTACHMENT##', showAttach);
                htmlSettings = htmlSettings.replace ('##EDIT_TYPE##', 'FieldList');
                htmlSettings = htmlSettings.replace ('##FIELDS_REQUIRED##', fieldJson);
                // End - Editable fields code replace
                htmlSettings = QuikGenerateHTML.upsertQuikGroupForm(asFormId, 'Sign', htmlSettings, saveRecp, highestFormCount);
                quikDoCallOut(savedForm[0].Account_Servicing__c, '', htmlSettings, savedForm[0].Form_Numbers__c, 
                              savedForm[0].Custodian__c, savedForm[0].Custodian_Info__c, uniqueId, '', 
                              savedForm[0].FAS_Id_List__c, savedForm[0].FAS_List__c, savedForm[0].Form_No_with_Ids__c);
            }
        }
    }
    
    @future(callout=true)
    public static void quikDoCallOut(Id asRecordId, String fasRecordId, String reqBody, String quikFormIds, String custodianName, 
                                     String custodianInfoForQF, String uniqueId, String formType, String fasIdsToStoreInQuikForm, 
                                     String asFasNamesToStoreInQuikForm, String formNoWithIds) 
    {
        String returnData = QuikGenerateFormRequest.doCallOut(asRecordId, fasRecordId, reqBody, quikFormIds, custodianName, custodianInfoForQF, 
                                                              uniqueId, formType, fasIdsToStoreInQuikForm, asFasNamesToStoreInQuikForm, 
                                                              formNoWithIds);
    }
    
    
    
    // To create or upsert Quik form group record
    global static String upsertQuikGroupForm(String asformId, String objName, String htmlSettings, String saveRecp, Integer highestFormCount) {
        String modifiedHtmlSettings = '';
        AS_Quik_Forms_Group__c formGroup = new AS_Quik_Forms_Group__c();
        List<As_Quik_Forms__c>  asForm = [SELECT Account_Servicing__c, Form_Numbers__c, Form_HTML_URL__c, UNID__c, Custodian__c, UniqueId__c , 
                                          Financial_Account_Servicing__c, Form_For__c, FAS_Id_List__c, FAS_List__c, AS_Quik_Forms_Group__r.Id, 
                                          AS_Quik_Forms_Group__r.Callout_Status__c  FROM As_Quik_Forms__c WHERE Id = :asFormId];
        try{
            if(asForm.size() > 0) {
                if(saveRecp.equals('yes')) {
                    formGroup.Account_Servicing__c = asForm[0].Account_Servicing__c;
                    formGroup.Financial_Account_Servicing__c = asForm[0].Financial_Account_Servicing__c;
                    formGroup.UniqueId__c =  asForm[0].UniqueId__c;
                    formGroup.Type__c = asForm[0].Form_For__c;
                    formGroup.FAS_Id_List__c = asForm[0].FAS_Id_List__c;
                    formGroup.FAS_List__c = asForm[0].FAS_List__c;
                    formGroup.Custodian__c = asForm[0].Custodian__c;
                    formGroup.Callout_Status__c = 'In Progress';
                    upsert formGroup UniqueId__c;
                    asForm[0].AS_Quik_Forms_Group__c =  formGroup.Id;
                    update asForm;
                    modifiedHtmlSettings = QuikGenerateHTML.createRecipients(formGroup.Id, asForm[0].Account_Servicing__c, asFormId, 
                                                                             htmlSettings, saveRecp, highestFormCount);
                } else if(saveRecp.equals('no')) {
                    String recId = asForm[0].AS_Quik_Forms_Group__r.Id;
                    AS_Quik_Forms_Group__c asQfRec = [SELECT Callout_Status__c 
                                                      FROM AS_Quik_Forms_Group__c 
                                                      WHERE Id = :recId];
                    asQfRec.Callout_Status__c = 'In Progress';
                    update asQfRec;
                    modifiedHtmlSettings = QuikGenerateHTML.createRecipients(asForm[0].AS_Quik_Forms_Group__r.Id, asForm[0].Account_Servicing__c, 
                                                                             asFormId, htmlSettings, saveRecp, highestFormCount);
                }
            }
        } catch(Exception exc) {
            QuikErrorLogGeneration.createErrorLog('', '', '', exc.getMessage(), 'QuikGenerateHTML', 'upsertQuikGroupForm', exc.getlineNumber());
        }
        return modifiedHtmlSettings;
    }
    
    public static String createRecipients(String formgrpId, String accSerId , String asFormId, String htmlSettings, String saveRecp, 
                                          Integer highestFormCount) 
    {
        String modifiedHtmlSettings = '';
        String recipientsOrderInHtml = '';
        AS_Quik_Forms_Group__c asFormGroup = new AS_Quik_Forms_Group__c();
        asFormGroup = [SELECT 
                       Docusign_Envelope_Id__c, FAS_Id_List__c, 
                       Account_Servicing__c, Account_Servicing__r.Name, 
                       Account_Servicing__r.WEGP1_Primary_Individual__c,
                       Account_Servicing__r.WEGP1_Primary_Individual__r.Account.Name,
                       Account_Servicing__r.WEGP1_Primary_Individual__r.Email,
                       Account_Servicing__r.WEGP1_Primary_Individual__r.MobilePhone,
                       
                       Account_Servicing__r.WEGP1_Secondary_Individual__c,
                       Account_Servicing__r.WEGP1_Secondary_Individual__r.Account.Name,
                       Account_Servicing__r.WEGP1_Secondary_Individual__r.Email,
                       Account_Servicing__r.WEGP1_Secondary_Individual__r.MobilePhone,
                       
                       Account_Servicing__r.Related_Account__c,
                       Account_Servicing__r.WEG_HH_Business_Owner__c,
                       Account_Servicing__r.HH_Business_Owner_Email__c,
                       Account_Servicing__r.HH_Business_Owner_Phone__c, 
                       Account_Servicing__r.HH_Business_Owner_Mobile_Phone__c, 
                       
                       Financial_Account_Servicing__c, Financial_Account_Servicing__r.Name, 
                       Financial_Account_Servicing__r.WEG_Custodian_Info__c,
                       Financial_Account_Servicing__r.Primary_Owner__c,
                       Financial_Account_Servicing__r.Primary_Owner__r.Name,
                       Financial_Account_Servicing__r.Primary_Owner__r.FinServ__PrimaryContact__r.Email,
                       Financial_Account_Servicing__r.Primary_Owner__r.FinServ__PrimaryContact__r.MobilePhone,
                       
                       Financial_Account_Servicing__r.Joint_Owner__c,
                       Financial_Account_Servicing__r.Joint_Owner__r.Name,
                       Financial_Account_Servicing__r.Joint_Owner__r.FinServ__PrimaryContact__r.Email,
                       Financial_Account_Servicing__r.Joint_Owner__r.FinServ__PrimaryContact__r.MobilePhone,
                       
                       Financial_Account_Servicing__r.Advisor_Approver__c,
                       Financial_Account_Servicing__r.Advisor_Approver__r.Name,
                       Financial_Account_Servicing__r.Advisor_Approver__r.Email,
                       Financial_Account_Servicing__r.Advisor_Approver__r.Phone,
                       Financial_Account_Servicing__r.Advisor_Approver__r.MobilePhone,
                       
                       Financial_Account_Servicing__r.WEG_Custodian_Info__r.WEG_eSign_Authorization_Type__c,
                       (SELECT Email__c, Name__c, Order__c, Sign_Type__c, Phone_Number__c FROM Recipients__r) 
                       FROM AS_Quik_Forms_Group__c WHERE Id = :formgrpId LIMIT 1];
        List<Recipients__c> recpToInsert = new List<Recipients__c>();
        if(asFormGroup.Financial_Account_Servicing__c != NULL) {
            if(asFormGroup.Financial_Account_Servicing__r.Primary_Owner__c != null) {
                Recipients__c signer1 = new Recipients__c();
                signer1.Name__c = asFormGroup.Financial_Account_Servicing__r.Primary_Owner__r.Name;
                signer1.Email__c = asFormGroup.Financial_Account_Servicing__r.Primary_Owner__r.FinServ__PrimaryContact__r.Email;
                signer1.Phone_Number__c = asFormGroup.Financial_Account_Servicing__r.Primary_Owner__r.FinServ__PrimaryContact__r.MobilePhone;
                signer1.Order__c = 1;
                signer1.Envelope_Id__c = asFormGroup.Docusign_Envelope_Id__c;
                signer1.Sign_Type__c = 'Sign';
                signer1.WEG_eSign_Authorization_Type__c = asFormGroup.Financial_Account_Servicing__r.WEG_Custodian_Info__r.WEG_eSign_Authorization_Type__c;
                signer1.Signer_Type__c = 'Primary';
                signer1.AS_Quik_Forms_Group__c = asFormGroup.Id;
                signer1.AS_Quik_Form__c = asFormId;
                recpToInsert.add(signer1);
                if(!recipientsOrderInHtml.contains('1own')) {
                    recipientsOrderInHtml += '{"Order": 1, "Role": "1own", "SendType": "EmailToSign", "AuthTypes": "SMS"},';
                }
                for(Integer intg = 1; intg < highestFormCount; intg++) {
                    if(!recipientsOrderInHtml.contains('1own-' + intg)) {
                        recipientsOrderInHtml += '{"Order": ' + (intg + 1) + ', "Role": "1own-' + intg + '", "SendType": "EmailToSign", "AuthTypes": "SMS"},';
                    }
                    Recipients__c signer12 = new Recipients__c();
                    signer12.Name__c = asFormGroup.Financial_Account_Servicing__r.Primary_Owner__r.Name;
                    signer12.Email__c = asFormGroup.Financial_Account_Servicing__r.Primary_Owner__r.FinServ__PrimaryContact__r.Email;
                    signer12.Phone_Number__c = asFormGroup.Financial_Account_Servicing__r.Primary_Owner__r.FinServ__PrimaryContact__r.MobilePhone;
                    signer12.Order__c = intg + 1;
                    signer12.Envelope_Id__c = asFormGroup.Docusign_Envelope_Id__c;
                    signer12.Sign_Type__c = 'Sign';
                    signer12.WEG_eSign_Authorization_Type__c = asFormGroup.Financial_Account_Servicing__r.WEG_Custodian_Info__r.WEG_eSign_Authorization_Type__c;
                    signer12.Signer_Type__c = 'Primary';
                    signer12.AS_Quik_Forms_Group__c = asFormGroup.Id;
                    signer12.AS_Quik_Form__c = asFormId;
                    recpToInsert.add(signer12);
                }
            }
            if(asFormGroup.Financial_Account_Servicing__r.Joint_Owner__c != null) {
                Recipients__c signer2 = new Recipients__c();
                signer2.Name__c = asFormGroup.Financial_Account_Servicing__r.Joint_Owner__r.Name;
                signer2.Email__c = asFormGroup.Financial_Account_Servicing__r.Joint_Owner__r.FinServ__PrimaryContact__r.Email;
                signer2.Phone_Number__c = asFormGroup.Financial_Account_Servicing__r.Joint_Owner__r.FinServ__PrimaryContact__r.MobilePhone;
                signer2.Order__c = 1;
                signer2.Envelope_Id__c = asFormGroup.Docusign_Envelope_Id__c;
                signer2.Sign_Type__c = 'Sign';
                signer2.WEG_eSign_Authorization_Type__c = asFormGroup.Financial_Account_Servicing__r.WEG_Custodian_Info__r.WEG_eSign_Authorization_Type__c;
                signer2.Signer_Type__c = 'Secondary';
                signer2.AS_Quik_Forms_Group__c = asFormGroup.Id;
                signer2.AS_Quik_Form__c = asFormId;
                recpToInsert.add(signer2);
                if(!recipientsOrderInHtml.contains('2own')) {
                    recipientsOrderInHtml += '{"Order": 2, "Role": "2own", "SendType": "EmailToSign", "AuthTypes":"SMS"},';
                }
                for(Integer intg = 1; intg < highestFormCount; intg++) {
                    if(!recipientsOrderInHtml.contains('2own-' + intg)) {
                        recipientsOrderInHtml += '{"Order": ' + (intg + 1) + ', "Role": "2own-' + intg + '", "SendType": "EmailToSign", "AuthTypes": "SMS"},';
                    }
                    Recipients__c signer22 = new Recipients__c();
                    signer22.Name__c = asFormGroup.Financial_Account_Servicing__r.Joint_Owner__r.Name;
                    signer22.Email__c = asFormGroup.Financial_Account_Servicing__r.Joint_Owner__r.FinServ__PrimaryContact__r.Email;
                    signer22.Phone_Number__c = asFormGroup.Financial_Account_Servicing__r.Joint_Owner__r.FinServ__PrimaryContact__r.MobilePhone;
                    signer22.Order__c = intg + 1;
                    signer22.Envelope_Id__c = asFormGroup.Docusign_Envelope_Id__c;
                    signer22.Sign_Type__c = 'Sign';
                    signer22.WEG_eSign_Authorization_Type__c = asFormGroup.Financial_Account_Servicing__r.WEG_Custodian_Info__r.WEG_eSign_Authorization_Type__c;
                    signer22.Signer_Type__c = 'Secondary';
                    signer22.AS_Quik_Forms_Group__c = asFormGroup.Id;
                    signer22.AS_Quik_Form__c = asFormId;
                    recpToInsert.add(signer22);
                }
            }
            if(asFormGroup.Financial_Account_Servicing__r.Advisor_Approver__c != null) {
                Integer advisorOrder = (highestFormCount + 30);
                Recipients__c rep = new Recipients__c();
                rep.Name__c = asFormGroup.Financial_Account_Servicing__r.Advisor_Approver__r.Name;
                rep.Email__c = asFormGroup.Financial_Account_Servicing__r.Advisor_Approver__r.Email;
                rep.Phone_Number__c = asFormGroup.Financial_Account_Servicing__r.Advisor_Approver__r.MobilePhone;
                rep.Order__c = advisorOrder;
                rep.Envelope_Id__c = asFormGroup.Docusign_Envelope_Id__c;
                rep.Sign_Type__c = 'Sign';
                rep.WEG_eSign_Authorization_Type__c = asFormGroup.Financial_Account_Servicing__r.WEG_Custodian_Info__r.WEG_eSign_Authorization_Type__c;
                rep.Signer_Type__c = 'Advisor';
                rep.AS_Quik_Forms_Group__c = asFormGroup.Id;
                rep.AS_Quik_Form__c = asFormId;
                recpToInsert.add(rep);
                if(!recipientsOrderInHtml.contains('1rep')) {
                    recipientsOrderInHtml += '{"Order": ' + advisorOrder + ', "Role": "1rep", "SendType": "EmailToSign", "AuthTypes":"SMS"},';
                }
                for(Integer intg = 1; intg < highestFormCount; intg++) {
                    ++advisorOrder;
                    if(!recipientsOrderInHtml.contains('1rep-' + intg)) {
                        recipientsOrderInHtml += '{"Order": ' + advisorOrder + ', "Role": "1rep-' + intg + '", "SendType": "EmailToSign", "AuthTypes": "SMS"},';
                    }
                    Recipients__c rep2 = new Recipients__c();
                    rep2.Name__c = asFormGroup.Financial_Account_Servicing__r.Advisor_Approver__r.Name;
                    rep2.Email__c = asFormGroup.Financial_Account_Servicing__r.Advisor_Approver__r.Email;
                    rep2.Phone_Number__c = asFormGroup.Financial_Account_Servicing__r.Advisor_Approver__r.MobilePhone;
                    rep2.Order__c = advisorOrder;
                    rep2.Envelope_Id__c = asFormGroup.Docusign_Envelope_Id__c;
                    rep2.Sign_Type__c = 'Sign';
                    rep2.WEG_eSign_Authorization_Type__c = asFormGroup.Financial_Account_Servicing__r.WEG_Custodian_Info__r.WEG_eSign_Authorization_Type__c;
                    rep2.Signer_Type__c = 'Advisor';
                    rep2.AS_Quik_Forms_Group__c = asFormGroup.Id;
                    rep2.AS_Quik_Form__c = asFormId;
                    recpToInsert.add(rep2);
                }
            }                
        } else if(asFormGroup.Account_Servicing__c != null) {
            if(asFormGroup.Account_Servicing__r.WEGP1_Primary_Individual__c != NULL) {
                Recipients__c asSigner1 = new Recipients__c();
                asSigner1.Name__c = asFormGroup.Account_Servicing__r.WEGP1_Primary_Individual__r.Account.Name;
                asSigner1.Email__c = asFormGroup.Account_Servicing__r.WEGP1_Primary_Individual__r.Email;
                asSigner1.Phone_Number__c = asFormGroup.Account_Servicing__r.WEGP1_Primary_Individual__r.MobilePhone;
                asSigner1.Order__c = 1;
                asSigner1.Envelope_Id__c = asFormGroup.Docusign_Envelope_Id__c;
                asSigner1.Sign_Type__c = 'Sign';
                asSigner1.WEG_eSign_Authorization_Type__c = 'SMS';
                asSigner1.Signer_Type__c = 'Primary';
                asSigner1.AS_Quik_Forms_Group__c = asFormGroup.Id;
                asSigner1.AS_Quik_Form__c = asFormId;
                recpToInsert.add(asSigner1);
                if(!recipientsOrderInHtml.contains('1own')) {
                    recipientsOrderInHtml += '{"Order": 1, "Role": "1own", "SendType": "EmailToSign", "AuthTypes": "SMS"},';
                }
                for(Integer intg = 1; intg < highestFormCount; intg++) {
                    if(!recipientsOrderInHtml.contains('1own-' + intg)) {
                        recipientsOrderInHtml += '{"Order": ' + (intg + 1) + ', "Role": "1own-' + intg + '", "SendType": "EmailToSign", "AuthTypes": "SMS"},';
                    }
                    Recipients__c asSigner12 = new Recipients__c();
                    asSigner12.Name__c = asFormGroup.Account_Servicing__r.WEGP1_Primary_Individual__r.Account.Name;
                    asSigner12.Email__c = asFormGroup.Account_Servicing__r.WEGP1_Primary_Individual__r.Email;
                    asSigner12.Phone_Number__c = asFormGroup.Account_Servicing__r.WEGP1_Primary_Individual__r.MobilePhone;
                    asSigner12.Order__c = intg + 1;
                    asSigner12.Envelope_Id__c = asFormGroup.Docusign_Envelope_Id__c;
                    asSigner12.Sign_Type__c = 'Sign';
                    asSigner12.WEG_eSign_Authorization_Type__c = 'SMS';
                    asSigner12.Signer_Type__c = 'Primary';
                    asSigner12.AS_Quik_Forms_Group__c = asFormGroup.Id;
                    asSigner12.AS_Quik_Form__c = asFormId;
                    recpToInsert.add(asSigner12);
                }
            }
            if(asFormGroup.Account_Servicing__r.WEGP1_Secondary_Individual__c != NULL) {
                Recipients__c asSigner2 = new Recipients__c();
                asSigner2.Name__c = asFormGroup.Account_Servicing__r.WEGP1_Secondary_Individual__r.Account.Name;
                asSigner2.Email__c = asFormGroup.Account_Servicing__r.WEGP1_Secondary_Individual__r.Email;
                asSigner2.Phone_Number__c = asFormGroup.Account_Servicing__r.WEGP1_Secondary_Individual__r.MobilePhone;
                asSigner2.Order__c = 1;
                asSigner2.Envelope_Id__c = asFormGroup.Docusign_Envelope_Id__c;
                asSigner2.Sign_Type__c = 'Sign';
                asSigner2.WEG_eSign_Authorization_Type__c = 'SMS';
                asSigner2.Signer_Type__c = 'Secondary';
                asSigner2.AS_Quik_Forms_Group__c = asFormGroup.Id;
                asSigner2.AS_Quik_Form__c = asFormId;
                recpToInsert.add(asSigner2);
                if(!recipientsOrderInHtml.contains('2own')) {
                    recipientsOrderInHtml += '{"Order": 2, "Role": "2own", "SendType": "EmailToSign", "AuthTypes":"SMS"},';
                }
                for(Integer intg = 1; intg < highestFormCount; intg++) {
                    if(!recipientsOrderInHtml.contains('2own-' + intg)) {
                        recipientsOrderInHtml += '{"Order": ' + (intg + 1) + ', "Role": "2own-' + intg + '", "SendType": "EmailToSign", "AuthTypes": "SMS"},';
                    }
                    Recipients__c asSigner22 = new Recipients__c();
                    asSigner22.Name__c = asFormGroup.Account_Servicing__r.WEGP1_Secondary_Individual__r.Account.Name;
                    asSigner22.Email__c = asFormGroup.Account_Servicing__r.WEGP1_Secondary_Individual__r.Email;
                    asSigner22.Phone_Number__c = asFormGroup.Account_Servicing__r.WEGP1_Secondary_Individual__r.MobilePhone;
                    asSigner22.Order__c = intg + 1;
                    asSigner22.Envelope_Id__c = asFormGroup.Docusign_Envelope_Id__c;
                    asSigner22.Sign_Type__c = 'Sign';
                    asSigner22.WEG_eSign_Authorization_Type__c = 'SMS';
                    asSigner22.Signer_Type__c = 'Secondary';
                    asSigner22.AS_Quik_Forms_Group__c = asFormGroup.Id;
                    asSigner22.AS_Quik_Form__c = asFormId;
                    recpToInsert.add(asSigner22);
                }
            }
            if(asFormGroup.Account_Servicing__r.Related_Account__c != NULL) {
                Integer advisorOrder = (highestFormCount + 30);
                Recipients__c asRep = new Recipients__c();
                asRep.Name__c = asFormGroup.Account_Servicing__r.WEG_HH_Business_Owner__c;
                asRep.Email__c = asFormGroup.Account_Servicing__r.HH_Business_Owner_Email__c;
                asRep.Phone_Number__c = asFormGroup.Account_Servicing__r.HH_Business_Owner_Mobile_Phone__c;
                asRep.Order__c = advisorOrder;
                asRep.Envelope_Id__c = asFormGroup.Docusign_Envelope_Id__c;
                asRep.Sign_Type__c = 'Sign';
                asRep.WEG_eSign_Authorization_Type__c = 'SMS';
                asRep.Signer_Type__c = 'Advisor';
                asRep.AS_Quik_Forms_Group__c = asFormGroup.Id;
                asRep.AS_Quik_Form__c = asFormId;
                recpToInsert.add(asRep);
                if(!recipientsOrderInHtml.contains('1rep')) {
                    recipientsOrderInHtml += '{"Order": ' + advisorOrder + ', "Role": "1rep", "SendType": "EmailToSign", "AuthTypes":"SMS"},';
                }
                for(Integer intg = 1; intg < highestFormCount; intg++) {
                    ++advisorOrder;
                    if(!recipientsOrderInHtml.contains('1rep-' + intg)) {
                        recipientsOrderInHtml += '{"Order": ' + advisorOrder + ', "Role": "1rep-' + intg + '", "SendType": "EmailToSign", "AuthTypes": "SMS"},';
                    }
                    Recipients__c asRep2 = new Recipients__c();
                    asRep2.Name__c = asFormGroup.Account_Servicing__r.WEG_HH_Business_Owner__c;
                    asRep2.Email__c = asFormGroup.Account_Servicing__r.HH_Business_Owner_Email__c;
                    asRep2.Phone_Number__c = asFormGroup.Account_Servicing__r.HH_Business_Owner_Mobile_Phone__c;
                    asRep2.Order__c = advisorOrder;
                    asRep2.Envelope_Id__c = asFormGroup.Docusign_Envelope_Id__c;
                    asRep2.Sign_Type__c = 'Sign';
                    asRep2.WEG_eSign_Authorization_Type__c = 'SMS';
                    asRep2.Signer_Type__c = 'Advisor';
                    asRep2.AS_Quik_Forms_Group__c = asFormGroup.Id;
                    asRep2.AS_Quik_Form__c = asFormId;
                    recpToInsert.add(asRep2);
                }
            }
        }
        htmlSettings = htmlSettings.replace('##RECIPIENTS_ORDER##', '"Signers":[' + recipientsOrderInHtml.removeEnd(',') + ']');
        modifiedHtmlSettings = updateRecipientDetails(htmlSettings, JSON.serialize(recpToInsert));
        Integer recipientOrder = (highestFormCount + 40);
        String fasIdInQF = asFormGroup.FAS_Id_List__c;
        List<String> fasIdsList = new List<String>();
        if(fasIdInQF != null & fasIdInQF != '') {
            if(fasIdInQF.contains(',')) {
                for(String str : fasIdInQF.split(',')) {
                    String objectName = Id.valueOf(str).getSObjectType().getDescribe().getName();
                    if(objectName == 'Financial_Account_Servicing__c') {
                        fasIdsList.add(str);
                    }
                }
            } else {
                fasIdsList.add(fasIdInQF);
            }
        }
        Map<Integer, String> custInfoIdsMap = new Map<Integer, String>();
        Integer custInfoCount = 1;
        for(Financial_Account_Servicing__c fas : [SELECT WEG_Custodian_Info__c FROM Financial_Account_Servicing__c 
                                                  WHERE Id IN :fasIdsList]) 
        {
            custInfoIdsMap.put(custInfoCount++, fas.WEG_Custodian_Info__c);
        }
        Map<String, Custodian_Info__c> custodianInfoMap = new Map<String, Custodian_Info__c>();
        for(Custodian_Info__c cusInfo : [SELECT Custodian_Name__c, Custodian_Email_1__c, Custodian_Email_2__c, 
                                         Custodian_Phone__c, WEG_eSign_Authorization_Type__c 
                                         FROM Custodian_Info__c 
                                         WHERE Id IN :custInfoIdsMap.values()])
        {
            custodianInfoMap.put(cusInfo.Id, cusInfo);
        }
        if(custInfoIdsMap.size() > 0) {
            for(Integer csInt : custInfoIdsMap.keySet()) {
                Custodian_Info__c custodianRec = custodianInfoMap.get(custInfoIdsMap.get(csInt));
                if(custodianRec.Custodian_Email_1__c != null && custodianRec.Custodian_Email_1__c != '') {
                    Recipients__c cc1 = new Recipients__c();
                    cc1.Name__c = custodianRec.Custodian_Name__c + ' CC1';
                    cc1.Email__c = custodianRec.Custodian_Email_1__c;
                    cc1.Phone_Number__c = custodianRec.Custodian_Phone__c;
                    cc1.Order__c = recipientOrder++;
                    cc1.Envelope_Id__c = asFormGroup.Docusign_Envelope_Id__c;
                    cc1.Sign_Type__c = 'Carbon Copy';
                    cc1.Signer_Type__c = 'CC1';
                    cc1.AS_Quik_Forms_Group__c = asFormGroup.Id;
                    cc1.AS_Quik_Form__c = asFormId;
                    recpToInsert.add(cc1);
                }
                if(custodianRec.Custodian_Email_2__c != null && custodianRec.Custodian_Email_2__c != '') {
                    Recipients__c cc2 = new Recipients__c();
                    cc2.Name__c = custodianRec.Custodian_Name__c + ' CC2';
                    cc2.Email__c = custodianRec.Custodian_Email_2__c;
                    cc2.Phone_Number__c = custodianRec.Custodian_Phone__c;
                    cc2.Order__c = recipientOrder++;
                    cc2.Envelope_Id__c = asFormGroup.Docusign_Envelope_Id__c;
                    cc2.Sign_Type__c = 'Carbon Copy';
                    cc2.Signer_Type__c = 'CC2';
                    cc2.AS_Quik_Forms_Group__c = asFormGroup.Id;
                    cc2.AS_Quik_Form__c = asFormId;
                    recpToInsert.add(cc2);
                }
            }
        }
        modifiedHtmlSettings = modifiedHtmlSettings.replaceAll('##1ownfullname##', '');
        modifiedHtmlSettings = modifiedHtmlSettings.replaceAll('##1ownemail##', '');
        modifiedHtmlSettings = modifiedHtmlSettings.replaceAll('##1ownphone##', '');
        modifiedHtmlSettings = modifiedHtmlSettings.replaceAll('##2ownfullname##', '');
        modifiedHtmlSettings = modifiedHtmlSettings.replaceAll('##2ownemail##', '');
        modifiedHtmlSettings = modifiedHtmlSettings.replaceAll('##2ownphone##', '');
        modifiedHtmlSettings = modifiedHtmlSettings.replaceAll('##1repfullname##', '');
        modifiedHtmlSettings = modifiedHtmlSettings.replaceAll('##1repemail##', '');
        modifiedHtmlSettings = modifiedHtmlSettings.replaceAll('##1repphone##', '');
        if(recpToInsert.size() > 0 && saveRecp.equals('yes')) {
            try {
                insert recpToInsert;
            } catch(Exception exc) {
                QuikErrorLogGeneration.createErrorLog('', '', '', exc.getMessage(),'QuikGenerateHTML','createRecipients', 
                                                      exc.getlineNumber());
            }
        }
        return modifiedHtmlSettings;
    }
    
    public static String updateRecipientDetails(String htmlSettings, String updatedRecipientString) {
        Map<String, String> signerTypeNameMap = new Map<String, String>();
        Map<String, String> signerTypePhoneMap = new Map<String, String>();
        Map<String, String> signerTypeEmailMap = new Map<String, String>();
        String oneOwnFN = '';
        String twoOwnFN = '';
        String oneRepFN = '';
        String oneOwnPhone = '';
        String twoOwnPhone = '';
        String oneRepPhone = '';
        String oneOwnEmail = '';
        String twoOwnEmail = '';
        String oneRepEmail = '';
        
        String extraOneOwnFN = '';
        String extraTwoOwnFN = '';
        String extraOneRepFN = '';
        String extraOneOwnPhone = '';
        String extraTwoOwnPhone = '';
        String extraOneRepPhone = '';
        String extraOneOwnEmail = '';
        String extraTwoOwnEmail = '';
        String extraOneRepEmail = '';
        
        JSONParser parser = JSON.createParser(htmlSettings);
        if(updatedRecipientString != null && updatedRecipientString != '' && updatedRecipientString != 'undefined') {
            List<Recipients__c> updatedRecpWrap = (List<Recipients__c>)System.JSON.deserializeStrict(updatedRecipientString, 
                                                                                                     List<Recipients__c>.class);
            for(Recipients__c recp : updatedRecpWrap) {
                signerTypeNameMap.put(recp.Signer_Type__c, recp.Name__c);
                signerTypePhoneMap.put(recp.Signer_Type__c, recp.Phone_Number__c);
                signerTypeEmailMap.put(recp.Signer_Type__c, recp.Email__c);
            }
            while(parser.nextToken() != null) {
                if(parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    parser.nextValue();
                    if(parser.getCurrentName() == 'FormFields') {
                        while(parser.nextToken() != JSONToken.END_ARRAY) {
                            if(parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                                parser.nextValue();
                                if(parser.getCurrentName() == 'FieldName') {
                                    if(('1own.FullName').equals(parser.getText())) {
                                        parser.nextValue();
                                        if(parser.getCurrentName() == 'FieldValue') {
                                            oneOwnFN = parser.getText();
                                        }
                                    }
                                    if(parser.getText() != '' && parser.getText() != null) {
                                        String parserFullName = parser.getText();
                                        if(parserFullName.contains('1own.FullName-')) {
                                            parser.nextValue();
                                            if(parser.getCurrentName() == 'FieldValue') {
                                                extraOneOwnFN = parser.getText();
                                            }
                                        }
                                    }
                                    if(('1own.H.Phone').equals(parser.getText())) {
                                        parser.nextValue();
                                        if(parser.getCurrentName() == 'FieldValue') {
                                            oneOwnPhone = parser.getText();
                                        }
                                    }
                                    if(parser.getText() != '' && parser.getText() != null) {
                                        String parserPhone = parser.getText();
                                        if(parserPhone.contains('1own.H.Phone-')) {
                                            parser.nextValue();
                                            if(parser.getCurrentName() == 'FieldValue') {
                                                extraOneOwnPhone = parser.getText();
                                            }
                                        }
                                    }
                                    if(('1own.H.Email').equals(parser.getText())) {
                                        parser.nextValue();
                                        if(parser.getCurrentName() == 'FieldValue') {
                                            oneOwnEmail = parser.getText();
                                        }
                                    }
                                    if(parser.getText() != '' && parser.getText() != null) {
                                        String parserEmail = parser.getText();
                                        if(parserEmail.contains('1own.H.Email-')) {
                                            parser.nextValue();
                                            if(parser.getCurrentName() == 'FieldValue') {
                                                extraOneOwnEmail = parser.getText();
                                            }
                                        }
                                    }
                                    if(('2own.FullName').equals(parser.getText())) {
                                        parser.nextValue();
                                        if(parser.getCurrentName() == 'FieldValue') {
                                            twoOwnFN = parser.getText();
                                        }
                                    }
                                    if(parser.getText() != '' && parser.getText() != null) {
                                        String parserFullName = parser.getText();
                                        if(parserFullName.contains('2own.FullName-')) {
                                            parser.nextValue();
                                            if(parser.getCurrentName() == 'FieldValue') {
                                                extraTwoOwnFN = parser.getText();
                                            }
                                        }
                                    }
                                    if(('2own.H.Phone').equals(parser.getText())) {
                                        parser.nextValue();
                                        if(parser.getCurrentName() == 'FieldValue') {
                                            twoOwnPhone = parser.getText();
                                        }
                                    }
                                    if(parser.getText() != '' && parser.getText() != null) {
                                        String parserPhone = parser.getText();
                                        if(parserPhone.contains('2own.H.Phone-')) {
                                            parser.nextValue();
                                            if(parser.getCurrentName() == 'FieldValue') {
                                                extraTwoOwnPhone = parser.getText();
                                            }
                                        }
                                    }
                                    if(('2own.H.Email').equals(parser.getText())) {
                                        parser.nextValue();
                                        if(parser.getCurrentName() == 'FieldValue') {
                                            twoOwnEmail = parser.getText();
                                        }
                                    }
                                    if(parser.getText() != '' && parser.getText() != null) {
                                        String parserEmail = parser.getText();
                                        if(parserEmail.contains('2own.H.Email-')) {
                                            parser.nextValue();
                                            if(parser.getCurrentName() == 'FieldValue') {
                                                extraTwoOwnEmail = parser.getText();
                                            }
                                        }
                                    }
                                    if(('1rep.FullName').equals(parser.getText())) {
                                        parser.nextValue();
                                        if(parser.getCurrentName() == 'FieldValue') {
                                            oneRepFN = parser.getText();
                                        }
                                    }
                                    if(parser.getText() != '' && parser.getText() != null) {
                                        String parserFullName = parser.getText();
                                        if(parserFullName.contains('1rep.FullName-')) {
                                            parser.nextValue();
                                            if(parser.getCurrentName() == 'FieldValue') {
                                                extraOneRepFN = parser.getText();
                                            }
                                        }
                                    }
                                    if(('1rep.P.Phone').equals(parser.getText())) {
                                        parser.nextValue();
                                        if(parser.getCurrentName() == 'FieldValue') {
                                            oneRepPhone = parser.getText();
                                        }
                                    }
                                    if(parser.getText() != '' && parser.getText() != null) {
                                        String parserPhone = parser.getText();
                                        if(parserPhone.contains('1rep.P.Phone-')) {
                                            parser.nextValue();
                                            if(parser.getCurrentName() == 'FieldValue') {
                                                extraOneRepPhone = parser.getText();
                                            }
                                        }
                                    }
                                    if(('1rep.P.Email').equals(parser.getText())) {
                                        parser.nextValue();
                                        if(parser.getCurrentName() == 'FieldValue') {
                                            oneRepEmail = parser.getText();
                                        }
                                    }
                                    if(parser.getText() != '' && parser.getText() != null) {
                                        String parserEmail = parser.getText();
                                        if(parserEmail.contains('1rep.P.Email-')) {
                                            parser.nextValue();
                                            if(parser.getCurrentName() == 'FieldValue') {
                                                extraOneRepEmail = parser.getText();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if(signertypeNameMap.containsKey('Primary') ) {
                if(oneOwnFN != '' && oneOwnFN != null 
                   && (signertypeNameMap.get('Primary') != '' && signertypeNameMap.get('Primary') != null)) 
                {
                    htmlSettings = htmlSettings.replaceAll(oneOwnFN, signertypeNameMap.get('Primary'));
                }
                if(extraOneOwnFN != '' && extraOneOwnFN != null 
                   && (signertypeNameMap.get('Primary') != '' && signertypeNameMap.get('Primary') != null)) 
                {
                    htmlSettings = htmlSettings.replaceAll(extraOneOwnFN, signertypeNameMap.get('Primary'));
                }
                if(oneOwnPhone != '' && oneOwnPhone != null 
                   && (signertypePhoneMap.get('Primary') != '' && signertypePhoneMap.get('Primary') != null)) 
                {
                    htmlSettings = htmlSettings.replaceAll(oneOwnPhone, signertypePhoneMap.get('Primary'));
                }
                if(extraOneOwnPhone != '' && extraOneOwnPhone != null 
                   && (signertypePhoneMap.get('Primary') != '' && signertypePhoneMap.get('Primary') != null)) 
                {
                    htmlSettings = htmlSettings.replaceAll(extraOneOwnPhone, signertypeNameMap.get('Primary'));
                }
                if(oneOwnEmail != '' && oneOwnEmail != null 
                   && (signertypeEmailMap.get('Primary') != '' && signertypeEmailMap.get('Primary') != null)) 
                {
                    htmlSettings = htmlSettings.replaceAll(oneOwnEmail, signertypeEmailMap.get('Primary'));
                }
                if(extraOneOwnEmail != '' && extraOneOwnEmail != null 
                   && (signertypeEmailMap.get('Primary') != '' && signertypeEmailMap.get('Primary') != null)) 
                {
                    htmlSettings = htmlSettings.replaceAll(extraOneOwnEmail, signertypeEmailMap.get('Primary'));
                }
            }
            if(signertypeNameMap.containsKey('Secondary')) {
                if(twoOwnFN != '' && twoOwnFN != null 
                   && (signertypeNameMap.get('Secondary') != '' && signertypeNameMap.get('Secondary') != null)) 
                {
                    htmlSettings = htmlSettings.replaceAll(twoOwnFN, signertypeNameMap.get('Secondary'));
                }
                if(extraTwoOwnFN != '' && extraTwoOwnFN != null 
                   && (signertypeNameMap.get('Secondary') != '' && signertypeNameMap.get('Secondary') != null)) 
                {
                    htmlSettings = htmlSettings.replaceAll(extraTwoOwnFN, signertypeNameMap.get('Secondary'));
                }
                if(twoOwnPhone != '' && twoOwnPhone != null 
                   && (signertypePhoneMap.get('Secondary') != '' && signertypePhoneMap.get('Secondary') != null)) 
                {
                    htmlSettings = htmlSettings.replaceAll(twoOwnPhone, signertypePhoneMap.get('Secondary'));
                }
                if(extraTwoOwnPhone != '' && extraTwoOwnPhone != null 
                   && (signertypePhoneMap.get('Secondary') != '' && signertypePhoneMap.get('Secondary') != null)) 
                {
                    htmlSettings = htmlSettings.replaceAll(extraTwoOwnPhone, signertypePhoneMap.get('Secondary'));
                }
                if(twoOwnEmail != '' && twoOwnEmail != null 
                   && (signertypeEmailMap.get('Secondary') != '' && signertypeEmailMap.get('Secondary') != null)) 
                {
                    htmlSettings = htmlSettings.replaceAll(twoOwnEmail, signertypeEmailMap.get('Secondary'));
                }
                if(extraTwoOwnEmail != '' && extraTwoOwnEmail != null 
                   && (signertypeEmailMap.get('Secondary') != '' && signertypeEmailMap.get('Secondary') != null)) 
                {
                    htmlSettings = htmlSettings.replaceAll(extraTwoOwnEmail, signertypeEmailMap.get('Secondary'));
                }
            }
            if(signertypeNameMap.containsKey('Advisor')) {
                if((oneRepFN != '' && oneRepFN != null) 
                   && (signertypeNameMap.get('Advisor') != '' && signertypeNameMap.get('Advisor') != null)) 
                {
                    htmlSettings = htmlSettings.replaceAll(oneRepFN, signertypeNameMap.get('Advisor'));
                }
                if((extraOneRepFN != '' && extraOneRepFN != null) 
                   && (signertypeNameMap.get('Advisor') != '' && signertypeNameMap.get('Advisor') != null)) 
                {
                    htmlSettings = htmlSettings.replaceAll(extraOneRepFN, signertypeNameMap.get('Advisor'));
                }
                if((oneRepPhone != '' && oneRepPhone != null) 
                   && (signertypePhoneMap.get('Advisor') != '' && signertypePhoneMap.get('Advisor') != null)) 
                {
                    htmlSettings = htmlSettings.replaceAll(oneRepPhone, signertypePhoneMap.get('Advisor'));
                }
                if((extraOneRepPhone != '' && extraOneRepPhone != null) 
                   && (signertypePhoneMap.get('Advisor') != '' && signertypePhoneMap.get('Advisor') != null)) 
                {
                    htmlSettings = htmlSettings.replaceAll(extraOneRepPhone, signertypePhoneMap.get('Advisor'));
                }
                if(oneRepEmail != '' && oneRepEmail != null 
                   && (signertypeEmailMap.get('Advisor') != null && signertypeEmailMap.get('Advisor') != '')) 
                {
                    htmlSettings = htmlSettings.replaceAll(oneRepEmail, signertypeEmailMap.get('Advisor'));
                }
                if(extraOneRepEmail != '' && extraOneRepEmail != null 
                   && (signertypeEmailMap.get('Advisor') != null && signertypeEmailMap.get('Advisor') != '')) 
                {
                    htmlSettings = htmlSettings.replaceAll(extraOneRepEmail, signertypeEmailMap.get('Advisor'));
                }
            }
        }
        return htmlSettings;
    }
}