public class QuikForms_RESP{
    public cls_ResultData ResultData;
    public Integer ErrorCode;   //0
    public String Message;  //
    public class cls_ResultData {
        public Integer PageNumber;  //1
        public Integer PageSize;    //5
        public Integer TotalCount;  //110
        public cls_Result[] Result;
    }
    public class cls_Result {
        public Integer FormID;  //940
        public String DealerName;   //Charles Schwab & Co., Inc.
        public String FormShortName;    //Transfer of Account
        public String FormDesc; //Transfer assets from a different custodian to Schwab
        public String PublishDate;  //2019-06-13T14:09:46.923
        public String RevisionDate; //2016-11-01T00:00:00
        public Integer FileSize;    //452803
        public String LitNo;    //APP10864-26
        public Integer NoPages; //6
        public String DealerStatus; //Active
        public String FormThumbnail;    //https://dq6apn6hy8vc6.cloudfront.net/prod/forms/publish/current/t940_1_22.png?Expires=1565416544&Signature=g9vMBkNH8WxjrHtmfB-kfSchDZ747Jf7gE0WkaOKRjQCb2B3~1crefn6cqLtpj7IrrUgL4FUfgXYwiZtmWxVlha8NLikg-8HMUHBfpQwkF~8tVEPvMTlnNUMStSqFE3ikTRV2cQkLb0PgyK1BIQ~bjq00ibvXMR3rx46tPM~cAc_&Key-Pair-Id=APKAIO63VAHYK7C5DQRQ
        public boolean IsESignable;
        public Integer SignFieldsCount; //3
    }
    public static QuikForms_RESP parse(String json){
        return (QuikForms_RESP) System.JSON.deserialize(json, QuikForms_RESP.class);
    }

    
}