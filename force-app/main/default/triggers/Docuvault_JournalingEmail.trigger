trigger Docuvault_JournalingEmail on EmailMessage (After insert) {
    
    ComplianceArchivingHelper.emailMessageShare (Trigger.NEW);
}