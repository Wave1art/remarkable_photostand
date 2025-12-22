.ONESHELL:
.SHELLFLAGS = -ec
.SILENT:

host=10.11.99.1
cooldown=3600

version := $(shell git describe --tags --always 2>/dev/null || git rev-parse --short HEAD)

renews.arm:
	# build inside the module directory so go can find the local go.mod
	cd remarkable_service && env GOOS=linux GOARCH=arm GOARM=7 go build -o ../renews.arm .

renews.arm64:
	# build inside the module directory so go can find the local go.mod
	cd remarkable_service && env GOOS=linux GOARCH=arm64 go build -tags "rmpp" -o ../renews.arm64 .

renews.x86:
	# build inside the module directory so go can find the local go.mod
	cd remarkable_service && go build -o ../renews.x86 .

# get latest prebuilt releases
.PHONY: download_prebuilt
download_prebuilt:
	curl -LO http://github.com/wave1art/remarkable_photog/releases/latest/download/release.zip
	unzip release.zip

# build release
.PHONY: release
release: renews.arm renews.x86 renews.arm64
	zip release.zip renews.arm renews.x86 renews.arm64
	gh release create --latest --verify-tag $(version) release.zip

# tag and push tag
.PHONY: tag
tag:
	git tag $(version)
	git push --tags

clean:
	rm -f renews.x86 renews.arm renews.arm64 release.zip
