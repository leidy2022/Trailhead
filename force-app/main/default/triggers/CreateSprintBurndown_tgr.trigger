trigger CreateSprintBurndown_tgr on Sprint__c (before update) {   
    
        List< SprintBurndown__c > SBItem = new List< SprintBurndown__c >();
       
        for (integer c = 0; c < trigger.new.size(); c++){
            
            if(  trigger.old[c].Status__c != 'In Progress' && trigger.new[c].Status__c == 'In Progress'){
               
               date DateSB = trigger.new[c].P_Str_Date__c;
               date FinalDateSB = trigger.new[c].P_End_Date__c;
               integer dayNumber = 0;
               //decimal PointsByDay = trigger.new[c].PointsDayComplete__c;
               //decimal EstimatedPoints = trigger.new[c].SprintEstimatedPoints__c;
               
               do{
                   
                   SprintBurndown__c Burndown = new SprintBurndown__c();
                   Burndown.Sprint__c = trigger.new[c].Id;
                   //Burndown.SprintEstimatedPoints__c = trigger.new[c].SprintEstimatedPoints__c;
                   Burndown.Date__c = DateSB;
                   Burndown.DayNumber__c = dayNumber;
                   //Burndown.PlannedBurndown__c = EstimatedPoints;
                   //EstimatedPoints = EstimatedPoints - PointsByDay;
                   
                   system.debug(DateSB);
                   
                   DateSB = DateSB.addDays(1);
                   
                   date DateWeek = DateSB.toStartofWeek();
                   
                   integer numberDays = DateSB.daysBetween(DateWeek);
                   
                   system.debug('Proxima Data' + DateSB);
                   system.debug('DateWeek' + DateWeek);
                   system.debug('Numero do Dia' + numberDays);
                   
                   if(numberDays == -6) DateSB = DateSB.addDays(2);
                   if(numberDays == -1) DateSB = DateSB.addDays(1);
                   
                   SBItem.add(Burndown);
                   dayNumber++;
                   
                   
               }
               while(DateSB <= FinalDateSB);
                
            }
        }
        insert SBItem;
    }