/**************************************************************************************************
 * Name: TestCaseConsoleController
 * Object: Project__c, Sprint__c, Test_Case__c, Test_Steps__c, Defect__c
 * Purpose: This class is used to show test cases tree view and create defects for the failed steps
***************************************************************************************************/
public with sharing class TestCaseConsoleController {
    public String data {get; set;}
    public List<Test_Case__c> testCaseList {get; set;}
    public List<Test_Steps__c> testStepList {get; set;}
    public Map<Id, List<Defect__c>> testStepIdDefectsMap {get; set;}
    public Map<Id, Integer> testStepIdDefectNumberMap {get; set;}
    public Id selectedSprintId {get; set;}
    public Id selectedScenarioId {get; set;}
    public Id selectedTestCaseId {get; set;}

    private Map<String, Set<Test_Scenario__c>> sprintScenariosMap;
    private Map<Id, Test_Steps__c> testStepMap;
    private Set<String> openedProjectSet;
    private Set<String> openedSprintSet;

    /******************************************************************
    Purpose:  This method is the constructor, used to initial the tree nodes
    *******************************************************************/
    public TestCaseConsoleController() {
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
        queryTestCases();
        getOpendNodes();
        data = '[';
        
        for(Project__c project : [SELECT Name, 
                                               (SELECT Name 
                                                FROM Sprints__r
                                                WHERE Show_In_Test_Console__c = true
                                                ORDER BY CreatedDate DESC)
                                        FROM Project__c
                                        ORDER BY Name]){
            if(String.isNotBlank(project.Name)){
                // project names
                Boolean openProjectNode = openedProjectSet.contains(project.Name);
                data += '{ "id" : "' + project.Id + '", "parent" : "#", "text" : "' + project.Name + '", "state" : { "opened" : ' + openProjectNode + '} },';
                for(Sprint__c sprint : project.Sprints__r){
                    if(String.isNotBlank(sprint.Name)){
                        // sprint names
                        Boolean openSprintNode = openedSprintSet.contains(sprint.Name);
                        data += '{ "id" : "' + sprint.Id + '", "parent" : "' + project.Id + '", "text" : "' + sprint.Name + '", "state" : { "opened" : ' + openSprintNode + '} },';
                    }
                    Set<Test_Scenario__c> scenarioSet = sprintScenariosMap.get(sprint.Id);
                    if(scenarioSet != null && !scenarioSet.isEmpty()){
                        // scenario names
                        for(Test_Scenario__c scenario : scenarioSet){
                            if(String.isNotBlank(scenario.Name)){
                                data += '{ "id" : "' + scenario.Id + '", "parent" : "' + sprint.Id + '", "text" : "' + scenario.Name + '" },';
                            }
                        }
                    }
                }
            }
        }
        data += ']';

        testCaseList = new List<Test_Case__c>();
        testStepList = new List<Test_Steps__c>();
    }

    /******************************************************************
    Purpose:  This method is used to query test cases by sprint id and scenario id
    *******************************************************************/
    public void queryTestCasesBySprintIdAndScenarioId(){
        System.debug(LoggingLevel.INFO, '*** selectedSprintId: ' + selectedSprintId);
        System.debug(LoggingLevel.INFO, '*** selectedScenarioId: ' + selectedScenarioId);
        testCaseList = [SELECT Name,
                               NO__c,
                               Subject__c,
                               Owner.Name, 
                               Test_Scenario__r.Name
                       FROM   Test_Case__c
                       WHERE  Sprint__c = :selectedSprintId
                       AND Test_Scenario__c = :selectedScenarioId
                       ORDER BY NO__c];
        System.debug(LoggingLevel.INFO, '*** testCaseList: ' + testCaseList);                       
    }

    /******************************************************************
    Purpose:  This method is used to query test steps by test case id
    *******************************************************************/    
    public void queryTestStepsByTestCaseId(){
        testStepIdDefectsMap = new Map<Id, List<Defect__c>>();
        testStepIdDefectNumberMap = new Map<Id, Integer>();
        testStepList = [SELECT  Name,
                                Sequence__c,
                                Status__c,
                                Step_Details__c,
                                Expected_Results__c,
                                Actual_Results__c,
                                Plan_Start_Date__c,
                                Exec_Date_time__c,
                                Tester__r.Name,
                                (SELECT Name,
                                        Status__c 
                                FROM Defects__r
                                ORDER BY Name DESC)
                       FROM Test_Steps__c
                       WHERE Test_Case__c = :selectedTestCaseId
                       ORDER BY Sequence__c ASC];
        
        testStepMap = new Map<Id, Test_Steps__c>();
        for(Test_Steps__c ts : testStepList){
            testStepMap.put(ts.Id, ts);
            if(!testStepIdDefectsMap.containsKey(ts.Id)){
                testStepIdDefectsMap.put(ts.Id, new List<Defect__c>());
            }
            for(Defect__c def : ts.Defects__r){
                testStepIdDefectsMap.get(ts.Id).add(def);
            }
            if(!testStepIdDefectNumberMap.containsKey(ts.Id)){
                testStepIdDefectNumberMap.put(ts.Id, ts.Defects__r.size());
            }
        }                       
    }

    /******************************************************************
    Purpose:  This method is used to save test steps
    *******************************************************************/
    public void saveTestSteps(){
        //compare whether status changed
        List<Test_Steps__c> tsList = new List<Test_Steps__c>();
        for(Test_Steps__c ts : testStepList){
            Test_Steps__c ots = testStepMap.get(ts.Id);
            if(ots.Status__c != ts.Status__c){
                ts.Exec_Date_time__c = Datetime.now();
            }
            tsList.add(ts);
        }
        try{
            update tsList;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Success!'));
        }catch (DMLException ex){
            for(Integer i = 0; i < ex.getNumDml(); i++){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDmlMessage(i)));
            }
        }
    }

    /******************************************************************
    Purpose:  This method is used to get test scenario object prefix
    *******************************************************************/
    public String getTestScenarioPrefix(){
        return Schema.SObjectType.Test_Scenario__c.getkeyprefix();
    }

    /******************************************************************
    Purpose:  This method is used to query all test cases
    *******************************************************************/
    private void queryTestCases(){
        sprintScenariosMap = new Map<String, Set<Test_Scenario__c>>();
        for(Test_Case__c tc : [SELECT Name,
                                      NO__c,
                                      Subject__c,
                                      Owner.Name,
                                      Sprint__c,
                                      Test_Scenario__c,
                                      Test_Scenario__r.Name
                               FROM   Test_Case__c
                               ORDER BY Test_Scenario__r.Name]){
            if(!sprintScenariosMap.containsKey(tc.Sprint__c)){
                sprintScenariosMap.put(tc.Sprint__c, new Set<Test_Scenario__c>());
            }
            Test_Scenario__c ts = new Test_Scenario__c();
            ts.Id = tc.Test_Scenario__c;
            ts.Name = tc.Test_Scenario__r.Name;
            sprintScenariosMap.get(tc.Sprint__c).add(ts);
        }
    }

    /******************************************************************
    Purpose:  This method is used to get maintained settings for opened nodes by default
    *******************************************************************/
    private void getOpendNodes(){
        openedProjectSet = new Set<String>();
        openedSprintSet = new Set<String>();
        for(String key : TestCaseConsoleTreeView__c.getAll().keySet()){
            TestCaseConsoleTreeView__c node = TestCaseConsoleTreeView__c.getAll().get(key);
            if(node.Active__c){
                openedProjectSet.add(node.Project__c);
                openedSprintSet.add(node.Sprint__c);
            }
        }
    }
}