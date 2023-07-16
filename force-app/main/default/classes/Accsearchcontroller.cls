public with sharing class Accsearchcontroller {
    @AuraEnabled(cacheable=true)
    public static list<account> getAccountlist(string inpname)
    {
        string sTempSearchKey ;
        sTempSearchKey = '%' + inpname + '%';
        string que = 'select id,name,industry from account where name like:sTempSearchKey';
        return Database.query(que);        
    }
    @AuraEnabled(cacheable=true)
    public static list<contact> getContactlist(string inpname)
    {
        string sTempSearchKey = '%' + inpname + '%';
        string que = 'select id,firstname,lastname,Account.Name,Name,Email from contact where account.name like:sTempSearchKey';
        return Database.query(que);        
    }
}