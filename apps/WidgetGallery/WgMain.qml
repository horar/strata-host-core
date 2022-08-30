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
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0

Item {

    ListModel {
        id: pageModel

        ListElement {
            name: "SGWidgets 1.0"
            page: "widgets1_0/PageSGWidgetsOneZero.qml"
        }

        ListElement {
            name: "SGWidgets 2.0"
            page: "widgets2_0/PageSGWidgetsTwoZero.qml"
        }

        ListElement {
            name: "CommonCpp 1.0"
            page: "commoncpp1_0/PageSGCommonCppOneZero.qml"
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent

        initialItem: welcomePage
    }

    Component {
        id: welcomePage

        Item {
            Grid {
                anchors.centerIn: parent
                spacing: 20

                Repeater {
                    id: pageRepeater
                    model: pageModel
                    delegate: SGWidgets.SGButton {
                        minimumContentHeight: 100
                        minimumContentWidth: 200
                        fontSizeMultiplier: 1.6
                        color: TangoTheme.palette.chameleon2
                        text: model.name
                        onClicked: {
                            stackView.push(model.page)
                        }
                    }
                }
            }
        }
    }
}
