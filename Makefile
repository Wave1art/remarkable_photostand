.ONESHELL:
.SHELLFLAGS = -ec
.SILENT:

# We use a recursive variable (=) so it evaluates when called
VERSION = $(shell git describe --tags --always 2>/dev/null || git rev-parse --short HEAD)

renews.arm:
	cd remarkable_service && env GOOS=linux GOARCH=arm GOARM=7 go build -o ../renews.arm .

renews.arm64:
	cd remarkable_service && env GOOS=linux GOARCH=arm64 go build -tags "rmpp" -o ../renews.arm64 .

renews.x86:
	cd remarkable_service && go build -o ../renews.x86 .

.PHONY: release
release: renews.arm renews.x86 renews.arm64
	# 1. Check for uncommitted changes
	if [ -n "$$(git status --porcelain)" ]; then \
		echo "ERROR: Working directory is dirty. Commit your changes before releasing."; \
		exit 1; \
	fi; \
	\
	# 2. Capture the version string
	V=$(VERSION); \
	echo "Target version: $$V"; \
	\
	# 3. Ensure the tag exists locally
	if ! git rev-parse -q --verify "refs/tags/$$V" >/dev/null; then \
		echo "Creating local tag: $$V"; \
		git tag "$$V"; \
	fi; \
	\
	# 4. Push the tag to origin
	echo "Syncing tag $$V to origin..."; \
	git push origin "refs/tags/$$V:refs/tags/$$V"; \
	\
	# 5. Package and Release
	zip release.zip renews.arm renews.x86 renews.arm64; \
	echo "Creating GitHub release for $$V..."; \
	gh release create "$$V" release.zip --latest --verify-tag