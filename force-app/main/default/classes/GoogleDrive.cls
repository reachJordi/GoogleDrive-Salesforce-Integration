public class GoogleDrive {
    public static String createGoogleDriveFolder(String folderName) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Google_Drive/drive/v3/files');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        
        String body = '{"name": "' + folderName + '", "mimeType": "application/vnd.google-apps.folder"}';
        req.setBody(body);
        
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String folderId = (String)responseMap.get('id');
            System.debug('Folder created successfully. ID: ' + folderId);
            return folderId;
        } 
        System.debug('Error creating folder: ' + res.getBody());
        return null;
    }
}