
# Vehicle Crash Detection and Reporting System (VeCDeRS) V1.1

- [Vehicle Crash Detection and Reporting System](#vehicle-crash-detection-and-reporting-system)
  * [Abstract](#abstract)
  * [Features](#features)
  * [Features not yet Implemented](#features-not-yet-implemented)
  * [Images](#images)
  * [Components](#components)
  * [GSM Commands List](#gsm-commands-list)
  * [Stuff to Do/Implement](#stuff-to-doimplement)


----
Abstract
----

<p>When driving a vehicle around there is always a chance that something may go wrong a person may pop up from your blind spot, you may hit a pothole-loose control and crash into something, a cow or dog may walk onto the road and you may swerve to avoid it may be hitting a neighboring vehicle, many such unexpected situations can occur on the road and even more so in India with the poorly designed roads in many places making them extremely dangerous to drive in. Two-wheelers are extremely common in India. It's a no brainer that motorbikes and scooters are not as safe as cars or buses as such we hear many cases of two-wheeler riders dying in accidents many of which do not get medical treatment on time for many reasons like lack of clarity as to where the victim is, or the absence of bystanders to call for an ambulance and the victim is unconscious, in any case, every second count to whether the victim lives or dies.</p>
<p>This DIY project was designed and built with the hopes of one day being able to help save the lives of accident victims and as such is open source and the schematics and code is free for all to use, and do note proper credits should be given to me if it is being used for any purpose other than testing and learning. Also, note no guarantee is given for the sound functioning of the system as this is <b><b>JUST A PROTOTYPE</b></b> as such some edge cases were unconsidered and many more features were unadded and some minor bugs still exist in the code.</p>

----
Features
----


- Travel / Accident Mode: Detects a possible accident and reports it to the registered phone numbers.
- Sentry / Parking Mode: Engaged when owner parks and leaves area (out of Bluetooth range), Saves power also by decreasing frequency of GPS / Bluetooth updates, Looks for changes in movement and reports attempted theft to owners phone.
- SMS interface for compatibility with any device with a phone number.
- Remote Location Request: Registered numbers can request the location of the device at anytime.
- Mobile App for configuration and management of the device.
- Bluetooth Low Energy protocol used to connect to the owners phone and to save power.
- Uses last known phone location as a backup in case GPS signal is not available.
----

Features not yet Implemented
----
- Analytics : Travel time, distance travelled, average speed.
- Web Interface for configuration and analytics.
- Internal Li-Po battery is used as backup power supply in case vehicle battery is damaged in crash.

----
Images
---
- Device:

![](https://github.com/NEType24443/Vehicle-Crash-Detection-System/blob/main/images/device_1_GIF.gif)

> Prototype device

- Location of the device in the Motorcycle:

![](https://github.com/NEType24443/Vehicle-Crash-Detection-System/blob/main/images/vehicle_1_GIF.gif)

> Differs based on the Motorcycle make

![](https://github.com/NEType24443/Vehicle-Crash-Detection-System/blob/main/images/vehicle_2_GIF.gif)

> Device working under the seat

- Mobile App:

<img src="https://github.com/NEType24443/Vehicle-Crash-Detection-System/blob/main/images/app_home_page_conn.jpg" width="500" height="1000" />

> Home page when Bluetooth is on

<img src="https://github.com/NEType24443/Vehicle-Crash-Detection-System/blob/main/images/app_reg.jpg" width="500" height="1000" />

> New device registration page

<img src="https://github.com/NEType24443/Vehicle-Crash-Detection-System/blob/main/images/app_loc.jpg" width="500" height="1000" />

> Location/Device reset sync page

- Testing:

![](https://github.com/NEType24443/Vehicle-Crash-Detection-System/blob/main/images/accident_thresh_test.gif)

> Testing method for determining accident threshold, not scientific but gives a good baseline

- Schematic:

![](https://github.com/NEType24443/Vehicle-Crash-Detection-System/blob/main/Schematic/VeCDeRS.png)

> Latest Schematic V1.1

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
	+ MAX232 ( RS-232 <-> TTL, used for controling the Mosfets )
	+ IRF520 Mosfet ( 1, for toggling between using Li-ion and Motorcycle batteries)
	+ 2N7002 (3, for  toggling between using Li-ion and Motorcycle batteries)
	+ 1N4007 Diodes (3, To prevent Buck and Boost converter from taking power from the wrong end and getting a the 4.2V required for SIM800L Module)
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
	- [ ] Adding Driver Ckt, MOSFET's and MAX232 (Simulation Done)
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
