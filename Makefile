.SUFFIXES:
.PHONY: all clean build_info

# remove ALL implicit rules
.SUFFIXES:
MAKEFLAGS+=" -r "

# add parallelism equal to number of cores
MAKEFLAGS+=" -j$(grep -c "vendor_id" /proc/cpuinfo) "

BUILD_MODE ?= debug

BUILD_ROOT=build/
EXE_DIR=$(BUILD_ROOT)EXE/
OBJ_DIR=$(BUILD_ROOT)OBJ/
DEPS_DIR=$(BUILD_ROOT)DEPS/
LIB_DIR=$(BUILD_ROOT)LIB/

# Define subsystems
SUBSYSTEMS = circuit_graph/ elements/ main/ text/ utils/ analysis/

# Define source directories
SOURCE_ROOT = src/
SOURCE_DIRS = \
	$(SOURCE_ROOT) \
	$(addprefix $(SOURCE_ROOT),$(SUBSYSTEMS))


# compute all directories that might need creation
DIRS=$(BUILD_ROOT) $(EXE_DIR) $(OBJ_DIR) $(DEPS_DIR) $(DEPS_DIR)$(SOURCE_ROOT) $(LIB_DIR) \
	$(addprefix $(OBJ_DIR),$(SUBSYSTEMS)) \
	$(addprefix $(DEPS_DIR),$(SOURCE_DIRS))

# CXX = clang++ -stdlib=libstdc++
# CXX = g++

# put warning flags here - go to compiler *and* linker.
WARNING_FLAGS += -Wall -Wextra -pedantic -Weffc++ -Werror

# put other flags for both the compiler & linker here
EXTRA_FLAGS = -std=c++11

# add flags for debugging
ifeq ($(BUILD_MODE),debug)
	EXTRA_FLAGS += -ggdb -D DEBUG
endif

# add flags for release
ifeq ($(BUILD_MODE),release)
	EXTRA_FLAGS += -flto -O3
#	EXTRA_FLAGS += -Wno-maybe-uninitialized # silence g++
endif

LIBRARY_LINK_FLAGS += \
	$(shell pkg-config --libs --static opencv) \
	$(shell pkg-config --libs --static tesseract) \
	$(shell pkg-config --libs --static python3) \
	-lboost_python3 \
	-lboost_system \
	-lpthread \

# GRAPHICS_INCL_FLAGS += $(shell pkg-config --cflags gtkmm-3.0)
OPENCV_INCL_FLAGS += $(shell pkg-config --cflags opencv)
PYTHON_INCL_FLAGS += $(shell pkg-config --cflags python3)

INCLUDE_FLAGS += \
	-I $(SOURCE_ROOT)

CXXFLAGS += $(EXTRA_FLAGS) $(WARNING_FLAGS) $(INCLUDE_FLAGS) -fPIC
LDFLAGS  += $(EXTRA_FLAGS) $(WARNING_FLAGS) $(LIBRARY_LINK_FLAGS)

# keep .o files
.PRECIOUS: $(OBJ_DIR)%.o

# define executables
EXES= \
	$(EXE_DIR)elements \	
	$(EXE_DIR)circuit_graph_test \
	$(EXE_DIR)text_test \
	$(EXE_DIR)analysis_test \
	$(EXE_DIR)main

# define libs to build
LIBS= \
	$(LIB_DIR)circuit_analyzer.so \
	$(LIB_DIR)common.so

all: $(EXES) $(LIBS) | build_info

build_info:
	@echo "Building with makeflags ${MAKEFLAGS}"
	@echo "In build mode ${BUILD_MODE}"

# add more dependencies here:
$(EXE_DIR)elements: \
	$(OBJ_DIR)elements/elements.o \
	$(OBJ_DIR)elements/elements_test_main.o

$(EXE_DIR)circuit_graph_test: \
	$(OBJ_DIR)circuit_graph/circuit_graph_test_main.o \
	$(OBJ_DIR)circuit_graph/circuit_graph.o \
	$(OBJ_DIR)circuit_graph/connection_finding.o \
	$(OBJ_DIR)circuit_graph/line_clustering.o \
	$(OBJ_DIR)circuit_graph/line_finding.o \
	$(OBJ_DIR)elements/elements.o \
	$(OBJ_DIR)utils/geometry_utils.o

$(EXE_DIR)text_test: \
	$(OBJ_DIR)text/text_finder.o \
	$(OBJ_DIR)text/text_test_main.o

$(EXE_DIR)analysis_test: \
	$(OBJ_DIR)analysis/analysis.o \
    $(OBJ_DIR)analysis/analysis_test_main.o

