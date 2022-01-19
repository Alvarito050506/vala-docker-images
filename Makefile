include vala-release.mk
-include config.mk
include config.def.mk

export ARCHS_DEF

VALA_MINOR=$(shell printf $(VALA_VERSION) | sed -E 's/^([0-9]+)\.([0-9]+)\.([0-9]+)$$/\1.\2/')
VALA_NAME=vala-$(VALA_VERSION)

all: build build/$(VALA_NAME) $(DISTROS:%=buildx-%)

build:
	mkdir -p $@

build/$(VALA_NAME): build/$(VALA_NAME).tar.xz
	tar xf $^ -C build
	patch -s -p0 -d $@ < src/fixes.diff
	touch $@

build/$(VALA_NAME).tar.xz:
	curl -fsSL https://download.gnome.org/sources/vala/$(VALA_MINOR)/$(VALA_NAME).tar.xz -o $@

buildx-%: DISTRO=$(@:buildx-%=%)
build/Dockerfile.%: DISTRO=$(@:build/Dockerfile.%=%)

buildx-%: build/Dockerfile.%
	cd cfg && DISTRO=$(DISTRO) . $(DISTRO).cfg && cd .. && \
	docker buildx build -f $< --platform $${ARCHS} \
		--tag $(NAMESPACE):latest-$(DISTRO) \
		--build-arg VALA_NAME=$(VALA_NAME) \
		--build-arg DISTRO=$(DISTRO) \
		--build-arg TAG=$${TAG} build/

build/Dockerfile.%: cfg/%.cfg
	cd cfg && DISTRO=$(DISTRO) . ../$< && cd .. && \
	awk -v FROM="$${FROM}" -v BASE="$${BASE}" -v BUILD="$${BUILD}" -f src/gen.awk src/Dockerfile.tmpl > $@

clean:
	rm -rf build
