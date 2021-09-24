Bundle app dependencies
-----------------------

If actual PATH environment variable was updated with paths to intalled Qt5
then trigger in terminal in build folder:
```
cd bin
windeployqt ^
	--release ^
	--force ^
	--no-translations ^
	--dir out ^
	--no-compiler-runtime ^
	flasher-cli.exe
copy flasher-cli.exe .\out\
```

And now package the content of 'out' sub-folder.
