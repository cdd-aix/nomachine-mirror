SHELL := /bin/bash
downloaded: download.list
	@echo +++ Fetching product files
	@mkdir -p $(DOWNLOADS)
	$(WGET) --mirror --input-file $< --directory-prefix $(DOWNLOADS)
# TODO: touch downloaded based on newest file on DOWNLOADS
CLEANFILES += downloaded
PRECIOUS_CLEANDIRS += $(DOWNLOADS)
DOWNLOADS = $(DESTDIR)/downloads
DESTDIR ?= $(PWD)
WGET = wget --wait=5 --random-wait --waitretry=5 --timestamping --no-verbose
WGET_BULK = $(WGET) --base='$(BASE_URL)' --input-file

PRODUCT_PAGES_D = $(DESTDIR)/product_pages.d
download.list: $(wildcard $(PRODUCT_PAGES_D)/*) product_pages
	@echo +++ Generating product file list
	./extract download $(PRODUCT_PAGES_D)/* > $@.new
	[ -s $@.new ] && mv -v $@.new $@
CLEANFILES += download.list

BASE_PAGES_D = $(DESTDIR)/base_pages.d
product_pages: $(wildcard $(BASE_PAGES_D)/*) $(wildcard $(PRODuCT_PAGES_D)/*) base_pages
	@echo +++ Fetching Product Pages
	@mkdir -p $(PRODUCT_PAGES_D)
	./extract product $(BASE_PAGES_D)/* > $@.product_pages1
	$(WGET_BULK) $@.product_pages1 --directory-prefix $(PRODUCT_PAGES_D)
	./extract product $(PRODUCT_PAGES_D)/* > $@.product_pages2
	$(WGET_BULK) $@.product_pages2 --directory-prefix $(PRODUCT_PAGES_D)
	find $(PRODUCT_PAGES_D) > $@
CLEANDIRS += $(PRODUCT_PAGES_D)
CLEANFILES += product_pages
BASE_URL = http://www.nomachine.com

base_pages: relative.urls
	@echo Fetching Base Pages
	@mkdir -p $(BASE_PAGES_D)
	$(WGET_BULK) $< --directory-prefix $(BASE_PAGES_D)
	find $(BASE_PAGES_D) > $@
CLEANFILES += base_pages
CLEANDIRS += $(BASE_PAGES_D)

clean:
	rm -vf $(CLEANFILES)
	rm -rvf $(CLEANDIRS)

realclean: clean
	rm -rvf $(PRECIOUS_CLEANDIRS)
