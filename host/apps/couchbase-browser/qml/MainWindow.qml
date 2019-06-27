import QtQuick 2.0
import QtQuick.Layouts 1.12
Item {
    id: root
    anchors.fill: parent

    property var content: ""
    property var jsonObj

    onContentChanged: {
        if (content !== "") {
            let tempModel = ["All documents"];
            jsonObj = JSON.parse(content);
            for (let i in jsonObj) tempModel.push(i);
            let prevID = tableSelectorView.model[tableSelectorView.currentIndex];
            let newIndex = tempModel.indexOf(prevID);
            if (newIndex === -1) newIndex = 0;
            tableSelectorView.model = tempModel;

            if (tableSelectorView.currentIndex === newIndex) {
                if (tableSelectorView.currentIndex !== 0)
                    bodyView.content = JSON.stringify(jsonObj[tableSelectorView.model[tableSelectorView.currentIndex]],null,4);
                else
                    bodyView.content = JSON.stringify(jsonObj,null,4);
            }
            else
                tableSelectorView.currentIndex = newIndex;
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#b55400"
        GridLayout {
            id: gridview
            anchors.fill: parent
            rows: 2
            columns: 2
            columnSpacing: 1
            rowSpacing: 1


            Rectangle {
                id: menuContainer
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: 82
                Layout.row: 0
                Layout.columnSpan: 2
                color: "#222831"
                SystemMenu {
                    id: mainMenuView
                    anchors {
                        fill: parent
                        bottomMargin: 10
                    }

                }
            }
            Rectangle {
                id: selectorContainer
                Layout.preferredWidth: 150
                Layout.preferredHeight: (parent.height - menuContainer.height)
                Layout.row: 1
                Layout.alignment: Qt.AlignTop
                color: "#222831"

                TableSelector {
                    id: tableSelectorView
                    onCurrentIndexChanged: {
                        if (content !== "") {
                            if (currentIndex !== 0)
                                bodyView.content = JSON.stringify(jsonObj[model[currentIndex]],null,4);
                            else
                                bodyView.content = JSON.stringify(jsonObj,null,4);
                        }
                    }
                }
                Image {
                    id: onLogo
                    width: 50
                    height: 50
                    source: "Images/OnLogo.png"
                    fillMode: Image.PreserveAspectCrop
                    anchors {
                        bottom: parent.bottom
                        bottomMargin: 20
                        horizontalCenter: parent.horizontalCenter
                    }
                }
            }
            Rectangle {
                id: bodyContainer
                Layout.preferredWidth: (parent.width - selectorContainer.width)
                Layout.preferredHeight: (parent.height - menuContainer.height)
                Layout.alignment: Qt.AlignTop
                color: "steelblue"
                BodyDisplay {
                    id: bodyView
                }
            }
        }
    }
}
