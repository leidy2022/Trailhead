trigger Work_trg on Work__c (before update, before insert, after update) {
    Work_cls workclss = new Work_cls();
    if(!SingleExecution_cls.hasAlreadyDone('MasterSwitch') ){ //Verifica flag estático que evita recursão 
        
        if(trigger.isBefore){ //BEFORE METHODS
            if(trigger.isUpdate){ //BEFORE UPDATE
              
              
              workclss.UpdatePointsComplete(trigger.old,trigger.new);              
              workclss.validateSequenceInsert(trigger.new, trigger.old, true);    



              workclss.UpdateSequence(trigger.old,trigger.new,true);
              
              
              
            }
          if(trigger.isInsert){ //BEFORE INSERT
              workclss.validateSequenceInsert(trigger.new, null,  false);
              workclss.UpdateSequence(trigger.old,trigger.new,false);
            }
        
        }

        if(trigger.isAfter){ //AFTER METHODS
          
          if(trigger.isUpdate){ //AFTER UPDATE
            workclss.validateSprintChange(trigger.old,trigger.new);            
          }
        }            
        
    }
}