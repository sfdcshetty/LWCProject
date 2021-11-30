/*
 * Copyright (c) 2020. 7Summits Inc.
 */

global with sharing class x7sAnnouncementsUtils {
    // Return true/false to determine guest user
    global static Boolean isGuestUser() {
        Boolean isGuest = false;
        if (UserInfo.getUserType() == 'Guest' || UserInfo.getUserName() == x7sAnnouncementsTestConstants.GUEST_USERNAME) {
            isGuest = true;
        }
        return isGuest;
    }

    // Get the site prefix
    global static String getSitePrefix() {
        return System.Site.getPathPrefix();
    }

    // Get picklist values for any object, any field
    public static List<String> getPicklistValues(String ObjectApi_name, String Field_name) {
        // Thanks http://salesforce.stackexchange.com/questions/4992/how-to-get-a-picklist-all-values-in-apex-controller
        List<String> lstPickvals = new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        SObject Object_name = targetType.newSObject();
        Schema.SObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPicklistValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }

        return lstPickvals;
    }

    public static Boolean isNullOrEmpty(List<Object> objectList) {
        if (objectList == null || objectList.size() == 0) {
            return true;
        }
        return false;
    }

    public static List<String> createListFromMultiPicklist(String multiPicklistValue) {

        List<String> multiPicklistValueList = multiPicklistValue.split(';');
        return multiPicklistValueList;
    }

    // Get the fieldmap for an object
    public static Map<String, Schema.SObjectField> getFieldSchema(String objectName) {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType schema = schemaMap.get(objectName);
        Map<String, Schema.SObjectField> fieldMap = schema.getDescribe().fields.getMap();

        return fieldMap;
    }
}