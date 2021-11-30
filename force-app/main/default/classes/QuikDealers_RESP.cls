public class QuikDealers_RESP{
    public cls_ResultData[] ResultData;
    public Integer ErrorCode;   //0
    public String Message;  //Dealers returned successfully
    public class cls_ResultData {
        public Integer DealerID;    //29
        public String DealerName;   //Charles Schwab & Co., Inc.
        public Integer DealerStatusID;  //1
        public String DealerStatus; //Active
        public boolean IsMyCompany;
    }
    public static QuikDealers_RESP parse(String json){
        return (QuikDealers_RESP) System.JSON.deserialize(json, QuikDealers_RESP.class);
    }

    
}