$(EXE_DIR)main: \
	$(OBJ_DIR)main/main.o \
	$(OBJ_DIR)analysis/analysis.o \
	$(OBJ_DIR)elements/elements.o \
	$(OBJ_DIR)text/text_finder.o \
	$(OBJ_DIR)circuit_graph/circuit_graph.o \
	$(OBJ_DIR)circuit_graph/connection_finding.o \
	$(OBJ_DIR)circuit_graph/line_clustering.o \
	$(OBJ_DIR)circuit_graph/line_finding.o \
	$(OBJ_DIR)utils/geometry_utils.o

# define extra flags for particular object files
# adds graphics include flags to everything in graphics dir
# $(OBJ_DIR)graphics/%.o: INCLUDE_FLAGS+=$(GRAPHICS_INCL_FLAGS)

$(OBJ_DIR)elements/%.o: INCLUDE_FLAGS+=$(OPENCV_INCL_FLAGS)

$(OBJ_DIR)main/%.o: INCLUDE_FLAGS+=$(PYTHON_INCL_FLAGS)

# Define the dependancies for the main circuit analyzer library
$(LIB_DIR)circuit_analyzer.so: \
	$(OBJ_DIR)main/main.o \
	$(OBJ_DIR)analysis/analysis.o \
	$(OBJ_DIR)elements/elements.o \
	$(OBJ_DIR)text/text_finder.o \
	$(OBJ_DIR)circuit_graph/circuit_graph.o \
	$(OBJ_DIR)circuit_graph/connection_finding.o \
	$(OBJ_DIR)circuit_graph/line_clustering.o \
	$(OBJ_DIR)circuit_graph/line_finding.o \
	$(OBJ_DIR)utils/geometry_utils.o

$(LIB_DIR)common.so: \
	$(OBJ_DIR)main/common.o

# include all the dependency files, if any exist
EXISTING_DEP_FILES = \
	$(foreach dir,$(SOURCE_DIRS), \
		$(wildcard $(DEPS_DIR)$(dir)*.d) \
	)
ifneq (,$(EXISTING_DEP_FILES))
include $(EXISTING_DEP_FILES)
endif

# compile .cpp to .o
# second CC line generates the initial dependency file
# first sed line adds $(OBJ_DIR) prefixes to the dependency file,
# second one adds stub rules for each depended on file (make might
# complain with generated files
.SECONDEXPANSION:
$(OBJ_DIR)%.o: $(SOURCE_ROOT)%.cpp | build_info $(OBJ_DIR)$$(dir %) $(DEPS_DIR)$(SOURCE_ROOT)$$(dir %)
	$(CXX) -c  $(shell readlink --canonicalize $<) -o  $@ $(CXXFLAGS)
	@$(CXX) -MM $< -MF $(DEPS_DIR)$<.d.tmp $(CXXFLAGS)
	@sed -e 's|.*:|$@:|' < $(DEPS_DIR)$<.d.tmp > $(DEPS_DIR)$<.d
	@sed -e 's/.*://' -e 's/\\$$//' < $(DEPS_DIR)$<.d.tmp | fmt -1 | \
	 sed -e 's/^ *//' -e 's/$$/:/' >> $(DEPS_DIR)$<.d
	@rm -f $(DEPS_DIR)$<.d.tmp

# compile *.o's into an executable
$(EXE_DIR)%: | build_info $(EXE_DIR)
	$(CXX) $^ -o $@ $(LDFLAGS)

# compile *.o's into libraries
$(LIB_DIR)%: | build_info $(LIB_DIR)
	$(CXX) -shared -Wl,--export-dynamic $^ -o $@ $(LDFLAGS)

$(DIRS):
	mkdir -p $@

clean:
	-rm -f $(EXES);
	-rm -f $(LIBS);
	-if [ -e $(EXE_DIR)  ]; then rmdir --ignore-fail-on-non-empty $(EXE_DIR);  fi;
	-if [ -e $(LIB_DIR)  ]; then rmdir --ignore-fail-on-non-empty $(LIB_DIR);  fi;

	for subdir in $(SOURCE_DIRS); do \
		if [ -e $(DEPS_DIR)$${subdir} ]; then \
			deps_subdir=$$(readlink --canonicalize $(DEPS_DIR)$${subdir})/; \
			echo $${deps_subdir}; \
			rm -f $${deps_subdir}*.d; \
			rmdir --ignore-fail-on-non-empty $${deps_subdir}; \
		fi; \
	done
	for subdir in $(SUBSYSTEMS); do \
		if [ -e $(OBJ_DIR)$${subdir} ]; then \
			objs_subdir=$$(readlink --canonicalize $(OBJ_DIR)$${subdir})/; \
			echo $${objs_subdir}; \
			rm -f $${objs_subdir}*.o; \
			rmdir --ignore-fail-on-non-empty $${objs_subdir}; \
		fi; \
	done
