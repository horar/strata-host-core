# RS: simple apps self-update/reload

Goals:
- update and install new components via maintenance tool and live server
- reload Qt plugins with resources or plain Qt resource file

2 demo apps:
- IFW package created by CMake
    - adv.: re-use version strings from CMake
    - disadv.: complicated, looks like CMake doesn't support 100% of IFw features (?)
- demo update app (experiment - plugin/resource reloading)


## demo 1 - check for updates
 1. make online installer based on how-to in sibling 'shell' folder
 2. start http server handling package repository
 3. install sw via on-line installer (needed only to get maintenance tool used to access the repo-server)
 4. build this project; choose 'strata' run configuration
 5. copy above from installed tool location to the app build/bin folder side-by-side to 'strata' folder following files:
     components.xml
     maintenancetool.app
     maintenancetool.dat
     maintenancetool.ini
     network.xml
 6. enable server poll i.e. 'updates watchdog'
 7. switch to 'shell' project; modify e.g. hcs2 package version in './setup/packages/tech.spyglass.strata.hcs2.osx/meta/package.xml'
 8. re-generate packages
 9. new packages appears in main UI window packages list
10. push update button


## demo 2 - reload updated plugin/binary resource file

### Compilation
1. load project in QtCreator & build as standard CMake project
2. start app (updates-plugin-test)
3. trigger plugin/resource reload buttons; qml-engine restart button...
4. go to build folder and rename 'libsgwidgets.so' and rename 'sgwidgets2.rcc'
5. modify files in editor:
    - e.g. color in:
        - './ota/gui/strata/plugins/sgwidgets/qml/OnSemiQuick/Bob.qml'
        - './ota/gui/strata/plugins/sgwidgets2/qml/OnSemiQuick2/Bob.qml'
    - e.g. model in:
        - './ota/gui/strata/plugins/sgwidgets/qml/OnSemiQuick/Alice.qml'
        - './ota/gui/strata/plugins/sgwidgets2/qml/OnSemiQuick2/Alice.qml'
6. compile & start app again
7. again; go to build folder and rename 'libsgwidgets.so' and rename 'sgwidgets2.rcc'
8. replace existing above mentioned 'so' and 'rcc' files with those renamed one
9. click again buttons in app to reload plugin/resources or restart engine -> items in main windows are changed

### Conclusions
#### binary Qt plugin
- adv:
    - introduce defined interface for version, name etc.
    - loading/unloading may trigger different activities (etc. upgrade/change cfg/db if necessary)
- disadv:
    - window is locking DLL;
    - multiple packages in repository for one module (one pkg for every platform)

#### binary Qt resource file
-adv:
    - small, compact file
    - multiplatform modules (most of them)
- disadv:
    - any version/name/description require extra info/cfg file inside binary
