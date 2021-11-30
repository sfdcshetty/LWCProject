//TestClassName: Docuvault_DD_ShareOnPortal_TC
global class Docuvault_CreatePortalFileSchedule_QAMR implements schedulable
{
    global void execute(SchedulableContext sc)
    {
      Docuvault_CreatePortalFileNightlyBatch b = new Docuvault_CreatePortalFileNightlyBatch('QAMR');
      database.executebatch(b);
    }
}