public class Work_cls {
    public void UpdatePointsComplete(list<work__c> lstOld, list<work__c> lstNew){
        ConfiguracoesSprint__c Param = ConfiguracoesSprint__c.getInstance();
        map<id,work__c> MapSprintxWork = new map<id,work__c>();
        for(integer i  = 0; i < lstNew.size();i++){
            if(lstold[i].Work_Status__c != 'Accomplished' && lstnew[i].Work_Status__c == 'Accomplished'){
                MapSprintxWork.put(lstnew[i].Sprint__c,lstnew[i]);
            }
        }



        list<sprint__c> lstSprint = new list<sprint__c>();
        list<SprintBurndown__c> lstSprintsBurn = new list<SprintBurndown__c>();

        
        lstSprint = [select id, SprintPointsComplete__c, (select id,PointsCompletedToday__c, PointsCompleted__c, Date__c  from Sprint_Burndown__r where date__c >= TODAY ) from Sprint__c where id in: MapSprintxWork.keySet()];
        
        for(sprint__c sp : lstSprint){
          
            decimal points = MapSprintxWork.get(Sp.id).Points__c != null ? MapSprintxWork.get(Sp.id).Points__c : 0;
            system.debug('points ' + points);
            boolean hassprinttoday = false;

            for(SprintBurndown__c spbrd : sp.Sprint_Burndown__r){
                //Se for o Burndown da data atual atualiza o campo completedToday
                if(spbrd.date__c == date.today()){
                    hassprinttoday = true;
                    if(spbrd.PointsCompletedToday__c == null)
                        spbrd.PointsCompletedToday__c = 0;
                    spbrd.PointsCompletedToday__c += points;
                    
                }
                //Para o da data atual e todos os outros, atualiza o pointsCompleted    
                if(spbrd.PointsCompleted__c == null)
                    spbrd.PointsCompleted__c = 0;
                spbrd.PointsCompleted__c += points;     

                lstSprintsBurn.add(spbrd);
            }
            if(Param.CriarBurndown__c && !hassprinttoday){
                SprintBurndown__c newsb = new SprintBurndown__c(date__c = date.today(), sprint__c = sp.id);               
                lstSprintsBurn.add(newsb);
            }
        }
        upsert lstSprintsBurn id;
    }
    
    

