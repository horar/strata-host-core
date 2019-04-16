import QtQuick.Controls 2.12
import QtQuick 2.12

Button {
    id: control

    property bool hasAlternativeColor: false
    property alias fontSizeMultipier: textItem.fontSizeMultiplier
    property int minimumContentHeight: -1
    property int minimumContentWidth: -1
    property bool isFirst: true
    property bool isLast: true
    property bool hasDelimeter: false
    property int iconPosition: Item.Left
    property alias iconColor: iconItem.iconColor
    property alias color: bg.color
    property int iconPadding: 4

    padding: 4

    contentItem: Item {
        implicitWidth: Math.max(wrapper.width, minimumContentWidth)
        implicitHeight: Math.max(wrapper.height, minimumContentHeight)

        Item {
            id: wrapper
            anchors.centerIn: parent

            width: {
                var w = 0
                if (display === Button.IconOnly) {
                    w = iconItem.width
                } else if (display === Button.TextOnly) {
                    w = textItem.width
                } else if (control.display === Button.TextBesideIcon && icon.source) {
                    w = iconItem.width + textItem.paintedWidth + iconPadding
                } else if (control.display === Button.TextUnderIcon && icon.source) {
                    w = Math.max(textItem.paintedWidth, iconItem.width)
                }

                return w
            }

            height: {
                var h = 0
                if (display === Button.IconOnly) {
                    h = iconItem.height
                } else if (display === Button.TextOnly) {
                    h = textItem.height
                } else if (control.display === Button.TextBesideIcon && icon.source) {
                    h = Math.max(textItem.paintedHeight, iconItem.height)

                } else if (control.display === Button.TextUnderIcon && icon.source) {
                    h = iconItem.height + textItem.paintedHeight + iconPadding
                }
                return h
            }

            SgIcon {
                id: iconItem
                anchors {
                    left: display === Button.TextBesideIcon ? parent.left : undefined
                    verticalCenter: display === Button.IconOnly || display === Button.TextBesideIcon ? parent.verticalCenter : undefined
                    horizontalCenter: display === Button.IconOnly || display === Button.TextUnderIcon ? parent.horizontalCenter : undefined
                }

                source: control.icon.source
                sourceSize.height: control.icon.height
                visible: display !== Button.TextOnly
            }

            SgText {
                id: textItem
                anchors {
                    top: display === Button.TextUnderIcon ? iconItem.bottom : undefined
                    left: display === Button.TextBesideIcon ? iconItem.right : undefined
                    leftMargin: iconPadding
                    topMargin: iconPadding
                    verticalCenter: display === Button.TextOnly || display === Button.TextBesideIcon ? parent.verticalCenter : undefined
                    horizontalCenter: display === Button.IconOnly || display === Button.TextUnderIcon ? parent.horizontalCenter : undefined
                }

                text: control.text
                hasAlternativeColor: control.checked || control.hasAlternativeColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                opacity: enabled ? 1 : 0.5
                visible: display !== Button.IconOnly
            }
        }
    }

    background: SgButtonImage {
        id: bg
        implicitWidth: 80
        implicitHeight: 40
        hasLeftBorder: control.isFirst
        hasRightBorder: control.isLast
        hasDelimeter: control.hasDelimeter
        pressed: control.pressed
        checked: control.checkable && control.checked
        opacity: enabled ? 1 : 0.5
    }
}
