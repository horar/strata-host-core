/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCpp
import Qt.labs.settings 1.1 as QtLabsSettings

SGWidgets.SGWindow {
    id: window
    width: 1024
    height: 768
    minimumWidth: 800
    minimumHeight: 600

    title: "Markdown syntax overview"

    Component.onCompleted: {
        mdTextArea.text = CommonCpp.SGUtilsCpp.readTextFileContent(":/resources/example.md")

        var savedScreenLayout = (settings.desktopAvailableWidth === Screen.desktopAvailableWidth)
                && (settings.desktopAvailableHeight === Screen.desktopAvailableHeight)

        window.x = (savedScreenLayout) ? settings.x : Screen.width / 2 - window.width / 2
        window.y = (savedScreenLayout) ? settings.y : Screen.height / 2 - window.height / 2
    }

    QtLabsSettings.Settings {
        id: settings
        category: "MdExampleWindow"

        property alias x: window.x
        property alias y: window.y
        property alias width: window.width
        property alias height: window.height

        property int desktopAvailableWidth
        property int desktopAvailableHeight

        Component.onDestruction: {
            desktopAvailableWidth = Screen.desktopAvailableWidth
            desktopAvailableHeight = Screen.desktopAvailableHeight
        }
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        color:"#eeeeee"
    }

    SGWidgets.SGSplitView {
        anchors.fill: parent

        Item {
            Layout.minimumWidth: 400

            SGWidgets.SGTextArea {
                id: mdTextArea
                anchors {
                    fill: parent
                    margins: 2
                }
            }
        }

        Item {
            Layout.minimumWidth: 200
            Layout.fillWidth: true

            SGWidgets.SGMarkdownViewer {
                anchors.fill: parent

                text: mdTextArea.text
            }
        }
    }
}
