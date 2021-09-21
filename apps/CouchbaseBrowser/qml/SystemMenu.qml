/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import "Components"
import "Popups"


Rectangle {
    id: root

    color: "#222831"

    property bool startedListening: false
    property bool openedFile: false
    property bool onSingleDocument: false

    signal openFileSignal()
    signal newDatabaseSignal()
    signal newDocumentSignal()
    signal deleteDocumentSignal()
    signal editDocumentSignal()
    signal saveAsSignal()
    signal closeSignal()
    signal startListeningSignal()
    signal stopListeningSignal()
    signal newWindowSignal()

    RowLayout {
        id: row
        height: implicitHeight
        width: implicitWidth
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 15
        }

        spacing: 15
        CustomMenuItem {
            id: openFile
            Layout.preferredHeight: 50
            Layout.preferredWidth: implicitWidth

            filename: "qrc:/qml/Images/folder-icon.svg"
            label: "<b>Open</b>"
            onButtonPress: openFileSignal()
        }
        CustomMenuItem {
            id: newDocument
            Layout.preferredHeight: 50
            Layout.preferredWidth: implicitWidth

            filename: "qrc:/qml/Images/page-icon.svg"
            label: "<b>New Doc</b>"
            disable: !openedFile
            onButtonPress: newDocumentSignal()
        }
        CustomMenuItem {
            id: deleteDocument
            Layout.preferredHeight: 50
            Layout.preferredWidth: implicitWidth

            filename: "qrc:/qml/Images/trashcan-icon.svg"
            label: "<b>Delete Doc</b>"
            disable: !openedFile || !onSingleDocument
            onButtonPress: deleteDocumentSignal()
        }
        CustomMenuItem {
            id: editDocument
            Layout.preferredHeight: 50
            Layout.preferredWidth: implicitWidth

            filename: "qrc:/qml/Images/pencil-and-paper-icon.svg"
            label: "<b>Edit Doc</b>"
            disable: !openedFile || !onSingleDocument
            onButtonPress: editDocumentSignal()
        }
        CustomMenuItem {
            id: saveAs
            Layout.preferredHeight: 50
            Layout.preferredWidth: implicitWidth

            filename: "qrc:/qml/Images/floppy-disk-icon.svg"
            label: "<b>Save As</b>"
            disable: !openedFile
            onButtonPress: saveAsSignal()
        }
        CustomMenuItem {
            id: close
            Layout.preferredHeight: 50
            Layout.preferredWidth: implicitWidth

            filename: "qrc:/qml/Images/circle-with-x-icon.svg"
            label: "<b>Close</b>"
            visible: openedFile
            onButtonPress: {
                closeSignal()
                openedFile = false
                startedListening = false
            }
        }
    }

    RowLayout {
        id: newWindowLayout
        height: implicitHeight
        width: implicitWidth
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: 15
        }

        spacing: 15
        CustomMenuItem {
            id: startListening
            Layout.preferredHeight: 50
            Layout.preferredWidth: implicitWidth

            visible: !startedListening
            label: "<b>Start Listening</b>"
            filename: "Images/ear-icon.svg"
            disable: !openedFile
            onButtonPress: startListeningSignal()
        }
        CustomMenuItem {
            id: stopListening
            Layout.preferredHeight: 50
            Layout.preferredWidth: implicitWidth

            visible: startedListening
            label: "<b>Stop Listening</b>"
            filename: "Images/ear-with-x-icon.svg"
            onButtonPress: {
                stopListeningSignal()
                startedListening = false
            }
        }
        CustomMenuItem {
            id: newDB
            Layout.preferredHeight: 50
            Layout.preferredWidth: implicitWidth

            filename: "Images/database-icon.svg"
            label: "<b>New DB</b>"
            onButtonPress: newDatabaseSignal()
        }
        CustomMenuItem {
            id: newWindow
            Layout.preferredHeight: 50
            Layout.preferredWidth: implicitWidth

            label: "<b>New Window</b>"
            filename: "Images/duplicate-icon.svg"
            onButtonPress: newWindowSignal()
        }
    }
}

