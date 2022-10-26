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
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0
import tech.strata.logconf 1.0

SGWidgets.SGDialog {
    id: qtFilterRulesDialog

    property string filterRulesString

    title: "Edit qtFilterRules "
    modal: true
    focus: true
    destroyOnClose: true
    closePolicy: Dialog.NoAutoClose
    headerIcon: "qrc:/sgimages/edit.svg"


    QtFilterRulesModel {
        id: filterRulesModel
    }

    Component.onCompleted: {
        filterRulesModel.init(filterRulesString)
    }

    ColumnLayout {
        id: dialogContent
        anchors.fill: parent

        Rectangle {
            id: listViewBg
            Layout.minimumWidth: 250
            Layout.minimumHeight: {
                if (filterRulesModel.count <= 4) {
                    45 * filterRulesModel.count + filterRulesListView.topMargin + filterRulesListView.bottomMargin
                } else {
                    200
                }
            }

            border.color: Theme.palette.gray
            color: Theme.palette.lightGray

            ListView {
                id: filterRulesListView

                anchors {
                    fill: listViewBg
                    margins: 5
                }
                clip: true
                ScrollBar.vertical: ScrollBar {}
                spacing: 2
                model: filterRulesModel

                delegate: SGWidgets.SGTextField {
                    width: parent.width
                    text: filterName
                    placeholderText: "Filter rule input..."
                    onTextEdited: filterRulesModel.setItem(index, text)

                    onActiveFocusChanged: {
                        if (activeFocus == true) {
                            filterRulesListView.currentIndex = index
                        }
                    }
                }
            }
        }

        Row {
            spacing: 5
            Layout.alignment: Qt.AlignHCenter

            SGWidgets.SGIconButton {
                icon.source: "qrc:/sgimages/minus.svg"
                hintText: "Remove selected filter rule"
                onClicked: {
                    if (filterRulesListView.currentItem == null) {
                        console.log("Remove failed. No filter rule was selected for removing.")
                    } else {
                        filterRulesModel.removeItem(filterRulesListView.currentIndex)
                        filterRulesListView.currentIndex = -1
                    }
                }
            }

            SGWidgets.SGIconButton {
                icon.source: "qrc:/sgimages/plus.svg"
                hintText: "Add new filter rule"
                onClicked: {
                    filterRulesModel.appendItem("")
                    filterRulesListView.currentIndex = filterRulesModel.count - 1
                }
            }
        }

        SGWidgets.SGButton {
            text: "Apply"
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                filterRulesString = filterRulesModel.joinItems()
                qtFilterRulesDialog.accepted()
            }
        }
    }
}
