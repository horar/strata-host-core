/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.logconf 1.0 as LcuPlugin

SGWidgets.SGDialog {
    id: wgSettingsDialog

    title: "Settings"
    headerIcon: "qrc:/sgimages/tools.svg"
    modal: true
    focus: true
    destroyOnClose: true

    property int innerSpacing: 5

    ColumnLayout {
        id: wgSettings
        anchors.fill: parent
        spacing: innerSpacing

        SGWidgets.SGText {
            text: "Logging Configuration"
            fontSizeMultiplier: 1.3
            font.bold: true
            Layout.alignment: Qt.AlignVCenter
            Layout.minimumHeight: logLevel.height
        }

        LcuPlugin.LogLevel {
            id: logLevel
            Layout.fillWidth: true
            fileName: Qt.application.name
        }


        LcuPlugin.LogDetails {
            id: logDetails
            Layout.fillWidth: true
            fileName: Qt.application.name
            lcuApp: false
        }

        SGWidgets.SGButton {
            id: closeButton

            text: "Close"
            fontSizeMultiplier: 1.3
            font.bold: true
            Layout.alignment: Qt.AlignCenter
            Layout.minimumHeight: logLevel.height
            Layout.minimumWidth: 2*height
            onClicked: wgSettingsDialog.accepted()
            background: Rectangle {
                anchors.fill: parent
                radius: innerSpacing
                color: parent.hovered ? headerBgColor : closeButton.implicitColor
            }
        }
    }
}
