# Spyglass Project Infrastructure:

* Platform - has been deprecated
* Host
* Cloud

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