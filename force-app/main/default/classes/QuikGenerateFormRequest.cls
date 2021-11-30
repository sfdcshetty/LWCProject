public class QuikGenerateFormRequest {
    
    public static String generateRequestBody (String selectedFormsJSON, String unId, ID asRecId, String formType, 
                                              Map<String, String> allFormsInfo) 
    {
        if(unId != NULL && unId != '') {
            try {
                AS_Quik_Forms__c quikForm = new AS_Quik_Forms__c ();
                quikForm = [SELECT UNID__c, Form_HTML_URL__c FROM AS_QUik_Forms__c WHERE UNID__c = :unId LIMIT 1];
                return '{"UNID" : "' + quikForm.UNID__c + '", "URL" : "' + quikForm.Form_HTML_URL__c + '", "recId" : "' 
                    + quikForm.Id + '"}';
            } catch(Exception e) {
                return generateRequestBody(selectedFormsJSON, '', asRecId, formType, allFormsInfo);
            }
        } else {
            try {
                String custodianName = '';
                Set<String> custodianNameList = new Set<String>();
                String custodianInfoForQF = '';
                String excludeDocsFormIds = '';
                String asFasIdsToStoreInQuikForm = '';
                String asFasNamesToStoreInQuikForm = '';
                QuikSelectedForms_REQ obj = QuikSelectedForms_REQ.parse(selectedFormsJSON);
                List<Id> recIds = new List<Id>();
                String quikFormIds = '';
                String formFields = '';
                ID asRecordId = null;
                Map<String, Integer> fileCountIdMap = new Map<String, Integer>();
                String objectName = '';
                for(QuikSelectedForms_REQ.cls_results res : obj.results) {
                    String formIds = res.Id;
                    excludeDocsFormIds = formIds;
                    if(formIds.contains(',')) {
                        for(String str : formIds.split(',')) {
                            String selectedObjectName = Id.valueOf(str).getSObjectType().getDescribe().getName();
                            objectName = selectedObjectName; 
                            if(selectedObjectName == 'Account_Servicing__c') {
                                asRecordId = str;
                                asFasIdsToStoreInQuikForm += str + ',';
                            } else {
                                recIds.add(str);
                                asFasIdsToStoreInQuikForm += str + ',';
                            }
                        }
                    } else {
                        String selectedObjectName = Id.valueOf(res.Id).getSObjectType().getDescribe().getName();
                        objectName = selectedObjectName; 
                        if(selectedObjectName == 'Account_Servicing__c') {
                            asRecordId = res.Id;
                            asFasIdsToStoreInQuikForm += res.Id + ',';
                        } else {
                            recIds.add(res.Id);
                            asFasIdsToStoreInQuikForm += res.Id + ',';
                        }
                    }
                    for(QuikSelectedForms_REQ.cls_list rec : res.records) {
                        if(rec.fileCount != null && rec.fileCount != '') {
                            fileCountIdMap.put(rec.formId, Integer.valueOf(rec.fileCount));
                        }
                    }
                }
                String allFormIdsCombine = '';
                for(String str : allFormsInfo.keySet()) {
                    if(asFasIdsToStoreInQuikForm.contains(str)) {
                        allFormIdsCombine += allFormsInfo.get(str) + ',';
                    }
                }
                allFormIdsCombine = allFormIdsCombine.removeEnd(',');
                Map<String, Integer> uniqueFormsCount = new Map<String, Integer>();
                List<String> formIdsList = allFormIdsCombine.split(',');
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
                allFormIdsCombine += ',';
                for(String str : fileCountIdMap.keySet()) {
                    for(Integer i = 0; i < fileCountIdMap.get(str); i++) {
                        quikFormIds += str + ',';
                    }
                }
                List<Quik_AttachmentForms__mdt> attachmentForms = [SELECT MasterLabel, AS_Attachment_Form__c, FAS_Attachment_Form__c
                                                                   FROM Quik_AttachmentForms__mdt LIMIT 1];
                if(objectName == 'Account_Servicing__c' && attachmentForms != null
                   && attachmentForms[0].AS_Attachment_Form__c != null && attachmentForms[0].AS_Attachment_Form__c != '' 
                   && formType == 'Sign') {
                       quikFormIds = quikFormIds + attachmentForms[0].AS_Attachment_Form__c +',';
                       allFormIdsCombine += attachmentForms[0].AS_Attachment_Form__c +',';
                   }
                if(objectName != 'Account_Servicing__c' && attachmentForms != null 
                   && attachmentForms[0].FAS_Attachment_Form__c != null && attachmentForms[0].FAS_Attachment_Form__c != '' 
                   && formType == 'Sign') {
                       quikFormIds = quikFormIds + attachmentForms[0].FAS_Attachment_Form__c +',';
                       allFormIdsCombine += attachmentForms[0].FAS_Attachment_Form__c +',';
                   }
                quikFormIds = quikFormIds.removeEnd(',');
                allFormIdsCombine = allFormIdsCombine.removeEnd(',');
                Map<String, List<Quik_Mapping__c>> mappings = new Map<String, List<Quik_Mapping__c>>();
                for(Quik_Mapping__c mapping : [SELECT WEG_Origin__c, WEG_Role_Name__c, WEG_Field_Name__c, WEG_SF_Reference__c 
                                               FROM Quik_Mapping__c]) 
                {
                    String mapSfRef = mapping.WEG_SF_Reference__c;
                    if(mapSfRef != '' && mapSfRef != null) {
                        if(mappings.containsKey(mapping.WEG_Origin__c)){
                            mappings.get(mapping.WEG_Origin__c).add(mapping);
                        } else {
                            mappings.put(mapping.WEG_Origin__c, new List<Quik_Mapping__c> {mapping});
                        }
                    }
                }
                Account_Servicing__c asRecord = new Account_Servicing__c();
                String asQuery = 'SELECT ';
                if(mappings.containskey('AS') && asRecordId != NULL) {
                    Set<String> fieldNames = new Set<String>();
                    for(Quik_Mapping__c record: mappings.get('AS')) {
                        String recSFReference = record.WEG_SF_Reference__c;
                        if(recSFReference != '' && recSFReference != null) {
                            fieldNames.add(record.WEG_SF_Reference__c);   
                        }
                    }
                    for(String field : fieldNames) {
                        asQuery += field + ',';
                    }
                    asQuery = asQuery.removeEnd(',');
                    asQuery += ' FROM Account_Servicing__c WHERE Id =: asRecordId';
                    asRecord = Database.query(asQuery);
                    if(asRecord.Id != NULL) {
                        asFasNamesToStoreInQuikForm += 'Household / Business, ';
                        for(String str : fileCountIdMap.keySet()) {
                            for(Quik_Mapping__c record : mappings.get('AS')) {
                                formfields += '{"FieldName" : "' + record.WEG_Role_Name__c 
                                    + '.' + record.WEG_Field_Name__c 
                                    + '", "FieldValue" : "' + mergeFields(asRecord, record) + '"},'  ;
                            }
                            //We have to add form fields based upon the count
                            if(fileCountIdMap.get(str) > 1) {
                                for(Quik_Mapping__c record : mappings.get('AS')) {
                                    for(Integer i = 1; i < fileCountIdMap.get(str); i++) {
                                        formfields += '{"FieldName" : "' + record.WEG_Role_Name__c 
                                            + '.' + record.WEG_Field_Name__c + '-' + i 
                                            + '", "FieldValue" : "' + mergeFields(asRecord, record) + '"},'  ;
                                    }
                                }
                            }
                            if(highestFormCount > 1) {
                                for(Integer intg = 1; intg < highestFormCount; intg++) {
                                    for(Quik_Mapping__c record : mappings.get('AS')) {
                                        formfields += '{"FieldName" : "' + record.WEG_Role_Name__c 
                                            + '.' + record.WEG_Field_Name__c + '-' + intg 
                                            + '", "FieldValue" : "' + mergeFields(asRecord, record) + '"},'  ;
                                    }
                                }
                            }
                        }
                        formfields = formfields.removeEnd(',');
                    }
                }
                List<Financial_Account_Servicing__c> fasRecords = new List<Financial_Account_Servicing__c>();
                String fasQuery = 'SELECT Quik_Group_Number__c, ';
                if(mappings.containsKey('FAS') && recIds.size() > 0) {
                    Set<String> fieldNames = new Set<String>();
                    for(Quik_Mapping__c record: mappings.get('FAS')) {
                        String recSFReferenceFAS = record.WEG_SF_Reference__c;
                        if(recSFReferenceFAS != '' && recSFReferenceFAS != null) {
                            fieldNames.add(record.WEG_SF_Reference__c);
                        }
                    }
                    fieldNames.add('Name');
                    fieldNames.add('WEG_Custodian__c');
                    fieldNames.add('WEG_Custodian_Info__c');
                    for(String field : fieldNames) {
                        fasQuery += field + ',';
                    }
                    fasQuery = fasQuery.removeEnd(',');
                    fasQuery += ' FROM Financial_Account_Servicing__c WHERE Id IN: recIds';
                    fasRecords = database.query (fasQuery);
                    if(fasRecords.size() > 0) {
                        if(formfields != '') {
                            formfields += ',';
                        }
                        Integer groupNum = 0;
                        for(Financial_Account_Servicing__c serv : fasRecords) {
                            custodianName = serv.WEG_Custodian__c;
                            custodianInfoForQF = serv.WEG_Custodian_Info__c;
                            custodianNameList.add(serv.WEG_Custodian__c);
                            for(String str : fileCountIdMap.keySet()) {
                                for(Quik_Mapping__c record : mappings.get('FAS')) {
                                    String groupNumber = '';
                                    if(serv.Quik_Group_Number__c != NULL && groupNum != 0 && formType != 'Sign') {
                                        groupNumber = '-' + groupNum;
                                    }
                                    formfields += '{"FieldName" : "' + record.WEG_Role_Name__c 
                                        + '.' + record.WEG_Field_Name__c 
                                        + groupNumber 
                                        + '", "FieldValue" : "' + mergeFields(serv, record) + '"},'  ;
                                    //We have to add form fields based upon the count
                                    if(fileCountIdMap.get(str) > 1) {
                                        for(Integer i = 1; i < fileCountIdMap.get(str); i++) {
                                            formfields += '{"FieldName" : "' + record.WEG_Role_Name__c 
                                                + '.' + record.WEG_Field_Name__c 
                                                + groupNumber + '-' + i 
                                                + '", "FieldValue" : "' + mergeFields(serv, record) + '"},'  ;
                                        }
                                    }
                                }
                                groupNum = groupNum + 1000;    
                            }
                            if(highestFormCount > 1) {
                                for(Integer intg = 1; intg < highestFormCount; intg++) {
                                    for(Quik_Mapping__c record : mappings.get('FAS')) {
                                        formfields += '{"FieldName" : "' + record.WEG_Role_Name__c 
                                            + '.' + record.WEG_Field_Name__c + '-' + intg 
                                            + '", "FieldValue" : "' + mergeFields(serv, record) + '"},'  ;
                                    }
                                }
                            }
                        }
                        formfields = formfields.removeEnd(',');
                    }
                }
                quikFormIds = quikFormIds.removeEnd('-');
                Quik_API__mdt mdtSettings = [SELECT HTMLSettings__c FROM Quik_API__mdt WHERE developerName = 'HTMLSettings'];
                String htmlSettings = mdtSettings.HTMLSettings__c;
                htmlSettings = htmlSettings.replace('##EXPIRE_DATE##', DateTime.Now().addDays(180).format());
                htmlSettings = htmlSettings.replace('##DISABLE_ATTACHMENT##', 'true');
                htmlSettings = htmlSettings.replace('##QUIK_IDS##', allFormIdsCombine);
                htmlSettings = htmlSettings.replace ('##UN_ID##', unId);
                htmlSettings = htmlSettings.replace('##FORM_FIELDS##', '[' + formfields + ']');
                String extraFormsSignerFields = '';
                for(Integer sf = 1; sf < highestFormCount; sf++) {
                    extraFormsSignerFields += '{"Order": ' + (sf + 1) + ', "Role": "1own-' + sf + '", "SendType": "EmailToSign", "AuthTypes": "NoIDCheck"},';
                    extraFormsSignerFields += '{"Order": ' + (sf + 1) + ', "Role": "2own-' + sf + '", "SendType": "EmailToSign", "AuthTypes": "NoIDCheck"},';
                    extraFormsSignerFields += '{"Order": ' + (sf + 1) + ', "Role": "1rep-' + sf + '", "SendType": "EmailToSign", "AuthTypes": "NoIDCheck"},';
                }
                extraFormsSignerFields = extraFormsSignerFields.removeEnd(',');
                String signerFields = '"Signers": [{"Order": 1, "Role": "1own", "SendType": "EmailToSign", "AuthTypes": "NoIDCheck"},';
                signerFields += '{"Order": 2, "Role": "2own", "SendType": "EmailToSign", "AuthTypes":"NoIDCheck"},';
                signerFields += '{"Order": 3, "Role": "1rep", "SendType": "EmailToSign", "AuthTypes":"NoIDCheck"},' + extraFormsSignerFields + ']';
                htmlSettings = htmlSettings.replace('##RECIPIENTS_ORDER##', signerFields);
                if(objectName == 'Account_Servicing__c') {
                    htmlSettings = htmlSettings.replace('##EXTRA_RECIPIENTS_INFO##', '');
                } else {
                    Map<String, String> fasCustodianIdsMap = new Map<String, String>();
                    Set<String> fasCustodianIds = new Set<String>();
                    for(Financial_Account_Servicing__c fas : [SELECT Name, WEG_Custodian_Info__c FROM Financial_Account_Servicing__c 
                                                              WHERE Id IN :recIds]) 
                    {
                        fasCustodianIdsMap.put(fas.Id, fas.WEG_Custodian_Info__c);
                        fasCustodianIds.add(fas.WEG_Custodian_Info__c);
                        asFasNamesToStoreInQuikForm += fas.Name + ', ';
                    }
                    Map<String, Custodian_Info__c> custodianInfoRecMap = new Map<String, Custodian_Info__c>();
                    for(Custodian_Info__c custodianInfoRec : [SELECT Custodian_Name__c, Custodian_Email_1__c, Custodian_Email_2__c, 
                                                              Custodian_Phone__c, WEG_eSign_Authorization_Type__c 
                                                              FROM Custodian_Info__c 
                                                              WHERE Id IN :fasCustodianIds]) 
                    {
                        custodianInfoRecMap.put(custodianInfoRec.Id, custodianInfoRec);
                    }
                    String extraRecpFields = '';
                    Integer recipientNoCount = 1;
                    Integer orderCount = 2;
                    for(String str : fasCustodianIdsMap.keySet()) {
                        String formsToBeExcluded = '';
                        if(excludeDocsFormIds.contains(',')) {
                            for(String excId : excludeDocsFormIds.split(',')) {
                                if(!str.equals(excId)) {
                                    formsToBeExcluded += allFormsInfo.get(excId) + ',';
                                }
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
                            extraRecpFields += '"RecipientNumber": ' + (recipientNoCount++) + '},';
                        }
                        if(cusInfo.Custodian_Email_2__c != '' && cusInfo.Custodian_Email_2__c != null) {
                            extraRecpFields += '{"Order": ' + (orderCount++) + ',';
                            extraRecpFields += '"Email": "' + cusInfo.Custodian_Email_2__c + '",';
                            extraRecpFields += '"Name": "' + cusInfo.Custodian_Name__c + ' CC2",';
                            if(formsToBeExcluded != null && formsToBeExcluded != '') {
                                extraRecpFields += '"ExcludedDocuments": [' + formsToBeExcluded + '],';
                            }
                            extraRecpFields += '"RecipientNumber": ' + (recipientNoCount++) + '},';
                        }
                    }
                    htmlSettings = htmlSettings.replace('##EXTRA_RECIPIENTS_INFO##', extraRecpFields.removeEnd(','));
                }
                Datetime dt = Datetime.now();
                Long l = dt.getTime();
                String uniqueId = userinfo.getUserId()+String.valueOf(l);
                htmlSettings = htmlSettings.replace('UNIQUEID1', uniqueId);
                // Start - Editable fields code replace with Quik Mapping object
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
                htmlSettings = htmlSettings.replace ('##EDIT_TYPE##', 'FieldList');
                htmlSettings = htmlSettings.replace ('##FIELDS_REQUIRED##', fieldJson);
                // End - Editable fields code replace with Quik Mapping object
                String fasRecId = '';
                if(recIds.size() > 0) {
                    fasRecId = String.valueOf(recIds[0]);
                }
                if(custodianNameList.size() > 0) {
                    custodianName = '';
                    for(String str : custodianNameList) {
                        custodianName += str + ', ';
                    }
                }
                String formNumWithRecId = '';
                for(String str : allFormsInfo.keySet()) {
                    formNumWithRecId += str + ':' + allFormsInfo.get(str) + '-';
                }
                return doCallOut(asRecId, fasRecId, htmlSettings, allFormIdsCombine, custodianName.removeEnd(', '), custodianInfoForQF, 
                                 uniqueId, formType, asFasIdsToStoreInQuikForm.removeEnd(','), 
                                 asFasNamesToStoreInQuikForm.removeEnd(', '), formNumWithRecId.removeEnd('-'));
            } catch(exception e) {
                QuikErrorLogGeneration.createErrorLog('', '', '', e.getMessage(), 'QuikGenerateFormRequest', 'generateRequestBody', 
                                                      e.getLineNumber());
                return null;
            }
        }
    }
    
    public static String doCallout(ID asRecordId, String fasRecordId, String reqBody, String quikFormIds, String custodianName, 
                                   String custodianInfoForQF, String uniqueId, String formType, String fasIdsToStoreInQuikForm, 
                                   String asFasNamesToStoreInQuikForm, String formNumWithRecId) 
    {
        try {
            String returnVal = '';
            Quik_API__mdt logins = [SELECT Endpoint__c FROM Quik_API__mdt WHERE developerName = 'HTMLLogins'];
            HTTPRequest req = new HTTPRequest ();
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer '+QuikFormHandler.getAccessToken());
            req.setHeader('content-type', 'application/json');
            req.setEndpoint(logins.Endpoint__c);        
            req.setBody(reqBody);
            req.setTimeout(120000);
            HTTP http = new HTTP ();
            HTTPResponse res = new HTTPResponse ();
            if(!Test.isRunningTest()) {
                res = http.send(req);
            }
            if(res.getStatusCode() != 200) {
                QuikErrorLogGeneration.createErrorLog(reqBody, res.getBody(), '', '', 'QuikGenerateFormRequest', 'doCallout', 389);
            }
            if(res.getStatusCode() == 500) {
                returnVal = 'Error';
                QuikErrorLogGeneration.createErrorLog(reqBody, res.getBody(), '', '', 'QuikGenerateFormRequest', 'doCallout', 393);
            }
            if(Test.isRunningTest()) {
                res.setStatusCode(200);
                res.setBody ('{"ResultData": {"UNID": "sh2ajtGY", "HTML": "https://quikforms.com/viewform/zqTZ-wrkuTag4", "FormIDs": "918" },"ErrorCode": 0, "Message": "Forms.", "Errors": null}');
            }
            if(res.getStatusCode() == 200) {
                QuikHTML_RESP response = QuikHTML_RESP.parse(res.getBody());
                String url = response.ResultData.HTML;
                if(url != '' && url != NULL) {
                    List<String> temp = url.split('/');
                    url = temp[temp.size() - 1];
                }
                String htmlBody = getHTMLFromQuik(url, 0);
                Boolean isExist = false;
                AS_Quik_Forms__c form = new AS_Quik_Forms__c();
                try {
                    form = [SELECT UNID__c, Form_For__c, AS_Quik_Forms_Group__c, AS_Quik_Forms_Group__r.Id 
                            FROM AS_Quik_Forms__c 
                            WHERE UNID__c =: response.ResultData.UNID LIMIT 1];
                    isExist = true;
                } catch(Exception e) {                   
                }
                form.Account_Servicing__c = asRecordId;
                form.Form_HTML_URL__c = response.ResultData.HTML;
                form.Form_Numbers__c = quikFormIds;
                form.UNID__c = response.ResultData.UNID;
                form.FAS_Id_List__c = fasIdsToStoreInQuikForm;
                form.FAS_List__c = asFasNamesToStoreInQuikForm;
                form.Form_No_with_Ids__c = formNumWithRecId;
                if(form.Form_For__c == null)
                    form.Form_For__c = 'Print';
                if(formType == 'Sign') {
                    form.Form_For__c = 'Sign';
                    if(fasRecordId != '') {
                        form.Financial_Account_Servicing__c = fasRecordId;
                    }
                    form.UniqueId__c =  uniqueId;
                }
                if(custodianName != NULL && custodianName != '') {
                    form.Custodian__c = custodianName;
                }
                if(custodianInfoForQF != NULL && custodianInfoForQF != '') {
                    form.Custodian_Info__c = custodianInfoForQF;
                }
                upsert form UNID__c;
                returnVal = '{"UNID" : "' + response.ResultData.UNID + '", "URL" : "' + form.Form_HTML_URL__c+'", "recId" : "' + form.Id + '"}';
                Attachment att = new Attachment();
                att.Body = Blob.valueOf(reqBody);
                att.Name = 'QuikForm_' + DateTime.Now().getTime() + '.txt';
                try {
                    att.id = [SELECT ID FROM Attachment WHERE parentID =: form.ID AND Name LIKE 'QuikForm_%'].ID;
                    update att;
                } catch(Exception e) {                  
                    att.parentId = form.Id;
                    insert att;
                }
                if(HTMLBody != '' && HTMLBody != NULL) {
                    Attachment attHtml = new Attachment();
                    attHtml.Body = Blob.valueOf(HTMLBody);
                    attHtml.Name = 'HTML_QuikForm_' + DateTime.Now().getTime() + '.txt';
                    try {
                        attHtml.id = [SELECT ID FROM Attachment WHERE parentID =: form.ID AND Name LIKE 'HTML_QuikForm_%'].ID;
                        update attHtml;
                    } catch(Exception e) {                  
                        attHtml.parentId = form.Id;
                        insert attHtml;
                    }
                }
                String qfRec = form.AS_Quik_Forms_Group__r.Id;
                if(qfRec != null && qfRec != '') {
                    AS_Quik_Forms_Group__c asQfRec = [SELECT Callout_Status__c 
                                                      FROM AS_Quik_Forms_Group__c 
                                                      WHERE Id = :qfRec];
                    asQfRec.Callout_Status__c = 'Completed';
                    update asQfRec;
                }
            }
            return returnVal;  
        } catch(exception e) {
            QuikErrorLogGeneration.createErrorLog(reqBody, '', '', e.getMessage(),'QuikGenerateFormRequest','doCallout',e.getLineNumber());
            return null;
        }
    }
    
    public static String mergeFields(Sobject asRecord, Quik_Mapping__c record) {
        String mergeFieldValue = '';
        if(!record.WEG_SF_Reference__c.contains('.')) {
            mergeFieldValue = ''+asRecord.get(record.WEG_SF_Reference__c);
        } else {
            try {
                List<String> childObjects = new List<String>();
                childObjects = record.WEG_SF_Reference__c.split('\\.');
                if(childObjects.size() == 2) {
                    mergeFieldValue = ''+asRecord.getSobject(childObjects[0]).get (childObjects[1]);
                }
                if(childObjects.size() == 3) {
                    mergeFieldValue = ''+asRecord.getSobject(childObjects[0]).getSobject (childObjects[1]).get (childObjects[2]);
                }
                if(childObjects.size() == 4) {
                    mergeFieldValue = ''+asRecord.getSobject(childObjects[0]).getSobject (childObjects[1]).getSobject (childObjects[2]).get (childObjects[3]);
                }
                if(childObjects.size() == 5) {
                    mergeFieldValue = ''+asRecord.getSobject(childObjects[0]).getSobject (childObjects[1]).getSobject (childObjects[2]).getSobject (childObjects[3]).get (childObjects[4]);
                }
            } catch(Exception e) {}
        }
        if(mergeFieldValue == null || mergeFieldValue == 'null')
            mergeFieldValue = '';
        mergeFieldValue = mergeFieldValue.replace('\"','\\"');
        return mergeFieldValue;
    }
    
    public static String getHTMLFromQuik(String unId, Integer count) {
        String returnHTML = '';
        Quik_API__mdt logins = [SELECT Endpoint__c FROM Quik_API__mdt WHERE developerName = 'HTMLSettings'];
        HTTPRequest req = new HTTPRequest();
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + QuikFormHandler.getAccessToken());
        req.setHeader('content-type', 'application/json');
        req.setEndpoint(logins.Endpoint__c + unId);        
        req.setTimeout(120000);
        HTTP http = new HTTP();
        HTTPResponse res = new HTTPResponse();
        try {
            if(!Test.isRunningTest()) {
                res = http.send(req);
            }
            if(res.getStatusCode() != 200) {
                if(count == 3) {
                    QuikErrorLogGeneration.createErrorLog('', res.getBody(), '', '', 'QuikGenerateFormRequest', 'getHTMLFromQuik', null);
                } else {
                    count++;
                    getHTMLFromQuik(unId, count);
                }
            }
        } catch(Exception exc) {
            QuikErrorLogGeneration.createErrorLog('', res.getBody(), '', exc.getMessage(), 'QuikGenerateFormRequest', 'getHTMLFromQuik', 
                                                  exc.getLineNumber());
        }
        if(res.getStatusCode() == 200) {
            Map <String, Object> jsonRes = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            returnHTML = String.valueOf(jsonRes.get('ResultData'));
        }
        return returnHTML;
    }
}