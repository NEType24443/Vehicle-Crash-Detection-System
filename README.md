
# Vehicle Crash Detection and Reporting System


[TOC]

Features
----

- SMS interface for compatibility with any device with a sim card and internet connection.
- Mobile App for configuration and management of the device.
- Crash / Accident detection and reporting.(done using the vibration sensor module and reported via Push Notifications and SMS/Call on phones of Guardians with GPS location data).
- Movement Alert Mode: Alerts owners phone if vehicle has been moved when it was parked.
- Sentry / Parking Mode: Automatically detects when owner parks and leaves area(out of Bluetooth range), Saves power also by decreasing frequency of GPS / Bluetooth updates, Looks for changes in movement (interrupt function of MPU6050).

Features not yet Implemented
----
- Analytics : Travel time, distance travelled, average speed.
- Internal Li-Po battery is used as backup power supply in case vehicle battery is damaged in crash.

Images
---
- Device:

![](https://pandao.github.io/editor.md/examples/images/4.jpg)

> Prototype device

- Location of the device in the Motorcycle:

![]()

> Differs based on the Motorcycle make

- Mobile App:

![]()

> Latest iteration of the app

----

Components
------
+ Main Hardware
	+ ESP32 development board
	+ MPU-6050 Module
	+ NEO-6M Module
	+ SIM800L Module
+ Power Components
	+ TP4056 Lithium Battery Charger Module
	+ Li-ion battery 7800mAh 3.7V <- Doubtful of capacity
	+ XL6009E1 Boost converter module (needs replacement)
	+ LM2596 Buck converter module
+ Miscellanious Components
	+ MAX3485 ( RS-232 <-> TTL, possibly can be used for controling the Mosfets )
	+ IRF520 Mosfets ( 2, for toggling between using Li-ion and Motorcycle batteries)
	+ 1N4007 Diodes ( To prevent Buck and Boost converter from taking power from the wrong end )
-------

GSM Commands List
-------

| Command   | Description                    |
| ------------- | ------------------------------ |
| `?register <password>`     | Registers the phone number as one to send updates to. |
| `?deregister <password>`   | Deregisters the phone number. |
| `?location` | Sends current location of the device if registered |
| `?help` | Sends a list of commands |
----

Stuff to Do/Implement
----

+ Hardware
	- [x] Schematic
	- [x] Testing individulal modules
		- [x] ESP32 DevKit V1
		- [x] SIM800L (Added a bigger capacitor removed flawed original)
		- [x] NEO-6M GPS module
		- [x] MPU-6050 module
		- [x] TP4056 Charger (Damaged Charging LED's due to Over Voltage)
		- [x] Li-ion battery 7800mAh 3.7V <- Doubtful of capacity
		- [x] LM2596 Buck converter module
		- [x] XL6009E1 Boost converter module (needs replacement)
	- [x] Adding 12V Battery input to buck
		- [x] Added JST terminal for 12V Battery
	- [x] Added 2200uF capacitor between V<sub>cc</sub> and GND
	- [x] Adding Li-Po battery and charger with boost converter
	- [ ] Recharge Li-ion battery from motorcycle battery automatically
	- [ ] PCB design (after everything works properly)
----
+ Android Code
	- [x] Basic BLE communication
	- [x] Getting location data
	- [x] Sending phone location to ESP32 using BLE
	- [x] Registration screen
	- [ ] Active notifications for connection state
	- [ ] Background service to send the data when phone screen is off
----
+ Arduino Code
	- [x] Interrupts for ESP32
	- [x] Peripheral interface code
		- [x] MPU interfacing
		- [x] SIM800L interfacing
		- [x] NEO-6M interfacing
	- [x] Intialisation Functions
	- [x] BLE Characteristic Setup
	- [x] SENTRY Mode
	- [x] TRAVEL Mode
	- [x] ALERT Mode
	- [x] Basic Free RTOS code for handling SMS Messages and calls from GSM
	- [x] EEPROM Functions
	- [x] INITIAL(Setup) Mode
	- [ ] Automatic power source switching depending on the mode
------
