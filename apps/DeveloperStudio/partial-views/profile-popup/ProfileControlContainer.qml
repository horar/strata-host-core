import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0

Rectangle {
    id: root

    Layout.alignment: Qt.AlignRight
    Layout.columnSpan: 1
    Layout.preferredWidth: editSaveButton.width + cancelButton.width + 5
    Layout.topMargin: 10

    property string errorAlertText: "Error updating. Try again"
    property alias expandAnimation: expandAnimation
    property alias hideAnimation: hideAnimation
    property double expandHeight: 200
    property double hideHeight: 0
    property variant allFieldsvalid
    property var animationTargets: []
    property bool editing: false
    property bool guestUser: mainGrid.guestUser

    signal saved()
    signal failed()
    signal canceled()

    function resetHeight() {
        animationTargets.forEach((target) => target.Layout.preferredHeight = hideHeight);
    }

    NumberAnimation {
        id: expandAnimation
        targets: animationTargets
        properties: "Layout.preferredHeight"
        to : expandHeight
        duration: 200
        easing.type: Easing.InOutQuad

        onStarted: {
            expandAnimationStarted()
        }

        onFinished: {
            expandAnimationFinished()
        }
    }

    NumberAnimation {
        id: hideAnimation
        targets: animationTargets
        property: "Layout.preferredHeight"
        to: hideHeight
        duration: 200
        easing.type: Easing.InOutQuad

        onStarted: hideAnimationStarted()

        onFinished: hideAnimationFinished()
    }

    SGText {
       id: editSaveButton

       anchors {
           right: root.editing ? cancelButton.left : root.right
           rightMargin: root.editing ? 5 : 0
       }

       text: {
           if (root.guestUser === true) {
                return ""
           }
           return root.editing ? "Save" : "Edit"
       }
       color: Theme.palette.onsemiOrange

       MouseArea {
           anchors.fill: parent
           hoverEnabled: true
           cursorShape: entered ? Qt.PointingHandCursor : Qt.ArrowCursor

           onClicked: {
               if (editSaveButton.text === "Edit") {
                   expandAnimation.start()
                   root.editing = true
               } else {
                   if (allFieldsValid()) {
                       root.saved()
                       root.editing = false
                       alertRect.hide()
                   } else {
                       root.failed()
                       alertRect.text = errorAlertText
                       alertRect.color = "red"
                       alertRect.show()
                   }
               }
           }

           onEntered: parent.font.underline = true
           onExited: parent.font.underline = false
       }
    }

    SGText {
       id: cancelButton

       anchors {
           right: root.right
       }

       text: "Cancel"
       color: "grey"
       visible: parent.editing

       MouseArea {
           anchors.fill: parent
           hoverEnabled: true
           cursorShape: entered ? Qt.PointingHandCursor : Qt.ArrowCursor

           onClicked: {
               root.editing = false
               hideAnimation.start()
               root.canceled()
           }

           onEntered: parent.font.underline = true
           onExited: parent.font.underline = false
       }
    }

    // These functions can all be overwritten. These are the default actions for the events

    function allFieldsValid() {
        for (let i = 0; i < animationTargets.length; i++) {
            if (!animationTargets[i].textField.valid) {
                return false
            }
        }
        return true
    }

    function expandAnimationStarted() {
        animationTargets.forEach(target => target.plainText.visible = false)
    }

    function expandAnimationFinished() {
        animationTargets.forEach((target) => {
            target.textField.text = target.plainText.text
            if (root.guestUser === false) {
                target.editable = true
                animationTargets[0].textField.focus = true
            }
        });

    }

    function hideAnimationStarted() {
        animationTargets.forEach(target => target.editable = false)
    }

    function hideAnimationFinished() {
        animationTargets.forEach((target) => {
            target.plainText.visible = true
            target.textField.focus = false
        });
    }    
}
