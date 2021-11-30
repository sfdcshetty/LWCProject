public class Quik_GetReceipients_Parser {

    public List<Signers> signers;
    public List<Agents> agents;
    public List<Agents> editors;
    public List<Agents> intermediaries;
    public List<Agents> carbonCopies;
    public List<Agents> certifiedDeliveries;
    public List<Agents> inPersonSigners;
    public List<Agents> seals;
    public List<Agents> witnesses;
    public String recipientCount;

    public class Signers {
        public String creationReason;
        public String isBulkRecipient;
        public String requireUploadSignature;
        public String name;
        public String firstName;
        public String lastName;
        public String email;
        public String recipientId;
        public String recipientIdGuid;
        public String requireIdLookup;
        public String idCheckConfigurationName;
        public SmsAuthentication smsAuthentication;
        public String userId;
        public String routingOrder;
        public String status;
        public String completedCount;
        public String deliveryMethod;
        public String recipientType;
    }

    public class Agents {
    }

    public class SmsAuthentication {
        public List<String> senderProvidedNumbers;
    }

    
    public static Quik_GetReceipients_Parser parse(String json) {
        return (Quik_GetReceipients_Parser) System.JSON.deserialize(json, Quik_GetReceipients_Parser.class);
    }
}