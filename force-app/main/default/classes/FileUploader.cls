/**
 * @author            : Anirban Roy && reachJordi
 * @description       : Core File Upload Handler class for GDrive
 * @Created on        : 10-12-2023
 * @last modified by  : 11-12-2024
**/

public class FileUploader {
    public static void handleUpload(List<ContentDocumentLink> cdlList, String folderId) {

        List<ContentDocument> cDocList = new List<ContentDocument>();

        for(ContentDocumentLink cdlItem: cdlList) {
            ContentDocumentLink cdl = [SELECT Id, ContentDocument.ContentSize, ContentDocument.FileExtension, ContentDocument.FileType,
                                       ContentDocument.LatestPublishedVersion.Id, ContentDocument.LatestPublishedVersion.Title,
                                       ContentDocument.LatestPublishedVersion.FileExtension, ContentDocument.LatestPublishedVersion.VersionData,
                                       ContentDocument.LatestPublishedVersion.FileType
                                       FROM ContentDocumentLink WHERE Id =: cdlItem.Id];
            
            ContentDocument cDoc = cdl.ContentDocument;

            cDocList.add(cDoc);

            // File size restricted 11 MB. You can add other conditions, like verifying the fileTypes with cDoc.FileExtension
            if(cDoc.ContentSize < 200 || cDoc.ContentSize > 11534336 || cDoc.FileType == 'SNOTE') {
                continue;
            }
            ContentVersion cVersion = cdl.ContentDocument.LatestPublishedVersion;
            String base64File = EncodingUtil.base64Encode(cVersion.VersionData);
            String file_name = cVersion.Title + '.' + cVersion.FileExtension;
            
            String endpoint2 = 'upload/drive/v3/files?uploadType=multipart';
            
            // Determinar el tipo MIME según el archivo
        	String mimeType = getMimeType(cVersion.FileType);
            
            // Crear metadata para Google Drive
            String metadata = JSON.serialize(new Map<String, Object>{
                'name' => cVersion.Title,
                'mimeType' => mimeType,
                'parents' => new List<String>{ folderId } // Especificar la carpeta de destino
            });
            
            //uploadtoGDrive(file_name, EncodingUtil.base64Decode(base64File), cVersion.Id, endpoint2, folderId);
            uploadtoGDrive(file_name, EncodingUtil.base64Decode(base64File), cVersion.Id, endpoint2, cVersion.VersionData, metadata, mimeType);
        }

        if(!cdlList.isEmpty()) {
            Database.delete(cdlList, false);
        }

        if(!cDocList.isEmpty()) {
            Database.delete(cDocList, false);
        }
    }
    
    @future(callout=true)
    private static void uploadtoGDrive(String file_name, Blob file_body, Id version_id, String endPoint, Blob versionData, String metadata, String mimeType) {
       	// Configurar límites para el cuerpo multipart
        String boundary = 'foo_bar_baz';
        
        // Parte inicial como texto
        String bodyStart = '--' + boundary + '\r\n' +
                           'Content-Type: application/json; charset=UTF-8\r\n\r\n' +
                           metadata + '\r\n' +
                           '--' + boundary + '\r\n' +
                           'Content-Type: ' + mimeType + '\r\n\r\n';

        // Parte final como texto
        String bodyEnd = '\r\n--' + boundary + '--';

        // Convertir las partes inicial y final a datos binarios
        Blob bodyStartBlob = Blob.valueOf(bodyStart);
        Blob bodyEndBlob = Blob.valueOf(bodyEnd);
        
        // Obtener el contenido del archivo como Blob
        Blob fileContentBlob = versionData;

        // Construir el cuerpo completo binario
        Blob completeBody = combineBlobs(new Blob[] { bodyStartBlob, fileContentBlob, bodyEndBlob });
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
        req.setMethod('POST');
        req.setEndpoint('callout:Google_Drive/' + endpoint);
        req.setBodyAsBlob(completeBody);
        req.setTimeout(120000);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        Integer statusCode = res.getStatusCode();
        DriveResponseDetail responseWrapper = (DriveResponseDetail) JSON.deserialize(res.getBody(), DriveResponseDetail.class);
        
        System.debug('=> ' + statusCode);
        if(statusCode == 200) {
            System.debug('file ID: ' + responseWrapper.id);
        }
        else {
            System.debug('Error Message: ' + responseWrapper.error.message);
            System.debug('Error Code: ' + responseWrapper.error.code);
        }
        
    }
 
    // Función para combinar múltiples blobs en un flujo binario único
    private static Blob combineBlobs(List<Blob> blobs) {
        String hexResult = '';
    
        for (Blob blobx : blobs) {
            String hex = EncodingUtil.convertToHex(blobx);
            hexResult += hex;
        }
    
        // Convertir el flujo hexadecimal combinado de vuelta a un Blob
        return EncodingUtil.convertFromHex(hexResult);
    }
    
    
    // Función para determinar el tipo MIME según el archivo
    private static String getMimeType(String fileType) {
        switch on fileType.toLowerCase() {
            when 'pdf' {
                return 'application/pdf';
            }
            when 'png' {
                return 'image/png';
            }
            when 'jpeg', 'jpg' {
                return 'image/jpeg';
            }
            when else {
                return 'application/octet-stream';
            }
        }
    }
    
    public class GPTResponseDetail {
        public String id;
        public GPTError error;
    }
    
    public class GPTError {
        public String code;         //error code
        public String message;      //error message
    }
    
    public class DriveResponseDetail {
        public String id;
        public DriveError error;
    }
    
    public class DriveError {
        public Integer code;        //error code
        public String message;      //error message
    }
}