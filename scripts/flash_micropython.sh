#/bin/sh

poetry run esptool.py --chip esp32 --port /dev/ttyACM0 erase_flash
poetry run esptool.py --chip esp32 --port /dev/ttyACM0 write_flash -z 0x1000 ~/Downloads/esp32-20220618-v1.19.1.bin
