#################################
#folder configuration

BIN_DIR = ./build
OBJ_DIR = ./obj
SRC_DIR = ./src

GAMENAME = piupocket
ROM = ${BIN_DIR}/${GAMENAME}.gbc

#################################
#flag configuration

ASMFLAGS = -p 0xFF -Weverything -Werror -I ./src
LINKFLAGS = -p 0xFF -m ${BIN_DIR}/${GAMENAME}.map -n ${BIN_DIR}/${GAMENAME}.sym -S romx=255,wramx=7
FIXFLAGS = -p 0xFF -C -v -j -k HB -l 0x33 -m mbc5+ram+battery -n 0 -r 4 -t ${GAMENAME} -O
#pad | gbc only | fix chksm | non-JP | licensee code | MBC | ver | ram size | title | ignore overwrite
# p       C           v         j            kl         m     n       r         t            O

#################################
#retrieve ASM files

rwildcard = $(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))
SRC_FILES = $(call rwildcard, ${SRC_DIR}, *.asm)
OBJ_FILES = $(patsubst ./%.asm, ${OBJ_DIR}/%.o, ${SRC_FILES})
DEPENDS   = $(patsubst %.o, %.d, ${OBJ_FILES})

##################################
#clean

.PHONY: all
all: ${ROM}

.PHONY: clean
clean:
	rm -rf ${BIN_DIR} ${OBJ_DIR}

.PHONY: from-scratch
from-scratch:
	${MAKE} clean
	${MAKE} all

#################################
# build the rom

${ROM}: ${OBJ_FILES}
	@#make build dir
	@mkdir -p "${@D}"
	@#link "all" ($^)
	rgblink ${LINKFLAGS} -o $@ $^
	rgbfix ${FIXFLAGS} $@

${OBJ_DIR}/%.o: %.asm ./Makefile
	@#mirror the folder structure
	@mkdir -p "${@D}"
	@#assemble the .asm ($^)
	rgbasm ${ASMFLAGS} -M ${@:.o=.d} $< -o $@

-include ${DEPENDS}

