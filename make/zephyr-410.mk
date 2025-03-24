## PATH to your zephyr installation
export ZEPHYR_BASE := ${HOME}/_dev/_lib/zephyr_410/zephyr
## Toolchain to use, zephyr should be fine
export ZEPHYR_TOOLCHAIN_VARIANT := zephyr
## PATH to your zephyr SDK location, by default it is located in the home directory
export ZEPHYR_SDK_INSTALL_DIR := ${HOME}/zephyr-sdk-0.17.0

PATH := ${ZEPHYR_BASE}/scripts:${PATH}

