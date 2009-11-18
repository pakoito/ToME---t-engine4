PROJECTNAME=collision
SGEDIR=../..

include $(SGEDIR)/setup.project
include $(SGEDIR)/setup.$(PLATFORM)

TARGET=$(PROJECTNAME)$(EXEC)

OBJ=main.o

CFLAGS=-Wall -I$(SGEDIR)/include $(SDLCFLAGS)
LDFLAGS=$(SDLLDFLAGS)

%.o:%.c
	$(CC) -o $@ $(CFLAGS) -c $<

all:$(OBJ)
	$(CC) -o $(TARGET) $(LDFLAGS) $(OBJ) $(SGEDIR)/libsge.a $(STATICLIBS)

clean:
	rm -f stdout.txt stderr.txt
	rm -f $(OBJ)
	rm -f $(TARGET)

data:
	rm -rf ./data.d
	$(SGEDIR)/tools/sga asdf ./data.d sprite.png
