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

    // Method to fetch Google Drive files
    @AuraEnabled(Cacheable=true)
    public static String getGoogleDriveFiles(String folderId) {
        // Implement logic to fetch files from Google Drive using the provided folderId
        // This will involve making an HTTP request to the Google Drive API
        // You need to handle authentication (OAuth 2.0) and error handling
        // For simplicity, this example does not include authentication details
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('callout:Google_Drive/drive/v3/files?q=\'' + folderId + '\'+in+parents+and+trashed=false');
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        // Handle response
        if (res.getStatusCode() == 200) {
            // Parse JSON response
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> filesList = (List<Object>) responseMap.get('files');
            
            List<Map<String, Object>> files = new List<Map<String, Object>>();
            
            // Explicitly cast each object to Map<String, Object>
            for (Object file : filesList) {
                files.add((Map<String, Object>) file);
            }
            
            System.debug('*** Files: ' + JSON.serialize(files));
            System.debug('*** Number of files: ' + files.size());
            return JSON.serialize(files);
        } else {
            return 'Error: ' + res.getStatusCode();
        }
    }
}