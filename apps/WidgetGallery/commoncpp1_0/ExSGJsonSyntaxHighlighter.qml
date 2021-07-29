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
