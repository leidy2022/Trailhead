/**************************************************************************************************
 * Name: DefectsController
 * Object: Test_Steps__c, Defect__c
 * Purpose: This class is used to show all defects associated with the test steps
***************************************************************************************************/
public with sharing class DefectsController {
    public List<Defect__c> defectList {get; set;}

    private Id testStepId;

    /******************************************************************
    Purpose:  This method is the constructor
    *******************************************************************/
    public DefectsController() {
        testStepId = ApexPages.currentPage().getParameters().get('id');
        defectList = new List<Defect__c>();
        if(String.isNotBlank(testStepId)){
            queryDefects();
        }
    }

    /******************************************************************
    Purpose:  This method is used to query defects
    *******************************************************************/
    private void queryDefects(){
        defectList = [SELECT Name,
                             Severity__c,
                             Status__c,
                             Subject__c,
                             Assign_To__c
                      FROM Defect__c
                      WHERE Test_Step__c = :testStepId
                      ORDER BY Name DESC];
    }
}