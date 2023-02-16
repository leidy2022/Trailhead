public with sharing class SingleExecution_cls {
 
	private static set<string> ExecutedTriggers_set = new set<string>();	     
	public static boolean hasAlreadyDone(string strAPINameOfTrigger) {  //Retorna true se o trigger já foi executado
		if(!ExecutedTriggers_set.isEmpty()){
			return ExecutedTriggers_set.contains(strAPINameOfTrigger);
		}
		else{
			return false;
		}
	} 
	public static void setAlreadyDone(string strAPINameOfTrigger) { //Inclui o nome do trigger para lista de já executados
		ExecutedTriggers_set.add(strAPINameOfTrigger);
	}
    
	public static void resetTriggerExecutionStatus(string strAPINameOfTrigger){ //Remove o trigger da lista de já executados 
		ExecutedTriggers_set.remove(strAPINameOfTrigger);
	}

}