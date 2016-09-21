
GEM_NAME = termkit

include Makefile.common

.PHONY: test
test:
	RUBYOPT=-w TZ=Europe/Vienna $(BUNDLER) exec ./test/suite_all.rb -v

.PHONY: cov
cov:
	RUBYOPT=-w TZ=Europe/Vienna COVERAGE=1 $(BUNDLER) exec ./test/suite_all.rb -v

.PHONY: cov_local
cov_local:
	RUBYOPT=-w TZ=Europe/Vienna SIMPLECOV_PHPUNIT_LOAD_PATH=../simplecov-phpunit COVERAGE=1 $(BUNDLER) exec ./test/suite_all.rb -v

doc:
	rdoc README.md lib/termkit
