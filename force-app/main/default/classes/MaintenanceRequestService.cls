public with sharing class MaintenanceRequestService {

    public static void assignVendor(List<Maintenance_Request__c> requests) {

        List<Vendor__c> vendors = [
            SELECT Id, Name
            FROM Vendor__c
            WHERE IsActive__c = true
            ORDER BY Name
        ];

        if (vendors.isEmpty()) {
            return;
        }

        Map<Id, Integer> workloadMap = new Map<Id, Integer>();

        for (AggregateResult ar : [
            SELECT Vendor__c vendorId, COUNT(Id) total
            FROM Maintenance_Request__c
            WHERE Vendor__c != null
            AND Status__c IN ('Open', 'In Progress')
            GROUP BY Vendor__c
        ]) {
            workloadMap.put(
                (Id) ar.get('vendorId'),
                (Integer) ar.get('total')
            );
        }

        for (Maintenance_Request__c req : requests) {

            Id selectedVendor = vendors[0].Id;

            Integer minimumLoad = workloadMap.containsKey(selectedVendor)
                ? workloadMap.get(selectedVendor)
                : 0;

            for (Vendor__c vendor : vendors) {

                Integer currentLoad = workloadMap.containsKey(vendor.Id)
                    ? workloadMap.get(vendor.Id)
                    : 0;

                if (currentLoad < minimumLoad) {
                    minimumLoad = currentLoad;
                    selectedVendor = vendor.Id;
                }
            }

            req.Vendor__c = selectedVendor;
            workloadMap.put(selectedVendor, minimumLoad + 1);
        }
    }
}