public class Sprint_cls {
    public void validaStatusinProgess(list<sprint__c> lstold, list<sprint__c> lstnew){
        map<id,Sprint__c> MapProjxSprint = new map<id,Sprint__c>();
        set<id> idSprint = new set<id>();
        
        for(integer i = 0; i < lstnew.size(); i++){
            if(lstold[i].Status__c != 'In Progress' && lstnew[i].Status__c == 'In Progress' && lstnew[i].Project__c != null){
                MapProjxSprint.put(lstnew[i].Project__c, lstnew[i]);
                idSprint.add(lstnew[i].id);                
            }           
        }
        if(MapProjxSprint.size() == 0 )
            return;
        for(Project__c Pro : [select id, (select id, status__c from Sprints__r where status__c = 'In Progress') from project__c where id in: MapProjxSprint.keySet()]){
            if(Pro.sprints__r.size() > 0){
                MapProjxSprint.get(Pro.id).addError('Já existe um sprint em progresso nesse projeto');
            }                        
        }
    }

}