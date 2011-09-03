# change these if you're not on a Mac, or don't run "make install" :)
PROCESSING_PATH = "/Applications/Processing.app/Contents/Resources/Java/core.jar"
LIBRARY_PATH = "/Users/$(USER)/Documents/Processing/libraries/"

test:
	echo $(LIBRARY_PATH)

modestmaps.jar:
	javac -sourcepath src/ -cp $(PROCESSING_PATH) -d classes src/com/modestmaps/*.java src/com/modestmaps/core/*.java src/com/modestmaps/providers/*.java src/com/modestmaps/geo/*.java
	jar cvf modestmaps.jar -C classes .

install: modestmaps.jar
	mkdir modestmaps
	mkdir modestmaps/library
	mv modestmaps.jar modestmaps/library/
	mv modestmaps $(LIBRARY_PATH)

clean:
	rm -rf classes/*
	rm -rf modestmaps.jar
	rm -rf modestmaps