    public void UpdateSequence(list<work__c> lstOld, list<work__c> lstNew, boolean isUpdate){
        try{

            map<string,work__c> MapIDSequencia = new map<string,work__c>(); // MAP para controle de cada número de sequencia nos Sprints (SprintID + Sequencia)
            set<id> WorksAlterados = new set<id>();
            set<id> setSprintsid = new set<id>();
            list<work__c> WorkstoUpdate = new list<work__c>();
            
     
            set<id> WorksIntrigger = new set<id>();

            for(integer i  = 0; i < lstNew.size();i++){
                WorksIntrigger.add(lstNew[i].id);
                if(isUpdate){ //Se é update valida se a sequencia foi alterada.
                    if(lstold[i].Sequence__c != lstnew[i].Sequence__c  && lstold[i].sprint__c == lstnew[i].sprint__c ){ 
                        
                        if( MapIDSequencia.get(lstNew[i].sprint__c + string.valueof(lstnew[i].Sequence__c) ) != null ){
                             //Valida se está alteração dois valores com mesma sequencia
                            lstNew[i].addError('Não é possível alterar dois registros para o mesmo valor de sequência.');
                            adderrortorecords(lstnew,i,null);

                            return;
                        }
                            
                    

                        MapIDSequencia.put(lstNew[i].sprint__c + string.valueof(lstnew[i].Sequence__c) , lstNew[i]);
                        WorksAlterados.add(lstNew[i].id);
                        setSprintsid.add(lstNew[i].sprint__c);
                    }
                }
                else{ //Se é insert valida se a sequência foi preenchida.
                    if(lstnew[i].sequence__c != null ){   //Sequência só pode ser preenchida se for ProductBacklog               
                        MapIDSequencia.put(lstNew[i].sprint__c + string.valueof( lstnew[i].Sequence__c ) , lstNew[i]);                    
                        setSprintsid.add(lstNew[i].sprint__c);
                    }
                }
            }

            if(MapIDSequencia.size()==0)
                return ;


             //Loop em Sprints com suas Works
            for(sprint__c sp : [select id, (select id, sequence__c 
                                                from User_Stories__r
                                                where sequence__c != null order by sequence__c)
                                            from sprint__c
                                            where id in: setSprintsid]){
                if(sp.User_Stories__r.size() == 0)
                    continue; //Se não works, não tem alterações 
                
                integer seq = integer.valueof( sp.User_Stories__r[0].sequence__c );  //Lista está ordenada por sequencia. [0] contém o número inicial das sequencias existentes
                
                integer i = 0;
                while(i < sp.User_Stories__r.size() ){ //Laço para encontrar nova posição (sequencia__c) para os registros existentes, respeitando as posições novas da alteraçõa da trigger
                    if(WorksAlterados.contains(sp.User_Stories__r[i].id)){
                        i++; //Se é um dos registros que ativaram a trigger, ignorar e aumentar contador para passar para o próixmo registro.
                        continue;
                    }
                    else{
                        if(MapIDSequencia.get(sp.id + string.valueof( seq) ) == null){//Verifica se a sequencia está disponível.
                            sp.User_Stories__r[i].sequence__c = seq;
                            if(!WorksIntrigger.contains(sp.User_Stories__r[i].id))
                                WorkstoUpdate.add(sp.User_Stories__r[i]);
                            i++; //Aumenta para ir para o próximo
                            seq++; //Auqmenta sequencia para ser validada no próximo registro
                        }
                        else{
                            seq++; //Se não estava disponível, repete o loop tentando a próxima sequência.
                        }
                    }


                }
            }

            SingleExecution_cls.setAlreadyDone('MasterSwitch');
            update WorkstoUpdate;
            SingleExecution_cls.resetTriggerExecutionStatus('MasterSwitch');

        }
        catch(exception e ){ 
            adderrortorecords(lstNew,null,'Erro ao salvar registros');
            system.debug('Erro: ' + e.getMessage());
        }

    }

