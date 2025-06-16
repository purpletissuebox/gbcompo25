#filepath to gbdk installation
ifndef GBDK_HOME
	GBDK_HOME = ../gbdk/
endif

#################################
#folder configuration

GAMENAME    = piupocket
OBJDIR      = obj
INCLUDEDIR  = src
INCLUDEDIR += res

#find all source files
rwildcard   = $(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

ROM         = $(OBJDIR)/$(GAMENAME).gbc
SOURCES     = $(call rwildcard, ., *.c)
OBJECTS     = $(patsubst ./%.c, ${OBJDIR}/%.o, ${SOURCES})
RELOCATES   = $(patsubst %.o, %.r, $(OBJECTS))
DEPENDS     = $(patsubst %.o, %.d, $(OBJECTS))

#################################

#LCC compiler + flags
LCCFLAGS += -debug -autobank
LCC = $(GBDK_HOME)bin/lcc $(LCCFLAGS)
#preprocessor flags
#     track dependencies
CPPFLAGS += -Wp-MMD
#compiler flags
#        warn as error       inc dir         do not link
CFLAGS += -Wf--Werror $(INCLUDEDIR:%=-Wf-I%) -c
#bankpack flags
#        file extension    mbc      shuffle
BANKFLAGS += -Wb-ext=.r -Wb-mbc=5 -Wb-random
#makebin flags
#            gbc    .sym  JP-flag    MBC      cart name         license code
ROMFLAGS += -Wm-yC -Wm-yS -Wm-yj -Wm-yt0x1B -Wm-ynINFINITYPOCKET -Wm-yk":)"

##################################

.PHONY: all
all: ${ROM}

.PHONY: clean
clean:
	rm -rf ${OBJDIR}

.PHONY: from-scratch
from-scratch:
	${MAKE} clean
	${MAKE} all

#################################

${ROM}: $(OBJECTS)
	@#mirror the folder structure
	@mkdir -p "${@D}"

	@#create relocated objects with bankpack
	$(LCC) $(BANKFLAGS) $^
	rm ./a.*

	@#create final rom
	$(LCC) $(ROMFLAGS) $(RELOCATES) -o $(ROM)

${OBJDIR}/%.o: %.c ./Makefile
	@#mirror the folder structure
	@mkdir -p "${@D}"

	@#compile object files
	$(LCC) $(CFLAGS) $< -o $@

-include $(DEPENDS)