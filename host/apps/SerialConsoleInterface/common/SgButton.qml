import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.fonts 1.0 as StrataFonts

Button {
    id: control

    font.family: StrataFonts.Fonts.franklinGothicBold

    background: Rectangle {
        implicitHeight: 40
        implicitWidth: 100
        opacity: enabled ? 1 : 0.5
        color: {
            if (control.pressed) {
                return "orange"
            }

            return "#aaaaaa"
        }
    }
}
