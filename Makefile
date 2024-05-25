PROJ_BUILD_DIR = build
DEPS_BUILD_DIR = build.depends


ifdef MAKEDIR:	# make - false,		nmake - unused target
!ifdef MAKEDIR	# make - not seen,	nmake - true

#### Microsoft nmake.
!MESSAGE Windows NMAKE Makefile
!if EXISTS(Makefile.local)
!include Makefile.local
!endif
mkdir = -mkdir
rmdir = -rmdir /s /q
DIRSEP=\\


!else		# make - not seen,		nmake - stops reading
else		# make started reading,		nmake: not seen

#### GNU/Linux make.
$(info Linux/GNU MAKE Makefile)
.NOTPARALLEL:
-include Makefile.local
mkdir = mkdir -p
rmdir = rm -rf
DIRSEP=/

CMAKE_REQV = 3.25
# https://cmake.org/files/v3.25/
CMAKE_PATCH = 3
CMAKE_CURV = $(shell (cmake --version 2>/dev/null|| echo version 0.00.0) | grep version | sed -e 's/.*version *\([0-9]*\.[0-9]*\).*/\1/')
ifeq ($(shell expr $(CMAKE_CURV) \< $(CMAKE_REQV)) , 1)
$(info CMake is too old. Version : $(CMAKE_CURV), Required: $(CMAKE_REQV))
$(info $(shell sudo apt-get purge -y -q cmake cmake-data))
$(info $(shell sudo rm /usr/bin/cmake 2>/dev/null))
CMAKE_FILES = /usr/bin/cmake /usr/share/cmake-$(CMAKE_REQV)/Licenses
else
$(info Found suitable CMake version : $(CMAKE_CURV), Required: $(CMAKE_REQV))
CMAKE_FILES = /usr/bin/cmake
endif
CMAKE_HW = $(shell uname --hardware-platform)
$(CMAKE_FILES):
	@echo Retrieving CMake V$(CMAKE_REQV)
	curl --silent --url https://cmake.org/files/v$(CMAKE_REQV)/cmake-$(CMAKE_REQV).$(CMAKE_PATCH)-linux-$(CMAKE_HW).sh --output /tmp/cmake-install.sh
	@sudo mkdir -p /opt/cmake
	@chmod u+x /tmp/cmake-install.sh
	sudo /tmp/cmake-install.sh --prefix=/usr --exclude-subdir --skip-license
	@rm /tmp/cmake-install.sh


CLANG_REQV = 17
CLANGCL_CURV = $(shell (/usr/bin/clang --version 2>/dev/null|| echo version 0.0.0) | grep version | sed -e 's/.*version *\([0-9]*\).*/\1/')
ifeq ($(shell expr $(CLANGCL_CURV) \< $(CLANG_REQV)) , 1)
$(info CLang C compiler is too old. Version : $(CLANGCL_CURV), Required: $(CLANG_REQV))
$(info $(shell sudo rm /usr/bin/clang 2>/dev/null))
CLANGCL_FILES = /usr/bin/clang /usr/bin/clang-$(CLANG_REQV)
else
$(info Found suitable CLang C compiler version: $(CLANGCL_CURV), Required: $(CLANG_REQV))
CLANGCL_FILES = /usr/bin/clang
endif
CLANGPP_CURV = $(shell (/usr/bin/clang++ --version 2>/dev/null|| echo version 0.0.0) | grep version | sed -e 's/.*version *\([0-9]*\).*/\1/')
ifeq ($(shell expr $(CLANGPP_CURV) \< $(CLANG_REQV)) , 1)
$(info CLang C++ compiler is too old. Version : $(CLANGPP_CURV), Required: $(CLANG_REQV))
$(info $(shell sudo rm /usr/bin/clang++ 2>/dev/null))
CLANGPP_FILES = /usr/bin/clang++ /usr/bin/clang++-$(CLANG_REQV)
else
$(info Found suitable CLang C++ compiler version: $(CLANGPP_CURV), Required: $(CLANG_REQV))
CLANGPP_FILES = /usr/bin/clang++
endif
CLANG_FILES =  $(CLANGCL_FILES) $(CLANGPP_FILES) /usr/bin/clangd /usr/bin/clang-format /usr/bin/clang-tidy
$(CLANG_FILES):
	@echo Retrieving CLang V$(CLANG_REQV)
	curl --silent --url https://apt.llvm.org/llvm.sh --output /tmp/llvm.sh
	@chmod u+x /tmp/llvm.sh
	sudo /tmp/llvm.sh $(CLANG_REQV) all
	@rm /tmp/llvm.sh
	@for FILE in /usr/bin/clang*-$(CLANG_REQV); do \
		sudo ln -s --force $${FILE} $${FILE%%-$(CLANG_REQV)}; \
		ls -l $${FILE%%-$(CLANG_REQV)}; \
	done

