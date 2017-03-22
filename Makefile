default:
	rm -f obj/Debug/vl401
	gprbuild
	(cd obj/Debug; arm-eabi-objdump -d vl401 >vl401.lst; arm-eabi-objdump -s vl401 >vl401.dmp; arm-eabi-gcc-nm -an vl401 >vl401.nm; arm-eabi-objcopy -Obinary vl401 vl401.bin)
