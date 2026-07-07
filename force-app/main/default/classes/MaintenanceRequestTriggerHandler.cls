public class MaintenanceRequestTriggerHandler {

    public static void beforeInsert(List<Maintenance_Request__c> requests){

        MaintenanceRequestService.assignVendor(requests);

    }

}