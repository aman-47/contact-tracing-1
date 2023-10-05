public with sharing class CTStatusUpdateSchedule implements Schedulable{
    
    // define the cron exp
    public static final String CRON = '0 0 2 * * ?';

    public void execute(SchedulableContext sc){
        CTUpdatePersonStatusBatch peopleBatch = new CTUpdatePersonStatusBatch();
        Database.executeBatch(peopleBatch, 2000);

        CTUpdateLocationStatusBatch locationBatch = new CTUpdateLocationStatusBatch();
        Database.executeBatch(locationBatch, 2000);
    }
}