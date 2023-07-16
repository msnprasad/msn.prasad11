public with sharing class AccountController {
    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccounts(String searchTerm) {
        String searchQuery = '%' + searchTerm + '%';
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name LIKE :searchQuery LIMIT 10];
        return accounts;
    }
}