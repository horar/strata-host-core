import QtQuick 2.10

Item {
    // Control View Creator only available in Debug builds
    visible: false

    state: "release"
    function toggleVisibility(){
        visible = false
    }
}
