/*
 * Copyright (c) 2020. 7Summits Inc.
 */

// ===================
// Custom Response wrapper
// ===================
public virtual with sharing class x7sAnnouncementsResponse
{
    @AuraEnabled public Boolean success{get;set;} // success or failure
    @AuraEnabled public List<String> messages{get;set;}  // messages to display
    @AuraEnabled public List<SObject> results{get;set;} // results to iterate over - use this when querying SOjbects directoy
    @AuraEnabled public List<x7sAnnouncementsContentObject> x7sResults{get;set;} // custom results to iterate over - use this when creating a list of custom wrapper classes

    public x7sAnnouncementsResponse(){
        success = true;
        messages = new List<String>();
        results = new List<SObject>();
        x7sResults = new List<x7sAnnouncementsContentObject>();
    }
}