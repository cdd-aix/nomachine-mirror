downloaded: download.list
	echo +++ Fetching product files
	mkdir -p $(DOWNLOADS)
	$(WGET) --input-file $< --directory-prefix $(DOWNLOADS)
	touch --reference=$< $@
# TODO: touch downloaded based on newest file on DOWNLOADS
CLEANFILES += downloaded
PRECIOUS_CLEANDIRS += $(DOWNLOADS)
DOWNLOADS = $(DESTDIR)/downloads
DESTDIR ?= $(PWD)
WGET = wget --timestamping

download.list: product_download_page.list extract_download_urls
	echo +++ Generating product file list
	./extract_download_urls < $< > $@.new
	touch --reference=$< $@.new
	mv -v $@.new $@
CLEANFILES += download.list

product_download_page.list: base_download.list
	echo +++ Fetching Producting Download Pages
	rm -rvf $(PRODUCT_PAGES_D)
	mkdir -p $(PRODUCT_PAGES_D)
	$(WGET) --base='$(BASE_URL)' --input-file $< --directory-prefix $(PRODUCT_PAGES_D)
	find $(PRODUCT_PAGES_D) -type f | sort > $@.new
	# touch --reference $< $@.new
	mv -v $@.new $@
CLEANFILES += product_page.list
CLEANDIRS += $(PRODUCT_PAGES_D)
BASE_URL = http://nomachine.com
PRODUCT_PAGES_D = $(DESTDIR)/product_pages.d

base_download.list: base_download extract
	echo +++ Generating Product Download Page List
	find $(BASE_DOWNLOAD_D) -type f | xargs ./extract product > $@.new
	[ -s $@.new ] || rm -vf $@.new
	cat $@.new
	mv -v $@.new $@
CLEANFILES += base_download.list

base_download: relative.urls
	mkdir -p $(BASE_DOWNLOAD_D)
	$(WGET) --base='$(BASE_URL)' --input-file $< --directory-prefix $(BASE_DOWNLOAD_D)
	touch --reference $< $@.new
	mv -v $@.new $@
CLEANFILES += base_download
CLEANDIRS += $(BASE_DOWNLOAD_D)
BASE_DOWNLOAD_D = $(DESTDIR)/base_download.d

clean:
	rm -vf $(CLEANFILES)
	rm -rvf $(CLEANDIRS)

realclean: clean
	rm -rvf $(PRECIOUS_CLEANDIRS)
