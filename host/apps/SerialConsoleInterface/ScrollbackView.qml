import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.logger 1.0
import tech.strata.commoncpp 1.0 as CommonCpp
import tech.strata.sci 1.0 as Sci
import tech.strata.theme 1.0


Item {
    id: scrollbackView

    property variant model
    property bool disableAllFiltering
    property bool automaticScroll
    property var filterList
    readonly property int count: scrollbackFilterModel.count

    signal resendMessageRequested(string message)


    function invalidateFilter() {
        scrollbackFilterModel.invalidate()
    }

    function positionViewAtEnd() {
        listView.positionViewAtEnd()
    }

    // internal stuff
    property int buttonRowIconSize: SGWidgets.SGSettings.fontPixelSize - 4
    property int buttonRowSpacing: 2

    Timer {
        id: scrollbackViewAtEndTimer
        interval: 1

        onTriggered: {
            listView.positionViewAtEnd()
        }
    }

    CommonCpp.SGSortFilterProxyModel {
        id: scrollbackFilterModel
        sourceModel: scrollbackView.model
        filterRole: "message"
        sortEnabled: false
        invokeCustomFilter: true

        onRowsInserted: {
            if (automaticScroll) {
                scrollbackViewAtEndTimer.restart()
            }
        }

        function filterAcceptsRow(row) {
            if (filterList.length === 0) {
                return true
            }

            if (disableAllFiltering) {
                return true
            }

            var type = sourceModel.data(row, "type")
            if (type !== Sci.SciScrollbackModel.NotificationReply) {
                return true
            }

            var value = sourceModel.data(row, "value")

            for (var i = 0; i < platformDelegate.filterList.length; ++i) {
                var filterString = platformDelegate.filterList[i]["filter_string"].toString().toLowerCase();
                var filterCondition = platformDelegate.filterList[i]["condition"].toString();

                if (filterCondition === "contains" && value.includes(filterString)) {
                    return false
                } else if (filterCondition === "equal" && value === filterString) {
                    return false
                } else if (filterCondition === "startswith" && value.startsWith(filterString)) {
                    return false
                } else if (filterCondition === "endswith" && value.endsWith(filterString)) {
                    return false
                }
            }

            return true
        }
    }


    SGWidgets.SGIconButton {
        id: dummyIconButton
        visible: false
        icon.source: "qrc:/sgimages/chevron-right.svg"
        iconSize: scrollbackView.buttonRowIconSize
    }

    Rectangle {
        anchors.fill: parent
        color: "white"
    }

    ListView {
        id: listView
        anchors {
            fill: parent
            leftMargin: 2
            rightMargin: 2
        }

        model: scrollbackFilterModel
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar {
            width: 12
            policy: ScrollBar.AlwaysOn
            minimumSize: 0.1
            visible: listView.height < listView.contentHeight
        }

        delegate: Item {
            id: cmdDelegate
            width: ListView.view.width
            height: cmdText.height + 3

            property color helperTextColor: "#333333"

            Rectangle {
                id: messageTypeBg
                anchors {
                    top: parent.top
                    left: parent.left
                    right: buttonRow.right
                    bottom: divider.top
                }

                color: {
                    if (model.type === Sci.SciScrollbackModel.Request) {
                        return Qt.lighter(TangoTheme.palette.chocolate1, 1.3)
                    }

                    return "transparent"
                }
            }

            Rectangle {
                id: messageValidityBg
                anchors {
                    top: parent.top
                    left: messageTypeBg.right
                    right: parent.right
                    bottom: divider.top
                }

                color: {
                    if (model.isJsonValid === false) {
                        return Qt.lighter(TangoTheme.palette.error, 2.3)
                    }

                    return "transparent"
                }
            }

            SGWidgets.SGText {
                id: timeText
                anchors {
                    top: parent.top
                    topMargin: 1
                    left: parent.left
                    leftMargin: 1
                }

                text: model.timestamp
                font.family: "monospace"
                color: cmdDelegate.helperTextColor
            }

            Item {
                id: buttonRow
                height: dummyIconButton.height
                width: 2*dummyIconButton.width + scrollbackView.buttonRowSpacing
                anchors {
                    left: timeText.right
                    leftMargin: scrollbackView.buttonRowSpacing
                    verticalCenter: timeText.verticalCenter
                }

                Loader {
                    anchors {
                        left: parent.left
                        leftMargin: scrollbackView.buttonRowSpacing
                        verticalCenter: parent.verticalCenter
                    }

                    sourceComponent: model.type === Sci.SciScrollbackModel.Request ? resendButtonComponent : null
                }

                Loader {
                    anchors {
                        left: parent.left
                        leftMargin: dummyIconButton.width + scrollbackView.buttonRowSpacing
                    }

                    sourceComponent: condensedButtonComponent
                }
            }

            SGWidgets.SGTextEdit {
                id: cmdText
                anchors {
                    top: timeText.top
                    left: buttonRow.right
                    leftMargin: 1
                    right: parent.right
                    rightMargin: 2
                }

                textFormat: Text.PlainText
                font.family: "monospace"
                wrapMode: Text.WordWrap
                selectByKeyboard: true
                selectByMouse: true
                readOnly: true
                text: model.message
                selectionColor: TangoTheme.palette.selectedText
                selectedTextColor: "white"

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.IBeamCursor
                    acceptedButtons: Qt.NoButton
                }
            }

            Loader {
                id: syntaxHighlighterLoader
                sourceComponent: model.isJsonValid ? syntaxHighlighterComponent : null
            }

            Rectangle {
                id: divider
                height: 1
                anchors {
                    top: cmdText.bottom
                    topMargin: 1
                    left: parent.left
                    right: parent.right
                }

                color: "black"
                opacity: 0.2
            }

            Component {
                id: resendButtonComponent
                SGWidgets.SGIconButton {
                    iconColor: cmdDelegate.helperTextColor
                    hintText: qsTr("Resend")
                    iconSize: scrollbackView.buttonRowIconSize
                    icon.source: "qrc:/images/redo.svg"
                    onClicked: {
                        if (model.isJsonValid) {
                            var msg = CommonCpp.SGJsonFormatter.prettifyJson(model.message)
                        } else {
                            msg = model.message
                        }

                        resendMessageRequested(msg)
                    }
                }
            }

            Component {
                id: condensedButtonComponent
                SGWidgets.SGIconButton {
                    iconColor: cmdDelegate.helperTextColor
                    hintText: qsTr("Condensed mode")
                    iconSize: scrollbackView.buttonRowIconSize
                    enabled: model.isJsonValid
                    icon.source: {
                        if (model.isCondensed || model.isJsonValid === false) {
                            return "qrc:/sgimages/chevron-right.svg"
                        }
                         return "qrc:/sgimages/chevron-down.svg"
                    }

                    onClicked: {
                        var sourceIndex = scrollbackFilterModel.mapIndexToSource(index)
                        var item = scrollbackView.model.setIsCondensed(sourceIndex, !model.isCondensed)
                    }
                }
            }

            Component {
                id: syntaxHighlighterComponent
                CommonCpp.SGJsonSyntaxHighlighter {
                    textDocument: cmdText.textDocument
                }
            }
        }
    }
}
