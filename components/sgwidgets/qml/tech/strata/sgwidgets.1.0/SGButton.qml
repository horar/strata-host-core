/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

Button {
    id: control

    hoverEnabled: true
    padding: 4
    horizontalPadding: padding
    spacing: 6

    icon.width: iconSize
    icon.height: iconSize

    property bool alternativeColorEnabled: false
    property alias fontSizeMultiplier: textItem.fontSizeMultiplier
    property int minimumContentHeight: -1
    property int minimumContentWidth: -1
    readonly property int preferredContentWidth: wrapper.width
    readonly property int preferredContentHeight: wrapper.height

    /* This is useful when minimumContentHeight and minimumContentWidth are in use and
       content is bigger than its implicit size.*/
    property int contentHorizontalAlignment: Text.AlignHCenter
    property int contentVerticalAlignment: Text.AlignVCenter

    property bool backgroundOnlyOnHovered: false
    property bool scaleToFit: false
    property alias hintText: tooltip.text
    property int iconSize: SGWidgets.SGSettings.fontPixelSize + 10
    property alias iconMirror: iconItem.mirror

    property alias iconColor: iconItem.iconColor
    property color implicitColor: "#aaaaaa"
    property color color: implicitColor
    property color pressedColor: Qt.darker(color, 1.1)
    property color checkedColor: Qt.darker(color, 1.3)

    property bool roundedLeft: true
    property bool roundedRight: true
    property bool roundedTop: true
    property bool roundedBottom: true

    focusPolicy: Qt.NoFocus

    ToolTip {
        id: tooltip
        visible: text.length && control.hovered
        delay: 500
        timeout: 4000
        font.pixelSize: SGWidgets.SGSettings.fontPixelSize
    }

    contentItem: Item {
        implicitWidth: Math.max(wrapper.width, minimumContentWidth)
        implicitHeight: Math.max(wrapper.height, minimumContentHeight)

        Item {
            id: wrapper
            anchors {
                horizontalCenter: contentHorizontalAlignment === Text.AlignHCenter ? parent.horizontalCenter : undefined
                left: contentHorizontalAlignment === Text.AlignLeft ? parent.left : undefined
                right: contentHorizontalAlignment === Text.AlignRight ? parent.right : undefined
                verticalCenter: contentVerticalAlignment === Text.AlignVCenter ? parent.verticalCenter : undefined
                top: contentVerticalAlignment === Text.AlignTop ? parent.top : undefined
                bottom: contentVerticalAlignment === Text.AlignBottom ? parent.bottom : undefined
            }

            width: {
                var w = 0
                if (display === Button.IconOnly) {
                    w = iconItem.width
                } else if (display === Button.TextOnly) {
                    w = textItem.width
                } else if (control.display === Button.TextBesideIcon) {
                    if (iconItem.status === Image.Ready && control.text.length) {
                        w = iconItem.width + textItem.paintedWidth + spacing
                    } else if(iconItem.status === Image.Ready) {
                        w = iconItem.width
                    } else {
                        w = textItem.paintedWidth
                    }
                } else if (control.display === Button.TextUnderIcon) {
                    if (iconItem.status === Image.Ready) {
                        w = Math.max(textItem.paintedWidth, iconItem.width)
                    } else {
                        w = textItem.paintedWidth
                    }
                }

                return w
            }

            height: {
                var h = 0
                if (display === Button.IconOnly) {
                    h = iconItem.height
                } else if (display === Button.TextOnly) {
                    h = textItem.height
                } else if (control.display === Button.TextBesideIcon) {
                    if (iconItem.status === Image.Ready) {
                        var textHeight = textItem.paintedWidth > 0 ? textItem.paintedHeight : 0
                        h = Math.max(textHeight, iconItem.height)
                    } else {
                        h = textItem.paintedHeight
                    }
                } else if (control.display === Button.TextUnderIcon) {
                    if (iconItem.status === Image.Ready) {
                        h = iconItem.height + textItem.paintedHeight + spacing
                    } else {
                        h = textItem.paintedHeight
                    }
                }
                return h
            }

            SGWidgets.SGIcon {
                id: iconItem
                height: control.icon.height
                width: height
                anchors {
                    left: display === Button.TextBesideIcon ? parent.left : undefined
                    verticalCenter: display === Button.IconOnly || display === Button.TextBesideIcon ? parent.verticalCenter : undefined
                    horizontalCenter: display === Button.IconOnly || display === Button.TextUnderIcon ? parent.horizontalCenter : undefined
                }

                source: control.icon.source
                opacity: enabled ? 1 : 0.5
                visible: display !== Button.TextOnly
            }

            SGWidgets.SGText {
                id: textItem
                anchors {
                    top: display === Button.TextUnderIcon && iconItem.status === Image.Ready ? iconItem.bottom : undefined
                    left: display === Button.TextBesideIcon && iconItem.status === Image.Ready ? iconItem.right : undefined
                    leftMargin: iconItem.status === Image.Ready ? spacing : 0
                    topMargin: iconItem.status === Image.Ready ? spacing : 0
                    verticalCenter: display === Button.TextOnly || display === Button.TextBesideIcon ? parent.verticalCenter : undefined
                    horizontalCenter: display === Button.IconOnly || display === Button.TextUnderIcon ? parent.horizontalCenter : undefined
                }

                text: control.text
                alternativeColorEnabled: control.checked || control.alternativeColorEnabled
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                opacity: enabled ? 1 : 0.5
                visible: display !== Button.IconOnly
            }
        }
    }

    background: Item {
        implicitHeight: scaleToFit ? 0 : 40
        implicitWidth: scaleToFit ? 0 : 100
        clip: true

        Rectangle {
            anchors {
                fill: parent
                leftMargin: roundedLeft ? 0 : -radius
                rightMargin: roundedRight ? 0 : -radius
                topMargin: roundedTop ? 0 : -radius
                bottomMargin: roundedBottom ? 0 : -radius
            }

            opacity: enabled ? 1 : 0.5

            radius: 4
            color: {
                if (control.pressed) {
                    return pressedColor
                }

                if (control.checked) {
                    return checkedColor
                }

                if (backgroundOnlyOnHovered && !control.hovered) {
                    return "transparent"
                }

                return control.color
            }
        }
    }
}
