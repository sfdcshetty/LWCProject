/**
 * This is the TriggerFactory class. This class is the factory
 * that builds the correct handler based off of SObject Type
 * sent to the factory from the Trigger Context.
 *
 * @author Matthew Lennington -- (PERFICIENT)
 * @date 09/2020
 *
 */
public class TriggerFactory {
    public static Boolean RUN_TRIGGER_LOGIC = true;
    public static void createHandler(Schema.sObjectType soType) {
        if (Trigger.isExecuting) {
            //Get a handler appropriate to the object being processed
            TriggerInterface handler = getHandler(soType);

            if (handler == null) {
                throw new TriggerException('No Trigger Handler registered for Object Type: ' + soType);
            }

            execute(handler);
        }
    }

    private static void execute(TriggerInterface handler) {
        //Turns off trigger logic
        if ((Properties__c.getOrgDefaults().Run_Trigger_Logic_In_Factory__c && RUN_TRIGGER_LOGIC) || (Test.isRunningTest() && RUN_TRIGGER_LOGIC)) {
            if (Trigger.isBefore) {
                if (Trigger.isDelete) {
                    handler.beforeDelete();
                } else if (Trigger.isInsert) {
                    handler.beforeInsert();
                } else if (Trigger.isUpdate) {
                    handler.beforeUpdate();
                }
            } else {
                if (Trigger.isDelete) {
                    handler.afterDelete();
                } else if (Trigger.isInsert) {
                    handler.afterInsert();
                } else if (Trigger.isUpdate) {
                    handler.afterUpdate();
                }
            }

            handler.finish();
        }
    }

    private static TriggerInterface getHandler(Schema.sObjectType soType) {
        if (soType == Campaign.sObjectType) {
            return CampaignTriggerHandler.getInstance();
        } else if (soType == CampaignMember.sObjectType) {
            return CampaignMemberTriggerHandler.getInstance();
        } else if (soType == Interaction__c.sObjectType) {
            return InteractionTriggerHandler.getInstance();
        } else if (soType == Lead.sObjectType) {
            return LeadTriggerHandler.getInstance();
        } else if (soType == CampaignInfluence.sObjectType) {
            return CampaignInfluenceTriggerHandler.getInstance();
        } else if (soType == Contact.sObjectType) {
            return ContactTriggerHandler.getInstance();
        } else if (soType == Interaction__ChangeEvent.sObjectType) {
            return InteractionChangeEventTriggerHandler.getInstance();
        }
        return null;
    }

    public class TriggerException extends Exception {
    }
}