public with sharing class FlowScoring {
    @InvocableMethod(label='Interaction Scoring' description='Sets Scoring in Interaction')
    public static List<result> scoreInteraction(List<Request> requests) {
        List<result> results = new List<result>();
        for (Request request : requests) {
            // try {
            if (request.rule.Type__c == 'Range') {
                results.add(rangeScoring(request));
            }
            if (request.rule.Type__c == 'String') {
                results.add(equalScoring(request));
            }
            if (request.rule.Type__c == 'Boolean') {
                results.add(booleanScoring(request));
            }
            //} catch (Exception ex) {
            //rule is screwed up send back interaction
            //   results.add(request.interaction);
            // }
        }

        return results;
    }

    //type string
    private static result equalScoring(Request request) {
        result res = new result(request.interaction);
        if (request.interaction.get(request.rule.Field__c) == request.rule.Value__c) {
            updateScore(res, request.rule);
        }
        return res;
    }

    //type boolean
    private static result booleanScoring(Request request) {
        result res = new result(request.interaction);
        Boolean ruleValue = (request.rule.Value__c == 'true');

        if (request.interaction.get(request.rule.Field__c) == ruleValue) {
            updateScore(res, request.rule);
        }

        return res;
    }

    //type range
    private static result rangeScoring(Request request) {
        result res = new result(request.interaction);

        Decimal fieldValue;
        if (request.interaction.get(request.rule.Field__c) == null) {
            return res;
        } else {
            fieldValue = (Decimal) request.interaction.get(request.rule.Field__c);
        }

        List<String> values = request.rule.Value__c.split('<<');
        Decimal lowerBound = Decimal.valueOf(values[0]);
        Decimal upperBound = Decimal.valueOf(values[values.size() - 1]);

        if (lowerBound != upperBound) {
            if (fieldValue >= lowerBound && fieldValue <= upperBound) {
                updateScore(res, request.rule);
            }
        } else {
            if (fieldValue >= lowerBound) {
                updateScore(res, request.rule);
            }
        }

        return res;
    }

    private static Result updateScore(Result res, Interaction_Scoring__mdt rule) {
        res.behaviorScore += rule.Behavior_Score__c;
        res.demographicScore += rule.Demographic_Score__c;

        //if reset was set on a previous rule, we do not update the value
        res.reset = (res.reset || rule.reset__c);
        return res;
    }

    public class Request {
        @InvocableVariable(label='Interaction' description='Interaction to be scored' required=true)
        public Interaction__c interaction;
        @InvocableVariable(label='rule' description='Scoring rule' required=true)
        public Interaction_Scoring__mdt rule;
    }

    public class Result {
        public Result(Interaction__c interaction) {
            this.behaviorScore = interaction.Behavior_Score__c;
            this.demographicScore = interaction.Demographic_Score__c;
            this.reset = interaction.reset__c;
        }
        @InvocableVariable(label='Behavior Score' description='behavior score' required=true)
        public Decimal behaviorScore;
        @InvocableVariable(label='Demographic Score' description='demographic score' required=true)
        public Decimal demographicScore;
        @InvocableVariable(label='reset' description='reset status' required=true)
        public boolean reset;
    }
}