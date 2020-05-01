Tests include:  
- Installation/uninstallation testing in different scenarios  
- Couchbase DB replication through HCS and check of contents  
- View image file download through HCS  
- Collateral file download through HCS  
- Login authentication and token testing  
- A display of every control view available to HCS  

These scripts were written to automate parts of the Strata release testing plan:  
https://ons-sec.atlassian.net/wiki/spaces/SPYG/pages/775848204/Master+test+plan+checklist  

To run:  

cd host/test/release-testing/  
.\Test-StrataRelease.ps1  

(you will be prompted for the installer executable to be tested).  