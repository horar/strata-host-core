Host Constroller Service:


The current host controller service contains the Nimbus files as well. While we are working the way to build Nimbus files, please apply the patch file in spyglass/host/HostControllerServices folder to remove the nimbus files from your directory.

Before applying the patch, make sure you are in the spyglass root directory.

The command to apply the patch,
```
git apply host/HostControllerService/patch/remove_nimbus_from_HCS.patch
```

