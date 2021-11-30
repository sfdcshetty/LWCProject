//TestClassName: Docuvault_DD_ShareOnPortal_TC
global class Docuvault_CreatePortalFileSchedule_CCPY implements schedulable
{
    global void execute(SchedulableContext sc)
    {
      Docuvault_CreatePortalFileNightlyBatch b = new Docuvault_CreatePortalFileNightlyBatch('CCPY');
      database.executebatch(b);
    }
}