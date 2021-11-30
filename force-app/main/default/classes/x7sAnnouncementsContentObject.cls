/*
 * Copyright (c) 2020. 7Summits Inc.
 */

public virtual with sharing class x7sAnnouncementsContentObject
{
	@AuraEnabled public Id contentID { get; set; }
	@AuraEnabled public String title { get; set; }
	@AuraEnabled public String description { get; set; }
	@AuraEnabled public String fullDescription { get; set; }
	@AuraEnabled public List<Attachment> attachments { get; set; }
	@AuraEnabled public String url { get; set; }
	@AuraEnabled public Boolean featured { get; set; }
	@AuraEnabled public String bannerImage { get; set; }
	@AuraEnabled public String avatar { get; set; }
	@AuraEnabled public Integer commentCount { get; set; }
	@AuraEnabled public String commentUrl { get; set; }
	@AuraEnabled public Datetime dateTimeField { get; set; }
	@AuraEnabled public Date dateField { get; set; }
}