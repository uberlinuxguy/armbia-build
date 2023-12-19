# Allwinner R16 quad core 2Gb SoC Wifi eMMC
BOARD_NAME="ClockworkPi Gameshell"
BOARDFAMILY="sun8i"
BOARD_MAINTAINER=""
BOOTCONFIG="clockworkpi-cpi3_defconfig"
OVERLAY_PREFIX="sun8i-r16"
KERNEL_TARGET="current,edge"
KERNEL_TEST_TARGET="current"
BOOT_FDT_FILE="sun8i-r16-clockworkpi-cpi3.dtb"
LINUXCONFIG=clockworkpi_cpi3



BOOTFS_TYPE="fat"
BOOT_FS_LABEL="BOOT"
DEFAULT_CONSOLE="serial"
SERIALCON="ttyS0:115200"


function post_family_tweaks__no_root_change_pw() {
	display_alert "$BOARD" "Removing /root/.not_logged_in_yet" "info"

	rm -f "${SDCARD}"/root/.not_logged_in_yet
	return 0
}
function post_family_tweaks__install_retroarch() {
	sudo apt-get -y install retroarch
	return $?
}

#function post_family_tweaks__install_emulationstation() {
#	sudo apt-get -y install libsdl2-dev libboost-system-dev libboost-filesystem-dev libboost-date-time-dev libboost-locale-dev libfreeimage-dev libfreetype6-dev libeigen3-dev libcurl4-openssl-dev libasound2-dev libgl1-mesa-dev build-essential cmake
#	cd /tmp
#	git clone https://github.com/Aloshi/EmulationStation.git
#	cd EmulationStation
#	cmake .
#	make
#	make install
#}
