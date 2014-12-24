MANTA_URL=https://us-east.manta.joyent.com
LATEST_POINTER=$(MANTA_URL)/Joyent_Dev/public/builds/platform/master-latest
LATEST_DIR=$(shell curl $(LATEST_POINTER) 2>/dev/null)
LATEST_VER=$(shell cut -d "-" -f 2 <<< $(notdir $(LATEST_DIR)))

all: output-usb/platform-$(LATEST_VER).usb

upload: output-usb/platform-$(LATEST_VER).usb.gz
	mmkdir ~~/public/smartos
	mput -m -f $< ~~/public/smartos/franken-smartos.usb.gz

output-usb/platform-$(LATEST_VER).usb: proto/boot/grub output/platform-$(LATEST_VER) Makefile src/*
	cp src/smartos_prompt_config.sh output/platform-$(LATEST_VER)/
	tools/build_usb -o standalone=true -c ttya
	touch $@

proto/boot/grub: downloads/boot-master-$(LATEST_VER).tgz
	mkdir -p proto
	(cd proto && tar xzvf $(CURDIR)/$<)
	touch $@

output/platform-$(LATEST_VER): downloads/platform-master-$(LATEST_VER).tgz
	mkdir -p output
	(cd output && tar xzvf $(CURDIR)/$<)
	touch $@

downloads:
	mkdir -p downloads
	touch $@

downloads/%: downloads
	(cd downloads && wget -c $(MANTA_URL)$(LATEST_DIR)/platform/$(notdir $@))
	touch $@

%.gz: %
	gzip --fast < $< > $@

clean:
	rm -rf output* proto*
