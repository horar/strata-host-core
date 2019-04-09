import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.prt 1.0 as PrtCommon
import "./SgUtils.js" as SgUtils
import "./Colors.js" as Colors

FocusScope {
    id: control
    width: 200
    height: Math.max(defaultLineHeight, flow.childrenRect.height + flow.padding)

    property variant tagModel
    property color tagColor: Colors.STRATA_GREEN
    property bool isValid: true
    property bool activeEditing: suggestionPopup.opened
    property bool validationReady: false
    property int defaultLines: 1
    property int defaultLineHeight: defaultLines*(dummyTag.height + flow.spacing) - flow.spacing + 2*flow.padding

    PrtCommon.SgSortFilterProxyModel {
        id: flowModel
        sourceModel: tagModel
        sortRole: "value"
        filterRole:  "selected"
        filterPattern: "true"
    }

    PrtCommon.SgSortFilterProxyModel {
        id: suggestionListModel
        sourceModel: tagModel
        sortRole: "value"
    }

    function getSelectedTags() {
        var list = []
        for(var i = 0; i < flowModel.count; ++i) {
            list.push(flowModel.get(i)["value"])
        }

        return list
    }

    Rectangle {
        anchors {
            fill: parent
        }

        color: dummyControl.palette.base
        border {
            width: control.activeFocus ? 2 : 1
            color: {
                if (control.activeFocus) {
                    return dummyControl.palette.highlight
                } else if (isValid) {
                    return dummyControl.palette.mid
                } else {
                    return Colors.ERROR_COLOR
                }
            }
        }
    }

    //this is here just to catch inputs
    TextInput {
        id: textInput
        text: ""
        selectByMouse: true
        activeFocusOnTab: true
        cursorDelegate: Item {}

        Keys.forwardTo: suggestionPopup.contentItem
        Keys.priority: Keys.BeforeItem

        onActiveFocusChanged: {
            if (activeFocus) {
                control.validationReady = true
            }
        }

        Keys.onPressed: {
            if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
                return
            }

            if (event.key === Qt.Key_Space|| event.key === Qt.Key_Down) {
                if (suggestionPopup.opened) {
                    return
                } else {
                    suggestionPopup.open()
                }
            }

            event.accepted = true
        }
    }

    Control {
        id: dummyControl
    }

    SgTag {
        id: dummyTag
        hasIcon: true
        text: "longest possible text"
        visible: false
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor
        onClicked: {
            openPopup()
        }
    }

    function openPopup() {
        if (textInput.activeFocus) {
            if (!suggestionPopup.opened) {
                suggestionPopup.open()
            }
        } else {
            textInput.forceActiveFocus()
        }
    }

    SgTagFlow {
        id: flow
        anchors {
            fill: parent
        }

        padding: 6 + 6
        model: flowModel
        tagColor: control.tagColor
    }

    SgSuggestionPopup {
        id: suggestionPopup

        textEditor: control
        model: suggestionListModel
        listSpacing: 0
        highlight: null
        controlWithSpace: true
        closeOnSelection: false
        openOnActiveFocus: true

        onDelegateSelected: {
            var sourceIndex = suggestionListModel.mapIndexToSource(index)
            var item = tagModel.get(sourceIndex)
            tagModel.setProperty(sourceIndex, "selected", !item.selected)
        }

        delegate: Item {
            id: wrapper
            width: ListView.view.width
            height: content.height + (isLast ? 0 : divider.height)

            property bool isLast: index === ListView.view.count - 1

            Rectangle {
                id: bg
                anchors.fill: content
                color: wrapper.ListView.isCurrentItem ? dummyControl.palette.highlight : "transparent"
            }

            Item {
                id: content
                width: parent.width
                height: tagItem.height + 4

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        wrapper.ListView.view.currentIndex = index
                        suggestionPopup.delegateSelected(index)
                    }
                }

                SgIcon {
                    id: checkMark
                    anchors {
                        verticalCenter: content.verticalCenter
                        left: parent.left
                        leftMargin: 4
                    }

                    sourceSize.height: Math.floor(tagItem.height * 0.8)
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/images/check.svg"
                    visible: model.selected
                    iconColor: Qt.lighter("green")
                }

                SgTag {
                    id: tagItem
                    anchors {
                        verticalCenter: content.verticalCenter
                        left: checkMark.right
                        leftMargin: 4
                    }

                    text: SgUtils.resolveTag(model.value, "text")
                    icon: SgUtils.resolveTag(model.value, "icon")
                    tagColor: control.tagColor
                }

                SgText {
                    id: descriptionText
                    anchors {
                        verticalCenter: content.verticalCenter
                        left: tagItem.left
                        leftMargin: dummyTag.width + 4
                        right: parent.right
                        rightMargin: 8
                    }

                    text: SgUtils.resolveTag(model.value, "description")
                    maximumLineCount: 2
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    hasAlternativeColor: wrapper.ListView.isCurrentItem
                }
            }

            Rectangle {
                id: divider
                anchors {
                    left: parent.left
                    leftMargin: 10
                    right: parent.right
                    rightMargin: 10
                    top: content.bottom
                }

                visible: !isLast
                color: dummyControl.palette.mid
                height: 1
            }
        }
    }
}
