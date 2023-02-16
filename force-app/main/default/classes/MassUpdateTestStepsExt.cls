/**************************************************************************************************
 * Name: MassUpdateTestStepsExt
 * Object: Test_Case__c, Test_Steps__c, Defect__c
 * Purpose: This class is used to run test steps in one page and create defects for the failed steps
***************************************************************************************************/
public with sharing class MassUpdateTestStepsExt {
    public Test_Case__c testCase {get; set;}
    public Map<Id, List<Defect__c>> testStepIdDefectsMap {get; set;}
    public Map<Id, Integer> testStepIdDefectNumberMap {get; set;}
    public List<Test_Steps__c> testStepList {get; set;}
    public Boolean hasError {get; set;}

    private Map<Id, Test_Steps__c> testStepMap;

    /******************************************************************
    Purpose:  This method is the constructor
    *******************************************************************/
    public MassUpdateTestStepsExt(ApexPages.StandardController con) {
        testCase = (Test_Case__c)con.getRecord();
        hasError = false;
        testStepIdDefectsMap = new Map<Id, List<Defect__c>>();
        testStepIdDefectNumberMap = new Map<Id, Integer>();
        getTestCaseAndTestSteps();
    }

    /******************************************************************
    Purpose:  This method is return test case page
    ******************************************************************/
    public PageReference cancelTestSteps(){
        PageReference pr = new PageReference('/' + testCase.Id);
        pr.setRedirect(true);
        return pr;
    }

    /******************************************************************
    Purpose:  This method is used to save test steps
    ******************************************************************/
    public PageReference saveTestSteps(){
        List<Test_Steps__c> tsList = new List<Test_Steps__c>();
        for(Test_Steps__c ts : testStepList){
            Test_Steps__c ots = testStepMap.get(ts.Id);
            //set executed date time if status changed
            if(ots.Status__c != ts.Status__c 
                || ots.Actual_Results__c != ts.Actual_Results__c){
                ts.Exec_Date_time__c = Datetime.now();
            }
            tsList.add(ts);
        }
        try{
            update tsList;
        }catch (DMLException ex){
            for(Integer i = 0; i < ex.getNumDml(); i++){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDmlMessage(i)));
            }
        }

        PageReference pr = new PageReference('/' + testCase.Id);
        pr.setRedirect(true);
        return pr;
    }

    /******************************************************************
    Purpose:  This method is used to get test case and its test steps by test case id
    ******************************************************************/
    public void getTestCaseAndTestSteps(){
        testCase = [SELECT  Id,
                            Subject__c,
                            Type__c
                    FROM Test_Case__c 
                    WHERE Id = :testCase.Id];
            
        testStepIdDefectsMap = new Map<Id, List<Defect__c>>();
        testStepIdDefectNumberMap = new Map<Id, Integer>();
        testStepList = [SELECT  Id, 
                                Name,
                                Sequence__c,
                                Status__c,
                                Step_Details__c,
                                Expected_Results__c,
                                Actual_Results__c,
                                Plan_Start_Date__c,
                                Exec_Date_time__c,
                                Tester__r.Name,
                                (SELECT Name 
                                FROM Defects__r
                                ORDER BY Name DESC)
                       FROM Test_Steps__c
                       WHERE Test_Case__c = :testCase.Id];
        
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

}