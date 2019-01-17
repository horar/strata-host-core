# Application icons

## macOS app icon in 'icns' format
The macOS icon may be created manually via different utilities e.g. Gimp. On other side exists many console scripts to speedup this process.
1. clone helper script: 
    ```
    git clone https://github.com/jamfit/icns-Creator.git
    ```
    or get script directly
    ```
    curl -o icns_creator.sh https://raw.githubusercontent.com/jamfit/icns-Creator/master/icns_creator.sh
    chmod u+x icns_creator.sh
    ```
2. prepare source image (e.g. from vector graphics) in minimum resolution 1024x1024 a fire the conversion
    ```
    ./icns_creator.sh input.png
    ```
    This will create a file named 'iconbuilder.icns'.
3. rename generated file, move it to right place and update Qt project file if necessary

## Windows OS app icon in 'ico' format
TODO