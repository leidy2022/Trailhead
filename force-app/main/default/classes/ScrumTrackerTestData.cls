public class ScrumTrackerTestData {
    public static Project__c createProject(){
        Project__c p = new Project__c();
        p.Name = 'Project';
        p.Project_Description__c = 'Test Scrum Project';
        insert p;
        return p;
    }
 
    public static Release__c createRelease(){
        Release__c r = new Release__c();
        r.Name = 'Release Test';
        r.PlannedDate__c = Date.newInstance(1960, 2, 17);
        insert r;
        return r;
    }
    
    
    public static Sprint__c createSprint(Project__c p, Release__c r){
        Sprint__c sp = new Sprint__c();
        sp.Name = 'Sprint';
        sp.Project__c = p.Id;
        sp.PlannedRelease__c = r.Id;
        insert sp;
        return sp;
    }

    public static Test_Scenario__c createTestScenario(){
        Test_Scenario__c tsc = new Test_Scenario__c();
        tsc.Name = 'Test Scenario';
        insert tsc;
        return tsc;
    }

    public static Test_Case__c createTestCase(Test_Scenario__c tsc, Sprint__c sp){
        Test_Case__c tc = new Test_Case__c();
        tc.Test_Scenario__c = tsc.Id;
        tc.Sprint__c = sp.Id;
        tc.Subject__c = 'Test Subject';
        insert tc;
        return tc;
    }

    public static Test_Steps__c createTestStep(Test_Case__c tc){
        Test_Steps__c ts = new Test_Steps__c();
        ts.Test_Case__c = tc.Id;
        // ts.Sequence__c = '01';
        ts.Status__c = 'No Run';
        insert ts;
        return ts;
    }

    public static Defect__c createDefect(Test_Steps__c ts){
        Defect__c def = new Defect__c();
        def.Test_Step__c = ts.Id;
        insert def;
        return def;
    }
}