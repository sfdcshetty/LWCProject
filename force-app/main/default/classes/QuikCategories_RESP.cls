public class QuikCategories_RESP{
    public cls_ResultData[] ResultData;
    public Integer ErrorCode;   //0
    public String Message;  //
    public class cls_ResultData {
        public Integer FormCategoryID;  //1
        public String FormCategory; //ADM
        public String FormCategoryDesc; //Account Admin
    }
    public static QuikCategories_RESP parse(String json){
        return (QuikCategories_RESP) System.JSON.deserialize(json, QuikCategories_RESP.class);
    }

    
}