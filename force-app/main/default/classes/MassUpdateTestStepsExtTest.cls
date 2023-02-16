/**************************************************************************************************
 * Name: TestCaseConsoleControllerTest
 * Object: Test_Case__c, Test_Steps__c, Defect__c
 * Purpose: A test class for MassUpdateTestStepsExt
 **************************************************************************************************/
@isTest
private class MassUpdateTestStepsExtTest {
    static testMethod void testMassUpdateTestStepsExt() {

        Project__c project = new Project__c(
            Name = 'Project Test');

        insert project;
        
        Release__c release = new Release__c(
            Name = 'Release Test',
            PlannedDate__c = Date.newInstance(1960, 2, 17));
        
        insert release;

        Sprint__c sprint = new Sprint__c(
            Project__c = project.Id,
            PlannedRelease__c = release.Id,
            Show_In_Test_Console__c = TRUE);

        insert sprint;

        Test_Scenario__c scenario = new Test_Scenario__c(
            Name = 'Scenario A');

        insert scenario;

        Test_Case__c testCase = new Test_Case__c(
            Test_Scenario__c = scenario.Id,
            Sprint__c = sprint.Id);

        insert testCase;

        Test_Steps__c testStep = new Test_Steps__c(
            Test_Case__c = testCase.Id);

        insert testStep;

        PageReference testPage = Page.MassUpdateTestSteps;
        Test.setCurrentPage(testPage);

        ApexPages.StandardController testCaseController = new ApexPages.StandardController(testCase);
        MassUpdateTestStepsExt testStepExt = new MassUpdateTestStepsExt(testCaseController);
        
        String nextPage = testStepExt.saveTestSteps().getUrl();

        System.assertEquals(TRUE, nextPage.contains(testCase.Id));

        String cancelPage = testStepExt.cancelTestSteps().getUrl();

        System.assertEquals(TRUE, cancelPage.contains(testCase.Id));
    }
}