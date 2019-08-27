# Developer notes

PDF.js monified module is created via CMake script for host.
Follow these steps (macOS only for now):
- install all dependencies mentioned in documentation (https://github.com/mozilla/pdf.js)
- turn CMake's option 'EXTERN_PDFJS' to ON
- configure 'host' project tree as for standard build (or use actual build folder)
- invoke in build folder something like:
```
cmake --build . --target pdf.js-v2.1.266
```
- some extra pdf.js dependencies will be downloaded and installed (locally to build folder)
- all patches will be automatically applied
- on the end will be shown a message with location of minified pdf.js component
- copy/move them to sgwidgets/SGPdfViewer component, review-test-commit to updated component
