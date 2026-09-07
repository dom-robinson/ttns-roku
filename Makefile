CHANNEL_NAME := TTNS FM
ZIP := out/ttns-roku.zip

-include .env
export

ROKU_DEV_TARGET ?=
ROKU_DEV_PASSWORD ?=
ROKU_SIGN_PASSWORD ?=
PYTHON ?= python3

.PHONY: images zip sideload package smoke screenshots deeplink clean

images:
	$(PYTHON) scripts/make_images.py

zip: images
	mkdir -p out
	rm -f $(ZIP)
	cd "$(CURDIR)" && zip -r $(ZIP) manifest source components images \
		-x "*.DS_Store" -x "out/*" -x ".env" -x ".env.*"

sideload: zip
	@test -n "$(ROKU_DEV_TARGET)" || (echo "Set ROKU_DEV_TARGET to your Roku IP"; exit 1)
	@test -n "$(ROKU_DEV_PASSWORD)" || (echo "Set ROKU_DEV_PASSWORD to the device developer password"; exit 1)
	curl --user rokudev:$(ROKU_DEV_PASSWORD) --digest \
		-F "mysubmit=Install" -F "archive=@$(ZIP)" \
		http://$(ROKU_DEV_TARGET)/plugin_install

package: zip
	@test -n "$(ROKU_DEV_TARGET)" || (echo "Set ROKU_DEV_TARGET to your Roku IP"; exit 1)
	@test -n "$(ROKU_DEV_PASSWORD)" || (echo "Set ROKU_DEV_PASSWORD to the device developer password"; exit 1)
	@test -n "$(ROKU_SIGN_PASSWORD)" || (echo "Set ROKU_SIGN_PASSWORD to your channel packaging password"; exit 1)
	curl --user rokudev:$(ROKU_DEV_PASSWORD) --digest \
		-F "mysubmit=Package" -F "app_name=$(CHANNEL_NAME)" \
		-F "passwd=$(ROKU_SIGN_PASSWORD)" -F "pkg_time=`date +%s`" \
		http://$(ROKU_DEV_TARGET)/plugin_package

smoke:
	python3 scripts/smoke_apis.py

screenshots:
	@test -n "$(ROKU_DEV_TARGET)" || (echo "Set ROKU_DEV_TARGET to your Roku IP"; exit 1)
	@test -n "$(ROKU_DEV_PASSWORD)" || (echo "Set ROKU_DEV_PASSWORD to the device developer password"; exit 1)
	python3 scripts/capture_store_screens.py

deeplink:
	@test -n "$(ROKU_DEV_TARGET)" || (echo "Set ROKU_DEV_TARGET to your Roku IP"; exit 1)
	curl -d '' "http://$(ROKU_DEV_TARGET):8060/launch/dev?contentId=brighton&mediaType=live"

clean:
	rm -rf out
