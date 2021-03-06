REDIS_SERVER_PATH=../redis-4.0-rc2/src/redis-server

# set environment variable RM_INCLUDE_DIR to the location of redismodule.h
ifndef RM_INCLUDE_DIR
        RM_INCLUDE_DIR=./
endif


# find the OS
uname_S := $(shell sh -c 'uname -s 2>/dev/null || echo not')

# Compile flags for linux / osx
ifeq ($(uname_S),Linux)
        SHOBJ_CFLAGS ?=  -fno-common -g -ggdb
        SHOBJ_LDFLAGS ?= -shared
else
        SHOBJ_CFLAGS ?= -dynamic -fno-common -g -ggdb
        SHOBJ_LDFLAGS ?= -bundle -undefined dynamic_lookup
endif

CFLAGS = -I$(RM_INCLUDE_DIR) -g -fPIC -lc -lm -O0 -std=gnu99
CC=gcc
.SUFFIXES: .c .so .o

MODULE = bloom_filter
OBJS = murmur.o
all:  $(OBJS) $(MODULE)



$(MODULE): %: %.o
	$(LD) -o $@.so  $(OBJS) $< $(SHOBJ_LDFLAGS) $(LIBS) -lc


test $(OBJS) $(MODULE):
	@pip install redis
	@echo "Starting redis server";
	$(REDIS_SERVER_PATH) --loadmodule $(PWD)/bloom_filter.so > /dev/null &
	python test.py
	@echo "Stoping redis server"
	@sleep 1
	@pkill redis-server

clean:
	rm -rf *.o *.so
