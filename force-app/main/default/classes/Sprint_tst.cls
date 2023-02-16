@isTest
private class Sprint_tst {
    @isTest static void test_method_one() {
        Project__c Projecto = new Project__c(name='Projecto uno');
        insert Projecto;
        Project__c Projecto2 = new Project__c(name='Projecto dos');
        insert Projecto2;
        
        Release__c rel = new Release__c(PlannedDate__c = Date.today());
        insert rel;
        Sprint__c SprintUno = new Sprint__c(Project__c = Projecto.id, PlannedRelease__c = rel.id, P_Str_Date__c  = date.today(), P_End_Date__c = date.today());
        insert SprintUno;
        Sprint__c SprintDos = new Sprint__c(Project__c = Projecto2.id, PlannedRelease__c = rel.id, P_Str_Date__c  = date.today(), P_End_Date__c = date.today(), status__c  = 'In Progress');
        insert SprintDos;
        SprintUno.status__c = 'In Progress';
        Update SprintUno;
        try{
        	SprintDos.status__c = 'In Progress';
        	Update SprintUno;
        }
        catch(exception e){
            system.assertEquals(true,e.getMessage().contains('Já existe um sprint em progresso nesse projeto'));
        }
        
        
        
    
    }

}