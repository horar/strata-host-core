import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.logger 1.0
import tech.strata.commoncpp 1.0 as CommonCpp

FocusScope {
    id: opnView

    property QtObject prtModel
    property int checkedOpnIndex: -1

    Keys.onDownPressed: listView.incrementCurrentIndex()
    Keys.onUpPressed: listView.decrementCurrentIndex()
    Keys.onEnterPressed: checkCurrentIndex()
    Keys.onReturnPressed: checkCurrentIndex()

    function checkCurrentIndex() {
        if (listView.currentIndex < 0) {
            return
        }

        checkedOpnIndex = opnSortFilterModel.mapIndexToSource(listView.currentIndex)
    }

    CommonCpp.SGSortFilterProxyModel {
        id: opnSortFilterModel
        sourceModel: prtModel.opnListModel
        filterRole: "opn"
        filterPattern: "*" + filterEdit.text + "*"
        filterPatternSyntax: CommonCpp.SGSortFilterProxyModel.Wildcard
        sortEnabled: false
    }

    ButtonGroup {
        id: exclusiveGroup
        exclusive: true
    }

    SGWidgets.SGTextField {
        id: filterEdit
        width: parent.width

        leftIconSource: "qrc:/sgimages/funnel.svg"
        placeholderText: "Filter by OPN..."
        focus: true
    }

    Rectangle {
        id: viewBg
        width: parent.width
        anchors {
            top: filterEdit.bottom
            topMargin: 4
            bottom: parent.bottom
        }

        color: "white"
        border.width: 1
        border.color: filterEdit.palette.mid
    }

    ListView {
        id: listView
        anchors {
            fill: viewBg
            margins: 1
        }

        model: opnSortFilterModel
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar {
            width: 12
            policy: ScrollBar.AlwaysOn
            minimumSize: 0.1
            visible: listView.height < listView.contentHeight
        }

        delegate: Item {
            id: delegate
            height: textColumn.height + 8
            width: parent.width

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    opnView.forceActiveFocus()
                    listView.currentIndex = index
                }
            }

            Rectangle {
                anchors.fill: parent

                color: {
                    if (delegate.ListView.isCurrentItem) {

                        if (filterEdit.activeFocus) {
                            return SGWidgets.SGColorsJS.PRIMARY_HIGHLIGHT
                        } else {
                            return Qt.rgba(0,0,0,0.4)
                        }
                    }

                    return index %2 === 0 ? "transparent" : Qt.rgba(0,0,0,0.05)
                }
            }

            SGWidgets.SGCheckBox {
                id: checkBox
                anchors {
                    left: parent.left
                    leftMargin: 8
                    verticalCenter: parent.verticalCenter
                }

                padding: 0
                text: ""
                ButtonGroup.group: exclusiveGroup
                focusPolicy: Qt.NoFocus

                onClicked: {
                    filterEdit.forceActiveFocus()

                    if (checked) {
                        checkedOpnIndex = opnSortFilterModel.mapIndexToSource(index)

                        listView.currentIndex = index
                    }
                }

                Binding {
                    target: checkBox
                    property: "checked"
                    value: checkedOpnIndex === opnSortFilterModel.mapIndexToSource(index)
                }
            }

            Column {
                id: textColumn
                width: parent.width
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: checkBox.right
                    leftMargin: 6
                }

                SGWidgets.SGText {
                    id: opnText
                    width: parent.width

                    text: model.opn
                    font.bold:  true
                    fontSizeMultiplier: 1.2
                    alternativeColorEnabled: delegate.ListView.isCurrentItem
                }

                SGWidgets.SGText {
                    id: verboseNameText
                    width: parent.width

                    text: model.verboseName
                    alternativeColorEnabled: delegate.ListView.isCurrentItem
                }
            }
        }
    }
}
