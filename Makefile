# IMPORTANT!!1!11!:w

# Add GBDK to your path, otherwise project won't compile
# Also, it seems like the GBDK devs are the dumbest fucks ever 
# born and made their lcc look for sdcc in some predefined loc.
# If running make doesn't work, try setting GBDKDIR var as well
# to the path of your GBDK directory.

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
CC = lcc
#compiler flags
#          warn as error       inc dir
CCFLAGS += -Wf--Werror $(INCLUDEDIR:%=-Wf-I%)
#makebin flags
#            gbc    .sym  JP-flag    MBC      cart name         license code
CCFLAGS += -Wm-yC -Wm-yS -Wm-yj -Wm-yt0x1B -Wm-ynINFINITYPOCKET -Wm-yk":)"
#lcc flags
CCFLAGS += -debug -autobank

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
	$(CC) $(CCFLAGS) -o $(ROM) $^

${OBJDIR}/%.o: %.c
	@#mirror the folder structure and build
	@mkdir -p "${@D}"
	$(CC) $(CCFLAGS) -c -o $@ $<
