/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0

Popup {
    id: root
    closePolicy: Popup.NoAutoClose

    property alias title: errorListTitle.text
    property alias qmlErrorListModel: qmlErrorListView.model

    contentItem: ColumnLayout {

        RowLayout {
            spacing: 10
            
            Label {
                id: errorListTitle
                Layout.fillWidth: true
                color: "red"
                font {
                    bold: true
                }
            }

            SGIcon {
                id: clean
                source: "qrc:/sgimages/broom.svg"
                implicitHeight: 30
                implicitWidth: 30
                iconColor: "grey"

                MouseArea {
                    anchors {
                        fill: parent
                    }
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked:  {
                        qmlErrorListModel.clear()
                    }
                }
            }
            
            SGIcon {
                id: close
                source: "qrc:/sgimages/times-circle.svg"
                implicitHeight: 30
                implicitWidth: 30
                iconColor: "grey"

                MouseArea {
                    anchors {
                        fill: parent
                    }
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked:  {
                        root.visible = false
                    }
                }
            }
        }
        
        SGQmlErrorListView {
            id: qmlErrorListView
            focus: true

            delegate: SGQmlErrorListViewDelegate {}
        }
    }
}
