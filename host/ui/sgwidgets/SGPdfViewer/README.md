# Dev. notes

- download & build PDF.js
urls:
    https://mozilla.github.io/pdf.js
    https://github.com/mozilla/pdf.js

- use e.g. Homebrew to for building
- follow instruction in README.md file and compile node.js project
    - note: with last node.js v11 the pdf.js compilation fails; use node.js v10.x

OR

- use pre-build version version from [here](https://mozilla.github.io/pdf.js/getting_started/#download)
- and unpack into 'minified' folder in SGPdfDocument source tree
```
    unzip pdfjs-2.0.550-dist.zip -d minified
```

## pdf.js modification

- apply patch or make changes in pdf.js
- compile it
```
    gulp minified
```
- copy/replace minified folder from 'build/minified' to SGPdfDocument source code project root (spyglass/host/ui/sgwidgets/SGPdfDocument)
- qmake will deploy it to right place

## Current issue:

- As described here: https://bugreports.qt.io/browse/QTBUG-70228 there is a cross-domain issue that is fixed in 5.12, right now there is a work-around in main.pp disabling web security in the webengine
