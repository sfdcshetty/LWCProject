public class DuplicateDetector {
    @InvocableMethod(label='Find Duplicate' description='Find Potential Duplicate Ids.')
    public static List<SObject> processDuplicates(List<SObject> objs) {
        List<SObject> duplicateSObj = new List<SObject>();
        for (SObject obj : objs) {
            duplicateSObj.add((SObject) findDuplicateFor(obj));
        }
        return duplicateSObj;
    }

    public static SObject findDuplicateFor(SObject record) {
        try {
            Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(new List<SObject>{ record });
            List<MatchRecordWrapper> matchRecordWrappers = new List<MatchRecordWrapper>();
            for (Datacloud.FindDuplicatesResult findDupeResult : results) {
                for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                    for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                        for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                            matchRecordWrappers.add(new MatchRecordWrapper(matchRecord));
                        }
                    }
                }
            }
            return (matchRecordWrappers.size() == 0) ? null : matchRecordWrappers[0].matchRecord.getRecord();
        } catch (Exception ex) {
            return null;
        }
    }

    public class MatchRecordWrapper implements Comparable {
        Datacloud.MatchRecord matchRecord;

        public MatchRecordWrapper(Datacloud.MatchRecord matchRecord) {
            this.matchRecord = matchRecord;
        }

        public Integer compareTo(Object compareTo) {
            // MatchRecordWrapper compareToMatchRecord = (MatchRecordWrapper) compareTo;
            // if (this.matchRecord.getMatchConfidence() > compareToMatchRecord.matchRecord.getMatchConfidence()) {
            //     return 1;
            // } else if (this.matchRecord.getMatchConfidence() < compareToMatchRecord.matchRecord.getMatchConfidence()) {
            //     return -1;
            // }
            return 0;
        }
    }
}