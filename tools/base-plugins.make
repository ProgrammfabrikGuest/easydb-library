WEB = build/webfrontend
L10N2JSON ?= easydb-l10n2json.py

JS ?= $(WEB)/${PLUGIN_NAME}.js
SCSS ?= $(WEB)/${PLUGIN_NAME}.scss
L10N = build-stamp-l10n


${JS}: $(subst .coffee,.coffee.js,${COFFEE_FILES})
	mkdir -p $(dir $@)
	cat $^ > $@

${SCSS}: ${SCSS_FILES}
	mkdir -p $(dir $@)
	cat $^ > $@

build-stamp-l10n: $(L10N_FILES)
	mkdir -p $(WEB)/l10n
	$(L10N2JSON) $(L10N_FILES) $(WEB)/l10n
	touch $@

%.coffee.js: %.coffee
	coffee -b -p --compile "$^" > "$@" || ( rm -f "$@" ; false )

$(WEB)/%: src/webfrontend/%
	mkdir -p $(dir $@)
	cp $^ $@

install:

uninstall:

google_csv:
	chmod u+w $(L10N_FILES)
	curl --silent -o - "https://docs.google.com/spreadsheets/u/1/d/$(L10N_GOOGLE_KEY)/export?format=csv&id=$(L10N_GOOGLE_KEY)&gid=$(L10N_GOOGLE_GID)" | sed -e 's/[[:space:]]*$$//' > $(L10N_FILES)
	chmod a-w $(L10N_FILES)
	$(MAKE) build-stamp-l10n


install-server: ${INSTALL_FILES}
	[ ! -z "${INSTALL_PREFIX}" ]
	mkdir -p ${INSTALL_PREFIX}/server/base/plugins/${PLUGIN_NAME}
	for f in ${INSTALL_FILES}; do \
		mkdir -p ${INSTALL_PREFIX}/server/base/plugins/${PLUGIN_NAME}/`dirname $$f`; \
		if [ -d "$$f" ]; then \
			cp -Pr $$f ${INSTALL_PREFIX}/server/base/plugins/${PLUGIN_NAME}/`dirname $$f`; \
		else \
			cp $$f ${INSTALL_PREFIX}/server/base/plugins/${PLUGIN_NAME}/$$f; \
		fi; \
	done

clean-base:
	rm -f $(L10N) $(subst .coffee,.coffee.js,${COFFEE_FILES}) $(JS) $(SCSS) \
    rm -f $(WEB)/l10n/*.json \
	rm -f build-stamp-l10n
	rm -rf build

wipe-base: clean-base
	find . -name '*~' -or -name '#*#' | xargs rm -f

.PHONY: all build clean clean-base wipe-base code install uninstall install-server google_csv

# vim:set ft=make:
