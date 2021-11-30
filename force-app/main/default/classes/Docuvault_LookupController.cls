global with sharing class Docuvault_LookupController {

    public Docuvault_LookupController (ApexPages.StandardSetController controller) {
    
    }
    
    public Docuvault_LookupController () {
    
    }
    global String getBucketName () {
        TVA_CFB__CloudFiles_Settings__c settings = TVA_CFB__CloudFiles_Settings__c.getInstance (UserInfo.getUserID ());
        return settings.TVA_CFB__Bucket_Name__c;
    }
    
    @remoteAction
    global static List <SObject> getlookupRecords (String objName,String recordTypeName, 
                                                   String searchableField , String pattern) {
        try {
            Id recordTypeId = null;
            Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe ();
            recordTypeId = gd.get (objName).getDescribe ().getRecordTypeInfosByName ().get (recordTypeName).getRecordTypeId ();
            
            String query = '';
            List <SObject> objList = NEW List <SObject> ();
            
            // SOSL Query Part
            if (!String.isNotBlank (searchableField)) {
                List<List<SObject>> advObjList = NEW List <List<SObject>> ();
                if (!String.isNotBlank (searchableField)) {
                    query = 'FIND {' + pattern + '*} IN ALL FIELDS RETURNING  '+objName;
                    query += '(Name ';
                    if (recordTypeId != NULL)
                        query += 'WHERE recordTypeId  =:recordTypeId ';
                    query += ') LIMIT 5' ;
                    
                    advObjList = search.query (query);
                    if (advObjList.size () > 0)
                        objList.addAll(advObjList[0]);
                
                }
            }
            
            // SOQL Query Part
            if (String.isNotBlank (searchableField)) {
                query = 'SELECT Id, Name FROM '+objName+' WHERE '+searchableField+' LIKE \'%'+pattern+'%\' ';
                if (recordTypeId != NULL)
                    query += ' AND recordTypeId =: recordTypeId' ;
                query += ' AND recordTypeId != NULL ORDER BY Name DESC limit 5 ';
                objList = Database.query (query);
            }
            return objList;
        } catch (Exception e) {
            return null;
        }
    }
    @remoteAction 
    global static String getAdvSearchRecords (String objName ,String recordTypeName, String pattern) {
        try {
            Id recordTypeId = null;
            Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
            recordTypeId = gd.get(objName).getDescribe ().getRecordTypeInfosByName ().get (recordTypeName).getRecordTypeId ();
            String baseURL = URL.getSalesforceBaseUrl ().toExternalForm ();
            List <Object> searchColumnsJSONString = NEW List <Object> ();
               
            HttpRequest req = new HttpRequest();
            req.setHeader ('Authorization', 'Bearer ' + UserInfo.getSessionID ());
            req.setHeader ('Content-Type', 'application/json');
            req.setEndpoint (baseURL+'/services/data/v41.0/search/layout?q='+objName);
            req.setMethod ('GET');
            
            Http httpConnection = new Http ();
            String responseBody = '';
            if(!Test.isRunningTest ()){
                HttpResponse res = httpConnection.send (req);
                responseBody = res.getBody ();
            }
            System.Debug (responseBody);
            if (Test.isRunningTest ()) {
                responsebody = '[{"searchColumns": [{"field": "Account.Name","format": null,"label": "Account Name","name": "Name"}]}]';
                responsebody = responsebody.replaceAll ('\n','').replaceAll ('\r','');

            }
            List <Object> jsonData = (List <Object>)JSON.deserializeUntyped (responseBody);
            JSONParser parser = JSON.createParser (responseBody);
            String querySearchFields = '';
            List <String> headerApi = NEW List <String>();
            List <String> headerLabels = NEW List<String>();
            while (parser.nextToken () != null) {
                if (parser.getCurrentToken () == JSONToken.FIELD_NAME ) { 
                    if (parser.getText () == 'searchColumns'){
                        if (parser.nextToken () == JSONToken.START_ARRAY) {
                            while (parser.nextToken () != null) {
                                if (parser.getCurrentToken () == JSONToken.FIELD_NAME ) {
                                    if (parser.getText () == 'name'){
                                        parser.nextToken ();
                                        querySearchFields  +=  parser.getText () +',';
                                        string header = parser.getText ();
                                        header  = header.replace ('toLabel(', '');
                                        header  = header.replace (')', '');
                                        headerApi.add (header) ;
                                    }
                                    if(parser.getText () == 'label'){
                                        parser.nextToken ();
                                        headerLabels.add (parser.getText ());
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            }
        
            querySearchFields = querySearchFields.substring (0,querySearchFields.length ()-1);
       
            List <SObject> advList = New List <Sobject> ();
            List <List <SObject>> advSearchRecordList = NEW List <List <SObject>> ();
            String query1 = '';   
            query1 = 'FIND {' + pattern + '*} IN ALL FIELDS RETURNING  '+objName;
            query1 += '(' + querySearchFields ;
            if (recordTypeId != NULL)
            query1 += ' WHERE recordTypeId  =:recordTypeId )';    
            System.Debug (query1);
            advSearchRecordList = search.query (query1);
           
            if (advSearchRecordList.size () > 0)
                advList.addAll (advSearchRecordList[0]);
           
            JSONGenerator gen = JSON.createGenerator (true);
            gen.writeStartObject ();
                gen.writeStringField ('records', JSON.serialize (advList));
                gen.writeStringField ('headers',  JSON.serialize (headerApi));
                gen.writeStringField ('headerlabels',  JSON.serialize (headerlabels));
            gen.writeEndObject ();
            
            
            String JSONBody = gen.getAsString ();
            System.Debug ('---jsonBody'+jsonBody);
            return JSONBody;
        
        }
        catch (Exception e){
            return null;
        
        }
    }
}