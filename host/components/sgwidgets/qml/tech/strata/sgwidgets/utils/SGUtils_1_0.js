.pragma library

function generateHtmlUnorderedList(list) {
    var text = "<ul>"
    for (var i = 0; i < list.length; ++i) {
        text += "<li>" + list[i] + "</li>"
    }
    text += "</ul>"

    return text
}
