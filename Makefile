SHELL = /bin/bash
CC = g++
CFLAGS = -c -Wall -O2 -I $(LIB_PATH)
LDFLAGS = -Wall -O2 -I $(LIB_PATH)

# library

LIB_PATH = lib
LIB = 	$(LIB_PATH)/math_misc.cpp \
	$(LIB_PATH)/point3D.cpp \
	$(LIB_PATH)/transit.cpp \
	$(LIB_PATH)/occultations.cpp
LIB_OBJ = $(LIB:.cpp=.o)

# base

BASE_PATH = base
BASE_SRC = $(BASE_PATH)/corbits.cpp
BASE_OBJ = $(BASE_SRC:.cpp=.o)

# examples

EXAMPLES = kepler-11 period-dist mhs-dist solar-system

KEP11_PATH = examples/kepler-11
KEP11_SRC = $(KEP11_PATH)/Kepler-11.cpp
KEP11_OBJ = $(KEP11_SRC:.cpp=.o)

PER_PATH = examples/period-dist
PER_SRC = $(PER_PATH)/koi_input.cpp \
	$(PER_PATH)/stat_dist.cpp \
	$(PER_PATH)/period_dist.cpp
PER_OBJ = $(PER_SRC:.cpp=.o)

MHS_PATH = examples/period-dist
MHS_SRC = $(MHS_PATH)/koi_input.cpp \
	$(MHS_PATH)/stat_dist.cpp \
	$(MHS_PATH)/mhs_dist.cpp
MHS_OBJ = $(MHS_SRC:.cpp=.o)

SOLSYS_PATH = examples/solar-system
SOLSYS_SRC = $(SOLSYS_PATH)/solsys.cpp
SOLSYS_OBJ = $(SOLSYS_SRC:.cpp=.o)

# targets

all: lib base examples

lib: $(LIB_OBJ)

corbits: base

base: lib $(BASE_OBJ)
	$(CC) $(LDFLAGS) $(LIB_OBJ) $(BASE_OBJ) -o $(BASE_PATH)/corbits

examples: $(EXAMPLES)

# Kepler-11

kepler-11: lib $(KEP11_OBJ)
	$(CC) $(LDFLAGS) $(LIB_OBJ) $(KEP11_OBJ) -o $(KEP11_PATH)/$@

run-kepler-11: kepler-11
	cd $(KEP11_PATH); ./kepler-11

# Period ratio distribution

period-dist: lib $(PER_OBJ)
	$(CC) $(LDFLAGS) $(LIB_OBJ) $(PER_OBJ) -o $(PER_PATH)/$@

run-period-dist: period-dist $(PER_PATH)/koi-data-edit.txt
	cd $(MHS_PATH); ./period-dist

period-hist: $(PER_PATH)/hist/adj_hist_py.txt \
	$(PER_PATH)/hist/all_hist_py.txt \
	$(PER_PATH)/hist/snr_hist_py.txt
	cd $(PER_PATH)/hist; python make_hist.py 2> /dev/null

# MHS distribution

mhs-dist: lib $(MHS_OBJ)
	$(CC) $(LDFLAGS) $(LIB_OBJ) $(MHS_OBJ) -o $(MHS_PATH)/$@

run-mhs-dist: mhs-dist $(MHS_PATH)/koi-data-edit.txt
	cd $(PER_PATH); ./mhs-dist

# Solar System

solar-system: lib $(SOLSYS_OBJ)
	$(CC) $(LDFLAGS) $(LIB_OBJ) $(SOLSYS_OBJ) -o $(SOLSYS_PATH)/$@

run-solar-system: solar-system
	cd $(SOLSYS_PATH); ./solar-system 2> /dev/null

# ref: http://mrbook.org/tutorials/make
.cpp.o:
	$(CC) $(CFLAGS) $< -o $@

# remove object files and executables
clean:
	rm -f $(LIB_PATH)/*.o \
	$(BASE)/*.o \
	$(BASE)/corbits \
	$(KEP11_PATH)/*.o \
	$(KEP11_PATH)/kepler-11 \
	$(PER_PATH)/*.o \
	$(PER_PATH)/period-dist \
	$(SOLSYS_PATH)/*.o \
	$(SOLSYS_PATH)/solar-system \

# remove all output files
clean-all: clean
	rm -f $(PER_PATH)/*.txt \
	$(PER_PATH)/stat/*.txt \
	$(PER_PATH)/hist/*.txt \
	$(PER_PATH)/hist/*.pdf \
	$(PER_PATH)/*.log \
	$(SOLSYS_PATH)/*.csv

# files

$(PER_PATH)/koi-data-edit.txt:
	cd $(PER_PATH); ./grab.sh

$(PER_PATH)/hist/adj_hist_py.txt: run-period-dist

$(PER_PATH)/hist/all_hist_py.txt: run-period-dist

$(PER_PATH)/hist/snr_hist_py.txt: run-period-dist
