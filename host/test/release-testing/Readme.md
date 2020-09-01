# Release Testing

These scripts were written to automate parts of the Strata release testing plan:
https://ons-sec.atlassian.net/wiki/spaces/SPYG/pages/775848204/Master+test+plan+checklist

# These tests cover the following

* Installation/uninstallation testing in different scenarios.
* Couchbase DB replication through HCS and check of contents.
* View image file download through HCS.
* Collateral file download through HCS.
* Login authentication and token testing.
* A display of every control view available to HCS.
* Verify that all released platforms are identified successfully by HCS.

# Software Requirements
1. PowerShell
  * PSSQLite module
2. Python3
  * pyzmq module
  * uiautomation module
  * requests module
3. JLink software

# Usage 
`.\Test-StrataRelease.ps1 -SDSInstallerPath <PATH-TO-THE-INSTALLER> [-EnablePlatformIdentificationTest]`

# Notes
1. This test was made to work with Windows. However, it is possible to run it on mac with some modifications on the paths and executables locations.
2. `Test-SDSControlViews` is disabled and it will be fixed in this story CS-626.
3. `Test-PlatformIdentification` is disabled by default, to enable this it, run `Test-StrataRelease.ps1` script with this optional flag `-EnablePlatformIdentificationTest`.
  * This test assumes that JLink software is installed in the default location `C:\Program Files (x86)\SEGGER\JLink\JLink.exe`.
  * This test requires connecting a platform and a JLink device to the test machine.
