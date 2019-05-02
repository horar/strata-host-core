import QtQuick 2.9
import QtQuick.Controls 2.3
import "qrc:/js/platform_selection.js" as PlatformSelection
import Fonts 1.0

Item {
    id: root
    implicitHeight: filterContainer.height + 160*2.5
    width: listviewBackground.width

    Rectangle {
        id: filterContainer
        anchors {
            bottom: listviewContainer.top
            horizontalCenter: listviewBackground.horizontalCenter
        }
        height: 30
        width: listviewBackground.width
        border {
            width: 1
            color: "#DDD"
        }

        TextInput {
            id: filter
            text: ""
            anchors {
                verticalCenter: filterContainer.verticalCenter
                left: filterContainer.left
                leftMargin: 10
                right: filterContainer.right
                rightMargin: 10
            }
            color: "black"
            selectByMouse: true

            Text {
                id: placeholderText
                text: "Filter Platforms..."
                color: "#AAA"
                visible: filter.text === ""
                anchors {
                    left: filter.left
                    verticalCenter: filter.verticalCenter
                }
            }

            onTextChanged: {
                if (text.length > 0) {
                    applyFilter(PlatformSelection.platformListModel, resultList, text)
                    listview.model = resultList
                } else {
                    listview.model = PlatformSelection.platformListModel
                }
            }

            ListModel {
                id: resultList
            }

            function applyFilter(inputList, outputList, cmd) {
                cmd = cmd.toLowerCase()
                outputList.clear()
                for( var i=0; i < inputList.count ; ++i )
                {
                    var platform = inputList.get(i)
                    var keywords = platform.description + " " + platform.on_part_number + " " + platform.verbose_name
                    if(keywords.toLowerCase().includes(cmd))
                    {
                        outputList.append(inputList.get(i))
                    }
                }
            }
        }
    }

    Rectangle {
        id: listviewBackground
        color: "white"
        border {
            width: 1
            color: "#DDD"
        }
        anchors {
            centerIn: listviewContainer
        }
        width: listviewContainer.width+2
        height: listviewContainer.height+2
    }

    Item {
        id: listviewContainer
        height: root.height - filterContainer.height
        width: 950
        clip: true
        anchors {
            top: filterContainer.bottom
        }

        Image {
            id: maskTop
            height: 30
            source: "images/whiteFadeMask.svg"
            anchors {
                top: listviewContainer.top
                left: listviewContainer.left
                leftMargin: 1
                right: listviewContainer.right
                rightMargin: 1
            }
            z: 1
        }

        Image {
            id: maskBottom
            height: 30
            anchors {
                bottom: listviewContainer.bottom
                left: listviewContainer.left
                leftMargin: 1
                right: listviewContainer.right
                rightMargin: 1
            }
            source: maskTop.source
            z: 1

            transform: Rotation {
                origin.y: maskBottom.height/2
                origin.x: maskBottom.width/2
                axis { x: 1; y: 0; z: 0 }
                angle: 180
            }
        }

        ListView {
            id: listview
            anchors {
                bottom: listviewContainer.bottom
                left: listviewContainer.left
                right: listviewContainer.right
                top: listviewContainer.top
            }

            property real delegateHeight: 160
            property real delegateWidth: 950

            Component.onCompleted: {
                model = PlatformSelection.platformListModel
                currentIndex = Qt.binding( function() { return PlatformSelection.platformListModel.currentIndex })
            }

            delegate: SGPlatformSelectorDelegate {
                height: listview.delegateHeight
                width: listview.delegateWidth
                isCurrentItem: ListView.isCurrentItem
            }

            highlight: highlightBar
            highlightFollowsCurrentItem: false
            ScrollBar.vertical: ScrollBar {
                width: 12
                anchors {
                    top: listview.top
                    bottom: listview.bottom
                    right: listview.right
                }
                policy: ScrollBar.AlwaysOn
                minimumSize: 0.1
                visible: listview.height < listview.contentHeight
            }

            Component {
                id: highlightBar
                Rectangle {
                    width: listview.delegateWidth
                    height: listview.delegateHeight
                    color: "#eee"
                    y: listview.currentItem ? listview.currentItem.y : 0
                }
            }
        }
    }
}
