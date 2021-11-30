public with sharing class CampaignTriggerHandler implements TriggerInterface {
    private static CampaignTriggerHandler instance;
    public static CampaignTriggerHandler getInstance() {
        if (instance == null) {
            instance = new CampaignTriggerHandler();
        }
        return instance;
    }

    public void beforeInsert() {
        forceLowercaseECID((List<Campaign>) Trigger.new);
        randomECIDFragmentAssignmentIfDuplicateNoParent((List<Campaign>) Trigger.new, new Set<Id>());
        randomECIDFragmentAssignmentIfDuplicate((List<Campaign>) Trigger.new, new Set<Id>());
        setECID((List<Campaign>) Trigger.new);
        setCampaignName((List<Campaign>) Trigger.new);
        updateChildrenFields((List<Campaign>) Trigger.new);
    }

    public void beforeUpdate() {
        forceLowercaseECID((List<Campaign>) Trigger.new);
        randomECIDFragmentAssignmentIfDuplicateNoParent((Map<Id, Campaign>) Trigger.newMap, (Map<Id, Campaign>) Trigger.oldMap);
        randomECIDFragmentAssignmentIfDuplicate((Map<Id, Campaign>) Trigger.newMap, (Map<Id, Campaign>) Trigger.oldMap);
        updateECID((Map<Id, Campaign>) Trigger.newMap, (Map<Id, Campaign>) Trigger.oldMap);
        setCampaignName((List<Campaign>) Trigger.new);
        updateChildrenFields((Map<Id, Campaign>) Trigger.newMap, (Map<Id, Campaign>) Trigger.oldMap);
    }

    public void beforeDelete() {
    }

    public void afterInsert() {
    }

    public void afterUpdate() {
        updateECIDChildren((Map<Id, Campaign>) Trigger.newMap, (Map<Id, Campaign>) Trigger.oldMap);
    }

    public void afterDelete() {
    }

    public void finish() {
    }

    private static void forceLowercaseECID(List<Campaign> newCampaigns) {
        for (Campaign campaign : newCampaigns) {
            if (campaign.ECID_Fragment__c != null) {
                campaign.ECID_Fragment__c.toLowerCase();
            }
        }
    }
    private static void setECID(List<Campaign> newCampaigns) {
        Set<Id> campaignIds = new Set<Id>();
        for (Campaign campaign : newCampaigns) {
            if (campaign.ParentId != null) {
                campaignIds.add(campaign.ParentId);
            }
        }
        Map<Id, Campaign> parentCampaigns = new Map<Id, Campaign>([SELECT Id, ECID__c FROM Campaign WHERE id = :campaignIds]);

        for (Campaign campaign : newCampaigns) {
            if (campaign.ParentId != null) {
                campaign.ECID__c = parentCampaigns.get(campaign.ParentId).ECID__c + campaign.ECID_Fragment__c;
            } else {
                campaign.ECID__c = campaign.ECID_Fragment__c;
            }
        }
    }
    private static void updateECID(Map<Id, Campaign> newCampaigns, Map<Id, Campaign> oldCampaigns) {
        List<Campaign> campaignList = new List<Campaign>();
        for (Id key : newCampaigns.keySet()) {
            if (
                newCampaigns.get(key).ECID_Fragment__c != oldCampaigns.get(key).ECID_Fragment__c ||
                newCampaigns.get(key).ParentId != oldCampaigns.get(key).ParentId
            ) {
                campaignList.add(newCampaigns.get(key));
            }
        }

        if (campaignList.size() > 0) {
            setECID(campaignList);
        }
    }
    private static void updateECIDChildren(Map<Id, Campaign> newCampaigns, Map<Id, Campaign> oldCampaigns) {
        Set<Id> campaignIds = new Set<Id>();
        for (Id key : newCampaigns.keySet()) {
            if (newCampaigns.get(key).ECID_Fragment__c != oldCampaigns.get(key).ECID_Fragment__c) {
                campaignIds.add(key);
            }
        }
        if (campaignIds.size() > 0) {
            Database.executeBatch(new CampaignCascadeChangesBatch(campaignIds));
        }
    }
    private static void randomECIDFragmentAssignmentIfDuplicateNoParent(Map<Id, Campaign> newCampaignMap, Map<Id, Campaign> oldCampaignMap) {
        Map<Id, Campaign> campaignMap = new Map<Id, Campaign>();
        Set<Id> excludedIdSet = new Set<Id>();
        for (Id key : newCampaignMap.keySet()) {
            if (
                newCampaignMap.get(key).parentId == null &&
                (newCampaignMap.get(key).ECID_Fragment__c != oldCampaignMap.get(key).ECID_Fragment__c ||
                String.isBlank(newCampaignMap.get(key).ECID_Fragment__c))
            ) {
                campaignMap.put(key, newCampaignMap.get(key));
            }
        }

        if (campaignMap.keySet().size() > 0) {
            randomECIDFragmentAssignmentIfDuplicateNoParent(campaignMap.values(), campaignMap.keySet());
        }
    }
    private static void randomECIDFragmentAssignmentIfDuplicateNoParent(List<Campaign> newCampaign, Set<Id> excludedIdSet) {
        Set<String> takenECID = new Set<String>();
        Boolean noparent = false;
        for (campaign c : newCampaign) {
            if (c.parentId == null) {
                noparent = true;
                break;
            }
        }
        if (noparent) {
            for (Campaign child : [
                SELECT Id, ECID_Fragment__c
                FROM Campaign
                WHERE parentId = :null AND ECID_Fragment__c != :null AND id NOT IN :excludedIdSet
            ]) {
                takenECID.add(child.ECID_Fragment__c);
            }
        } else {
            return;
        }

        for (Campaign c : newCampaign) {
            if (c.parentId == null) {
                while (String.isBlank(c.ECID_Fragment__c) || takenECID.contains(c.ECID_Fragment__c)) {
                    c.ECID_Fragment__c = generateRandomString();
                }
                takenECID.add(c.ECID_Fragment__c);
            }
        }
    }
    private static void randomECIDFragmentAssignmentIfDuplicate(Map<Id, Campaign> newCampaignMap, Map<Id, Campaign> oldCampaignMap) {
        Map<Id, Campaign> campaignMap = new Map<Id, Campaign>();
        for (Id key : newCampaignMap.keySet()) {
            if (
                newCampaignMap.get(key).parentId != null &&
                (newCampaignMap.get(key).parentId != oldCampaignMap.get(key).parentId ||
                newCampaignMap.get(key).ECID_Fragment__c != oldCampaignMap.get(key).ECID_Fragment__c ||
                String.isBlank(newCampaignMap.get(key).ECID_Fragment__c))
            ) {
                campaignMap.put(key, newCampaignMap.get(key));
            }
        }
        if (campaignMap.keySet().size() > 0) {
            randomECIDFragmentAssignmentIfDuplicate(campaignMap.values(), campaignMap.keySet());
        }
    }
    private static void randomECIDFragmentAssignmentIfDuplicate(List<Campaign> newCampaign, Set<Id> excludedIdSet) {
        Map<Id, Set<String>> parentChildrenMap = new Map<Id, Set<String>>();
        for (campaign c : newCampaign) {
            if (c.parentId != null) {
                parentChildrenMap.put(c.parentId, new Set<String>());
            }
        }
        for (Campaign child : [
            SELECT Id, ECID_Fragment__c, ParentId
            FROM Campaign
            WHERE parentId IN :parentChildrenMap.keySet() AND ECID_Fragment__c != :null AND Id NOT IN :excludedIdSet
        ]) {
            parentChildrenMap.get(child.ParentId).add(child.ECID_Fragment__c);
        }

        for (Campaign c : newCampaign) {
            if (c.parentId != null) {
                while (parentChildrenMap.get(c.parentId).contains(c.ECID_Fragment__c) || String.isBlank(c.ECID_Fragment__c)) {
                    c.ECID_Fragment__c = generateRandomString();
                }
                parentChildrenMap.get(c.parentId).add(c.ECID_Fragment__c);
            }
        }
    }
    public static void setCampaignName(List<Campaign> newCampaigns) {
        Map<Id, String> CampaignRecordTypeMap = new Map<Id, String>();
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SobjectType = :'Campaign']) {
            CampaignRecordTypeMap.put(rt.Id, rt.Name);
        }

        for (Campaign campaign : newCampaigns) {
            if (CampaignRecordTypeMap.get(campaign.recordtypeId) == 'Advisor') {
                if (campaign.ECID__c.length() == 3) {
                    campaign.Name = campaign.Business_Line__c;
                }

                if (campaign.ECID__c.length() == 6) {
                    campaign.Name = campaign.ECID__c.substring(0, 3).toUpperCase() + ' | ' + campaign.Year__c;
                }

                if (campaign.ECID__c.length() == 9) {
                    campaign.Name =
                        campaign.ECID__c.substring(0, 3).toUpperCase() +
                        ' | ' +
                        campaign.ECID__c.substring(3, 6).toUpperCase() +
                        ' | ' +
                        campaign.WEGP1_Region__c;
                }

                if (campaign.ECID__c.length() == 12) {
                    campaign.Name =
                        campaign.ECID__c.substring(0, 3).toUpperCase() +
                        ' | ' +
                        campaign.ECID__c.substring(3, 6).toUpperCase() +
                        ' | ' +
                        campaign.ECID__c.substring(6, 9).toUpperCase() +
                        ' | ' +
                        campaign.Objective__c;
                }
            }
            if (CampaignRecordTypeMap.get(campaign.recordtypeId) == 'Custodial Referral Program') {
                if (campaign.ECID__c.length() == 3) {
                    campaign.Name = campaign.Business_Line__c + ' - ' + campaign.Year__c;
                }

                if (campaign.ECID__c.length() == 6) {
                    campaign.Name = campaign.ECID__c.substring(0, 3).toUpperCase() + ' | ' + campaign.Program__c;
                }

                if (campaign.ECID__c.length() == 9) {
                    campaign.Name =
                        campaign.ECID__c.substring(0, 3).toUpperCase() +
                        ' | ' +
                        campaign.ECID__c.substring(3, 6).toUpperCase() +
                        ' | ' +
                        campaign.Regional_Vice_President__c;
                }

                if (campaign.ECID__c.length() == 12) {
                    campaign.Name =
                        campaign.ECID__c.substring(0, 3).toUpperCase() +
                        ' | ' +
                        campaign.ECID__c.substring(3, 6).toUpperCase() +
                        ' | ' +
                        campaign.Regional_Vice_President__c+
                        ' | ' +
                        campaign.State__c;
                }
            }
            if (CampaignRecordTypeMap.get(campaign.recordtypeId) == 'Marketing') {
                if (campaign.ECID__c.length() == 3) {
                    campaign.Name = campaign.Business_Line__c + ' - ' + campaign.Year__c;
                }

                if (campaign.ECID__c.length() == 6) {
                    campaign.Name = campaign.ECID__c.substring(0, 3).toUpperCase() + ' | ' + campaign.Initiative__c;
                }

                if (campaign.ECID__c.length() == 9) {
                    campaign.Name =
                        campaign.ECID__c.substring(0, 3).toUpperCase() +
                        ' | ' +
                        campaign.ECID__c.substring(3, 6).toUpperCase() +
                        ' | ' +
                        campaign.Persona__c;
                }

                if (campaign.ECID__c.length() == 12) {
                    campaign.Name =
                        campaign.ECID__c.substring(0, 3).toUpperCase() +
                        ' | ' +
                        campaign.ECID__c.substring(3, 6).toUpperCase() +
                        ' | ' +
                        campaign.ECID__c.substring(6, 9).toUpperCase() +
                        ' | ' +
                        campaign.Objective__c;
                }
            }
            if (campaign.Name.length() > 80) {
                campaign.Name = campaign.Name.substring(0, 79);
            }
        }
    }

    public static String generateRandomString() {
        final String chars = '0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < 3) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }

    public static void updateChildrenFields(Map<Id, Campaign> newCampaigns, Map<Id, Campaign> oldCampaigns) {
        List<Campaign> updateCampains = new List<Campaign>();
        for (Id key : newCampaigns.keySet()) {
            updateCampains.add(newCampaigns.get(key));
        }
        if (updateCampains.size() > 0) {
            updateChildrenFields(updateCampains);
        }
    }

    public static void updateChildrenFields(List<Campaign> newCampaigns) {
        Set<Id> parentIds = new Set<Id>();
        for (Campaign c : newCampaigns) {
            if (c.ParentId != null) {
                parentIds.add(c.ParentId);
            }
        }
        Map<Id, Campaign> parentMap = new Map<Id, Campaign>(
            [SELECT Id, Business_Line__c, Year__c, WEGP1_Region__c, Objective__c, Persona__c, Initiative__c, Topic__c FROM CAMPAIGN WHERE Id IN :parentIds]
        );

        for (Campaign c : newCampaigns) {
            if (c.ParentId != null && parentMap.containsKey(c.ParentId)) {
                if (parentMap.get(c.ParentId).Business_Line__c != null) {
                    c.Business_Line__c = parentMap.get(c.ParentId).Business_Line__c;
                }
                if (parentMap.get(c.ParentId).Year__c != null) {
                    c.Year__c = parentMap.get(c.ParentId).Year__c;
                }
                if (parentMap.get(c.ParentId).WEGP1_Region__c != null) {
                    c.WEGP1_Region__c = parentMap.get(c.ParentId).WEGP1_Region__c;
                }
                if (parentMap.get(c.ParentId).Objective__c != null) {
                    c.Objective__c = parentMap.get(c.ParentId).Objective__c;
                }
                if (parentMap.get(c.ParentId).Persona__c != null) {
                    c.Persona__c = parentMap.get(c.ParentId).Persona__c;
                }
                if (parentMap.get(c.ParentId).Initiative__c != null) {
                    c.Initiative__c = parentMap.get(c.ParentId).Initiative__c;
                }
                if (parentMap.get(c.ParentId).Topic__c != null) {
                    c.Initiative__c = parentMap.get(c.ParentId).Topic__c;
                }
            }
        }
    }
}