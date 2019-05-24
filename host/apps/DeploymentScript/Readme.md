# Couchbase Python deployment script

#### This script pushes, builds the JSON for the Couchbase document and uploads files to the cloud services.
### Given a directory path which contains consistent structure provided by the Hardware team.
### This script walks through the directory structure to build the JSON and uploads the file to the cloud services to be downloaded by HCS and possibly other services.

## What it can do
- Authenticate and upload files to the cloud services
- Build JSON structure based on the following directory structure
```html
- STR-NCP110-EVK
    - downloads
        - bom
            - ONSEC-18-004_REV1_bom.xlsx
    - views
        - Schematic
            - ONSEC-18-004_REV1_schematic.pdf
```
```json
{
   "channels": "<platform_document_class>",
   "name":"<Platform Class Verbose name. Example: USB 4-Port Power Delivery",
   "documents":{
       "views":[
           {
               "name":"Schematic",
               "file":"211/Schematic/ONSEC-18-004_REV1_schematic.pdf",
               "md5":"9e107d9d372bb6826bd81d3542a419d6",
               "timestamp":"2018-10-30 T 10:45.76"
           }
       ],
       "downloads":[
           {
               "name":"bom",
               "file":"211/bom/ONSEC-18-004_REV1_bom.xlsx",
               "md5":"5gr07d9d372bb6826bd81d3542a419d6",
               "timestamp":"2018-10-30 T 10:45.76"
           }
       ],
   }
}
```
- Create/Update couchbase document by making a REST API request to the couchbase sync-gateway

## NOTE
##### Make any proper changes to the config.json configuration file. 
##### The configuration file contains 
`sync-gateway url, sync-gateway DB, and cloud services url`

## Usage

```pip install requests```

`python deployment_script.py [--config CONFIG] directory classId verboseName`

## TODO
- sync-gateway request is using GUEST user by default. Once we are going to secure the sync-gateway we need to adjust this change here as well.