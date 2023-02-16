trigger Sprint_trg on Sprint__c (before update) {
    Sprint_cls Sprintcls = new Sprint_cls();
    if(trigger.isBefore){
        if(trigger.isUpdate){
            Sprintcls.validaStatusinProgess(trigger.old, trigger.new);
        }
    }

}