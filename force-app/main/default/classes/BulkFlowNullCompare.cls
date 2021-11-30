global with sharing class BulkFlowNullCompare {
    @InvocableMethod(label='bulk null compare' description='compares a value to null.  if not null updates first object')
    public static List<SObject> FlowNullCompareMethod(List<Requests> req) {
        Map<SObjectType, String> fieldMap = new Map<SObjectType, String>{
            Schema.Lead.getSObjectType() => 'Lead_Field__c',
            Schema.Contact.getSObjectType() => 'Contact_Field__c',
            Schema.Interaction__c.getSObjectType() => 'Interaction_Field__c'
        };
        List<SObject> responses = new List<SObject>();

        //create contact/lead maps
        for (Requests r : req) {
            Sobject result = r.object1;
            for (Interaction_Mapping__mdt rule : r.rules) {
                try {
                    String field1 = (String) rule.get(fieldMap.get(r.object1.getSObjectType()));
                    String field2 = (String) rule.get(fieldMap.get(r.object2.getSObjectType()));
                    // boolean destruck1 = r.destructive;
                    // boolean destruck2 = rule.Destructive__c;
                    // boolean set1 = r.object2.isSet(field2);
                    // boolean set2 = r.object1.isSet(field1);

                    if (
                        (r.object2.isSet(field2) && r.object2.get(field2) != null) &&
                        ((r.destructive && rule.Destructive__c) || !(r.object1.isSet(field1) && r.object1.get(field1) != null))
                    ) {
                        Schema.DisplayType type1 = getFieldType(field1, r.object1.getSObjectType());
                        Schema.DisplayType type2 = getFieldType(field2, r.object2.getSObjectType());

                        if (type1 == Schema.DisplayType.BOOLEAN && type2 == Schema.DisplayType.PICKLIST) {
                            result.put(field1, picklistToBooleanUpdate((String) r.object2.get(field2), (Boolean) r.object1.get(field1)));
                        } else if (type1 == Schema.DisplayType.PICKLIST && type2 == Schema.DisplayType.BOOLEAN) {
                            result.put(field1, booleanToPicklistUpdate((Boolean) r.object2.get(field2)));
                        } else {
                            result.put(field1, r.object2.get(field2));
                        }
                    }
                } catch (Exception ex) {
                    System.debug(ex);
                }
                //there could be all kinds of exceptions.  not sure how we want to hnadle them.  sending an email or some sort of notification would be good.
            }
            responses.add(result);
        }
        return responses;
    }

    private static Schema.DisplayType getFieldType(String fieldName, Schema.SObjectType sobj) {
        Schema.DescribeSObjectResult r = sobj.getDescribe();
        if (r.fields.getMap().containskey(fieldName)) {
            Schema.DescribeFieldResult f = r.fields.getMap().get(fieldName).getDescribe();
            return f.getType();
        }
        return null;
    }

    private static Boolean picklistToBooleanUpdate(String picklistValue, Boolean oldValue) {
        if (picklistValue == 'Yes') {
            return true;
        } else if (picklistValue == 'No') {
            return false;
        }
        return oldValue;
    }

    private static String booleanToPicklistUpdate(boolean booleanValue) {
        return (booleanValue) ? 'Yes' : 'No';
    }

    public class Requests {
        @InvocableVariable(label='Object1' description='Object1' required=true)
        public SObject object1;
        @InvocableVariable(label='Object2' description='Object2' required=true)
        public SObject object2;
        @InvocableVariable(label='rules' description='Object2' required=true)
        public List<Interaction_Mapping__mdt> rules;
        @InvocableVariable(label='Destructive' description='Do Destructive Changes' required=true)
        public Boolean destructive;
    }
}