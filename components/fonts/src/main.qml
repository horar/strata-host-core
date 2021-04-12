import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.fonts 1.0 as StrataFonts
import tech.strata.fonts 1.0


ApplicationWindow {
    id: mainWindow
    visible: true
    minimumWidth: 700
    minimumHeight: 500
    width: 800
    height: 600
    title: qsTr("SpyGlass Fonts Gallery")

    ColumnLayout {
        anchors.centerIn: parent

        RowLayout {
            ColumnLayout {

                Label {
                    text: "font \\ style"
                    horizontalAlignment: Label.AlignHCenter
                    Layout.fillWidth: true
                }

                Label {
                    text: "franklinGothicBold | "
                    horizontalAlignment: Label.AlignRight
                    Layout.fillWidth: true
                }
                Label {
                    text: "franklinGothicMedium | "
                    horizontalAlignment: Label.AlignRight
                    Layout.fillWidth: true
                }
                Label {
                    text: "franklinGothicBook | "
                    horizontalAlignment: Label.AlignRight
                    Layout.fillWidth: true
                }
                Label {
                    text: "inconsolata | "
                    horizontalAlignment: Label.AlignRight
                    Layout.fillWidth: true
                }
                Label {
                    text: "franklinGothic (auto) | "
                    horizontalAlignment: Label.AlignRight
                    Layout.fillWidth: true
                }
            }

            ColumnLayout {

                Label {
                    text: "(default)"
                    horizontalAlignment: Label.AlignHCenter
                    Layout.fillWidth: true
                }

                Label {
                    text: "Font test bold"
                    font.family: Fonts.franklinGothicBold
                    font.pointSize: 15
                }
                Label {
                    text: "Font test medium"
                    font.family: Fonts.franklinGothicMedium
                    font.pointSize: 15
                }
                Label {
                    text: "Font test book"
                    font.family: Fonts.franklinGothicBook
                    font.pointSize: 15
                }
                Label {
                    text: "Font test inconsolata"
                    font.family: StrataFonts.Fonts.inconsolata
                    font.pointSize: 15
                }
                Label {
                    text: "Font test"
                    font.family: Fonts.franklinGothicFontName
                    font.pointSize: 15
                }
            }

            ColumnLayout {
                Label {
                    text: "(bold)"
                    horizontalAlignment: Label.AlignHCenter
                    Layout.fillWidth: true
                }

                Label {
                    text: "Font test bold"
                    font.family: Fonts.franklinGothicBold
                    font.bold: true
                    font.pointSize: 15
                }
                Label {
                    text: "Font test medium"
                    font.family: Fonts.franklinGothicMedium
                    font.bold: true
                    font.pointSize: 15
                }
                Label {
                    text: "Font test book"
                    font.family: Fonts.franklinGothicBook
                    font.bold: true
                    font.pointSize: 15
                }
                Label {
                    text: "Font test inconsolata"
                    font.family: StrataFonts.Fonts.inconsolata
                    font.bold: true
                    font.pointSize: 15
                }
                Label {
                    text: "Font test"
                    font.family: Fonts.franklinGothicFontName
                    font.bold: true
                    font.pointSize: 15
                }
            }

            ColumnLayout {
                Label {
                    text: "(italic)"
                    horizontalAlignment: Label.AlignHCenter
                    Layout.fillWidth: true
                }

                Label {
                    text: "Font test bold"
                    font.family: Fonts.franklinGothicBold
                    font.italic: true
                    font.pointSize: 15
                }
                Label {
                    text: "Font test medium"
                    font.family: Fonts.franklinGothicMedium
                    font.italic: true
                    font.pointSize: 15
                }
                Label {
                    text: "Font test book"
                    font.family: Fonts.franklinGothicBook
                    font.italic: true
                    font.pointSize: 15
                }
                Label {
                    text: "Font test inconsolata"
                    font.family: StrataFonts.Fonts.inconsolata
                    font.italic: true
                    font.pointSize: 15
                }
                Label {
                    text: "Font test"
                    font.family: Fonts.franklinGothicFontName
                    font.italic: true
                    font.pointSize: 15
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 3
            color: "blue"
        }
        Label {
            text: "weight test"
            horizontalAlignment: Label.AlignHCenter
            Layout.fillWidth: true
        }

        RowLayout {

            ColumnLayout {
                property string fontFamily: Fonts.franklinGothicFontName

                Label {
                    text: "Franklin Gothic (auto) " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.Thin
                    font.pixelSize: 20
                }

                Label {
                    text: "Franklin Gothic (auto) " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.ExtraLight
                    font.pixelSize: 20
                }

                Label {
                    text: "Franklin Gothic (auto) " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.Light
                    font.pixelSize: 20
                }

                Label {
                    text: "Franklin Gothic (auto) " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.Normal
                    font.pixelSize: 20
                }

                Label {
                    text: "Franklin Gothic (auto) " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.Medium
                    font.pixelSize: 20
                }

                Label {
                    text: "Franklin Gothic (auto) " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.DemiBold
                    font.pixelSize: 20
                }

                Label {
                    text: "Franklin Gothic (auto) " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.Bold
                    font.pixelSize: 20
                }

                Label {
                    text: "Franklin Gothic (auto) " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.ExtraBold
                    font.pixelSize: 20
                }

                Label {
                    text: "Franklin Gothic (auto) " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.Black
                    font.pixelSize: 20
                }
            }

            ColumnLayout {
                property string fontFamily: Fonts.inconsolataFontName

                Label {
                    text: "Inconsolata " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.Thin
                    font.pixelSize: 20
                }

                Label {
                    text: "Inconsolata " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.ExtraLight
                    font.pixelSize: 20
                }

                Label {
                    text: "Inconsolata " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.Light
                    font.pixelSize: 20
                }

                Label {
                    text: "Inconsolata " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.Normal
                    font.pixelSize: 20
                }

                Label {
                    text: "Inconsolata " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.Medium
                    font.pixelSize: 20
                }

                Label {
                    text: "Inconsolata " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.DemiBold
                    font.pixelSize: 20
                }

                Label {
                    text: "Inconsolata " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.Bold
                    font.pixelSize: 20
                }

                Label {
                    text: "Inconsolata " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.ExtraBold
                    font.pixelSize: 20
                }

                Label {
                    text: "Inconsolata " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.Black
                    font.pixelSize: 20
                }
            }

            ColumnLayout {
                property string fontFamily: "Helvetica Neue"

                Label {
                    text: "Helvetica Neue " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.Thin
                    font.pixelSize: 20
                }

                Label {
                    text: "Helvetica Neue " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.ExtraLight
                    font.pixelSize: 20
                }

                Label {
                    text: "Helvetica Neue " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.Light
                    font.pixelSize: 20
                }

                Label {
                    text: "Helvetica Neue " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.Normal
                    font.pixelSize: 20
                }

                Label {
                    text: "Helvetica Neue " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.Medium
                    font.pixelSize: 20
                }

                Label {
                    text: "Helvetica Neue " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.DemiBold
                    font.pixelSize: 20
                }

                Label {
                    text: "Helvetica Neue " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.Bold
                    font.pixelSize: 20
                }

                Label {
                    text: "Helvetica Neue " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.ExtraBold
                    font.pixelSize: 20
                }

                Label {
                    text: "Helvetica Neue " + font.weight
                    font.family: parent.fontFamily
                    font.weight: Font.Black
                    font.pixelSize: 20
                }
            }
        }
    }
}
