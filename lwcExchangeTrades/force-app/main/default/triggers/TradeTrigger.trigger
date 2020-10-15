trigger TradeTrigger on Trade__c (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        TradeTriggerHandler.fillId(Trigger.new);
    }
}