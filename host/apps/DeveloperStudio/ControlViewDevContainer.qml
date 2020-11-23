import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.commoncpp 1.0
import tech.strata.sgwidgets 1.0

import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/constants.js" as Constants

Item {
    Layout.fillWidth: true
    Layout.fillHeight: true
    
    Loader {
        id: controlViewLoader
        objectName: "controlViewDevContainer"
        anchors.fill: parent

        asynchronous: true
        onStatusChanged: {
            if (status === Loader.Ready) {
                // Tear down creation context
                delete NavigationControl.context.class_id
                delete NavigationControl.context.device_id
            } else if (status === Loader.Error) {
                delete NavigationControl.context.class_id
                delete NavigationControl.context.device_id

                console.error("Error while loading control view")
                setSource(NavigationControl.screens.LOAD_ERROR, {"error_message": "Could not load control view"})
            }
        }
    }

    SGUserSettings {
        id: sgUserSettings
        classId: "controlViewDevContainer"
        user: NavigationControl.context.user_id
    }

    function setSource(path, initialProperties = null) {
        if (initialProperties) {
            controlViewLoader.setSource(path, initialProperties)
        } else {
            controlViewLoader.setSource(path)
        }
    }
}
