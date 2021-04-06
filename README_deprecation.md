# Platform Deprecation Note:

* Firmware development under spyglass has been deprecated and moved to platform-apps and embedded-strata-core repositories.
Checkout Hello Strata page for more details: https://confluence.onsemi.com/pages/viewpage.action?pageId=42449628

* To have an access to those deleted files, try using one of the following git commands:
  
  * Using git tag:

    ```git checkout platform```
  
  * Alternatively using git commit id:

    ```git checkout 280681185ad3b4e285097728b6cc8909ddaaca6e```
  
  * Another alternative is using `git worktree` on spyglass root directory:

    ```git worktree add ./platform platform```

# Deprecation Note #2:

## Directories and files that has been moved and removed 

* spyglass/platform_rsl10: Has been moved to: https://code.onsemi.com/projects/SECSWST/repos/embedded-portable-core/browse

## Directories and files that has been removed 
* spyglass/bitbucket-pipelines.yml
* spyglass/research-spike
* spyglass/DeploymentScript
* spyglass/cloud
* spyglass/CMakeLists.txt
* host/ui and host/ui_resources
* deployment/strata/patches/usb-pd-requestedId-retry-patch.patch
* deployment/strata/usbc-100w-installer.sh

#TODO: update tag and commit id right before merge to get the latest commit
* To retrieve spyglass old structure with the deleted files and directories, use one of the following methods:
  
  * Using git tag:

    ```git checkout ```
  
  * Alternatively using git commit id:

    ```git checkout ```