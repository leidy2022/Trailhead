/**************************************************************************************************
 * Name: NewDefectController
 * Object: Defect__c
 * Purpose: This class is used to create defect for selected test step
***************************************************************************************************/
public with sharing class NewDefectController {
    public Defect__c defect {get; set;}
    public Boolean hasError {get; set;}

    private Id testStepId;
    private Test_Steps__c testStep;

    private static final String TEST_STEP_STATUS_FAILED = 'Failed';

    /******************************************************************
    Purpose:  This method is the constructor
    *******************************************************************/
    public NewDefectController() {
        testStepId = ApexPages.currentPage().getParameters().get('id');
        getTestStep();
        initialDefect();

        // set hasError as true to validate the mandatory field
        hasError = true;
    }

    /******************************************************************
    Purpose:  This method is used to initial defect
    *******************************************************************/
    public void initialDefect(){
        defect = new Defect__c();
        defect.Test_Step__c = testStepId;
        defect.Test_Case__c = testStep.Test_Case__c;
        defect.Subject__c = testStep.Test_Case__r.Subject__c;
        defect.Project__c = testStep.Test_Case__r.Sprint__r.Project__c;
    }

    /******************************************************************
    Purpose:  This method is used to save defect
    ******************************************************************/
    public void saveDefect(){
        hasError = false;
        try{
            System.debug(LoggingLevel.INFO, '*** defect: ' + defect);
            insert defect;

            testStep.Status__c = TEST_STEP_STATUS_FAILED;
            testStep.Exec_Date_time__c = Datetime.now();
            update testStep;
        }catch (DMLException ex){
            hasError = true;
            for(Integer i = 0; i < ex.getNumDml(); i++){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDmlMessage(i)));
            }
            return;
        }
    }

    /******************************************************************
    Purpose:  This method is used to get test step by test step id
    ******************************************************************/
    private void getTestStep(){
        testStep = [SELECT  Id, 
                            Status__c,
                            Exec_Date_time__c,
                            Test_Case__c,
                            Test_Case__r.Subject__c,
                            Test_Case__r.Sprint__r.Project__c
                    FROM Test_Steps__c
                    WHERE Id = :testStepId ];
    }
}