    public void validateSequenceInsert(list<work__c> lstnew, list<work__c> lstold, boolean isUpdate) {
      try{
            set<id> IdSprints = new set<id>();

            map<id,integer> MapSprintMenor = new map<id,integer>();
            map<id,integer> MapSprintMaior = new map<id,integer>();

            for(integer i = 0; i < lstNew.size(); i++){
                IdSprints.add(Lstnew[i].sprint__c);
            }        
            for(sprint__c sp : [select id, (select id, sequence__c from User_Stories__r where sequence__c != null order by sequence__c)  from sprint__c where id in: IdSprints ]){
                MapSprintMenor.put(sp.id, sp.User_Stories__r.size() > 0 ? integer.valueof( sp.User_Stories__r[0].sequence__c ) : 1);            
                if(!isUpdate)
                    MapSprintMaior.put(sp.id, sp.User_Stories__r.size() > 0 ? integer.ValueOf( sp.User_Stories__r[sp.User_Stories__r.size() -1].sequence__c ) + 1 : 1);  //Se for insert o novo registro pode ter a sequencia maior que o último atual          
                else
                    MapSprintMaior.put(sp.id, sp.User_Stories__r.size() > 0 ? integer.ValueOf( sp.User_Stories__r[sp.User_Stories__r.size() -1].sequence__c )  : 1);    //Se for update o registro não pode ter a sequencia maior que o último atual        
            }

            if(isUpdate){

                for(integer i = 0; i < lstNew.size(); i++){
                    if(lstold[i].sequence__c == null && lstnew[i].sequence__c != null )
                        MapSprintMaior.put(lstnew[i].Sprint__c, MapSprintMaior.get(lstnew[i].Sprint__c )+1) ;        //Se o sequence estava nulo, aumenta o alcance do sprint pra cada um que er anulo      
                }
            }
            else{
                for(integer i = 0; i < lstNew.size(); i++){
                    if(lstnew[i].sequence__c == null ){
                        lstnew[i].sequence__c = MapSprintMaior.get(lstNew[i].Sprint__c);
                        system.debug('lstnew[i].sequence__c ' + lstnew[i].sequence__c);
                        MapSprintMaior.put(lstnew[i].Sprint__c, MapSprintMaior.get(Lstnew[i].sprint__c) + 1);              //se inseriu nulo assume próxima possição

                    }
                }
            }


            for(integer i = 0; i < lstNew.size(); i++){
                

                if(Lstnew[i].sequence__c != null &&  ( Lstnew[i].sequence__c < MapSprintMenor.get(Lstnew[i].sprint__c) || Lstnew[i].sequence__c > MapSprintMaior.get(Lstnew[i].sprint__c  ) )  )
                    if(isUpdate){

                        if(Lstnew[i].sprint__c == Lstold[i].sprint__c){
                            system.debug('Error');
                            Lstnew[i].addError('Número de sequência fora do alcançe do sprint selecionado');
                            adderrortorecords(lstnew,i,null);

                            return;
                        }
                        
                    }
                    else{
                        system.debug('Error');
                        Lstnew[i].addError('Número de sequência fora do alcançe do sprint selecionado');
                        adderrortorecords(lstnew,i,null);
                        return;
                    }

                
            }
        }
        catch(exception e ){
            adderrortorecords(lstNew,null,'Erro ao salvar registros');
            system.debug('Erro: ' + e.getMessage());
        }


    }

    //Faz o tratamento das sequências das histórias ao alterar Sprint
    
