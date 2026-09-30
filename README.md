# SmartThings Zigbee Edge Drivers

SmartThings Edge drivers are Lua programs that run locally on a compatible SmartThings hub and translate Zigbee messages into SmartThings controls and states.
This project ports selected Zigbee2MQTT device support into native SmartThings Edge drivers; it does not cover the full Zigbee2MQTT catalog.

**[Open the driver search →](https://wonjj6768.github.io/smartthings-zigbee-edge-drivers/)**

Search 4,206 exact manufacturer/model fingerprints across 49 SmartThings Edge drivers.

## Install

1. [Search for your device](https://wonjj6768.github.io/smartthings-zigbee-edge-drivers/) by its manufacturer and model, and note the matching driver name.
2. [Accept the SmartThings channel invitation](https://bestow-regional.api.smartthings.com/invite/d4297OmXrQjo) with the Samsung account used by your hub, then enroll that hub in the channel.
3. Under the enrolled hub, open **Available Drivers** and install the matching driver.
4. Remove the device from SmartThings and pair it again so the installed driver can handle it.

For the channel screens, see the [SmartThings installation guide](https://developer.smartthings.com/docs/devices/hub-connected/enroll-in-a-shared-channel).

## Caution: Re-pair the device

After applying a driver from this collection, you must delete the device from SmartThings and pair it again. Values received during an earlier pairing with an incorrect driver may remain incorrectly stored in SmartThings' internal persistent storage and cause unexpected behavior.

## Help

For a missing device, a problem, or a feature request, [open an issue](https://github.com/wonjj6768/smartthings-zigbee-edge-drivers/issues). Include the manufacturer, model, current driver name, and hub logcat when available.

## Driver catalog

<details><summary>Show all 49 drivers</summary>

| Driver | Exact fingerprints |
| --- | ---: |
| EF00 Bridge wonjj6768 | 3 |
| EF00 Controls 2 wonjj6768 | 23 |
| EF00 Controls wonjj6768 | 10 |
| EF00 Covers 2 wonjj6768 | 21 |
| EF00 Covers wonjj6768 | 194 |
| EF00 Energy wonjj6768 | 54 |
| EF00 Garage Door wonjj6768 | 11 |
| EF00 Lights 2 wonjj6768 | 30 |
| EF00 Lights wonjj6768 | 111 |
| EF00 Meters 2 wonjj6768 | 9 |
| EF00 Meters wonjj6768 | 63 |
| EF00 PIR Motion wonjj6768 | 25 |
| EF00 Presence 3 wonjj6768 | 34 |
| EF00 Presence Advanced wonjj6768 | 33 |
| EF00 Presence General 1 wonjj6768 | 30 |
| EF00 Presence General 2 wonjj6768 | 63 |
| EF00 Presence Switch wonjj6768 | 16 |
| EF00 Safety 2 wonjj6768 | 33 |
| EF00 Safety wonjj6768 | 101 |
| EF00 Screen Switch wonjj6768 | 9 |
| EF00 Sensors 2 wonjj6768 | 20 |
| EF00 Sensors wonjj6768 | 155 |
| EF00 Switch 2 wonjj6768 | 68 |
| EF00 Switch Panel wonjj6768 | 39 |
| EF00 Switch wonjj6768 | 113 |
| EF00 Thermostat FCU wonjj6768 | 42 |
| EF00 Thermostat HVAC 2 wonjj6768 | 23 |
| EF00 Thermostat TRV 1 wonjj6768 | 71 |
| EF00 Thermostat TRV 2 wonjj6768 | 34 |
| EF00 Thermostat TRV 3 wonjj6768 | 35 |
| EF00 Thermostat Wall wonjj6768 | 42 |
| EF00 Valves 2 wonjj6768 | 20 |
| EF00 Valves wonjj6768 | 31 |
| ZCL Bridge wonjj6768 | 3 |
| ZCL Controls 2 wonjj6768 | 12 |
| ZCL Controls wonjj6768 | 319 |
| ZCL Covers wonjj6768 | 43 |
| ZCL DALI wonjj6768 | 1 |
| ZCL EasyIoT wonjj6768 | 6 |
| ZCL Lights 2 wonjj6768 | 36 |
| ZCL Lights wonjj6768 | 695 |
| ZCL Locks wonjj6768 | 2 |
| ZCL Plugs wonjj6768 | 110 |
| ZCL Sensors 2 wonjj6768 | 337 |
| ZCL Sensors 3 wonjj6768 | 150 |
| ZCL Sensors wonjj6768 | 406 |
| ZCL Switch 2 wonjj6768 | 14 |
| ZCL Switch wonjj6768 | 504 |
| ZCL Thermostat wonjj6768 | 2 |

</details>

## Sources and license

- **Device references:** [Zigbee2MQTT](https://www.zigbee2mqtt.io/) · [zigbee-herdsman-converters](https://github.com/Koenkk/zigbee-herdsman-converters)
- **MIT licenses:** [This project](LICENSE) · [zigbee-herdsman-converters](https://github.com/Koenkk/zigbee-herdsman-converters/blob/master/LICENSE) (© 2018 Koen Kanters)
