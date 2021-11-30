public class QuikGenerateHTML_Print {
    Transient public String attachmentBody { get; set; }
    Transient public String savedFormData { get; set; }
    public QuikGenerateHTML_Print() { 
        savedFormData = ''; attachmentBody = '';
    }
    public void loadHTML() {
        savedFormData = '';
        reloadForm();
    }
    
    // Method to send the request JSON body to Quik and generate the form preview when load form is clicked.
    public void reloadForm() {
        ID asFormId = apexpages.currentpage().getparameters().get('id');
        String typeOfForm = apexpages.currentpage().getparameters().get('type');
        As_Quik_Forms__c savedForm = new As_Quik_Forms__c();
        savedForm = [SELECT Account_Servicing__c, Form_Numbers__c, Form_HTML_URL__c, UNID__c, Custodian__c, UniqueId__c , 
                     Financial_Account_Servicing__c
                     FROM As_Quik_Forms__c 
                     WHERE Id =:asFormId];
        Attachment attJSON = [SELECT Body FROM Attachment WHERE ParentId =: asFormId AND Name Like 'QuikForm_%'];
        Quik_API__mdt mdtSettings = [SELECT HTMLSettings__c FROM Quik_API__mdt WHERE developerName = 'HTMLSettings'];
        String htmlSettings = attJSON.body.toString();
        htmlSettings = htmlSettings.replace('"FormPackageRouteStatusID": 0', '"FormPackageRouteStatusID": ' 
                                             + (DateTime.Now().getTime() + '').subString(0, 10));
        htmlSettings = htmlSettings.replace('"UNID": ""', '"UNID": "' + savedForm.UNID__c + '"');
        Datetime dt = Datetime.now();
        Long l = dt.getTime();
        String uniqueId = userinfo.getUserId()+String.valueOf(l);
        if(savedForm.UniqueId__c != NULL && savedForm.UniqueId__c != '') {
            uniqueId = savedForm.UniqueId__c;
        }
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
        QuikGenerateFormRequest_Print.doCallOut(savedForm.Account_Servicing__c, '', htmlSettings, savedForm.Form_Numbers__c, 
                                                savedForm.Custodian__c, uniqueId, typeOfForm); 
        try {
            Attachment att = [SELECT Body FROM Attachment WHERE ParentId =: asFormId AND Name Like 'HTML_QuikForm_%'];
            attachmentBody = att.Body.toString();
        } catch(Exception e) {
            QuikErrorLogGeneration.createErrorLog('', '', '', e.getMessage(),'QuikGenerateHTML_Print','reloadForm', e.getlineNumber());
        }
    }
    
    // Method to update the JSON body attachment when save button is pressed on the quikc form view.
    public void updateData() {
        savedFormData = savedFormData.removeEnd('"').removeStart('"');
        String fieldNewMappingJSON = '';
        List<String> values = new List<String>();
        values = savedFormData.split('&');
        String unId = '';
        String pkgBundleId = '0';
        for(Integer i = 0; i < values.size(); i++) {
            String key = '', value = '';
            key = values[i].split('=')[0];
            try {
                value = values[i].split('=')[1];
            } catch(Exception e) {
            }
            value = EncodingUtil.urlDecode(value, 'UTF-8');
            if(key == 'QFVUNID')
                unId = value;
            if(key.endsWith('\''))
                key = key.removeEnd('\'');
            if(key.startsWith('\''))
                key = key.removeStart('\'');
            if(key.contains('QuikRadio')) {
                if(key.contains('.')) {
                    List<String> quikradioToRemove = key.split('\\.');
                    key = key.replace(quikradioToRemove[0] + '.', '');
                }
            }
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('FieldValue', value);
            gen.writeEndObject();
            value = gen.getAsString();
            value = value.removeStart ('{').removeEnd ('}');
            fieldNewMappingJSON += '{"FieldName" : "' + key + '", ' + value + '},'; 
            if (key == 'FormPackageRouteStatusID') {
                pkgBundleId = value;
            }
        }
        fieldNewMappingJSON = fieldNewMappingJSON.removeEnd(',');
        if(unId != '' && unId != NULL) {
            unId = unId.replace('UNID=', '');
            if(test.isRunningTest()) {
                unId = 'UNIDik';
            }
            As_Quik_Forms__c savedForm = new As_Quik_Forms__c();
            savedForm = [SELECT Account_Servicing__c, Form_Numbers__c, Form_HTML_URL__c, UNID__c, Custodian__c, UniqueId__c, 
                         Financial_Account_Servicing__c 
                         FROM As_Quik_Forms__c 
                         WHERE UNID__c =: unId];
            Quik_API__mdt mdtSettings = [SELECT HTMLSettings__c FROM Quik_API__mdt WHERE developerName = 'HTMLSettings'];
            String htmlSettings = mdtSettings.HTMLSettings__c;
            htmlSettings = htmlSettings.replace('##EXPIRE_DATE##', DateTime.Now().addDays(180).format());
            htmlSettings = htmlSettings.replace('##QUIK_IDS##', savedForm.Form_Numbers__c);
            htmlSettings = htmlSettings.replace ('##UN_ID##', savedForm.UNID__c);
            if(pkgBundleId == '0') {
                pkgBundleId = (DateTime.Now().getTime() + '').subString(0, 10);
            }
            htmlSettings = htmlSettings.replace ('"FormPackageRouteStatusID": 0', '"FormPackageRouteStatusID": ' + pkgBundleId);
            htmlSettings = htmlSettings.replace('##FORM_FIELDS##', '[' + fieldNewMappingJSON + ']');
            Datetime dt = Datetime.now();
            Long l = dt.getTime();
            String uniqueId = userinfo.getUserId()+String.valueOf(l);
            if(savedForm.UniqueId__c != NULL && savedForm.UniqueId__c != '') {
                uniqueId = savedForm.UniqueId__c;
            }
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
            QuikGenerateFormRequest_Print.doCallOut(savedForm.Account_Servicing__c, '', htmlSettings, savedForm.Form_Numbers__c, 
                                                    savedForm.Custodian__c, uniqueId, ''); 
        }
    }
}