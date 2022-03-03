/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
pragma Singleton

import QtQuick 2.12

QtObject {
    id: root

    readonly property string franklinGothicBold: fontLoaders.franklinGothicBoldFont.name
    readonly property string franklinGothicBook: fontLoaders.franklinGothicBookFont.name
    readonly property string franklinGothicMedium: fontLoaders.franklinGothicMediumFont.name
    readonly property string inconsolata: fontLoaders.inconsolataFont.name
    readonly property string digitalseven: fontLoaders.digitalsevenFont.name
    readonly property string sgicons: fontLoaders.sgiconsFont.name

    readonly property string franklinGothicFontName: "franklinGothic"
    readonly property string inconsolataFontName: "Inconsolata"

    property QtObject fontLoaders : QtObject {
        id: fontLoaders

        readonly property FontLoader inconsolataFont: FontLoader {
            source: "./Inconsolata.otf"
        }

        readonly property FontLoader franklinGothicBoldFont: FontLoader {
            source: "./FranklinGothicBold.ttf"
        }

        readonly property FontLoader franklinGothicBookFont: FontLoader {
            source: "./FranklinGothicBook.otf"
        }

        readonly property FontLoader franklinGothicMediumFont: FontLoader {
            source: "./FranklinGothicMedium.otf"
        }

        readonly property FontLoader digitalsevenFont: FontLoader {
            source: "./digitalseven.ttf"
        }

        // TODO: [LC] remove this; keep until all views migrated to new SVG appraoch (@DF)
        readonly property FontLoader sgiconsFont: FontLoader {
            source: "./sgicons.ttf"
        }
    }
}
