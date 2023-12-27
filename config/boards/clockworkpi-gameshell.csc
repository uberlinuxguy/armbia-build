# Allwinner R16 quad core 2Gb SoC Wifi eMMC
BOARD_NAME="ClockworkPi Gameshell"
BOARDFAMILY="sun8i"
BOARD_MAINTAINER=""
BOARD=clockworkpi-gameshell
BOOTCONFIG="clockworkpi-cpi3_defconfig"
OVERLAY_PREFIX="sun8i-r16"
KERNEL_TARGET="current,edge"
KERNEL_TEST_TARGET="current"
BOOT_FDT_FILE="sun8i-r16-clockworkpi-cpi3.dtb"
#LINUXCONFIG=clockworkpi_cpi3
INCLUDE_HOME_DIR=yes


BOOTFS_TYPE="fat"
BOOT_FS_LABEL="BOOT"
#DEFAULT_CONSOLE="serial"
SERIALCON="ttyS0:115200"


function post_family_tweaks__no_root_change_pw() {
	display_alert "$BOARD" "Removing /root/.not_logged_in_yet" "info"

	rm -f "${SDCARD}"/root/.not_logged_in_yet

	return 0
}

function post_family_tweaks__add_cpi_user(){
	display_alert "$BOARD" "Adding cpi user" "info"
	chroot_sdcard adduser cpi
	chroot_sdcard groupadd cpifav -g 31415
	chroot_sdcard adduser cpi cpifav
	chroot_sdcard groupmod -a -U cpi tty
	chroot_sdcard groupmod -a -U cpi video
	chroot_sdcard mkdir -p /home/cpi
	chroot_sdcard chown cpi /home/cpi
}

function post_family_tweaks__add_golang_and_git(){
	display_alert "$BOARD" "Installing golang and git" "info"
	do_with_retries 3 chroot_sdcard_apt_get_update
	chroot_sdcard_apt_get_install golang git
}

function post_family_tweaks__grab_cpi_launchergo(){
	display_alert "$BOARD" "Install and configure cpi launchergo" "info"
	do_with_retries 3 chroot_sdcard_apt_get_update
	chroot_sdcard_apt_get_install xinit twm xserver-xorg-legacy libsdl2-ttf-2.0-0 aria2 libsdl2-gfx-1.0-0 libsdl2-image-2.0-0 retroarch
	chroot_sdcard mkdir -p /home/cpi/apps/emulators
	chroot_sdcard mkdir -p /home/cpi/games
	chroot_sdcard mkdir -p /home/cpi/music

	chroot_sdcard cd '/home/cpi; git clone https://github.com/clockworkpi/launchergo.git'
	chroot_sdcard cp /home/cpi/launchergo/.cpirc /home/cpi/.bashrc
	chroot_sdcard touch /home/cpi/.lima

	run_host_command_logged cat <<- 'mpd_cpi.conf' > "${SDCARD}"/home/cpi/.mpd_cpi.conf
		music\_directory    "/home/cpi/music"
		playlist\_directory    "/home/cpi/music/playlists"
		db\_file    "/home/cpi/music/tag\_cache"
		log\_file    "/tmp/mpd.log"
		pid\_file    "/tmp/mpd.pid"
		state\_file    "/home/cpi/music/mpd\_state"
		sticker\_file    "/home/cpi/music/sticker.sql"
		user    "cpi"
		bind\_to\_address    "/tmp/mpd.socket"
		auto\_update    "yes"
		auto\_update\_depth    "3"
		input {
			plugin "curl"
		}

		audio\_output {
			type    "alsa"
			name    "My ALSA Device"
		}

		audio\_output {
			type    "fifo"
			name    "my_fifo"
			path    "/tmp/mpd.fifo"
			format    "44100:16:2"
		}

		filesystem\_charset    "UTF-8"
	mpd_cpi.conf

	chroot_sdcard chown cpi /home/cpi -R
}

function post_family_tweaks__autologin_cpi() {
	display_alert "$BOARD" "Set cpi user autologin" "info"
	chroot_sdcard mkdir -p /etc/systemd/system/getty@.service.d/
	run_host_command_logged cat <<- 'serial_override.conf' > "${SDCARD}"/etc/systemd/system/getty@.service.d/override.conf
		[Service]
		ExecStart=
		ExecStart=-/sbin/agetty --noissue --autologin cpi %I $TERM
		Type=idle

	serial_override.conf
}
