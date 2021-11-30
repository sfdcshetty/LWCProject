public class QuikHTML_RESP{
    public cls_ResultData ResultData;
    public Integer ErrorCode;   //0
    public String Message;  //Forms generated successfully.
    public cls_Errors Errors;
    public class cls_ResultData {
        public String UNID; //sh2ajtGYO2JHSuG%2fqXzUs%2f%2fvxXO0tI4Ronj4LwZ7MzmSTBNr7ET2E3LLJknp1Yfe
        public String HTML; //https://quikforms.com/viewform/zqTZ-wrkuTag4
        public String FormIDs;  //918
    }
    public class cls_Errors {
    }
    public static QuikHTML_RESP parse(String json){
        return (QuikHTML_RESP) System.JSON.deserialize(json, QuikHTML_RESP.class);
    }
    /*
    static testMethod void testParse() {
        String json=        '{'+
        '  "ResultData": {'+
        '    "UNID": "sh2ajtGYO2JHSuG%2fqXzUs%2f%2fvxXO0tI4Ronj4LwZ7MzmSTBNr7ET2E3LLJknp1Yfe",'+
        '    "HTML": "https://quikforms.com/viewform/zqTZ-wrkuTag4",'+
        '    "FormIDs": "918"'+
        '  },'+
        '  "ErrorCode": 0,'+
        '  "Message": "Forms generated successfully.",'+
        '  "Errors": null'+
        '}';
        QuikHTML_RESP obj = parse(json);
        System.assert(obj != null);
    }*/
}