import QtQuick 2.12

Item {
    id: controlViewCreatorRoot
    objectName: "ControlViewCreator"

    // Control View Creator only available in Debug Builds

    function blockWindowClose() {
        return false
    }
}
