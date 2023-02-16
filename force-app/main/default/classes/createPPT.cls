public with sharing class createPPT {
    public static void PPTgen (){
    	Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
		List<Account > acclist = [Select id,name from Account limit 3];
		string header = 'Record Id, Name \n';
		string finalstr = header ;
		for(Account a: acclist)
		{
		string recordString = a.id+','+a.Name+'\n';
		finalstr = finalstr +recordString;
		}
		blob csvBlob = Blob.valueOf(finalstr);
		string csvname= 'Venki.ppt';
		csvAttc.setFileName(csvname);
		csvAttc.setBody(csvBlob);
		Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
		String[] toAddresses = new list<string> {'julio8500@gmail.com'};
		String subject ='Account PPT';
		email.setSubject(subject);
		email.setToAddresses( toAddresses );
		email.setPlainTextBody('Account PPT ');
		email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
		Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
}