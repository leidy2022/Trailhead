@isTest
private class ScrumTrackerTest {
    @isTest
    private static void TestMassUpdateTestSteps_saveTestSteps(){
        Project__c p = ScrumTrackerTestData.createProject();
        Release__c r = ScrumTrackerTestData.createRelease();
        Sprint__c sp = ScrumTrackerTestData.createSprint(p, r);
        Test_Scenario__c tsc = ScrumTrackerTestData.createTestScenario();
        Test_Case__c tc = ScrumTrackerTestData.createTestCase(tsc, sp);
        Test_Steps__c ts01 = ScrumTrackerTestData.createTestStep(tc);
        Test_Steps__c ts02 = ScrumTrackerTestData.createTestStep(tc);

        Test.startTest();

        MassUpdateTestStepsExt massUpdateTestSteps = new MassUpdateTestStepsExt(new ApexPages.StandardController(tc));
        massUpdateTestSteps.saveTestSteps();

        Test.stopTest();
    }

    @isTest
    private static void TestMassUpdateTestSteps_cancelTestSteps(){
        Project__c p = ScrumTrackerTestData.createProject();
        Release__c r = ScrumTrackerTestData.createRelease();
        Sprint__c sp = ScrumTrackerTestData.createSprint(p,r);
        Test_Scenario__c tsc = ScrumTrackerTestData.createTestScenario();
        Test_Case__c tc = ScrumTrackerTestData.createTestCase(tsc, sp);
        Test_Steps__c ts01 = ScrumTrackerTestData.createTestStep(tc);
        Test_Steps__c ts02 = ScrumTrackerTestData.createTestStep(tc);

        Test.startTest();

        MassUpdateTestStepsExt massUpdateTestSteps = new MassUpdateTestStepsExt(new ApexPages.StandardController(tc));
        massUpdateTestSteps.cancelTestSteps();

        Test.stopTest();
    }

    @isTest
    private static void TestNewDefect(){
        Project__c p = ScrumTrackerTestData.createProject();
        Release__c r = ScrumTrackerTestData.createRelease();
        Sprint__c sp = ScrumTrackerTestData.createSprint(p,r);
        Test_Scenario__c tsc = ScrumTrackerTestData.createTestScenario();
        Test_Case__c tc = ScrumTrackerTestData.createTestCase(tsc, sp);
        Test_Steps__c ts01 = ScrumTrackerTestData.createTestStep(tc);
        Test_Steps__c ts02 = ScrumTrackerTestData.createTestStep(tc);

        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', ts01.Id);
        NewDefectController newDef = new NewDefectController();
        newDef.saveDefect();

        Test.stopTest();
    }

    @isTest
    private static void TestTestCaseConsole(){
        Project__c p = ScrumTrackerTestData.createProject();
        Release__c r = ScrumTrackerTestData.createRelease();
        Sprint__c sp = ScrumTrackerTestData.createSprint(p,r);
        Test_Scenario__c tsc = ScrumTrackerTestData.createTestScenario();
        Test_Case__c tc = ScrumTrackerTestData.createTestCase(tsc, sp);
        Test_Steps__c ts01 = ScrumTrackerTestData.createTestStep(tc);
        Test_Steps__c ts02 = ScrumTrackerTestData.createTestStep(tc);

        TestCaseConsoleTreeView__c node = new TestCaseConsoleTreeView__c();
        node.Name = 'OpenNode1';
        node.Project__c = 'Mid-market call center bid';
        node.Active__c = true;
        insert node;

        Test.startTest();

        TestCaseConsoleController testCaseConsole = new TestCaseConsoleController();

        testCaseConsole.selectedScenarioId = tsc.Id;
        testCaseConsole.selectedSprintId = sp.Id;
        testCaseConsole.queryTestCasesBySprintIdAndScenarioId();

        testCaseConsole.selectedTestCaseId = tc.Id;
        testCaseConsole.queryTestStepsByTestCaseId();

        testCaseConsole.getTestScenarioPrefix();

        testCaseConsole.saveTestSteps();

        Test.stopTest();
    }

    @isTest
    private static void TestDefectsController(){
        Project__c p = ScrumTrackerTestData.createProject();
        Release__c r = ScrumTrackerTestData.createRelease();
        Sprint__c sp = ScrumTrackerTestData.createSprint(p,r);
        Test_Scenario__c tsc = ScrumTrackerTestData.createTestScenario();
        Test_Case__c tc = ScrumTrackerTestData.createTestCase(tsc, sp);
        Test_Steps__c ts = ScrumTrackerTestData.createTestStep(tc);
        Defect__c def01 = ScrumTrackerTestData.createDefect(ts);
        Defect__c def02 = ScrumTrackerTestData.createDefect(ts);

        Test.startTest();

        DefectsController defectsController = new DefectsController();

        Test.stopTest();
    }    
}