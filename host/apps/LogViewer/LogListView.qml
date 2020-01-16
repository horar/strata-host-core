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
    property bool indexColumnVisible: true
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
    property int animationDuration: 500

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
        text: "9999-99-99 99:99.99.999 XXX+99:99"
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
        text: "Level"
    }

    TextMetrics {
        id: textMetricsSidePanel
        font: timestampHeaderText.font
        text: "Timestamp"
    }

    TextMetrics {
        id: textMetricsIndex
        font: timestampHeaderText.font
        text: "Row ID"
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
            height: messageHeaderText.contentHeight
            leftPadding: handleSpacer
            spacing: 8

            Item {
                id: indexHeader
                anchors.verticalCenter: parent.verticalCenter
                height: indexHeaderText.contentHeight + cellHeightSpacer
                width: textMetricsIndex.boundingRect.width + cellWidthSpacer
                visible: indexColumnVisible

                SGWidgets.SGText {
                    id: indexHeaderText
                    anchors {
                        left: indexHeader.left
                        verticalCenter: parent.verticalCenter
                    }
                    font.family: StrataFonts.Fonts.inconsolata
                    text: qsTr("Row ID")
                }
            }

            Divider {
                visible: indexColumnVisible
            }

            Item {
                id: tsHeader
                anchors.verticalCenter: parent.verticalCenter
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

            Divider {
                visible: timestampColumnVisible
            }

            Item {
                id: pidHeader
                anchors.verticalCenter: parent.verticalCenter
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

            Divider {
                visible: pidColumnVisible
            }

            Item {
                id: tidHeader
                anchors.verticalCenter: parent.verticalCenter
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

            Divider {
                visible: tidColumnVisible
            }

            Item {
                id: levelHeader
                anchors.verticalCenter: parent.verticalCenter
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

            Divider {
                visible: levelColumnVisible
            }

            Item {
                id: msgHeader
                anchors.verticalCenter: parent.verticalCenter
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
                        duration: animationDuration
                    }
                    ColorAnimation {
                        target: cell
                        property: "color"
                        from: highlightColor
                        to: index % 2 ? "#f2f0f0" : "white"
                        duration: animationDuration
                    }
                }
                SequentialAnimation {
                    ParallelAnimation {
                        ColorAnimation {
                            targets: [indexColumn,ts,pid,tid,msg]
                            properties: "color"
                            from: "black"
                            to: "white"
                            duration: animationDuration
                        }

                        ColorAnimation {
                            target: level
                            property: "color"
                            from: level.color
                            to: "white"
                            duration: animationDuration
                        }
                    }
                    ParallelAnimation {
                        ColorAnimation {
                            targets: [indexColumn,ts,pid,tid,msg]
                            properties: "color"
                            from: "white"
                            to: "black"
                            duration: animationDuration
                        }

                        ColorAnimation {
                            target: level
                            property: "color"
                            from: "white"
                            to: level.color
                            duration: animationDuration
                        }
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
                    }
                    if (index % 2) {
                        return "#f2f0f0"
                    }
                    else
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
                spacing: 18

                SGWidgets.SGText {
                    id: indexColumn
                    width: indexHeader.width
                    color: delegate.ListView.isCurrentItem ? "white" : "black"
                    font.family: StrataFonts.Fonts.inconsolata
                    text: visible ? model.rowIndex : ""
                    visible: indexColumnVisible
                }

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

                Rectangle {
                    id: levelTag
                    anchors.top: parent.top
                    anchors.topMargin: 1
                    height: level.height - 2
                    width: levelHeader.width
                    radius: 4
                    z: -1
                    color: {
                        if (model.level === "[W]") {
                            return SGWidgets.SGColorsJS.WARNING_COLOR
                        }
                        if (model.level === "[E]") {
                            return SGWidgets.SGColorsJS.ERROR_COLOR
                        }
                        else return cell.color
                    }
                    visible: levelColumnVisible

                    SGWidgets.SGText {
                        id: level
                        anchors.centerIn: parent
                        color: { delegate.ListView.isCurrentItem  || (model.level === "[W]" || model.level === "[E]") ? "white" : "black"
                        }
                        font.family: StrataFonts.Fonts.inconsolata
                        text: {
                            if (model.level === "[W]") {
                                return "WARN"
                            }
                            if (model.level === "[I]") {
                                return "INFO"
                            }
                            if (model.level === "[E]") {
                                return "ERROR"
                            }
                            if (model.level === "[D]") {
                                return "DEBUG"
                            }
                            if (level.visible === false) {
                                return ""
                            }
                            else {
                                return model.level
                            }
                        }
                    }
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

        if (event.key === Qt.Key_PageDown) {
            logListView.contentY = logListView.contentY + logListView.height
        }

        if (event.key === Qt.Key_PageUp) {
            logListView.contentY = logListView.contentY - logListView.height
        }

        if (event.key === Qt.Key_Home) {
            logListView.positionViewAtBeginning()
        }

        if (event.key === Qt.Key_End) {
            logListView.positionViewAtEnd()
        }
    }
}
