public class Quik_RecipientDetailsJSON {
    public cls_signers[] signers;
    public cls_agents[] agents;
    public cls_editors[] editors;
    public cls_intermediaries[] intermediaries;
    public cls_carbonCopies[] carbonCopies;
    public cls_certifiedDeliveries[] certifiedDeliveries;
    public cls_inPersonSigners[] inPersonSigners;
    public cls_seals[] seals;
    public cls_witnesses[] witnesses;
    public String recipientCount;   //3
    public String currentRoutingOrder;  //1
    public class cls_signers {
        public String creationReason;   //sender
        public String isBulkRecipient;  //false
        public String requireUploadSignature;   //false
        public String name; //1own_0.Name
        public String firstName;    //
        public String lastName; //
        public String email;    //1own_0.Mail@test.com
        public String recipientId;  //1
        public String recipientIdGuid;  //02ce09e3-f9a4-42b7-8bfb-99227ca224c1
        public String requireIdLookup;  //false
        public String userId;   //f0b9bd75-72b5-40b0-9bc4-419d720d8546
        public String routingOrder; //1
        public String status;   //sent
        public String completedCount;   //0
        public String deliveryMethod;   //email
        public String recipientType;    //signer
    }
    public class cls_agents {
    }
    public class cls_editors {
    }
    public class cls_intermediaries {
    }
    public class cls_carbonCopies {
        public String name; //CC1
        public String email;    //bharath.t@bigworks.co
        public String recipientId;  //3
        public String recipientIdGuid;  //2d54c1b3-3035-4339-b6d8-bcba85e03799
        public String requireIdLookup;  //false
        public String userId;   //d37c90e2-642b-4f0c-b544-b8a406f53b7b
        public String routingOrder; //2
        public String status;   //completed
    }
    public class cls_certifiedDeliveries {
    }
    public class cls_inPersonSigners {
    }
    public class cls_seals {
    }
    public class cls_witnesses {
    }
    public static Quik_RecipientDetailsJSON parse(String json) {
        return (Quik_RecipientDetailsJSON) System.JSON.deserialize(json, Quik_RecipientDetailsJSON.class);
    }
}