    public void validateSprintChange(list<work__c> lstOld, list<work__c> lstNew ){ //Método chamado em afterUpdate para poder conseguir buscar versão atualizada dos registros na query ordenada
        try{


            set<id> IdSprints = new set<id>();                
            Map<id,list<work__c>> MapSprintxWorksNew = new map<id,list<work__c>>();
            
            Map<id,list<work__c>> MapSprintxWorksOld = new map<id,list<work__c>>();
            map<id,work__c> WorkstoUpdate = new map<id,work__c>();
            set<id> idWorkchanged = new set<id>();

            Set<id> ListToReorder = new Set<id>(); //Lista para armazenar Sprints que precisam ser reordenados 

            for(integer i = 0; i < lstNew.size(); i++){
                if(Lstnew[i].sprint__c != Lstold[i].sprint__c){
                    idWorkchanged.add(lstnew[i].id);
                    ListToReorder.add(Lstold[i].sprint__c);
                    IdSprints.add(lstNew[i].sprint__c);
                    if(MapSprintxWorksOld.get(lstnew[i].sprint__c ) == null)
                        MapSprintxWorksOld.put(lstNew[i].sprint__c , new list<work__c> { lstnew[i]  } );
                    else
                        MapSprintxWorksOld.get(lstNew[i].sprint__c).add( lstnew[i]  );

                }
            }
            system.debug('MapSprintxWorksOld ' + MapSprintxWorksOld);
            if(MapSprintxWorksOld.size() == 0){
                return; //Se nenhum sprint foi alterado
            }

            for(id IDsp :  MapSprintxWorksOld.keySet()){


                //Ordenar a lista dos alterados de acordo com a sequence__c de cada:
                Map<integer,work__c> MapSequencexWork = new map<integer,work__c>();

                for (work__c wk : MapSprintxWorksOld.get(IDsp)){
                    MapSequencexWork.put(Integer.ValueOf( wk.sequence__c ) ,wk);
                }

                list<integer> orderingList = new list<integer>(); //Lista parta fazer ordenação        
                orderingList.addAll(MapSequencexWork.keyset());        
                orderingList.sort();

                MapSprintxWorksNew.put(IDsp, new list<work__c>());

                for(Integer i= 0;i < orderingList.size(); i++){
                    MapSprintxWorksNew.get( IDsp ).add(  MapSequencexWork.get(orderingList[i]) );                 
                }

            }            

            //Loop nos sprints com dados de sequencias atualizar as novas entradas
            for(sprint__c sp : [select id, ProductBacklog__c, (select id, sequence__c from User_Stories__r where sequence__c != null and id not in: idWorkchanged  order by sequence__c)  from sprint__c where id in: MapSprintxWorksNew.keyset() ]){
                
                integer ultimaSequencia;
                if(!sp.ProductBacklog__c)
                    ultimaSequencia = sp.User_Stories__r.size() > 0 ? sp.User_Stories__r.size() : 0;
                else
                    ultimaSequencia = 0;


                for(work__c wk :  MapSprintxWorksNew.get(sp.id) ){
                   ultimaSequencia++;
                    work__c NewWork = new work__c(id = wk.id, sequence__c = ultimaSequencia ); //Cria em novo registro para conseguir atualizar no afterUpdate
                    WorkstoUpdate.put(newwork.id,NewWork);
                
                }
                if(sp.ProductBacklog__c && sp.User_Stories__r.size() != 0 ){ //Se a nova lista é um ProductBacklog os novos registros  ocuparam as primeiras posições, então as existentes precisam ser reordenadas
                    
                    for(work__c wkOld : sp.User_Stories__r ){
                        ultimaSequencia++; // Aproveita o valor da última entrada de sequencia, e incrementa 1 para pegar a próxima
                        wkold.sequence__c = ultimaSequencia; //Works já estão ordenadas por sequencia, para não perder ordem de prioridade.                    
                        WorkstoUpdate.put(wkold.id,wkold);                    
                    }

                }


            }

            WorkstoUpdate.putAll( reorderWorkList(ListToReorder) ); //Adicionar Works antigas que foram reordenadas;
            SingleExecution_cls.setAlreadyDone('MasterSwitch');
            update WorkstoUpdate.values();
            SingleExecution_cls.resetTriggerExecutionStatus('MasterSwitch');
        }
        catch(exception e ){ 
            adderrortorecords(lstNew,null,'Erro ao salvar registros');
            system.debug('Erro: ' + e.getMessage());
        }
                


    }
    public map<id,work__c> reorderWorkList (set<id> SetidWork ){ //Reorndena Sequence__c de lista de Work__c
       

        map<id,work__c> MapOut = new map<id,work__c>();

        for( Sprint__c sp :  [select id, (select id, sequence__c from User_Stories__r where sequence__c != null order by sequence__c) from sprint__c where id in: SetidWork ] ){
            if(sp.User_Stories__r.size()==0)
                continue;
            integer SequenciaInicial  = 0;
            for(work__c wk: sp.User_Stories__r){
                SequenciaInicial++;

                work__c NewWork = new work__c(id = wk.id, sequence__c = SequenciaInicial ); //Cria em novo registro para conseguir atualizar no afterUpdate               

                MapOut.put(NewWork.id,NewWork);
            }

        }


        return MapOut;       
       


    }

    public void adderrortorecords(list<work__c> Lstnew, integer RecorderrorIndex, string message){
        //Método gera erro nos outros registros da lista, para forçar AllorNone que é ignorado no lineEdit do Lightning 
        for(integer i = 0 ; i<lstNew.size(); i++){
            if(RecorderrorIndex != null){
                if(i!= RecorderrorIndex)
                Lstnew[i].addError(message != null ? message : 'Erro em um ou mais registros da lista');
            }
            else{
                Lstnew[i].addError(message != null ? message : 'Erro em um ou mais registros da lista');
            }
        }       


    }


}