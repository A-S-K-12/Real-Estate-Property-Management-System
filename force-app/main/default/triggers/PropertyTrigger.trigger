trigger PropertyTrigger on Property__c (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {

    PropertyTriggerHandler handler = new PropertyTriggerHandler();

    if (Trigger.isBefore) {

        if (Trigger.isInsert) {
            handler.beforeInsert(Trigger.new);
        }

        if (Trigger.isUpdate) {
            handler.beforeUpdate(
                Trigger.new,
                Trigger.oldMap
            );
        }

        if (Trigger.isDelete) {
            handler.beforeDelete(
                Trigger.old
            );
        }
    }

    if (Trigger.isAfter) {

        if (Trigger.isInsert) {
            handler.afterInsert(
                Trigger.new
            );
        }

        if (Trigger.isUpdate) {
            handler.afterUpdate(
                Trigger.new,
                Trigger.oldMap
            );
        }

        if (Trigger.isDelete) {
            handler.afterDelete(
                Trigger.old
            );
        }

        if (Trigger.isUndelete) {
            handler.afterUndelete(
                Trigger.new
            );
        }
    }
}