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

#################################

#LCC compiler options
LCC = $(GBDK_HOME)bin/lcc
#compiler flags
#          warn as error       inc dir
LCCFLAGS += -Wf--Werror $(INCLUDEDIR:%=-Wf-I%)
#makebin flags
#            gbc    .sym  JP-flag    MBC      cart name         license code
LCCFLAGS += -Wm-yC -Wm-yS -Wm-yj -Wm-yt0x1B -Wm-ynINFINITYPOCKET -Wm-yk":)"
#lcc flags
LCCFLAGS += -debug -autobank

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

${ROM}: $(patsubst %.c, ${OBJDIR}/%.o, ${SOURCES})
	@#mirror the folder structure and build
	@mkdir -p "${@D}"
	$(LCC) $(LCCFLAGS) -o $(ROM) $^

${OBJDIR}/%.o: %.c
	@#mirror the folder structure and build
	@mkdir -p "${@D}"
	$(LCC) $(LCCFLAGS) -c -o $@ $<
