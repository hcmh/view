

-include Makefile.local

DEBUG?=0

BUILDTYPE = Linux
UNAME = $(shell uname -s)

ifeq ($(UNAME),Darwin)
    BUILDTYPE = MacOSX
endif


ifeq ($(origin CC), default)
	CC = gcc
endif

CFLAGS ?= -Wall

ifeq ($(DEBUG),1)
	CFLAGS += -Og -g
else
	CFLAGS += -O2
endif

ifeq ($(BUILDTYPE), MacOSX)
	CFLAGS += -std=c11 -Xpreprocessor -fopenmp
else
	CFLAGS += -std=c11 -fopenmp
endif

# clang

ifeq ($(findstring clang, $(CC)), clang)
	CFLAGS += -fblocks
	LDFLAGS += -lBlocksRuntime
endif


EXPDYN = -rdynamic


ifeq ($(BUILDTYPE), MacOSX)
	LDFLAGS += -L/opt/local/lib -lm -lpng -lomp -lrt
else
	LDFLAGS += -lm -lpng -lrt
endif


TOOLBOX_LIB=`pkg-config --variable=libdir bart`
TOOLBOX_INC=`pkg-config --variable=includedir bart`


all: view cfl2png

src/viewer.inc: src/viewer.ui
	@echo "STRINGIFY(`cat src/viewer.ui`)" > src/viewer.inc

view:	src/main.c src/view.[ch] src/draw.[ch] src/viewer.inc
	$(CC) $(CFLAGS) $(EXPDYN) -o view -I$(TOOLBOX_INC) `pkg-config --cflags gtk+-3.0` src/main.c src/view.c src/draw.c `pkg-config --libs gtk+-3.0` $(TOOLBOX_LIB)/libgeom.a $(TOOLBOX_LIB)/libnum.a $(TOOLBOX_LIB)/libmisc.a $(LDFLAGS) `pkg-config --libs bart`

cfl2png:	src/cfl2png.c src/view.[ch] src/draw.[ch] src/viewer.inc
	$(CC) $(CFLAGS) $(EXPDYN) -o cfl2png -I$(TOOLBOX_INC) src/cfl2png.c src/draw.c $(TOOLBOX_LIB)/libmisc.a  $(TOOLBOX_LIB)/libgeom.a $(TOOLBOX_LIB)/libnum.a $(CUDA_L) $(LDFLAGS) `pkg-config --libs bart`

install:
	install -D view $(DESTDIR)/usr/lib/bart/commands/view
	install cfl2png $(DESTDIR)/usr/lib/bart/commands/


clean:
	rm -f view cfl2png viewer.inc
