public with sharing class CTDataCleanupSchedule implements Schedulable {
    
    // define the cron exp
    public static final String CRON = '0 0 2 * * ?';

    public void execute(SchedulableContext sc){
        CTPeopleTracingDataCleanupBatch peopleTracingBatch = new CTPeopleTracingDataCleanupBatch();
        Database.executeBatch(peopleTracingBatch, 2000);

        CTLocationTracingDataCleanupBatch locationTracingBatch = new CTLocationTracingDataCleanupBatch();
        Database.executeBatch(locationTracingBatch, 2000);
    }
}