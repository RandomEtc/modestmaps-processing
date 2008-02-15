modestmaps.jar:
	javac src/com/modestmaps/*.java -cp core.jar -d classes
	jar cvf modestmaps.jar -C classes .

clean:
	rm -rf classes/*
