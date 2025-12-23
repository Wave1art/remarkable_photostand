.ONESHELL:
.SHELLFLAGS = -ec
.SILENT:

# Use := to ensure this is calculated once at the start
VERSION := $(shell git describe --tags --always 2>/dev/null || git rev-parse --short HEAD)

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
	fi
	
	# 2. Log Version
	echo "Target version: $(VERSION)"
	
	# 3. Ensure the tag exists locally
	if ! git rev-parse -q --verify "refs/tags/$(VERSION)" >/dev/null; then \
		echo "Creating local tag: $(VERSION)"; \
		git tag "$(VERSION)"; \
	fi
	
	# 4. Push the tag to origin
	echo "Syncing tag $(VERSION) to origin..."
	git push origin "refs/tags/$(VERSION):refs/tags/$(VERSION)"
	
	# 5. Package and Release
	zip -j release.zip renews.arm renews.x86 renews.arm64 ./remarkable_service/renews.sh
	echo "Creating GitHub release for $(VERSION)..."
	gh release create "$(VERSION)" release.zip --latest --verify-tag

clean:
	rm -f renews.x86 renews.arm renews.arm64 release.zip