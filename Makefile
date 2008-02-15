modestmaps.jar:
	javac src/com/modestmaps/*.java -cp lib/core.jar -d classes
	jar cvf modestmaps.jar -C classes .

clean:
	rm -rf classes/*
