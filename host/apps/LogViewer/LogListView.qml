import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.fonts 1.0 as StrataFonts

Item {
    id: logViewWrapper

    property alias model: logListView.model
    property alias currentIndex: logListView.currentIndex
    property int cellWidthSpacer: 6
    property int cellHeightSpacer: 6
    property int checkBoxSpacer: 60
    property int handleSpacer: 5
    property int searchResultCount: model.count
    property bool timestampColumnVisible: true
    property bool pidColumnVisible: true
    property bool tidColumnVisible: true
    property bool levelColumnVisible: true
    property bool messageColumnVisible: true
    property bool startAnimation: false
    property bool sidePanelShown: true
    property int sidePanelWidth: 150
    property bool messageWrapEnabled: true
    property bool searchTagShown: false
    property var highlightColor
    property int requestedWidth: 1
    property alias contentX: logListView.contentX

    signal newWidthRequested()
    signal currentItemChanged(int index)

    function positionViewAtIndex(index, param) {
        logListView.positionViewAtIndex(index, param)
    }

    function resetRequestedWith() {
        requestedWidth = 0
    }

    //fontMetrics.boundingRect(text) does not re-evaluate itself upon changing the font size
    TextMetrics {
        id: textMetricsTs
        font: timestampHeaderText.font
        text: "9999-99-99 99:99.99.999 XXX+99:9999"
    }

    TextMetrics {
        id: textMetricsPid
        font: timestampHeaderText.font
        text: "9999999999"
    }

    TextMetrics {
        id: textMetricsTid
        font: timestampHeaderText.font
        text: "9999999999"
    }

    TextMetrics {
        id: textMetricsLevel
        font: timestampHeaderText.font
        text: "[ 99 ]"
    }

    TextMetrics {
        id: textMetricsSidePanel
        font: timestampHeaderText.font
        text: " Timestamp "
    }

    Item {
        id: header
        anchors.top: parent.top
        width: if (logListView.contentWidth < logListView.width) {
                   return logListView.width
               } else {
                   return logListView.contentWidth
               }
        height: headerContent.height + 8
        x: -logViewWrapper.contentX

        Rectangle {
            id: headerBg
            anchors.fill: parent
            color: "lightgray"
        }

        Row {
            id: headerContent
            anchors {
                verticalCenter: parent.verticalCenter
            }
            leftPadding: handleSpacer

            Item {
                id: tsHeader
                height: timestampHeaderText.contentHeight + cellHeightSpacer
                width: textMetricsTs.boundingRect.width + cellWidthSpacer
                visible: timestampColumnVisible

                SGWidgets.SGText {
                    id: timestampHeaderText
                    anchors {
                        left: tsHeader.left
                        verticalCenter: parent.verticalCenter
                    }
                    font.family: StrataFonts.Fonts.inconsolata
                    text: qsTr("Timestamp")
                }
            }

            Item {
                id: pidHeader
                height: pidHeaderText.contentHeight + cellHeightSpacer
                width: textMetricsPid.boundingRect.width + cellWidthSpacer
                visible: pidColumnVisible

                SGWidgets.SGText {
                    id: pidHeaderText
                    anchors {
                        left: pidHeader.left
                        verticalCenter: parent.verticalCenter
                    }
                    font.family: StrataFonts.Fonts.inconsolata
                    text: qsTr("PID")
                }
            }

            Item {
                id: tidHeader
                height: tidHeaderText.contentHeight + cellHeightSpacer
                width: textMetricsTid.boundingRect.width + cellWidthSpacer
                visible: tidColumnVisible

                SGWidgets.SGText {
                    id: tidHeaderText
                    anchors {
                        left: tidHeader.left
                        verticalCenter: parent.verticalCenter
                    }
                    font.family: StrataFonts.Fonts.inconsolata
                    text: qsTr("TID")
                }
            }

            Item {
                id: levelHeader
                height: levelHeaderText.contentHeight + cellHeightSpacer
                width: textMetricsLevel.boundingRect.width + cellWidthSpacer
                visible: levelColumnVisible

                SGWidgets.SGText {
                    id: levelHeaderText
                    anchors {
                        left: levelHeader.left
                        verticalCenter: parent.verticalCenter
                    }
                    font.family: StrataFonts.Fonts.inconsolata
                    text: qsTr("Level")
                }
            }

            Item {
                id: msgHeader
                height: messageHeaderText.contentHeight + cellHeightSpacer
                width: messageHeaderText.contentWidth + cellWidthSpacer
                visible: messageColumnVisible

                SGWidgets.SGText {
                    id: messageHeaderText
                    anchors {
                        left: msgHeader.left
                        verticalCenter: parent.verticalCenter
                    }
                    font.family: StrataFonts.Fonts.inconsolata
                    text: qsTr("Message")

                    onFontChanged: {
                        logViewWrapper.contentX = 0
                        if(visible === false) {
                            return
                        }
                        requestNewWidthTimer.start()
                    }
                }
            }
        }
    }

    Timer {
        id: requestNewWidthTimer
        interval: 100
        onTriggered: {
            requestedWidth = 1
            newWidthRequested()
        }
    }

    SGWidgets.SGTag {
        id: searchTag
        anchors {
            right: logListView.right
            verticalCenter: header.verticalCenter
            rightMargin: 5
        }
        visible: searchTagShown
        text: searchResultCount == 1 ? "Search Result: " + searchResultCount : "Search Results: " + searchResultCount
    }

    ListView {
        id: logListView
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        contentWidth: messageWrapEnabled ? parent.width : requestedWidth
        flickableDirection: Flickable.HorizontalAndVerticalFlick
        boundsMovement: Flickable.StopAtBounds
        boundsBehavior: Flickable.DragAndOvershootBounds
        highlightMoveDuration: 0
        highlightMoveVelocity: -1
        clip: true
        headerPositioning: ListView.OverlayHeader

        ScrollBar.vertical: ScrollBar {
            minimumSize: 0.1
            policy: ScrollBar.AlwaysOn
        }

        ScrollBar.horizontal: ScrollBar {
            visible: !messageWrapEnabled
            minimumSize: 0.1
            policy: ScrollBar.AlwaysOn
        }

        delegate: FocusScope {
            id: delegate
            width: row.width
            height: row.height

            function setRequestedWidth() {
                if (delegate.width > requestedWidth) {
                    requestedWidth = delegate.width
                }
            }

            onWidthChanged: {
                setRequestedWidth()
            }

            Connections {
                target: logViewWrapper
                onNewWidthRequested: {
                    setRequestedWidth()
                }
            }

            ListView.onCurrentItemChanged : {
                if (ListView.isCurrentItem && startAnimation) {
                    cellAnimation.start()
                } else {
                    cellAnimation.complete()
                }
            }

            ParallelAnimation {
                id: cellAnimation
                loops: 1
                running: false
                SequentialAnimation {
                    ColorAnimation {
                        target: cell
                        property: "color"
                        from: "white"
                        to: highlightColor
                        duration: 400
                    }
                    ColorAnimation {
                        target: cell
                        property: "color"
                        from: highlightColor
                        to: "white"
                        duration: 400
                    }
                }
                SequentialAnimation {
                    ColorAnimation {
                        targets: [ts,pid,tid,level,msg]
                        properties: "color"
                        from: "black"
                        to: "white"
                        duration: 400
                    }
                    ColorAnimation {
                        targets: [ts,pid,tid,level,msg]
                        properties: "color"
                        from: "white"
                        to: "black"
                        duration: 400
                    }
                }
            }

            Rectangle {
                id: cell
                height: parent.height
                width: if (requestedWidth > root.width) {
                           return requestedWidth
                       } else {
                           return root.width
                       }
                color: {
                    if (delegate.ListView.isCurrentItem) {
                        if (logViewWrapper.activeFocus) {
                            return highlightColor
                        } else {
                            return "darkgray"
                        }
                    } else
                        return "white"
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed:  {
                        logViewWrapper.forceActiveFocus()
                        logListView.currentIndex = index
                        currentItemChanged(index)
                    }
                }
            }

            Row {
                id: row
                leftPadding: handleSpacer

                SGWidgets.SGText {
                    id: ts
                    width: tsHeader.width
                    color: delegate.ListView.isCurrentItem ? "white" : "black"
                    font.family: StrataFonts.Fonts.inconsolata
                    text: visible ? model.timestamp : ""
                    visible: timestampColumnVisible
                }

                SGWidgets.SGText {
                    id: pid
                    width: pidHeader.width
                    color: delegate.ListView.isCurrentItem ? "white" : "black"
                    font.family: StrataFonts.Fonts.inconsolata
                    text: visible ? model.pid : ""
                    visible: pidColumnVisible
                }

                SGWidgets.SGText {
                    id: tid
                    width: tidHeader.width
                    color: delegate.ListView.isCurrentItem ? "white" : "black"
                    font.family: StrataFonts.Fonts.inconsolata
                    text: visible ? model.tid : ""
                    visible: tidColumnVisible
                }

                SGWidgets.SGText {
                    id: level
                    width: levelHeader.width
                    color: delegate.ListView.isCurrentItem ? "white" : "black"
                    font.family: StrataFonts.Fonts.inconsolata
                    text: visible ? model.level : ""
                    visible: levelColumnVisible
                }

                SGWidgets.SGText {
                    id: msg
                    width: messageWrapEnabled ? (logListView.width - msg.x) : msg.contentWidth
                    color: delegate.ListView.isCurrentItem ? "white" : "black"
                    font.family: StrataFonts.Fonts.inconsolata
                    text: visible ? model.message : ""
                    visible: messageColumnVisible
                    wrapMode: messageWrapEnabled ? Text.WrapAtWordBoundaryOrAnywhere : Text.NoWrap
                }
            }
        }
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Up && currentIndex > 0){
            currentIndex = currentIndex - 1
            currentItemChanged(currentIndex)
        }
        else if (event.key === Qt.Key_Down && currentIndex < (searchResultCount - 1)) {
            currentIndex = currentIndex + 1
            currentItemChanged(currentIndex)
        }
    }
}
