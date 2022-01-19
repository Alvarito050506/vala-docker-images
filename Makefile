include vala-release.mk
-include config.mk
include config.def.mk

VALA_MINOR=$(shell printf $(VALA_VERSION) | sed -E 's/^([0-9]+)\.([0-9]+)\.([0-9]+)$/\1.\2/')
VALA_NAME=vala-$(VALA_VERSION)

all: $(VALA_NAME) $(patsubst %,buildx-%,$(DISTROS))

$(VALA_NAME): $(VALA_NAME).tar.xz
	tar xf $^
	patch -s -p0 -d $(VALA_NAME) < fixes.diff

$(VALA_NAME).tar.xz:
	curl -fsSLO https://download.gnome.org/sources/vala/$(VALA_MINOR)/$@

buildx-%: DISTRO=$(patsubst buildx-%,%,$@)
buildx-%: TAG=$(TAG_$(DISTRO))
buildx-%: NS_$(DISTRO)?=$(DISTRO)

buildx-%: Dockerfile.%
	docker buildx build -f $< --platform $(PLATFORMS) \
		--tag $(NAMESPACE):latest-$(DISTRO) \
		--build-arg VALA_NAME=$(VALA_NAME) \
		--build-arg DISTRO=$(DISTRO) \
		--build-arg TAG=$(TAG) .
