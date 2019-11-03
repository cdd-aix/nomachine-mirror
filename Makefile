downloaded: download.list
	mkdir -p $(DOWNLOADS)
	$(WGET) --input-file $< --directory-prefix $(DOWNLOADS)
	touch --reference=$< $@
# TODO: touch downloaded based on newest file on DOWNLOADS
CLEANFILES += downloaded
PRECIOUS_CLEANDIRS += $(DOWNLOADS)
DOWNLOADS = $(DESTDIR)/downloads
DESTDIR ?= $(PWD)
WGET = wget --timestamping
BASE_URL = https://www.nomachine.com
