
vl401
-----
This is a workalike for a demo that ST provides for their VL6180X
shield that plugs onto an STM32F4 nucleo board. That board has the
STM32F401RE SoC. 512k of flash and 96k of ram and a stripped down but
familial link to the higher STM32F4 series. In this way, addressing is
the same, It runs maximally at 84Mhz vs the doubled 168Mhz of its
higher peers. As a workalike, unlike being written in C as the ST
example code is, this is written in Ada.

About the VL6180X. It is a sensor that can report back a range to a
target from 0..~200mm with some error that scales with object
reflectivity and distance. The other mode of the sensor is an ambient
light meter. 

This would not exist w/o 
1) AdaCore Libre GNAT toolchain
2) The Ada_Drivers_Library from AdaCore
3) Pat Rogers's BNO055 generic driver and example usecase
4) Fabien Chouteau's help in citing vvvvv
5) Jerome Lambourg's VL5310X work. This was helpful for the display code
6) Tilen Majerle's excellent ST library + examples.
7) ST's evaluation kit EVALKIT-VL6180X (now superceded with a newer model).

To use this, you need a link to an Ada_Drivers_Library. My library is
a mod over the AdaCore one. Let me know if the library is
needed. Principally I add support for the STM32F401RE and fix the
issue that already in the the pull Q for i2c 16bit mem addr.
