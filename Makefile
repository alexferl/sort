.PHONY: dev test fmt pre-commit

.DEFAULT: help
help:
	@echo "make dev"
	@echo "	setup development environment"
	@echo "make test"
	@echo "	run v test"
	@echo "make fmt"
	@echo "	run v fmt"
	@echo "make pre-commit"
	@echo "	run pre-commit"

dev:
	@echo
ifeq (, $(shell which pre-commit))
	$(error "No pre-commit in $(PATH), pre-commit (https://pre-commit.com) is required")
endif

test:
	v -stats test .

fmt:
	v fmt -w .

pre-commit:
	pre-commit
