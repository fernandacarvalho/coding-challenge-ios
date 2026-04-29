.PHONY: setup lint

# Wire the versioned hooks directory — run once per clone
setup:
	git config core.hooksPath .githooks
	chmod +x .githooks/pre-commit
	@echo "Git hooks configured. SwiftLint will run before every commit."
	@echo "Install SwiftLint if you haven't: brew install swiftlint"

# Run lint manually against the full project
lint:
	cd world-peek-ios && swiftlint lint --config .swiftlint.yml
