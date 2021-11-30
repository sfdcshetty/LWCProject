public class QuikGenerateFormRequest_Print {
    
    public static String generateRequestBody(String selectedFormsJSON, String unId, ID asRecId, String formType) {
        if(unId != NULL && unId != '') {
            try {
                AS_Quik_Forms__c quikForm = new AS_Quik_Forms__c ();
                quikForm = [SELECT UNID__c, Form_HTML_URL__c FROM AS_QUik_Forms__c WHERE UNID__c = :unId LIMIT 1];
                return '{"UNID" : "' + quikForm.UNID__c + '", "URL" : "' + quikForm.Form_HTML_URL__c + '", "recId" : "' 
                    + quikForm.Id + '"}';
            } catch(Exception e) {
                return generateRequestBody (selectedFormsJSON, '', asRecId, formType);
            }
        } else {
            try {
                String custodianName = '';
                QuikSelectedForms_REQ obj = QuikSelectedForms_REQ.parse(selectedFormsJSON);
                List<ID> recIds = new List<ID>();
                String quikFormIds = '';
                String formFields = '';
                ID asRecordId = null;
                Map<String, Integer> fileCountIdMap = new Map<String, Integer>();
                String objectName = '';
                for(QuikSelectedForms_REQ.cls_results res : obj.results) {
                    String selectedObjectName = Id.valueOf(res.Id).getSObjectType().getDescribe().getName();
                    objectName = selectedObjectName; 
                    if(selectedObjectName == 'Account_Servicing__c') {
                        asRecordId = res.Id;
                    } else {
                        recIds.add(res.Id);
                    }
                    for(QuikSelectedForms_REQ.cls_list rec : res.records) {
                        fileCountIdMap.put(rec.formId, Integer.valueOf(rec.fileCount));                    
                    }
                }
                for(String str : fileCountIdMap.keySet()) {
                    for(Integer i = 0; i < fileCountIdMap.get(str); i++) {
                        quikFormIds += str + ',';
                    }
                }
                
                List<Quik_AttachmentForms__mdt> attachmentForms = [SELECT MasterLabel, AS_Attachment_Form__c, FAS_Attachment_Form__c
                                                                   FROM Quik_AttachmentForms__mdt LIMIT 1];
                if(objectName == 'Account_Servicing__c' && attachmentForms != null&& attachmentForms[0].AS_Attachment_Form__c != null 
                   && attachmentForms[0].AS_Attachment_Form__c != '' && formType == 'Sign') 
                {
                       quikFormIds = quikFormIds + attachmentForms[0].AS_Attachment_Form__c +',';
                   }
                if(objectName != 'Account_Servicing__c' && attachmentForms != null && attachmentForms[0].FAS_Attachment_Form__c != null 
                   && attachmentForms[0].FAS_Attachment_Form__c != '' && formType == 'Sign') 
                {
                       quikFormIds = quikFormIds + attachmentForms[0].FAS_Attachment_Form__c +',';
                   }
                quikFormIds = quikFormIds.removeEnd(',');
                
                Map<String, List<Quik_Mapping__c>> mappings = new Map<String, List<Quik_Mapping__c>>();
                for(Quik_Mapping__c mapping : [SELECT WEG_Origin__c, WEG_Role_Name__c, WEG_Field_Name__c, WEG_SF_Reference__c 
                                               FROM Quik_Mapping__c]) 
                {
                    if(mappings.containsKey(mapping.WEG_Origin__c)) {
                        mappings.get(mapping.WEG_Origin__c).add(mapping);
                    } else {
                        mappings.put(mapping.WEG_Origin__c, new List<Quik_Mapping__c> {mapping});
                    }
                }
                Account_Servicing__c asRecord = new Account_Servicing__c();
                String asQuery = 'SELECT ';
                if(mappings.containskey('AS') && asRecordId != NULL) {
                    Set<String> fieldNames = new Set<String>();
                    for(Quik_Mapping__c record: mappings.get('AS')) {
                        fieldNames.add(record.WEG_SF_Reference__c);               
                    }
                    for(String field : fieldNames) {
                        asQuery += field + ',';
                    }
                    asQuery = asQuery.removeEnd(',');
                    asQuery += ' FROM Account_Servicing__c WHERE Id =: asRecordId';
                    asRecord = Database.query(asQuery);
                    if(asRecord.Id != NULL) {
                        for(String str : fileCountIdMap.keySet()) {                        
                            for(Quik_Mapping__c record : mappings.get('AS')) {
                                
                                formfields += '{"FieldName" : "' + record.WEG_Role_Name__c 
                                    + '.' + record.WEG_Field_Name__c 
                                    + '", "FieldValue" : "' + QuikGenerateFormRequest.mergeFields(asRecord, record) + '"},';
                            }
                            //We have to add form fields based upon the count
                            if(fileCountIdMap.get(str) > 1) {
                                for(Quik_Mapping__c record : mappings.get('AS')) {
                                    for(Integer i = 1; i < fileCountIdMap.get(str); i++) {
                                        formfields += '{"FieldName" : "' + record.WEG_Role_Name__c 
                                            + '.' + record.WEG_Field_Name__c + '-' + i 
                                            + '", "FieldValue" : "' + QuikGenerateFormRequest.mergeFields(asRecord, record) + '"},';
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
                        fieldNames.add(record.WEG_SF_Reference__c);               
                    }
                    fieldNames.add('WEG_Custodian__c');
                    for(String field : fieldNames) {
                        fasQuery += field + ',';
                    }
                    fasQuery = fasQuery.removeEnd(',');
                    fasQuery += ' FROM Financial_Account_Servicing__c WHERE Id IN: recIds Order By CreatedDate DESC';
                    fasRecords = database.query (fasQuery);
                    if(fasRecords.size() > 0) {
                        if(formfields != '') {
                            formfields += ',';
                        }
                        Integer groupNum = 0;
                        for(Financial_Account_Servicing__c serv : fasRecords) {
                            custodianName = serv.WEG_Custodian__c;
                            for(String str : fileCountIdMap.keySet()) {
                                for(Quik_Mapping__c record : mappings.get('FAS')) {
                                    String groupNumber = '';
                                    if(serv.Quik_Group_Number__c != NULL && groupNum != 0 && formType != 'Sign') {
                                        groupNumber = '-' + groupNum;
                                    }
                                    formfields += '{"FieldName" : "' + record.WEG_Role_Name__c 
                                        + '.' + record.WEG_Field_Name__c 
                                        + groupNumber 
                                        + '", "FieldValue" : "' + QuikGenerateFormRequest.mergeFields(serv, record) + '"},';
                                    //We have to add form fields based upon the count
                                    if(fileCountIdMap.get(str) > 1) {
                                        for(Integer i = 1; i < fileCountIdMap.get(str); i++) {
                                            formfields += '{"FieldName" : "' + record.WEG_Role_Name__c 
                                                + '.' + record.WEG_Field_Name__c 
                                                + groupNumber + '-' + i 
                                                + '", "FieldValue" : "' + QuikGenerateFormRequest.mergeFields(serv, record) + '"},';
                                        }
                                    }
                                }
                                groupNum = groupNum + 1000;    
                            }
                        }
                        formfields = formfields.removeEnd(',');
                    }
                }
                
                quikFormIds = quikFormIds.removeEnd('-');
                Quik_API__mdt mdtSettings = [SELECT HTMLSettings__c FROM Quik_API__mdt WHERE developerName = 'HTMLSettings'];
                String htmlSettings = mdtSettings.HTMLSettings__c;
                htmlSettings = htmlSettings.replace('##EXPIRE_DATE##', DateTime.Now().addDays(180).format());
                htmlSettings = htmlSettings.replace('##QUIK_IDS##', quikFormIds);
                htmlSettings = htmlSettings.replace ('##UN_ID##', unId);
                htmlSettings = htmlSettings.replace('##FORM_FIELDS##', '[' + formfields + ']');
                Datetime dt = Datetime.now();
                Long l = dt.getTime();
                String uniqueId = userinfo.getUserId()+String.valueOf(l);
                htmlSettings = htmlSettings.replace('UNIQUEID1', uniqueId);
                htmlSettings = htmlSettings.replace('##DISABLE_ATTACHMENT##', 'true');
                htmlSettings = htmlSettings.replace('##ENABLE_ESIGN_EDITS##', 'false');
                htmlSettings = htmlSettings.replace('##EDIT_TYPE##', 'EmptyFields');
                htmlSettings = htmlSettings.replace('##FIELDS_REQUIRED##', '');
                String signerFields = '"Signers": [{"Order": 1, "Role": "1own", "SendType": "EmailToSign", "AuthTypes": "NoIDCheck"},';
                signerFields += '{"Order": 2, "Role": "2own", "SendType": "EmailToSign", "AuthTypes":"NoIDCheck"},';
                signerFields += '{"Order": 3, "Role": "1rep", "SendType": "EmailToSign", "AuthTypes":"NoIDCheck"}]';
                htmlSettings = htmlSettings.replace('##RECIPIENTS_ORDER##', signerFields);
                htmlSettings = htmlSettings.replace('##EXTRA_RECIPIENTS_INFO##', '');
                System.debug(':::finalhtmlsettings:: ' + htmlSettings);
                String fasRecId = '';
                if(recIds.size() > 0) {
                    fasRecId = String.valueOf(recIds[0]);
                }
                return doCallOut(asRecId, fasRecId, htmlSettings, quikFormIds, custodianName, uniqueId, formType);
            }
            catch (exception e){
                QuikErrorLogGeneration.createErrorLog('', '', '', e.getMessage(), 'QuikGenerateFormRequest_Print', 
                                                      'generateRequestBody', e.getLineNumber());
                return null;
            }
        }
    }
    
    public static String doCallout(ID asRecordId, String fasRecordId, String reqBody, String quikFormIds, 
                                   String custodianName, String uniqueId, String formType) 
    {
        try {
            String returnVal = '';
            Quik_API__mdt logins = [SELECT Endpoint__c FROM Quik_API__mdt WHERE developerName = 'HTMLLogins'];
            HTTPRequest req = new HTTPRequest ();
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + QuikFormHandler.getAccessToken());
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
                QuikErrorLogGeneration.createErrorLog(reqBody, res.getBody(), '', '', 'QuikGenerateFormRequest_Print', 'doCallout', 241);
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
                String htmlBody = QuikGenerateFormRequest.getHTMLFromQuik(url, 0);
                Boolean isExist = false;
                AS_Quik_Forms__c form = new AS_Quik_Forms__c();
                try {
                    form = [SELECT UNID__c,Form_For__c FROM AS_Quik_Forms__c WHERE UNID__c =: response.ResultData.UNID LIMIT 1];
                    isExist = true;
                } catch (Exception e) {                   
                }
                form.Account_Servicing__c = asRecordId;
                form.Form_HTML_URL__c = response.ResultData.HTML;
                form.Form_Numbers__c = quikFormIds;
                form.UNID__c = response.ResultData.UNID;
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
                upsert form UNID__c;
                returnVal = '{"UNID" : "' + response.ResultData.UNID + '", "URL" : "' + form.Form_HTML_URL__c + '", "recId" : "' 
                    + form.Id + '"}';
                Attachment att = new Attachment();
                att.Body = Blob.valueOf(reqBody);
                att.Name = 'QuikForm_' + DateTime.Now().getTime() + '.txt';
                try {
                    att.id = [SELECT ID FROM Attachment WHERE parentID =: form.ID AND Name LIKE 'QuikForm_%'].ID;
                    update att;
                }
                catch(Exception e) {                  
                    att.parentId = form.Id;
                    insert att;
                }
                if(HTMLBody != '' && HTMLBody != NULL) {
                    Attachment attHtml = new Attachment ();
                    attHtml.Body = Blob.valueOf (HTMLBody);
                    attHtml.Name = 'HTML_QuikForm_' + DateTime.Now().getTime() + '.txt';
                    try {
                        attHtml.id = [SELECT ID FROM Attachment WHERE parentID =: form.ID AND Name LIKE 'HTML_QuikForm_%'].ID;
                        update attHtml;
                    }
                    catch (Exception e) {                  
                        attHtml.parentId = form.Id;
                        insert attHtml;
                    }
                }
            }
            return returnVal;  
        }
        catch(exception e) {
            QuikErrorLogGeneration.createErrorLog(reqBody, '', '', e.getMessage(), 'QuikGenerateFormRequest_Print', 
                                                  'doCallout', e.getLineNumber());
            return null;
        }
    }
}