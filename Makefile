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

check-pre-commit:
ifeq (, $(shell which pre-commit))
	$(error "No pre-commit in $(PATH), pre-commit (https://pre-commit.com) is required")
endif

dev: check-pre-commit
	pre-commit install

test:
	v -stats test .

fmt:
	v fmt -w .

pre-commit: check-pre-commit
	pre-commit
