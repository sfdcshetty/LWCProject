public class QuikFormHandler {
    
    public class QuikFormRecords {
        @AuraEnabled
        public List<AS_Quik_Forms__c> asForms;
        @AuraEnabled
        public Boolean allowEsign; 
        public QuikFormRecords() {
            asForms = new List<AS_Quik_Forms__c>();
            allowEsign = false;
        }
    }
    
    public class FormRecordsPagination {
        @AuraEnabled
        public List<QuikForms> asForms;
        @AuraEnabled
        public Integer totalRecords; 
        @AuraEnabled
        public Integer totalpage;
        public FormRecordsPagination(List<QuikForms> formList, Integer totalRecordsCount, Integer totalNumberOfPage) {
            asForms = formList;
            totalRecords = totalRecordsCount;
            totalpage = totalNumberOfPage;
        }
    }
    
    @AuraEnabled
    public static QuikFormRecords displayASQuikFormRecords(String accServRecId, String formType) {
        List<AS_Quik_Forms__c> asQuikFormsList = [SELECT Custodian__c, Form_Numbers__c, LastModifiedDate, CreatedDate, Form_HTML_URL__c, 
                                                  AS_Quik_Forms_Group__r.DocuSign_Envelope_Status__c
                                                  FROM AS_Quik_Forms__c
                                                  WHERE Account_Servicing__c = :accServRecId 
                                                  AND (Form_For__c = null OR Form_For__c = :formType) 
                                                  ORDER By LastModifiedDate DESC LIMIT 5];
        QuikFormRecords obj = new QuikFormRecords();
        obj.asForms = asQuikFormsList;
        obj.allowEsign = [SELECT Allow_eSign__c FROM USER WHERE ID = :userinfo.getuserid()].Allow_eSign__c;
        return obj;
    }
    
    @AuraEnabled
    public static String deleteASQuikForm(String asQuikFormId) {
        AS_Quik_Forms__c ASQuikForm = [SELECT Id FROM AS_Quik_Forms__c WHERE Id = :asQuikFormId];
        try {
            delete ASQuikForm;
            return 'success';
        } catch(Exception e) {
            return e.getMessage();
        }
    }
    
    @AuraEnabled
    public static List<AS_Quik_Forms__c> getASFormGroupRecords(Id RecordId) {
        List<AS_Quik_Forms__c> asQuikFormList = [SELECT Id, AS_Quik_Forms_Group__c, Form_Numbers__c, AS_Quik_Forms_Group__r.Name, 
                                                 AS_Quik_Forms_Group__r.LastModifiedDate, AS_Quik_Forms_Group__r.CreatedDate, 
                                                 AS_Quik_Forms_Group__r.DocuSign_Envelope_Status__c 
                                                 FROM AS_Quik_Forms__c 
                                                 WHERE Account_Servicing__c = :RecordId AND AS_Quik_Forms_Group__c != null 
                                                 ORDER BY AS_Quik_Forms_Group__r.CreatedDate DESC LIMIT 5];
        return asQuikFormList;
    }
    
    @AuraEnabled
    public static String generateHTML_Print(String jsonBody, String urlId, Id recordId, String formType) {
        if(urlId == NULL) {
            urlId = '';
        }
        return QuikGenerateFormRequest_Print.generateRequestBody(jsonBody, urlId, recordId, formType);
    }
    
    @AuraEnabled
    public static String generateHTML(String jsonBody, String urlId, Id recordId, String asFasFormIdsMap, String formType) {
        if(urlId == NULL) {
            urlId = '';
        }
        Map<String, String> allFormsInfo = (Map<String, String>)JSON.deserialize(asFasFormIdsMap, Map<String, String>.class);
        return QuikGenerateFormRequest.generateRequestBody(jsonBody, urlId, recordId, formType, allFormsInfo);
    }
    
    @AuraEnabled
    public static List<SObject> getRecords(Id asRecordId) {
        List<SObject> records = new List<SObject>();
        Account_Servicing__c asRecord = [SELECT Name FROM Account_Servicing__c WHERE Id = :asRecordId];
        records.add(asRecord);
        for(Financial_Account_Servicing__c fas : [SELECT Name, WEG_Custodian__c FROM Financial_Account_Servicing__c 
                                                  WHERE Account_Servicing__c = :asRecordId])
        {
            records.add(fas);
        }
        return records;
    }
    
    @AuraEnabled
    public static List<Form_Bundle__c> getBundleGroups() {     
        return [SELECT Name FROM Form_Bundle__c WHERE Active__c = true];
    }
    
    @AuraEnabled
    public static List<Form_Bundle__c> getBundleGroupsSign() {     
        return [SELECT Name FROM Form_Bundle__c WHERE Active__c = true AND WEG_E_Signable__c = true];
    }
    
    public class quikBundleForms {
        @AuraEnabled
        public string formId;
        @AuraEnabled
        public string formShortName;
        @AuraEnabled
        public string formDesc;
        @AuraEnabled
        public string dealerName;
        @AuraEnabled
        public String iconName;
        @AuraEnabled
        public Integer pageSize { get; set; }
        @AuraEnabled
        public Integer pageNumber { get; set; }
        @AuraEnabled
        public Integer totalRecords { get; set; }
        @AuraEnabled
        public Integer recordStart { get; set; }
        @AuraEnabled
        public Integer recordEnd { get; set; }
    }
    
    @AuraEnabled
    public static List<quikBundleForms> getForms(String bundleId, Integer pageNumber, Integer pageSize, String Type) {
        List<quikBundleForms> recordsToReturn = new List<quikBundleForms>();
        Integer offset = (pageNumber - 1) * pageSize;
        Integer recordEnd = pageSize * pageNumber;
        Integer totalRecords = 0;            
        if(bundleId != 'All') {
            totalRecords = [SELECT Count() FROM Bundled_Forms__c WHERE Form_Bundle__c = :bundleId];
            for(Bundled_Forms__c bundle : [SELECT Quik_Form__r.Name, Quik_Form__r.Custodian__c, Quik_Form__r.Description__c, E_Signable__c, 
                                           Quik_Form__r.Form_Name__c FROM Bundled_Forms__c WHERE Form_Bundle__c = :bundleId 
                                           ORDER BY WEG_Sort__c ASC LIMIT :pageSize OFFSET :offset]) 
            {
                quikBundleForms obj = new quikBundleForms();
                obj.formId = bundle.Quik_Form__r.Name;
                obj.dealerName = bundle.Quik_form__r.Custodian__c;
                obj.formDesc = bundle.Quik_Form__r.Description__c;
                obj.formShortName = bundle.Quik_Form__r.Form_Name__c;
                obj.iconName = 'utility:add';
                obj.pageSize = pageSize;
                obj.pageNumber = pageNumber;
                obj.recordStart = offset + 1;
                obj.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
                obj.totalRecords = totalRecords;
                if((Type == 'Sign' && bundle.E_Signable__c == true) || (Type == 'Print'))
                {
                    recordsToReturn.add(obj);
                }
            }
        } else {
            totalRecords = [SELECT Count() FROM Quik_Form__c];
            if(Type == 'Sign') {
                for(Quik_Form__c bundle : [SELECT Name, Form_Name__c, Custodian__c, Description__c 
                                           FROM Quik_Form__c WHERE Is_ESignable__c = true ORDER BY Name ASC 
                                           LIMIT :pageSize OFFSET :offset]) 
                {
                    quikBundleForms obj = new quikBundleForms();
                    obj.formId = bundle.Name;
                    obj.dealerName = bundle.Custodian__c;
                    obj.formDesc = bundle.Description__c;
                    obj.formShortName = bundle.Form_Name__c;
                    obj.iconName = 'utility:add';
                    obj.pageSize = pageSize;
                    obj.pageNumber = pageNumber;
                    obj.recordStart = offset + 1;
                    obj.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
                    obj.totalRecords = totalRecords;
                    recordsToReturn.add(obj);
                }
            } else if(Type == 'Print') {
                Map<String, quikBundleForms> recordsToReturnMap = new Map<String, quikBundleForms>();
                for(Quik_Form__c bundle : [SELECT Name, Form_Name__c, Custodian__c, Description__c 
                                           FROM Quik_Form__c ORDER BY Name ASC 
                                           LIMIT :pageSize OFFSET :offset]) 
                {
                    quikBundleForms obj = new quikBundleForms();
                    obj.formId = bundle.Name;
                    obj.dealerName = bundle.Custodian__c;
                    obj.formDesc = bundle.Description__c;
                    obj.formShortName = bundle.Form_Name__c;
                    obj.iconName = 'utility:add';
                    obj.pageSize = pageSize;
                    obj.pageNumber = pageNumber;
                    obj.recordStart = offset + 1;
                    obj.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
                    obj.totalRecords = totalRecords;
                    recordsToReturnMap.put(bundle.Name, obj);
                }
                for(String str : recordsToReturnMap.keySet()) {
                    recordsToReturn.add(recordsToReturnMap.get(str));
                }
            }
        }
        return recordsToReturn;
    }
    
    public class QuikCategories {
        @AuraEnabled
        public String categoryId;
        @AuraEnabled
        public String categoryCode;
        @AuraEnabled
        public String categoryName;
    }
    
    //Method to get the categories from the QUIK API, based on the category count that is mentioned in the QUIK API Metadata
    @AuraEnabled
    public static List<QuikCategories> getCategories() {
        List<Quik_Form__c> catList = [SELECT Category__c FROM Quik_Form__c];
        Set<String> catSet = new Set<String>();
        for(Quik_Form__c qf : catList) {
            catSet.add(qf.Category__c);
        }
        catSet.remove('');
        catSet.remove(null);
        List<QuikCategories> categories = new List<QuikCategories>();
        for(String data : catSet) {
            QuikCategories qc = new QuikCategories();
            qc.categoryId = '';
            qc.categoryCode = '';
            qc.categoryName = data;
            categories.add(qc);
        }
        return categories;
    }
    
    public class QuikDealers {
        @AuraEnabled
        public String dealerId;
        @AuraEnabled
        public String dealerName;
    }
    
    //Method to get the dealers from Quik API
    @AuraEnabled
    public static List<QuikDealers> getDealers() {
        Quik_API__mdt logins = [SELECT Endpoint__c, Categories_Count__c FROM Quik_API__mdt WHERE DeveloperName = 'Logins'];
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint (logins.Endpoint__c + 'dealers');
        req.setMethod ('GET');
        req.setHeader ('Authorization', 'Bearer ' + getAccessToken());
        req.setHeader ('Content-Type', 'application/json');
        req.setTimeout(120000);
        HTTP http = new HTTP();
        HTTPResponse res = new HTTPResponse();
        try {
            if(!Test.isRunningTest()) {
                res = http.send(req);
            }
            if(res.getStatusCode() != 200) {
                QuikErrorLogGeneration.createErrorLog('', res.getBody(), '', '', 'QuikFormHandler', 'getDealers', null);
            }
        } catch(Exception exc) {
            QuikErrorLogGeneration.createErrorLog('', res.getBody(), '', exc.getMessage(), 'QuikFormHandler', 'getDealers', exc.getLineNumber());
        }
        if(Test.isRunningTest()) {
            res.setStatusCode (200);
            res.setBody ('{"ResultData":[{"DealerID": 29,"DealerName": "Charles Schwab & Co., Inc.","DealerStatusID": 1,"DealerStatus": "Active","IsMyCompany": true}]}');
        }
        List<QuikDealers> dealers = new List<QuikDealers>();
        if(res.getStatusCode () == 200) {
            QuikDealers_RESP obj = QuikDealers_RESP.parse(res.getBody());
            for(QuikDealers_RESP.cls_ResultData data : obj.ResultData) {
                if(data.DealerStatus == 'Active') {
                    QuikDealers qd = new QuikDealers();
                    qd.dealerId = String.valueOf(data.DealerID);
                    qd.dealerName = data.DealerName;
                    dealers.add(qd);
                }
            }
        }
        return dealers;
    }
    
    public class QuikForms {
        @AuraEnabled
        public String formId { get; set; }
        @AuraEnabled
        public String formShortName { get; set; }
        @AuraEnabled
        public String formDesc { get; set; }
        @AuraEnabled
        public String dealerName { get; set; }
        @AuraEnabled
        public Integer totalCount { get; set; }
        @AuraEnabled
        public Integer pageSize { get; set; }
        @AuraEnabled
        public String iconName { get; set; }
        @AuraEnabled
        public String fileCount { get; set; }
    }
    
    public static String getAccessToken() {
        Quik_API__mdt logins = [SELECT Endpoint__c, User_Name__c, Password__c, Authentication_URL__c, Categories_Count__c 
                                FROM Quik_API__mdt WHERE DeveloperName = 'Logins'];
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint(logins.Authentication_URL__c);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setMethod('POST');
        req.setTimeOut(120000);
        req.setBody('grant_type=password&username=' + logins.User_Name__c + '&password=' + logins.Password__c);        
        HTTP http = new HTTP();
        HTTPResponse res = new HTTPResponse();
        try {
            if(!Test.isRunningTest()) {
                res = http.send(req);
            }
            if(res.getStatusCode() != 200) {
                QuikErrorLogGeneration.createErrorLog(req.getBody(), res.getBody(), '', '', 'QuikFormHandler', 'getAccessToken', null);
            }
        } catch(Exception exc) {
            QuikErrorLogGeneration.createErrorLog(req.getBody(), res.getBody(), '', exc.getMessage(), 'QuikFormHandler', 
                                                  'getAccessToken', exc.getLineNumber());
        }
        String accessToken = '';
        if(!Test.isRunningTest()) {
            Map <String, Object> response = (Map <String, Object>) JSON.deserializeUntyped(res.getBody());
            accessToken = String.valueOf(response.get('access_token'));
        }
        return accessToken;
    }
    
    //Method to get the forms from QUIK based on the category, selected dealer, form name. 
    @AuraEnabled
    public static FormRecordsPagination searchForms_Sign(String formName, List<String> categoryIds, List<String> dealerIds, 
                                                         List<String> formIdsLoaded, String Type, String fileCountMap, 
                                                         Integer pageNumbersFormResult, Integer pageSize) 
    {
        Integer offSet = (pageNumbersFormResult - 1) * pageSize;
        Map<String, String> newMap= new Map<String, String>();
        if(!Test.isRunningTest()) {
            List<Object> result1 = (List<Object>)JSON.deserializeUntyped(fileCountMap);
            for(Object obj : result1) {
                String obj1 = String.valueOf(obj);
                String keyStr = obj1.subStringBetween('key=', ',');
                String valueStr = obj1.subStringBetween('value=', '}');
                newMap.put(keyStr, valueStr);
            }
        } else {
            newMap.put('12345', '1');
            newMap.put('12346', '2');
        }
        //Search functionality start
        List<QuikForms> forms = new List<QuikForms>();
        String searchQuery = '';
        if((formName == '' || formName == NULL) && dealerIds.size () == 0 && categoryIds.size () == 0) {
        } else {
            searchQuery += 'SELECT Name, Form_Name__c, Custodian__c, Description__c, Is_ESignable__c FROM Quik_Form__c';
        }
        if((formName != '' && formName != NULL) 
           || (dealerIds.size () > 0 && (dealerIds[0] != NULL && dealerIds[0] != '')) 
           || (categoryIds.size () > 0 && (categoryIds[0] != NULL && categoryIds[0] != ''))) {
               searchQuery += ' WHERE ';
           }
        if(formName != '' && formName != NULL) {
            searchQuery += ' (Form_Name__c LIKE \'%' + formName + '%\' OR Name LIKE \'%' + formName + '%\') AND';
        }
        if(dealerIds.size () > 0 && (dealerIds[0] != NULL && dealerIds[0] != '')) {
            searchQuery += ' Custodian__c IN :dealerIds AND';
        }
        if(categoryIds.size () > 0 && (categoryIds[0] != NULL && categoryIds[0] != '')) {
            searchQuery += ' Category__c IN :categoryIds AND';
        }
        searchQuery = searchQuery.removeEnd(' AND');
        List<Quik_Form__c> quikForm = new List<Quik_Form__c>();
        quikForm = Database.query(searchQuery);
        for(Quik_Form__c qf : quikForm) {
            if((Type == 'Sign' && qf.Is_ESignable__c == true)) {
                if(!formIdsLoaded.contains(qf.Name)) {
                    QuikForms form = new QuikForms();
                    form.formId = qf.Name;
                    form.dealerName = qf.Custodian__c;
                    form.formDesc = qf.Description__c;
                    form.formShortName = qf.Form_Name__c;
                    form.totalCount = quikForm.size();
                    form.pageSize = 10;
                    form.iconName = 'utility:add';
                    form.fileCount = '1';
                    forms.add(form);
                }
            }
        }
        Integer totalRecords = forms.size();
        Integer totalPages = totalRecords / pageSize;
        Integer totalFullPages = totalRecords / pageSize;
        Integer lastPageSize =  math.mod(totalRecords, pageSize);
        Integer lastFalf =  lastPageSize;
        if(lastPageSize != 0) {
            totalPages = totalPages + 1;
        }
        List<QuikForms> formsToReturn = new List<QuikForms>();
        if(pageNumbersFormResult <= totalFullPages) {
            for(Integer i = offSet; i < offSet + pageSize; i++) {
                formsToReturn.add(forms[i]);
            }
        } else if(pageNumbersFormResult == totalPages || totalFullPages != totalPages) {
            for(Integer i = offSet; i < offSet + lastFalf; i++) {
                formsToReturn.add(forms[i]);
            }  
        }
        FormRecordsPagination formList = new FormRecordsPagination(formsToReturn, totalRecords, totalPages);
        return formList;
    }
    
    @AuraEnabled
    public static FormRecordsPagination searchForms(String formName, List<String> categoryIds, List<String> dealerIds, Integer pageNumber, 
                                                    List<String> formIdsLoaded, String Type, Integer pageNumbersFormResult, Integer pageSize) 
    {
        //Search functionality starts
        Integer offSet = (pageNumbersFormResult - 1) * pageSize;
        List<QuikForms> forms = new List<QuikForms>();
        String searchQuery = '';
        if((formName == '' || formName == NULL) && dealerIds.size () == 0 && categoryIds.size () == 0) {
        } else {
            searchQuery += 'SELECT Name, Form_Name__c, Custodian__c, Description__c, Is_ESignable__c FROM Quik_Form__c';
        }
        if((formName != '' && formName != NULL) 
           || (dealerIds.size () > 0 && (dealerIds[0] != NULL && dealerIds[0] != '')) 
           || (categoryIds.size () > 0 && (categoryIds[0] != NULL && categoryIds[0] != ''))) {
               searchQuery += ' WHERE ';
           }
        if(formName != '' && formName != NULL) {
            searchQuery += ' (Form_Name__c LIKE \'%' + formName + '%\' OR Name LIKE \'%' + formName + '%\') AND';
        }
        if(dealerIds.size () > 0 && (dealerIds[0] != NULL && dealerIds[0] != '')) {
            searchQuery += ' Custodian__c IN :dealerIds AND';
        }
        if(categoryIds.size () > 0 && (categoryIds[0] != NULL && categoryIds[0] != '')) {
            searchQuery += ' Category__c IN :categoryIds AND';
        }
        searchQuery = searchQuery.removeEnd(' AND');
        List<Quik_Form__c> quikForm = new List<Quik_Form__c>();
        quikForm = Database.query(searchQuery);
        Map<String, Quik_Form__c> quikFormMap = new Map<String, Quik_Form__c>();
        for(Quik_Form__c qfRec : quikForm) {
            quikFormMap.put(qfRec.Name, qfRec);
        }
        for(Quik_Form__c qf : quikFormMap.values()) {
            if(Type == 'Print') {
                if(!formIdsLoaded.contains(qf.Name)) {
                    QuikForms form = new QuikForms();
                    form.formId = qf.Name;
                    form.dealerName = qf.Custodian__c;
                    form.formDesc = qf.Description__c;
                    form.formShortName = qf.Form_Name__c;
                    form.totalCount = quikForm.size();
                    form.pageSize = 10;
                    form.iconName = 'utility:add';
                    forms.add(form);
                }
            }
        }
        Integer totalRecords = forms.size();
        Integer totalPages = totalRecords / pageSize;
        Integer totalFullPages = totalRecords / pageSize;
        Integer lastPageSize = math.mod(totalRecords, pageSize);
        Integer lastFalf = lastPageSize;
        if(lastPageSize != 0){
            totalPages = totalPages + 1;
        }
        List<QuikForms> formsToReturn = new List<QuikForms>();
        if(pageNumbersFormResult <= totalFullPages) {
            for(Integer i = offSet; i < offSet + pageSize; i++) {
                formsToReturn.add(forms[i]);
            }
        } else if(pageNumbersFormResult == totalPages || totalFullPages != totalPages) {
            for(Integer i = offSet; i < offSet + lastFalf; i++) {
                formsToReturn.add(forms[i]);
            }  
        }
        FormRecordsPagination formList = new FormRecordsPagination(formsToReturn, totalRecords, totalPages);
        return formList;
    }
    
    @AuraEnabled
    public static Boolean getGroupId(Id FormId) {
        Boolean groupIdExists = false;
        AS_Quik_Forms__c form = [SELECT AS_Quik_Forms_Group__c FROM AS_Quik_Forms__c WHERE Id = :FormId];
        if(form.AS_Quik_Forms_Group__c != null) {
            groupIdExists = true;
        }
        return groupIdExists;
    }
    
    @AuraEnabled
    public static void deleteReceipients(Recipients__c recp) {
        Map<String, List<String>> recpsToDelete = new Map<String, List<String>>();
        List<String> recpId = new List<String>();
        if(recp.Docusign_Recipient_Id__c != null) {
            recpId.add(recp.Docusign_Recipient_Id__c);
            recpsToDelete.put(recp.envelope_id__c , recpId);
            try {
                Quik_SignUrl.callDeleteRecipients(recpsToDelete);
            } catch(Exception exc) {
                QuikErrorLogGeneration.createErrorLog('', '', '', exc.getMessage(), 'QuikFormHandler', 'deleteReceipients', exc.getLineNumber());
            }
        }
        if(recp.id != null) {
            try {
                delete recp;
            } catch(Exception exc) {
                QuikErrorLogGeneration.createErrorLog('', '', '', exc.getMessage(), 'QuikFormHandler', 'deleteReceipients', exc.getLineNumber());
            }
        }
    }
    
    @AuraEnabled
    public static Boolean callDocusign(String receipients) {
        Type receipientsType = Type.forName('List<Recipients__c>');
        List<Recipients__c> recipientsList = (List<Recipients__c>) JSON.deserialize(receipients, receipientsType);
        Set<Id> asFromGroupIds = new Set<Id>();
        Map<String, List<Recipients__c>> envWithRecipients = new Map<String, List<Recipients__c>>();
        Map<String, List<Quik_SignUrl.receipients>> envWithDocusignRec = new Map<String, List<Quik_SignUrl.receipients>>();
        List<AS_Quik_Forms_Group__c> formGroups = new List<AS_Quik_Forms_Group__c>();
        for(Recipients__c rec : recipientsList) {
            asFromGroupIds.add(rec.AS_Quik_Forms_Group__c); 
        }
        if(asFromGroupIds.size() > 0) {
            formGroups = [SELECT Docusign_Envelope_Id__c, Recipients_Size__c, DocuSign_Envelope_Status__c, 
                          Financial_Account_Servicing__r.WEG_Custodian_Info__r.WEG_eSign_Authorization_Type__c, 
                          (SELECT Id, Name__c, Email__c, Order__c, Sign_Type__c, Docusign_Recipient_Id__c, Phone_Number__c, Signer_Type__c, 
                           WEG_eSign_Authorization_Type__c, AS_Quik_Forms_Group__c, 
                           AS_Quik_Forms_Group__r.Financial_Account_Servicing__r.WEG_Custodian_Info__r.WEG_eSign_Authorization_Type__c
                           FROM Recipients__r WHERE Docusign_Recipient_Id__c != null ORDER BY Order__c ASC) 
                          FROM AS_Quik_Forms_Group__c WHERE Id IN :asFromGroupIds];
        }
        for(AS_Quik_Forms_Group__c asGroup : formGroups) {
            for(Recipients__c record : asGroup.Recipients__r) {
                if(envWithRecipients.containsKey(asGroup.Docusign_Envelope_Id__c)) {
                    envWithRecipients.get(asGroup.Docusign_Envelope_Id__c).add(record);
                } else {
                    envWithRecipients.put(asGroup.Docusign_Envelope_Id__c, new List<Recipients__c> { record });
                }
            }
        }
        List<Recipients__c> recipientsToUpdate = new List<Recipients__c>();  
        Docusign_Credentails__mdt mdtSettings = [SELECT Endpoint__c, Integrator_Key__c, User_Name__c, Password__c 
                                                 FROM Docusign_Credentails__mdt WHERE DeveloperName = 'Receipients'];
        for(String envpId : envWithRecipients.keyset()) {
            for(Recipients__c recp : envWithRecipients.get(envpId)) {
                Quik_SignUrl.receipients docSignRec = new Quik_SignUrl.receipients();
                docSignRec.receipientId = recp.Docusign_Recipient_Id__c;
                docSignRec.name = recp.Name__c;
                docSignRec.email = recp.Email__c;
                docSignRec.idCheckConfigurationName = recp.WEG_eSign_Authorization_Type__c;
                docSignRec.senderNumber = recp.Phone_Number__c;
                docSignRec.signType = recp.Sign_Type__c;
                docSignRec.signerType = recp.Signer_Type__c;
                try{
                    Quik_SignUrl.updateReceipients(envpId, new List<Quik_SignUrl.receipients> {docSignRec}, mdtSettings, recp.Sign_Type__c);
                } catch(Exception exc) {
                    QuikErrorLogGeneration.createErrorLog('', '', '', exc.getMessage(), 'QuikFormHandler', 'calldocusign', exc.getLineNumber());
                }
            }
        }
        List<AS_Quik_Forms_Group__c> asFormGroupToUpdate = new List<AS_Quik_Forms_Group__c>();
        List<AS_Quik_Forms_Group__c> asFormGroup = [SELECT DocuSign_Envelope_Status__c, UniqueId__c, 
                                                    (SELECT Docusign_Recipient_Id__c FROM Recipients__r Order BY Order__c ASC) 
                                                    FROM AS_Quik_Forms_Group__c WHERE Id IN: asFromGroupIds];
        List<String> uniqueEnvId = new List<String>();
        Boolean updateStatus = true;                                  
        for(AS_Quik_Forms_Group__c asformGrp : asFormGroup) {
            for(Recipients__c recp : asformGrp.Recipients__r) {
                if(recp.Docusign_Recipient_Id__c == null) {
                    updateStatus = false;
                }
            }
            if(updateStatus) {
                asformGrp.DocuSign_Envelope_Status__c = 'Ready to Send';
                asFormGroupToUpdate.add(asformGrp);
                uniqueEnvId.add(asformGrp.UniqueId__c);
            }
        }
        if(asFormGroupToUpdate.size() > 0) {
            try {
                update asFormGroupToUpdate; 
            } catch(Exception exc) {
                QuikErrorLogGeneration.createErrorLog('', '', '', exc.getMessage(), 'QuikFormHandler', 'calldocusign', exc.getLineNumber());
            }
        }
        return true;
    }
    
    @AuraEnabled
    public static Map<String, String> combineFormsBasedOnSigners(String asFasIds, String asFasArray) {
        Map<String, String> asFasFormsMap = (Map<String,String>)JSON.deserialize(asFasArray, Map<String, String>.class);
        List<String> asIdsList = new List<String>();
        List<String> fasIdsList = new List<String>();
        for(Id str : asFasIds.split(',')) {
            String objName = str.getSObjectType().getDescribe().getName();
            if(objName == 'Account_Servicing__c') {
                asIdsList.add(str);
            } else if(objName == 'Financial_Account_Servicing__c') {
                fasIdsList.add(str);
            }
        }
        Map<String, List<String>> sameSignersMap = new Map<String, List<String>>();
        for(Account_Servicing__c asRec : [SELECT WEGP1_Primary_Individual__r.Account.Name, WEGP1_Secondary_Individual__r.Account.Name 
                                          FROM Account_Servicing__c WHERE Id IN :asIdsList]) 
        {
            String finalStr = '';
            if(asRec.WEGP1_Primary_Individual__r.Account.Name != '' && asRec.WEGP1_Primary_Individual__r.Account.Name != null) {
                finalStr += 'Primary:' + asRec.WEGP1_Primary_Individual__r.Account.Name + ',';
            }
            if(asRec.WEGP1_Secondary_Individual__r.Account.Name != '' && asRec.WEGP1_Secondary_Individual__r.Account.Name != null) {
                finalStr += 'Secondary:' + asRec.WEGP1_Secondary_Individual__r.Account.Name;
            }
            if(sameSignersMap.containsKey(finalStr)) {
                sameSignersMap.get(finalStr).add(asRec.Id);
            } else {
                sameSignersMap.put(finalStr, new List<String> {asRec.Id});
            }
        }
        for(Financial_Account_Servicing__c fasRec : [SELECT Primary_Owner__r.Name, Joint_Owner__r.Name 
                                                     FROM Financial_Account_Servicing__c WHERE Id IN :fasIdsList]) 
        {
            String finalStr = '';
            if(fasRec.Primary_Owner__r.Name != '' && fasRec.Primary_Owner__r.Name != null) {
                finalStr += 'Primary:' + fasRec.Primary_Owner__r.Name + ',';
            }
            if(fasRec.Joint_Owner__r.Name != '' && fasRec.Joint_Owner__r.Name != null) {
                finalStr += 'Secondary:' + fasRec.Joint_Owner__r.Name;
            }
            if(sameSignersMap.containsKey(finalStr)) {
                sameSignersMap.get(finalStr).add(fasRec.Id);
            } else {
                sameSignersMap.put(finalStr, new List<String> {fasRec.Id});
            }
        }
        Map<String, String> recIdsWithForms = new Map<String, String>();
        for(String str : sameSignersMap.keySet()) {
            String recIds = '';
            String formIds = '';
            for(String idInList : sameSignersMap.get(str)) {
                recIds += idInList + ',';
                formIds += asFasFormsMap.get(idInList) + ',';
            }
            recIdsWithForms.put(recIds.removeEnd(','), formIds.removeEnd(','));
        }
        return recIdsWithForms;
    }
}