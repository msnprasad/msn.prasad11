public class CreateContent {
    public static void createContent(String documentTitle, String documentPath, String documentContent, String workspaceName) {
        // Create ContentVersion record
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = documentTitle;
        contentVersion.PathOnClient = documentPath;
        contentVersion.VersionData = Blob.valueOf(documentContent);
        contentVersion.Origin = 'H';
        insert contentVersion;
        
        // Create ContentWorkspace record
        ContentWorkspace contentWorkspace = new ContentWorkspace();
        contentWorkspace.Name = workspaceName;
        insert contentWorkspace;
        
        // Create ContentWorkspaceDoc record to link ContentVersion and ContentWorkspace
        ContentWorkspaceDoc workspaceDoc = new ContentWorkspaceDoc();
        workspaceDoc.ContentWorkspaceId = contentWorkspace.Id;
        workspaceDoc.ContentDocumentId = contentVersion.ContentDocumentId;
        insert workspaceDoc;
    }
}