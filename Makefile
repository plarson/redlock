build:
	@echo "Building Redscript"
	@swift build

debug: build
	@echo "Debugging Redscript"
	@lldb .build/debug/Redscript

build-release:
	@echo "Building Redscript in Release"
	@swift build --configuration release

test: redis
	@swift test

redis-start:
	@redis-server TestRedis/redis.conf

redis-stop:
	@if [ -e "TestRedis/redis.pid" ]; then kill `cat TestRedis/redis.pid`; fi;

redis:
	@if [ ! -e "TestRedis/redis.pid" ]; then redis-server TestRedis/redis.conf; fi;

clean: redis-stop
	rm -fr .build Packages TestRedis/dump.rdb