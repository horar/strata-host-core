import QtQuick 2.12

import QtQuick.XmlListModel 2.0

MainWindowForm {
    property string tmp: ""

    buttonUpdate.onClicked: {
        updateWatchdog.silentUpdate();
    }
    buttonInstall.onClicked: {
        updateWatchdog.installComponent();
    }

    Timer {
        id: checkUpdatesTiemr

        interval: updateInterval
        running: updateActivated
        repeat: true

        onTriggered: {
            updateWatchdog.checkForUpdate();
        }
    }

    XmlListModel {
        id: xmlModel
        xml: tmp
        query: "/updates/update"

        XmlRole { name: "name"; query: "@name/string()" }
        XmlRole { name: "version"; query: "@version/string()" }
        XmlRole { name: "size"; query: "@size/string()" }

        onXmlChanged: console.log("===> new 'tmp': " + tmp)
    }

    Connections {
        target: updateWatchdog
        onOutputChanged: {
            tmp = output
            console.log(" ===>" + xmlModel.count)

            textAreaText += new Date() + '\n----------------------------------------------------------------------\n'
            textAreaText += tmp + "----------------------------------------------------------------------\n"
        }

    }
}
