Patches for PDF.js:
Apply them via 'git apply' or SourceTree against pdf.js project (master branch)

add-viewer-origins-remove-default-file.patch:
adds qrc: and file: protocols to acceptable viewer origins, as well as removing the default demo pdf file

remove-toolbar-buttons.patch:
removes toolbar buttons that aren't appropriate for strata (open file, print etc)
