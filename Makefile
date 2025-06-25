#################################
#folder configuration

BIN = ./build
OBJ = ./obj
SRC = ./src

GAMENAME    = piupocket
ROM = ${BIN}/${GAMENAME}.gbc

#################################
#flag configuration

ASMFLAGS = -p 0xFF -Weverything -Werror
LINKFLAGS = -p 0xFF -m ${BIN}/${GAMENAME}.map -n ${BIN}/${GAMENAME}.sym
FIXFLAGS = -p 0xFF -C -v -i ELKS -j -k HB -l 0x33 -m mbc5+ram+battery -n 0 -r 4 -t gblinux -O
#pad | gbc only | fix chksm | gameID | non-JP | licensee code | MBC | ver | ram size | title | ignore overwrite
# p       C           v         i        j            kl         m     n       r         t            O

#################################
#retrieve ASM files

rwildcard = $(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))
SRC_FILES = $(call rwildcard, ${SRC}, *.asm)

##################################
#clean

.PHONY: all
all: ${ROM}

.PHONY: clean
clean:
	rm -rf ${BIN} ${OBJ}

.PHONY: from-scratch
from-scratch:
	${MAKE} clean
	${MAKE} all

#################################
# build the rom

${ROM}: $(patsubst ${SRC}/%.asm, ${OBJ}/%.o, ${SRC_FILES})
	@#make build dir
	@mkdir -p "${@D}"
	@#link "all" ($^)
	rgblink ${LINKFLAGS} -o $@ $^
	rgbfix ${FIXFLAGS} $@

${OBJ}/%.o: ${SRC}/%.asm
	@#mirror the folder structure
	@mkdir -p "${@D}"
	@#assemble the .asm ($^)
	rgbasm ${ASMFLAGS} -o ${@} -I ./include $<