@IsTest
public class CreateContentTest {
    @IsTest
    public static void testCreateContent() {
        // Test data
        String documentTitle = 'Test Document';
        String documentPath = 'TestFolder/TestDocument.txt';
        String documentContent = 'Test document content';
        String workspaceName = 'Test Workspace';
        
        // Create ContentWorkspace
        ContentWorkspace contentWorkspace;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            contentWorkspace = new ContentWorkspace();
            contentWorkspace.Name = workspaceName;
            insert contentWorkspace;
        }
        
        // Create ContentVersion
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = documentTitle;
        contentVersion.PathOnClient = documentPath;
        contentVersion.VersionData = Blob.valueOf(documentContent);
        contentVersion.Origin = 'H';
        insert contentVersion;
        
        // Retrieve ContentDocumentId
        Id contentDocumentId = [SELECT ContentDocumentId FROM contentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
        
        // Create ContentWorkspaceDoc to link ContentVersion and ContentWorkspace
        ContentWorkspaceDoc workspaceDoc = new ContentWorkspaceDoc();
        workspaceDoc.ContentWorkspaceId = contentWorkspace.Id;
        workspaceDoc.ContentDocumentId = contentDocumentId;
        insert workspaceDoc;
        
    }
}