.PHONY: env

env:
	sudo apt-get -y install make cmake ninja-build build-essential libfmt-dev python3


endif		# make: close condition,	nmake: not seen
!endif :	# make: unused target,		nmake close conditional


# $(error FINISH EARLY)



.PHONY: clean clean_deps clean_all

clean: $(CMAKE_FILES)
	@echo make CLEAN...
	@echo Deleting directory: $(PROJ_BUILD_DIR)
	$(rmdir) $(PROJ_BUILD_DIR)

clean_deps: $(CMAKE_FILES)
	@echo make CLEAN_DEPS...
	@echo Deleting directory: $(DEPS_BUILD_DIR)
	$(rmdir) $(DEPS_BUILD_DIR)

clean_all: clean_deps clean $(CMAKE_FILES) $(CLANG_FILES)
	@echo make CLEAN_ALL...
	@echo DONE CLEAN_ALL



.PHONY: config_dbg config_rel build release $(DEPS_BUILD_DIR) cmake--build

config_dbg: $(CMAKE_FILES) $(CLANG_FILES)
	@echo "~~~~~~~~~~ ~~~~~~~~~~ ~~~~~~~~~~ ~~~~~~~~~~ ~~~~~~~~~~ ~~~~~~~~~~ ~~~~~~~~~~ ~~~~~~~~~~"
	@echo make CONFIG_DBG...
	$(mkdir) "$(PROJ_BUILD_DIR)"
	cmake --preset=default -S . -B $(PROJ_BUILD_DIR) -Wdev  #--trace-source=CMakeLists.txt

config_rel: $(CMAKE_FILES) $(CLANG_FILES)
	@echo "~~~~~~~~~~ ~~~~~~~~~~ ~~~~~~~~~~ ~~~~~~~~~~ ~~~~~~~~~~ ~~~~~~~~~~ ~~~~~~~~~~ ~~~~~~~~~~"
	@echo make CONFIG_REL...
	$(mkdir) "$(PROJ_BUILD_DIR)"
	cmake --preset=release -S . -B $(PROJ_BUILD_DIR) -Wdev #--trace-source=CMakeLists.txt

build: config_dbg $(DEPS_BUILD_DIR) $(CLANG_FILES) cmake--build
	@echo make BUILD...

release: config_rel  $(DEPS_BUILD_DIR) $(CLANG_FILES) cmake--build
	@echo make RELEASE...

$(DEPS_BUILD_DIR):
	$(mkdir) "$(DEPS_BUILD_DIR)"

cmake--build: $(CMAKE_FILES)
	@echo "########## ########## ########## ########## ########## ########## ########## ##########"
	cmake --build $(PROJ_BUILD_DIR) --target all


.PHONY: lint test profile run

lint:
	@echo make LINT starting
	@echo ERROR: Not Implemented

test: $(CMAKE_FILES)
	@echo make TEST starting...
	@echo ERROR: Not Implemented

profile:
	@echo make BUILD starting...
	@echo ERROR: Not Implemented

run:
	@echo make RUN starting...
	@echo ERROR: Not Implemented
