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
* Opening of control views via OTA.

# Software Requirements
1. PowerShell
  * PSSQLite module
2. Python3
  * pyzmq module
  * uiautomation module
  * requests module
3. JLink software

# Usage 

## Testing an installer build
The below example runs the installer executable.

`.\Test-StrataRelease.ps1 -SDSInstallerPath <PATH-TO-THE-INSTALLER> [-EnablePlatformIdentificationTest] [-IncludeOTA]`

## Testing a pre-built executable
To run a pre-built `Strata Developer Studio.exe`, run the `Test-StrataWithoutInstaller.ps1` script. This script also allows you to choose which tests you want to run by specifying them in a comma-separated list inside of the `-TestsToRun` argument. The options are:
* `all` - Runs all tests
* `gui` - Runs the GUI tests
* `database` - Runs the database tests
* `collateral` - Runs the collateral tests
* `controlViews` - Runs the control views tests **Currently not working
* `hcs` - Runs the HCS tests
* `platformIndentification` - Runs the platform identification tests
* `tokenAndViews` - Runs the login token and views tests

It should be noted that in order to run OTA tests, the `-IncludeOTA` argument must be supplied. Also, if the `all` option is used, the platformIdentification and OTA tests will not be included unless it explicity added via the `-EnablePlatformIdentificationTest` argument. Ex) `-TestsToRun all -EnablePlatformIdentificationTest -IncludeOTA`

Example:

`.\Test-StrataWithoutInstaller.ps1 -SDSExecPath <PATH-TO-THE-EXECUTABLE-FILE> -TestsToRun gui,database,hcs -DPEnv [DEV | QA] [-EnablePlatformIdentificationTest] [-IncludeOTA]`

# Notes
1. This test was made to work with Windows. However, it is possible to run it on mac with some modifications on the paths and executables locations.
2. `Test-SDSControlViews` is disabled and it will be fixed in this story CS-626.
3. `Test-PlatformIdentification` is disabled by default, to enable this it, run `Test-StrataRelease.ps1` script with this optional flag `-EnablePlatformIdentificationTest`.
  * This test assumes that JLink software is installed in the default location `C:\Program Files (x86)\SEGGER\JLink\JLink.exe`.
  * This test requires connecting a platform and a JLink device to the test machine.
4. OTA tests are disabled by default unless the `-IncludeOTA` argument is provided
5. For the `Test-StrataWithoutInstaller` script, make sure that your `-DPEnv` is set to the environment that you built the executable in. For example, if HCS is configured to be communicating with the DEV deployment portal, make sure that you pass in `-DPEnv DEV`.
