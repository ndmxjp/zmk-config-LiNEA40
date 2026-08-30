CONFIG_DIR = config

SRCS_LEFT = $(shell find $(CONFIG_DIR) -type f ! -name "*_right*")
SRCS_RIGHT = $(shell find $(CONFIG_DIR) -type f ! -name "*_left*")

TARGET_LEFT = ../zmk/app/build/left/zephyr/zmk.uf2
TARGET_RIGHT = ../zmk/app/build/right/zephyr/zmk.uf2

SHIELD_DIR = $(CONFIG_DIR)/boards/shields/LiNEA40
DRAWER_DIR = keymap-drawer
DRAWER_VENV = .venv-keymap-drawer
DRAWER = $(DRAWER_VENV)/bin/keymap

.PHONY: build clean draw

build: $(TARGET_LEFT) $(TARGET_RIGHT)

#build: $(TARGET_RIGHT)

$(TARGET_LEFT): $(SRCS_LEFT)
	docker exec -w /workspaces/zmk/app -it $(container_name) west build -d build/left -b seeeduino_xiao_ble -- -DSHIELD=LiNEA40_left -DZMK_CONFIG="/workspaces/zmk-config/config"
	docker exec -w /workspaces/zmk/app -it $(container_name) cp build/left/zephyr/zmk.uf2 build/LiNEA40_left.uf2

$(TARGET_RIGHT): $(SRCS_RIGHT)
	docker exec -w /workspaces/zmk/app -it $(container_name) west build -d build/right -b seeeduino_xiao_ble -S studio-rpc-usb-uart -S zmk-usb-logging -- -DSHIELD=LiNEA40_right -DZMK_CONFIG="/workspaces/zmk-config/config" -DZMK_EXTRA_MODULES="/workspaces/zmk-modules/zmk-pmw3610-driver;/workspaces/zmk-modules/zmk-rgbled-widget" -DCONFIG_ZMK_STUDIO=y -DCONFIG_ZMK_STUDIO_LOCKING=n
	docker exec -w /workspaces/zmk/app -it $(container_name) cp build/right/zephyr/zmk.uf2 build/LiNEA40_right.uf2

clean:
	docker exec -it $(container_name) rm -rf /workspaces/zmk/app/build

# Regenerate the keymap cheat sheet in $(DRAWER_DIR) from the keymap itself.
# The physical layout comes from the shield's zmk,physical-layout via -d, so the
# drawing cannot drift from the firmware.
#
# keymap-drawer 0.21.0 asks for tree-sitter>=0.24 but still calls the removed
# Language.query API, so it crashes on the version it requests. Downgrading has
# to be a second pip call: asking for both at once is a resolver conflict, while
# a follow-up install only warns and proceeds.
$(DRAWER):
	python3 -m venv $(DRAWER_VENV)
	$(DRAWER_VENV)/bin/pip install -q keymap-drawer==0.21.0
	$(DRAWER_VENV)/bin/pip install -q "tree-sitter<0.24" "tree-sitter-devicetree<0.13"

draw: $(DRAWER)
	$(DRAWER) -c keymap_drawer.config.yaml parse \
		-z $(CONFIG_DIR)/LiNEA40.keymap -o $(DRAWER_DIR)/LiNEA40.yaml
	$(DRAWER) -c keymap_drawer.config.yaml draw \
		-d $(SHIELD_DIR)/LiNEA40.dtsi $(DRAWER_DIR)/LiNEA40.yaml -o $(DRAWER_DIR)/LiNEA40.svg
