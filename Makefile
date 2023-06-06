url_buildroot = https://buildroot.org/downloads/buildroot-2023.05-rc3.tar.gz
archive_buildroot = buildroot.tar.gz
system_image = stm32f429i-disco_system.uImage
dir_download = downloads
dir_configs = configs
dir_buildroot = buildroot

bootstrap:
	mkdir -p $(dir_download)
	mkdir -p $(dir_buildroot)
	wget -O $(dir_download)/$(archive_buildroot) $(url_buildroot)
	tar zxvf $(dir_download)/$(archive_buildroot) -C $(dir_buildroot) --strip-components=1
	cp $(dir_configs)/buildroot $(dir_buildroot)/.config

build:
	make -j$(shell grep -c '^processor' /proc/cpuinfo) -C $(dir_buildroot)

menuconfig:
	make -C $(dir_buildroot) menuconfig

saveconfig:
	cp -fv $(dir_buildroot)/.config $(dir_configs)/buildroot

flash:
	cd $(dir_buildroot)/output/build/host-openocd-0.12.0/tcl && ../../../host/usr/bin/openocd \
	-f board/stm32f429discovery.cfg \
	-c "init" \
	-c "reset init" \
	-c "flash probe 0" \
	-c "flash info 0" \
	-c "flash write_image erase ../../../images/stm32f429i-disco.bin 0x08000000" \
	-c "flash write_image erase ../../../images/stm32f429-disco.dtb 0x08004000" \
	-c "flash write_image erase ../../../images/xipImage 0x0800C000" \
	-c "reset run" -c shutdown

clean:
	rm -rf $(dir_buildroot) $(dir_download)
