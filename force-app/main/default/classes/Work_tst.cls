@isTest
public class Work_tst {
    @TestSetup static void CreateData(){
        Project__c Projecto = new Project__c(name='Projecto uno');
        insert Projecto;
        Release__c rel = new Release__c(PlannedDate__c = Date.today());
        insert rel;
        Project__c Projecto2 = new Project__c(name='Projecto dos');
        insert Projecto2;
        Sprint__c SprintUno = new Sprint__c(ProductBacklog__c = true, Project__c = Projecto.id, PlannedRelease__c = rel.id, P_Str_Date__c  = date.today(), P_End_Date__c = date.today());
        insert SprintUno;
        ConfiguracoesSprint__c param = new ConfiguracoesSprint__c(CriarBurndown__c = true);
        insert param;
        
        Sprint__c SprintDos = new Sprint__c(ProductBacklog__c = true, Project__c = Projecto2.id, PlannedRelease__c = rel.id, P_Str_Date__c  = date.today(), P_End_Date__c = date.today(), status__c ='In Progress');
        insert SprintDos;
    }
    @isTest static void Test_method_one(){
		Sprint__c Sprintuno = [select id from sprint__c limit 1];
        work__c FstW = new work__c(sprint__c = Sprintuno.id, sequence__c = 1);
        insert FstW;
        work__c SndW = new work__c(sprint__c = Sprintuno.id, sequence__c = 2);
        insert SndW;
        try{
            work__c ThrdW = new work__c(sprint__c = Sprintuno.id, sequence__c = 4);
        	insert ThrdW;
        }
        catch(exception e){
            system.assertEquals(true,e.getMessage().contains('Número de sequência fora do alcançe do sprint selecionado'));
            try{
                work__c FrthW = new work__c(sprint__c = Sprintuno.id, sequence__c = 0);
        		insert FrthW;
            }   
            catch(exception ex){
            	system.assertEquals(true,ex.getMessage().contains('Número de sequência fora do alcançe do sprint selecionado'));
            }
        }
        
        
    }
     @isTest static void Test_method_two(){
		list<Sprint__c> Sprints = [select id from sprint__c limit 2];
         
        work__c FstW = new work__c(sprint__c = Sprints[0].id, sequence__c = 1);
        insert FstW;
         
        work__c SndW = new work__c(sprint__c = Sprints[0].id, sequence__c = 2);
        insert SndW;
         
        work__c ThrdW = new work__c(sprint__c = Sprints[0].id, sequence__c = 3);
        insert ThrdW;
         
        Sndw.sequence__c =  1;
        update Sndw;
         
		system.assertEquals(2,[select sequence__c from work__c where id =: FstW.id].sequence__c);         
         
         try{
             Sndw.sequence__c =  2;
             ThrdW.sequence__c =  2;             
             Update new list<work__c>{Sndw,Thrdw};
             
         }
         catch(exception e){           
            
       		try{
                 ThrdW.sequence__c =  5;             
                 Update Thrdw;             
         	}
            catch(exception ex){
                //system.assertEquals(true,ex.getMessage().contains('Número de sequência fora do alcançe do sprint selecionado'));
            }
         }
         
     	
     }
      @isTest static void Test_method_three(){
		list<Sprint__c> Sprints = [select id from sprint__c];
        Sprints[0].Status__c ='In Progress';
        Update Sprints[0];
          
        work__c FstW = new work__c(sprint__c = Sprints[0].id, Points__c = 10);
        insert FstW;
        Fstw.Work_Status__c = 'Accomplished';
        Update Fstw;
          
        SprintBurndown__c burndown = new SprintBurndown__c(sprint__c = Sprints[0].id, date__c = Date.today());
        Insert burndown;
          
        Fstw.Work_Status__c = null;
        Update Fstw;
        
        delete burndown;
          
        Fstw.Work_Status__c = 'Accomplished';
        Update Fstw;
          
        Fstw.sprint__c = Sprints[1].id;
        Fstw.Work_Status__c = null;
        Update Fstw;
          
        system.assertequals(1,[select count() from SprintBurndown__c]);
         
      	
        
      }

}