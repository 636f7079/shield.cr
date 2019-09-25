SHIELD_OUT ?= bin/shield
SHIELD_SRC ?= src/shield.cr
SYSTEM_BIN ?= /usr/local/bin

install: build
	cp $(SHIELD_OUT) $(SYSTEM_BIN) && rm -f $(SHIELD_OUT)*
build: shard
	crystal build $(SHIELD_SRC) -o $(SHIELD_OUT) --release
test: shard
	crystal spec
shard:
	shards build
clean:
	rm -f $(SHIELD_OUT)* && rm -rf lib