# Minimal makefile to just check that everything from SWIG to C++ to wrappers to Java compiles and runs
# As is, this is not portable at all to a different machine let alone different OS
java_home = /Library/Java/JavaVirtualMachines/temurin-11.jdk/Contents/Home
jni_headers =$(java_home)/include
jni_darwin_headers = $(java_home)/include/darwin
occ_headers = /usr/local/include/opencascade
typetraits = /Library/Developer/CommandLineTools/usr/include/c++/v1/
swigout = swigout
output = bin
all:
	rm -r -f ./$(swigout)
	mkdir $(swigout)
	mkdir $(swigout)/occjava
	rm -r -f ./$(output)
	mkdir $(output)
	gcc -std=c++11 -c -I$(occ_headers) -o $(swigout)/experiment-cc-code.so experiment-cc-code.cxx
	swig -java -package occjava -I$(typetraits) -cpperraswarn -I$(occ_headers) -outdir $(swigout)/occjava  -c++ -java occ-java.i
	gcc -std=c++11 -c -I. -I$(occ_headers) -I$(jni_headers) -I$(jni_darwin_headers) -o $(output)/experiment-cc-code_wrap.so occ-java_wrap.cxx
	gcc -std=c++11 \
		-undefined dynamic_lookup \
		-o $(output)/experiment.dylib -shared -I. \
		-I$(occ_headers) -I$(jni_headers) \
		-I$(jni_darwin_headers) experiment-cc-code.cxx \
		occ-java_wrap.cxx \
		-L/usr/local/lib -Wl,-rpath,/usr/local/lib \
		-lTKernel \
		-lTKPrim \
		-lTKSTEP \
		-lTKFillet \
		-lTKOffset \

	javac -d $(output) -sourcepath $(swigout) $(swigout)/occjava/*.java
	javac -d $(output) -classpath $(output) Experiment.java
	java -cp $(output) Experiment

java:
	javac -d $(swigout) out/*.java
	javac -d $(swigout) -classpath ./out *.java
	java -XX:+PrintGCDetails -XX:+PrintGC -cp out Experiment
