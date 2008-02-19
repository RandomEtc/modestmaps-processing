modestmaps.jar:
	javac -sourcepath src/ -cp lib/core.jar -d classes src/com/modestmaps/*.java src/com/modestmaps/core/*.java src/com/modestmaps/providers/*.java src/com/modestmaps/geo/*.java
	jar cvf modestmaps.jar -C classes .

clean:
	rm -rf classes/*
