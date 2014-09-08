### Modify these appropriately for your system!

JDK_BASE=/usr/lib/jvm/java-1.6.0-openjdk-i386
J2ME_BASE=$(HOME)/more/WTK2.5.2


### For the tutorial, you shouldn't have to modify anything below this line
NAME=Midlet
SRC=$(NAME).java

JAVAC=$(JDK_BASE)/bin/javac
JAVA_CFLAGS=-bootclasspath "$(J2ME_BASE)/lib/midpapi20.jar:$(J2ME_BASE)/lib/cldcapi10.jar"  \
          -target 1.3                                                                     \
          -source 1.3                                                                     \
	      -d compiled                                                                     \
	      -classpath compiled                                                             \
	      -sourcepath .                                                                   \
	      -g
PREVERIFY=$(J2ME_BASE)/bin/preverify
PREVERIFY_CLASSPATH=$(J2ME_BASE)/lib/midpapi20.jar:$(J2ME_BASE)/lib/cldcapi10.jar


all: $(NAME).jar $(NAME).jad

run: $(NAME).jad
	$(J2ME_BASE)/bin/emulator -Xdescriptor:$(NAME).jad

$(NAME).jar: verified compiled Manifest $(SRC:.java=.class)
	jar cfm $(NAME).jar Manifest icon.png -C verified $(SRC:.java=.class)

compiled:
	mkdir -p compiled

verified:
	mkdir -p verified

%.class: %.java
	$(JAVAC) $(JAVA_CFLAGS) $<
	$(PREVERIFY) -classpath $(PREVERIFY_CLASSPATH):compiled -d verified $(NAME)

%.jad: %.jar
	unzip -aa -j -p $< "META-INF/MANIFEST.MF" > $@
	echo "MIDlet-Jar-URL: $<" >> $@
	echo "MIDlet-Jar-Size: " `stat -c%s $<` >> $@

clean:
	rm -Rf compiled verified
	rm -f *.jar *.jad

.PHONY: clean all run

