# Platform Deprecation Note:

* Firmware development under spyglass has been deprecated and moved to platform-apps and embedded-strata-core repositories.
Checkout Hello Strata page for more details: https://confluence.onsemi.com/pages/viewpage.action?pageId=42449628

* In case you want to have an access to those deleted files try using one of the following git commands:
  
  * Using git tag:

    ```git checkout platform```
  
  * Alternatively using git commit:

    ```git checkout 280681185ad3b4e285097728b6cc8909ddaaca6e```
  
  * Another alternative is using `git worktree` on spyglass root directory:

    ```git worktree add ./platform platform```

# Deprecation Note #2:

### spyglass/platform_rsl10 
* Has been moved to: https://code.onsemi.com/projects/SECSWST/repos/embedded-portable-core/browse

### spyglass/bitbucket-pipelines.yml
* Has been removed
  
### spyglass/research-spike
* has been removed

### spyglass/DeploymentScript
* has been removed

### spyglass/cloud
* has been removed

### spyglass/CMakeLists.txt
* has been removed

### host/ui and host/ui_resources
* has been removed

### host/ext_libs
* has been removed