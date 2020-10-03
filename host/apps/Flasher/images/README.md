Sourece:                  Icon dimensions:
flasher-logo-small.svg    16 x 16, 24 x 24
flasher-logo-med.svg      32 x 32, 48 x 48
flasher-logo-big.svg      rest of icon dimensions


Windows icon sizes:
  16 x 16
  24 x 24
  32 x 32
  48 x 48
  64 x 64
  96 x 96
  128 x 128
  192 x 192
  256 x 256

Free icon creator: Greenfish Icon Editor Pro: http://greenfishsoftware.org/gfie.php


Mac icon sizes:
  name:            dimensions:
  icon_16x16       16 x 16
  icon_16x16@2x    32 x 32
  icon_32x32       32 x 32
  icon_32x32@2x    64 x 64
  icon_128x128     128 x 128
  icon_128x128@2x  256 x 256
  icon_256x256     256 x 256
  icon_256x256@2x  512 x 512
  icon_512x512     512 x 512
  icon_512x512@2x  1024 x 1024

Use this script for creating Mac icns file:
 git clone https://github.com/jamfit/icns-Creator.git
Run it:
 ./icns_creator.sh input.png
It will create folder with set of images in all required dimensions.
It is possible to replace some images in this folder and run script again
with removed these conditions (and all code in them):
'if [ "${src_image:(-3)}" != "png" ]; then'
and
'if [ -e "$iconset_path" ]; then'.
As a result, ICNS file with replaced images will be created.
