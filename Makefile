# change these if you're not on a Mac, or don't run "make install" :)
#PROCESSING_PATH = "/Applications/Processing.app/Contents/Resources/Java/core.jar"
PROCESSING_PATH = "/home/notyours/processing-3.3.7/core/library/core.jar"
#LIBRARY_PATH = "/Users/$(USER)/Documents/Processing/libraries/"
LIBRARY_PATH = "/home/notyours/sketchbook/libraries/"

#modestmaps/library/modestmaps.jar:
java6:
	mkdir -p classes
	javac -sourcepath src/ -cp $(PROCESSING_PATH) -d classes src/com/modestmaps/*.java src/com/modestmaps/core/*.java src/com/modestmaps/providers/*.java src/com/modestmaps/geo/*.java -source 6 -target 6
	mkdir -p Java6/modestmaps/library
	jar cvf Java6/modestmaps/library/modestmaps.jar -C classes .

java7:
	mkdir -p classes
	javac -sourcepath src/ -cp $(PROCESSING_PATH) -d classes src/com/modestmaps/*.java src/com/modestmaps/core/*.java src/com/modestmaps/providers/*.java src/com/modestmaps/geo/*.java -source 7 -target 7
	mkdir -p Java7/modestmaps/library
	jar cvf Java7/modestmaps/library/modestmaps.jar -C classes .

java8:
	mkdir -p classes
	javac -sourcepath src/ -cp $(PROCESSING_PATH) -d classes src/com/modestmaps/*.java src/com/modestmaps/core/*.java src/com/modestmaps/providers/*.java src/com/modestmaps/geo/*.java -source 8 -target 8
	mkdir -p Java8/modestmaps/library
	jar cvf Java8/modestmaps/library/modestmaps.jar -C classes .

all:
	#Java6 build
	mkdir -p classes
	javac -sourcepath src/ -cp $(PROCESSING_PATH) -d classes src/com/modestmaps/*.java src/com/modestmaps/core/*.java src/com/modestmaps/providers/*.java src/com/modestmaps/geo/*.java -source 6 -target 6
	mkdir -p Java6/modestmaps/library
	jar cvf Java6/modestmaps/library/modestmaps.jar -C classes .
	rm -rf classes/*
	#Java7 build
	mkdir -p classes
	javac -sourcepath src/ -cp $(PROCESSING_PATH) -d classes src/com/modestmaps/*.java src/com/modestmaps/core/*.java src/com/modestmaps/providers/*.java src/com/modestmaps/geo/*.java -source 7 -target 7
	mkdir -p Java7/modestmaps/library
	jar cvf Java7/modestmaps/library/modestmaps.jar -C classes .
	rm -rf classes/*
	#Java8 build
	mkdir -p classes
	javac -sourcepath src/ -cp $(PROCESSING_PATH) -d classes src/com/modestmaps/*.java src/com/modestmaps/core/*.java src/com/modestmaps/providers/*.java src/com/modestmaps/geo/*.java -source 8 -target 8
	mkdir -p Java8/modestmaps/library
	jar cvf Java8/modestmaps/library/modestmaps.jar -C classes .


#install: modestmaps/library/modestmaps.jar
install: java6
	cp -r Java6/modestmaps $(LIBRARY_PATH)

clean:
	rm -rf classes/*
	rm -rf modestmaps
	rm -rf Java6
	rm -rf Java7
	rm -rf Java8
