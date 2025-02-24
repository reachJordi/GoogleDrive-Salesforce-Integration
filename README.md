# Google Drive Salesforce Integration  

This integration enables seamless file transfers from Salesforce to Google Drive.  

## Google Drive API Setup  

### 1. Create a Google Project  
- Navigate to **API & Services** → **Enable APIs and Services**  
- Search for **Google Drive API** and enable it  

### 2. Generate API Credentials  
- Go to **API & Services** → **Credentials** → **Create Credentials** → **OAuth client ID**  
- Save the **Client ID** and **Client Secret**  

## Salesforce Setup  

- Create an Auth. Provider for your Salesforce org
  - Navigate to **Setup** → **Identity** → **Auth. Providers
  - Click **New**  
  - Fill in the required fields and click **Save**
    - **Name: Add your Auth. Provider name
    - **URL Suffix: Add URL Suffix
    - **Consumer Key:** `Client ID from Google Drive API`
    - **Consumer Secret:** `Client Secret from Google Drive API`
    - **Authorize Endpoint URL:** `https://accounts.google.com/o/oauth2/auth?access_type=offline&approval_prompt=force`
    - **Token Endpoint URL:** `https://accounts.google.com/o/oauth2/token`
    - **Default Scope:** `openid email profile https://www.googleapis.com/auth/drive`

- Create a Named Credential for your Salesforce org
  - Navigate to **Setup** → **Security** → **Named Credentials**  
  - Click **New Legacy**  
  - Fill in the required fields and click **Save**  
    - **Name:** Add your Named Credential name
    - **URL:** `https://www.googleapis.com`
    - **Identity Type:** `Named Principal`
    - **Authentication Protocol:** `OAuth 2.0`
    - **Authentication Provider:** Add your Auth.Provider
    - **Scope:** `openid https://www.googleapis.com/auth/drive`
    - **Start Authentication Flow on Save:** `Checked`


## Usage  

To use this integration, create a custom field on the **Account** object:  
- **Field Name:** `SendToGoogleDrive__c`  

Once set up, this field will allow users to send files directly from Salesforce to Google Drive.  