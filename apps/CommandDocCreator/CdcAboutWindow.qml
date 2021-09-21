/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

SGWidgets.SGAboutWindow {
    appLogoSource: "qrc:/images/cdc-logo.svg"
    additionalAttributionText: {
        return "The conversion from Markdown to HTML is done with the help of the marked JavaScript library created by Christopher Jeffrey.<br>"+
                "<a href=\"https://github.com/markedjs/marked\">https://github.com/markedjs/marked</a><br>"+
                "The style sheet was created by Brett Terpstra.<br>"+
                "<a href=\"https://github.com/ttscoff/MarkedCustomStyles\">https://github.com/ttscoff/MarkedCustomStyles</a><br>"
    }
}
