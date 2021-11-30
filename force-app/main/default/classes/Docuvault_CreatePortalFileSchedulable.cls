//TestClassName: Docuvault_DD_ShareOnPortal_TC
global class Docuvault_CreatePortalFileSchedulable implements schedulable
{
    global void execute(SchedulableContext sc)
    {
      Docuvault_CreatePortalFileNightlyBatch b = new Docuvault_CreatePortalFileNightlyBatch();
      database.executebatch(b);
    }
}