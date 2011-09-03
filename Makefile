# change these if you're not on a Mac, or don't run "make install" :)
PROCESSING_PATH = "/Applications/Processing.app/Contents/Resources/Java/core.jar"
LIBRARY_PATH = "/Users/$(USER)/Documents/Processing/libraries/"

modestmaps/library/modestmaps.jar:
	javac -sourcepath src/ -cp $(PROCESSING_PATH) -d classes src/com/modestmaps/*.java src/com/modestmaps/core/*.java src/com/modestmaps/providers/*.java src/com/modestmaps/geo/*.java
	mkdir modestmaps
	mkdir modestmaps/library
	jar cvf modestmaps/library/modestmaps.jar -C classes .

install: modestmaps/library/modestmaps.jar
	cp -r modestmaps $(LIBRARY_PATH)

clean:
	rm -rf classes/*
	rm -rf modestmaps
