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
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCPP

ColumnLayout {
    id: contentColumn
    spacing: 10
    Layout.fillWidth: true

    CommonCPP.SGJsonSyntaxHighlighter {
        textDocument: noteText.textDocument
    }

    SGWidgets.SGTextEdit {
        id: noteText
        wrapMode: Text.WordWrap
        enabled: false
        text: "This example demonstrates how JSON syntax is hihghlighted.\n\n"
            + "Example of valid JSON:\n"
            +"{\n"
            + "    \"object\": {\n"
            + "        \"string_key\": \"test value\",\n"
            + "        \"real_number_key\": 1.23\n"
            + "        \"integer_key\": 56\n"
            + "        \"boolean_key\": true\n"
            + "        \"empty_key\": Null\n"
            + "        \"array_string_key\": [\"value1\", \"value2\", \"value3\"]\n"
            + "        \"array_number_key\": [1, 2, 3]\n"
            + "    }\n"
            + "}\n"
    }
}
