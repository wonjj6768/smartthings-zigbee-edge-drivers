# SmartThings Zigbee Edge Drivers

## August 31, 2026 Update

This release expands the public channel to 48 drivers and 3564 exact device fingerprints.
If a device that worked before no longer works after the August 31 update, please report it in [GitHub Issues](https://github.com/wonjj6768/smartthings-zigbee-edge-drivers/issues).
Please include the manufacturer, model, current driver name, and hub logcat if available.

## Driver Split Notice (updated 2026-08-20)

Some drivers were split because a SmartThings Edge driver package cannot exceed 512 KB.
Newly exposed device settings increased package size, so the affected device definitions were divided.

| Before | After |
| --- | --- |
| `ef00-thermostats-wonjj6768` | `ef00-thermostat-trv-1`, `ef00-thermostat-trv-2`, `ef00-thermostat-wall`, `ef00-thermostat-fcu` |
| `ef00-switch-wonjj6768` | `ef00-switch`, `ef00-switch-panel`, `ef00-garage-door` |
| `ef00-energy-wonjj6768` | `ef00-energy`, `ef00-meters` |
| `ef00-presence-general-wonjj6768` | `ef00-presence-general-1`, `ef00-presence-general-2` |
| `zcl-switch-wonjj6768` | `zcl-switch-wonjj6768`, `zcl-plugs-wonjj6768` |

**Existing devices are not reassigned automatically. If a device stops updating, or a ZCL plug remains on ZCL Switch, open it in the SmartThings app and switch it to the driver listed for its fingerprint below.**

Names ending in a number, such as `-trv-1` / `-trv-2` and `-general-1` / `-general-2`,
are size groups rather than device categories: both halves hold the same kind of device.
Use the fingerprint tables under [Supported Fingerprints](#supported-fingerprints) to find which driver lists your manufacturer and model.

## Development

This project is under active development. If a device does not work correctly, please [open an issue](https://github.com/wonjj6768/smartthings-zigbee-edge-drivers/issues) and include the hub logcat.
If you want a device to support an additional feature, please [open an issue](https://github.com/wonjj6768/smartthings-zigbee-edge-drivers/issues) with your request.

## Install

Driver channel invite: https://bestow-regional.api.smartthings.com/invite/d4297OmXrQjo

Search by manufacturer and model: https://wonjj6768.github.io/smartthings-zigbee-edge-drivers/

Open the invite link with the Samsung account used by your SmartThings hub, enroll the hub, then install the needed driver from the channel.

## Drivers

| Driver | Package key | Fingerprints |
| --- | --- | ---: |
| EF00 Controls wonjj6768 | `ef00-controls-wonjj6768` | 10 |
| EF00 Covers wonjj6768 | `ef00-covers-wonjj6768` | 189 |
| EF00 Energy wonjj6768 | `ef00-energy-wonjj6768` | 52 |
| EF00 Garage Door wonjj6768 | `ef00-garage-door-wonjj6768` | 11 |
| EF00 Lights wonjj6768 | `ef00-lights-wonjj6768` | 111 |
| EF00 Meters wonjj6768 | `ef00-meters-wonjj6768` | 62 |
| EF00 PIR Motion wonjj6768 | `ef00-pir-motion-wonjj6768` | 23 |
| EF00 Presence Advanced wonjj6768 | `ef00-presence-advanced-wonjj6768` | 33 |
| EF00 Presence General 1 wonjj6768 | `ef00-presence-general-1-wonjj6768` | 30 |
| EF00 Presence General 2 wonjj6768 | `ef00-presence-general-2-wonjj6768` | 62 |
| EF00 Presence Switch wonjj6768 | `ef00-presence-switch-wonjj6768` | 16 |
| EF00 Safety wonjj6768 | `ef00-safety-wonjj6768` | 99 |
| EF00 Screen Switch wonjj6768 | `ef00-screen-switch-wonjj6768` | 8 |
| EF00 Sensors wonjj6768 | `ef00-sensors-wonjj6768` | 155 |
| EF00 Switch Panel wonjj6768 | `ef00-switch-panel-wonjj6768` | 39 |
| EF00 Switch wonjj6768 | `ef00-switch-wonjj6768` | 111 |
| EF00 Thermostat FCU wonjj6768 | `ef00-thermostat-fcu-wonjj6768` | 40 |
| EF00 Thermostat TRV 1 wonjj6768 | `ef00-thermostat-trv-1-wonjj6768` | 71 |
| EF00 Thermostat TRV 2 wonjj6768 | `ef00-thermostat-trv-2-wonjj6768` | 34 |
| EF00 Thermostat Wall wonjj6768 | `ef00-thermostat-wall-wonjj6768` | 43 |
| EF00 Valves wonjj6768 | `ef00-valves-wonjj6768` | 30 |
| Z2M EF00 Bridge wonjj6768 | `z2m-ef00-bridge-wonjj6768` | 2 |
| Z2M EF00 Controls Category wonjj6768 | `z2m-ef00-controls-wonjj6768` | 15 |
| Z2M EF00 Covers Category wonjj6768 | `z2m-ef00-covers-wonjj6768` | 18 |
| Z2M EF00 Lights Category wonjj6768 | `z2m-ef00-lights-wonjj6768` | 26 |
| Z2M EF00 Meters Category wonjj6768 | `z2m-ef00-meters-wonjj6768` | 5 |
| Z2M EF00 Presence Category wonjj6768 | `z2m-ef00-presence-wonjj6768` | 21 |
| Z2M EF00 Safety Category wonjj6768 | `z2m-ef00-safety-wonjj6768` | 22 |
| Z2M EF00 Sensors Category wonjj6768 | `z2m-ef00-sensors-wonjj6768` | 8 |
| Z2M EF00 Switch Category wonjj6768 | `z2m-ef00-switch-wonjj6768` | 48 |
| Z2M EF00 Thermostat Wall FCU wonjj6768 | `z2m-ef00-thermo-hvac-wonjj6768` | 18 |
| Z2M EF00 Thermostat TRV wonjj6768 | `z2m-ef00-thermo-trv-wonjj6768` | 34 |
| Z2M EF00 Valves Category wonjj6768 | `z2m-ef00-valves-wonjj6768` | 19 |
| Z2M ZCL Bridge wonjj6768 | `z2m-zcl-bridge-wonjj6768` | 3 |
| Z2M ZCL Controls Category wonjj6768 | `z2m-zcl-controls-wonjj6768` | 5 |
| Z2M ZCL DALI wonjj6768 | `z2m-zcl-dali-wonjj6768` | 1 |
| Z2M ZCL Lights Category wonjj6768 | `z2m-zcl-lights-wonjj6768` | 8 |
| Z2M ZCL Locks wonjj6768 | `z2m-zcl-locks-wonjj6768` | 2 |
| Z2M ZCL Sensors Category wonjj6768 | `z2m-zcl-sensors-wonjj6768` | 9 |
| Z2M ZCL Switch Category wonjj6768 | `z2m-zcl-switch-wonjj6768` | 12 |
| Z2M ZCL Thermostat wonjj6768 | `z2m-zcl-thermostat-wonjj6768` | 2 |
| ZCL Controls wonjj6768 | `zcl-controls-wonjj6768` | 313 |
| ZCL Covers wonjj6768 | `zcl-covers-wonjj6768` | 41 |
| ZCL EasyIoT wonjj6768 | `zcl-easyiot-wonjj6768` | 6 |
| ZCL Lights wonjj6768 | `zcl-lights-wonjj6768` | 692 |
| ZCL Plugs wonjj6768 | `zcl-plugs-wonjj6768` | 110 |
| ZCL Sensors wonjj6768 | `zcl-sensors-wonjj6768` | 394 |
| ZCL Switch wonjj6768 | `zcl-switch-wonjj6768` | 501 |

## Supported Fingerprints

<details>
<summary>EF00 Controls wonjj6768 (10 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports EF00 scene remotes and button controllers.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZ3210_3ulg9kpo` | `TS0021` | `buttons-button-2-battery` |
| `_TZE200_2m38mh6k` | `TS0601` | `buttons-button-6-battery` |
| `_TZE200_dhke3p9w` | `TS0601` | `buttons-button-18` |
| `_TZE200_mfamvsdb` | `TS0601` | `buttons-button-4-foria-options` |
| `_TZE200_nojsjtj2` | `TS0601` | `security-remotes-sos-battery-low` |
| `_TZE200_vrcfo4i0` | `TS0601` | `security-remotes-sos-battery-low` |
| `_TZE284_2baujqot` | `TS0601` | `security-remotes-sos-battery` |
| `_TZE284_5ys44kzo` | `TS0601` | `buttons-button-6-battery` |
| `_TZE284_dhke3p9w` | `TS0601` | `buttons-button-18` |
| `_TZE284_nj7sfid2` | `TS0601` | `buttons-button-4` |

</details>

<details>
<summary>EF00 Covers wonjj6768 (189 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports EF00 curtains, blinds, shades, and cover motors.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TYST11_fzo2pocs` | `zo2pocs\x00` | `covers-cover-cover-one` |
| `_TYST11_udank5zs` | `dank5zs\x00` | `covers-cover-cover-one` |
| `_TZ3210_emqmwtym` | `TS0601` | `covers-cover-battery-epj-zb` |
| `_TZE200_127x7wnl` | `TS0601` | `covers-cover` |
| `_TZE200_1fuxihti` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_1vxgqfba` | `TS0601` | `covers-cover` |
| `_TZE200_2jwrgrro` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_2odrmqwq` | `TS0601` | `covers-cover` |
| `_TZE200_2vfxweng` | `TS0601` | `covers-cover` |
| `_TZE200_3i3exuay` | `TS0601` | `covers-cover` |
| `_TZE200_3ylew7b4` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_4vobcgd3` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_5nldle7w` | `TS0601` | `covers-cover-switch-2` |
| `_TZE200_5sbebbzs` | `TS0601` | `covers-cover` |
| `_TZE200_5zbp6j0u` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_68nvbi09` | `TS0601` | `covers-cover-battery-cover-three` |
| `_TZE200_68nvbio9` | `TS0601` | `covers-cover-battery-cover-three` |
| `_TZE200_7eue9vhc` | `TS0601` | `covers-cover` |
| `_TZE200_7shyddj3` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_9p5xmj5r` | `TS0601` | `covers-cover-battery-cover-three` |
| `_TZE200_9vpe3fl1` | `TS0601` | `covers-cover` |
| `_TZE200_a8z0g46u` | `TS0601` | `covers-cover` |
| `_TZE200_ax8a8ahx` | `TS0601` | `covers-cover-zm79e-dt` |
| `_TZE200_axgvo9jh` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_b2u1drdv` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_ba69l9ol` | `TS0601` | `covers-cover-battery-cover-three` |
| `_TZE200_bdblidq3` | `TS0601` | `covers-cover` |
| `_TZE200_bjzrowv2` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_bqcqqjpb` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_bv1jcqqu` | `TS0601` | `covers-cover` |
| `_TZE200_cf1sl3tj` | `TS0601` | `covers-cover-battery-cover-three` |
| `_TZE200_clm4gdw4` | `TS0601` | `covers-cover` |
| `_TZE200_cowvfni3` | `TS0601` | `covers-cover` |
| `_TZE200_cpbo62rn` | `TS0601` | `covers-cover` |
| `_TZE200_cxu0jkjk` | `TS0601` | `covers-cover` |
| `_TZE200_dng9fn0k` | `TS0601` | `covers-cover` |
| `_TZE200_eatmkx5j` | `TS0301` | `covers-cover` |
| `_TZE200_eegnwoyw` | `TS0601` | `covers-cover` |
| `_TZE200_eevqq1uv` | `TS0601` | `covers-cover-battery-cover-three` |
| `_TZE200_en3wvcbx` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_eqpaxqdv` | `TS0601` | `covers-cover-pims3028` |
| `_TZE200_ergbiejo` | `TS0601` | `covers-cover` |
| `_TZE200_fctwhugx` | `TS0601` | `covers-cover` |
| `_TZE200_fdtjuw7u` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_feolm6rk` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_fodv6bkr` | `TS0601` | `covers-cover-battery-rm28-le` |
| `_TZE200_fzo2pocs` | `TS0601` | `covers-cover` |
| `_TZE200_g5wdnuow` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_g5xqosu7` | `TS0601` | `covers-cover` |
| `_TZE200_gaj531w3` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_gnw1rril` | `TS0601` | `covers-cover` |
| `_TZE200_gubdgai2` | `TS0601` | `covers-cover` |
| `_TZE200_hojryzzd` | `TS0601` | `covers-cover` |
| `_TZE200_hsgrhjpf` | `TS0601` | `covers-cover` |
| `_TZE200_icka1clh` | `TS0601` | `covers-cover` |
| `_TZE200_iossyxra` | `TS0601` | `covers-cover` |
| `_TZE200_jhkttplm` | `TS0601` | `covers-cover-switch-1` |
| `_TZE200_libht6ua` | `TS0601` | `covers-cover` |
| `_TZE200_llm0epxg` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_m6lwazh9` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_mlglxwp3` | `TS0601` | `covers-cover` |
| `_TZE200_n1aauwb4` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_nhyj64w2` | `TS0601` | `covers-cover` |
| `_TZE200_nkoabg8w` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_nogaemzt` | `TS0601` | `covers-cover` |
| `_TZE200_nueqqe6k` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_nv6nxo0c` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_nw1r9hp6` | `TS0601` | `covers-cover-battery-cover-three` |
| `_TZE200_odlldrxx` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_ol5jlkkr` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_osmxri8y` | `TS0601` | `covers-cover-zb-sm` |
| `_TZE200_p2qzzazi` | `TS0601` | `covers-cover` |
| `_TZE200_p6vz3wzt` | `TS0601` | `covers-cover` |
| `_TZE200_pk0sfzvr` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_pw7mji0l` | `TS0601` | `covers-cover-battery-cover-three` |
| `_TZE200_r0jdjrvi` | `TS0601` | `covers-cover` |
| `_TZE200_rddyvrci` | `TS0601` | `covers-cover` |
| `_TZE200_rmymn92d` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_rsj5pu8y` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_sfqyhvpv` | `TS0601` | `covers-cover-battery-cover-three` |
| `_TZE200_sq6affpe` | `TS0601` | `covers-cover` |
| `_TZE200_swlgvdlh` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_tvrvdj6o` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_udank5zs` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_vdiuwbkq` | `TS0601` | `covers-cover` |
| `_TZE200_vexa5o82` | `TS0601` | `covers-cover-battery-cover-three` |
| `_TZE200_wdfurkoa` | `TS0601` | `covers-cover` |
| `_TZE200_wehza30a` | `TS0601` | `covers-cover` |
| `_TZE200_wmcdj3aq` | `TS0601` | `covers-cover` |
| `_TZE200_xaabybja` | `TS0601` | `covers-cover` |
| `_TZE200_xu4a5rhj` | `TS0601` | `covers-cover` |
| `_TZE200_xuzcvlku` | `TS0601` | `covers-cover` |
| `_TZE200_yenbr4om` | `TS0601` | `covers-cover` |
| `_TZE200_yia0p3tr` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_yrugsphv` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_zah67ekd` | `TS0601` | `covers-cover` |
| `_TZE200_zpzndjez` | `TS0601` | `covers-cover` |
| `_TZE200_zuz7f94z` | `TS0601` | `covers-cover` |
| `_TZE200_zvo63cmo` | `TS0601` | `covers-cover` |
| `_TZE200_zxxfv8wi` | `TS0601` | `covers-cover-cover-one` |
| `_TZE200_zyrdrmno` | `TS0601` | `covers-cover-zb-sm` |
| `_TZE204_1fuxihti` | `TS0601` | `covers-cover-cover-one` |
| `_TZE204_2rvvqjoa` | `TS0601` | `covers-cover-bx82-tyz1` |
| `_TZE204_57hjqelq` | `TS0601` | `covers-cover-cover-one` |
| `_TZE204_5slehgeo` | `TS0601` | `covers-cover` |
| `_TZE204_a2jcoyuk` | `TS0601` | `covers-cover-cover-one` |
| `_TZE204_a8z0g46u` | `TS0601` | `covers-cover` |
| `_TZE204_bdblidq3` | `TS0601` | `covers-cover` |
| `_TZE204_bjzrowv2` | `TS0601` | `covers-cover-cover-one` |
| `_TZE204_dpqsvdbi` | `TS0601` | `covers-cover-cover-one` |
| `_TZE204_ejh6owwz` | `TS0601` | `covers-cover-battery-cover-three` |
| `_TZE204_g5xqosu7` | `TS0601` | `covers-cover` |
| `_TZE204_guvc7pdy` | `TS0601` | `covers-cover-cover-one` |
| `_TZE204_ic7jtutb` | `TS0601` | `covers-cover-cover-one` |
| `_TZE204_lh3arisb` | `TS0601` | `covers-cover-cover-one` |
| `_TZE204_m1wl5fvq` | `TS0601` | `covers-cover-cover-one` |
| `_TZE204_nladmfvf` | `TS0601` | `covers-cover-cover-one` |
| `_TZE204_odlldrxx` | `TS0601` | `covers-cover-cover-one` |
| `_TZE204_p6vz3wzt` | `TS0601` | `covers-cover` |
| `_TZE204_q9xty0ad` | `TS0601` | `covers-cover` |
| `_TZE204_r0jdjrvi` | `TS0601` | `covers-cover` |
| `_TZE204_tgl8i2np` | `TS0601` | `covers-cover-cover-one` |
| `_TZE204_trwaxi57` | `TS0601` | `covers-cover-switch-2-trwaxi57` |
| `_TZE204_vvvtcehj` | `TS0601` | `covers-cover-cover-one` |
| `_TZE204_wzre8hu2` | `TS0601` | `covers-cover-cover-one` |
| `_TZE204_xu4a5rhj` | `TS0601` | `covers-cover` |
| `_TZE204_ycke4deo` | `TS0601` | `covers-cover` |
| `_TZE204_yrugsphv` | `TS0601` | `covers-cover-cover-one` |
| `_TZE204_zuq5xxib` | `TS0601` | `covers-cover-cover-one` |
| `_TZE20C_xbexmf8h` | `TS130F` | `covers-cover` |
| `_TZE210_inpjmc0h` | `TS0301` | `covers-cover-2` |
| `_TZE210_m6lwazh9` | `TS0301` | `covers-cover` |
| `_TZE210_yqwse3h5` | `TS0301` | `covers-cover-2` |
| `_TZE284_1fuxihti` | `TS0601` | `covers-cover-cover-one` |
| `_TZE284_2gi1hy8s` | `TS0601` | `covers-cover-battery-mb60l` |
| `_TZE284_3mzb0sdz` | `TS0601` | `covers-cover` |
| `_TZE284_4vobcgd3` | `TS0601` | `covers-cover-cover-one` |
| `_TZE284_5slehgeo` | `TS0601` | `covers-cover` |
| `_TZE284_6fopvb6v` | `TS0601` | `covers-cover` |
| `_TZE284_b7kbnl6q` | `TS0601` | `covers-cover-cover-one` |
| `_TZE284_bjzrowv2` | `TS0601` | `covers-cover-cover-one` |
| `_TZE284_clm4gdw4` | `TS0601` | `covers-cover` |
| `_TZE284_fzo2pocs` | `TS0601` | `covers-cover` |
| `_TZE284_gaj531w3` | `TS0601` | `covers-cover-cover-one` |
| `_TZE284_koxaopnk` | `TS0601` | `covers-cover` |
| `_TZE284_libht6ua` | `TS0601` | `covers-cover` |
| `_TZE284_n73badib` | `TS0601` | `covers-cover-battery-cover-three` |
| `_TZE284_r3szw0xr` | `TS0601` | `covers-cover` |
| `_TZE284_udank5zs` | `TS0601` | `covers-cover-cover-one` |
| `_TZE284_uqfph8ah` | `TS0601` | `covers-cover` |
| `_TZE284_waa352qv` | `TS0601` | `covers-cover` |
| `_TZE284_wdfurkoa` | `TS0601` | `covers-cover` |
| `_TZE284_zofmmt9s` | `TS0601` | `covers-cover-zsm01` |
| `_TZE28C1000000_alh14edn` | `TS0601` | `covers-cover` |
| `_TZE28C1000000_vvvtcehj` | `TS0601` | `covers-cover-cover-one` |
| `_TZE600_ogyg1y6b` | `TS0105` | `covers-cover` |
| `A-OK` | `AM25` | `covers-cover-cover-one` |
| `Alutech` | `AM/R-Sm` | `covers-cover-cover-one` |
| `Binthen` | `BCM100D` | `covers-cover-cover-one` |
| `Binthen` | `CV01A` | `covers-cover-cover-one` |
| `Hiladuo` | `B09M3R35GC` | `covers-cover` |
| `HOBEIAN` | `ZG-301Z-MOTO` | `covers-cover-cover-one` |
| `Homeetec` | `37022173` | `covers-cover-switch-2` |
| `Homeetec` | `37022483` | `covers-cover` |
| `Homeetec` | `37022493` | `covers-cover-switch-1` |
| `HUARUI` | `CMD900LE` | `covers-cover-cover-one` |
| `Larkkey` | `ZSTY-SM-1SRZG-EU` | `covers-cover-cover-one` |
| `Moes` | `AM43-0.45/40-ES-EB` | `covers-cover` |
| `Novato` | `WPK` | `covers-cover-cover-one` |
| `Oz Smart Things` | `ZM85EL-1Z` | `covers-cover-cover-one` |
| `Quoya` | `AT8510-TY` | `covers-cover-cover-one` |
| `Roximo` | `CRTZ01` | `covers-cover-cover-one` |
| `Shaman` | `25EB-1/30-TYZ` | `covers-cover` |
| `Somgoms` | `ZSTY-SM-1DMZG-US-W_1` | `covers-cover-cover-one` |
| `Tuya` | `DT82LEMA-1.2N` | `covers-cover-cover-one` |
| `Tuya` | `M515EGZT` | `covers-cover-cover-one` |
| `Tuya` | `MYQ-RM25-1.3/25-BZ` | `covers-cover` |
| `Tuya` | `TS0601_alh14edn` | `covers-cover` |
| `Tuya` | `ZD82TN` | `covers-cover-cover-one` |
| `Yoolax` | `Day-Night Shade` | `covers-cover` |
| `Yushun` | `YS-MT750` | `covers-cover-cover-one` |
| `Yushun` | `YS-MT750L` | `covers-cover-cover-one` |
| `Zemismart` | `AM43` | `covers-cover-cover-one` |
| `Zemismart` | `M515EGB` | `covers-cover-cover-one` |
| `Zemismart` | `ZM16EL-03/33` | `covers-cover` |
| `Zemismart` | `ZM25EL` | `covers-cover` |
| `Zemismart` | `ZM79E-DT` | `covers-cover-cover-one` |
| `Zemismart` | `ZM85EL-2Z` | `covers-cover` |
| `Zemismart` | `ZMS1-TYZ` | `covers-cover-cover-one` |

</details>

<details>
<summary>EF00 Energy wonjj6768 (52 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports EF00 DIN rail breakers and switching energy meters.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZE200_abatw3kj` | `TS0601` | `din-rail-switch-power-energy-voltage-current-din4` |
| `_TZE200_bkkmqmyo` | `TS0601` | `din-rail-switch-power-energy-voltage-current-din1` |
| `_TZE200_byzdayie` | `TS0601` | `din-rail-switch-power-energy-voltage-current` |
| `_TZE200_eaac7dkw` | `TS0601` | `din-rail-switch-power-energy-voltage-current-din1` |
| `_TZE200_ewxhg6o9` | `TS0601` | `din-rail-switch-power-energy-voltage-current` |
| `_TZE200_fsb6zw01` | `TS0601` | `din-rail-switch-power-energy-voltage-current` |
| `_TZE200_hkdl5fmv` | `TS0601` | `din-rail-switch-power-energy-voltage-current-rcbo` |
| `_TZE200_lsanae15` | `TS0601` | `din-rail-switch-power-energy-voltage-current-din2` |
| `_TZE200_rhblgy0z` | `TS0601` | `din-rail-switch-power-energy-voltage-current-din3` |
| `_TZE200_wbhaespm` | `TS0601` | `din-rail-switch-power-energy-3phase-stb3l125zj` |
| `_TZE204_432zhuwe` | `TS0601` | `din-rail-switch-power-energy-voltage-current-towsmr1` |
| `_TZE204_4bjixefp` | `TS0601` | `din-rail-switch-power-energy-voltage-current-din4` |
| `_TZE204_bkkmqmyo` | `TS0601` | `din-rail-switch-power-energy-voltage-current-din1` |
| `_TZE204_byzdayie` | `TS0601` | `din-rail-switch-power-energy-voltage-current` |
| `_TZE204_fhvdgeuh` | `TS0601` | `din-rail-switch-power-energy-voltage-current-din4` |
| `_TZE204_jcwbwckh` | `TS0601` | `din-rail-switch-power-energy-voltage-current-zbnjt63` |
| `_TZE204_kobbcyum` | `TS0601` | `din-rail-switch-power-energy-voltage-current-towsmr1` |
| `_TZE204_l6llgoxq` | `TS0601` | `din-rail-switch-power-energy-voltage-current-din2` |
| `_TZE204_lb0fsvba` | `TS0601` | `din-rail-switch-power-energy-voltage-current-zbndj63` |
| `_TZE204_lsanae15` | `TS0601` | `din-rail-switch-power-energy-voltage-current-din2` |
| `_TZE204_m64smti7` | `TS0601` | `din-rail-switch-power-energy-voltage-current-rmdzb1pnl63` |
| `_TZE204_mrffaamu` | `TS0601` | `din-rail-switch-power-energy-voltage-current-toqcb2` |
| `_TZE204_q22avxbv` | `TS0601` | `din-rail-switch-power-energy-voltage-current-toqcb2` |
| `_TZE204_rhblgy0z` | `TS0601` | `din-rail-switch-power-energy-voltage-current-din3` |
| `_TZE204_tuhfx7tf` | `TS0601` | `din-rail-switch-power-energy-voltage-current-towsmr1` |
| `_TZE204_tzreobvu` | `TS0601` | `din-rail-switch-power-energy-voltage-current-toqcb2` |
| `_TZE204_wbhaespm` | `TS0601` | `din-rail-switch-power-energy-3phase-stb3l125zj` |
| `_TZE284_432zhuwe` | `TS0601` | `din-rail-switch-power-energy-voltage-current-towsmr1` |
| `_TZE284_5m4nchbm` | `TS0601` | `din-rail-switch-power-energy-voltage-current-leakage-protector` |
| `_TZE284_6ocnqlhn` | `TS0601` | `din-rail-switch-power-energy-voltage-current-toqjzt` |
| `_TZE284_9xstqowh` | `TS0601` | `din-rail-switch-power-energy-voltage-current-toqcb2` |
| `_TZE284_hecsejsb` | `TS0601` | `din-rail-switch-power-energy-voltage-current-towsmr1` |
| `_TZE284_kobbcyum` | `TS0601` | `din-rail-switch-power-energy-voltage-current-towsmr1` |
| `_TZE284_kv1nvirl` | `TS0601` | `din-rail-switch-power-energy-voltage-current-toqcb2` |
| `_TZE284_mrffaamu` | `TS0601` | `din-rail-switch-power-energy-voltage-current-toqcb2` |
| `_TZE284_q22avxbv` | `TS0601` | `din-rail-switch-power-energy-voltage-current-toqcb2` |
| `_TZE284_s5vuaadg` | `TS0601` | `din-rail-switch-power-energy-voltage-current-towsmr1` |
| `_TZE284_tuhfx7tf` | `TS0601` | `din-rail-switch-power-energy-voltage-current-towsmr1` |
| `_TZE284_tzreobvu` | `TS0601` | `din-rail-switch-power-energy-voltage-current-toqcb2` |
| `_TZE284_wbhaespm` | `TS0601` | `din-rail-switch-power-energy-3phase-stb3l125zj` |
| `Hiking` | `DDS238-2` | `din-rail-switch-power-energy-voltage-current-din1` |
| `HOCH` | `ZJSBL7-100Z` | `din-rail-switch-power-energy-voltage-current-rcbo` |
| `MatSee Plus` | `DAC2161C` | `din-rail-switch-power-energy-voltage-current-din2` |
| `SUTON` | `STB3L-125/ZJ` | `din-rail-switch-power-energy-3phase-stb3l125zj` |
| `TNCE` | `RMDZB-1PNL63` | `din-rail-switch-power-energy-voltage-current-rmdzb1pnl63` |
| `Tongou` | `TOQCB2-80-2P` | `din-rail-switch-power-energy-voltage-current-toqcb2` |
| `Tongou` | `TOWSMR1-20A-AC` | `din-rail-switch-power-energy-voltage-current-towsmr1` |
| `Tongou` | `TOWSMR1-40A-A` | `din-rail-switch-power-energy-voltage-current-towsmr1` |
| `Tongou` | `TOWSMR1-40A-AC` | `din-rail-switch-power-energy-voltage-current-towsmr1` |
| `Tuya` | `RC-MCB` | `din-rail-switch-power-energy-voltage-current-din1` |
| `WDYK` | `ZJSBL7-100Z` | `din-rail-switch-power-energy-voltage-current-rcbo` |
| `XOCA` | `DAC2161C` | `din-rail-switch-power-energy-voltage-current-din3` |

</details>

<details>
<summary>EF00 Garage Door wonjj6768 (11 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports EF00 garage door openers.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZE200_nklqjk62` | `TS0601` | `doors-garage-contact-countdown` |
| `_TZE200_wfxuhoea` | `TS0601` | `doors-garage-contact` |
| `_TZE204_jktmrpoj` | `TS0601` | `doors-garage-contact-countdown` |
| `_TZE204_nklqjk62` | `TS0601` | `doors-garage-contact-countdown` |
| `_TZE204_wfxuhoea` | `TS0601` | `doors-garage-contact` |
| `_TZE284_nklqjk62` | `TS0601` | `doors-garage-contact-countdown` |
| `_TZE608_c75zqghm` | `TS0603` | `doors-garage-contact` |
| `_TZE608_fmemczv1` | `TS0603` | `doors-garage-contact` |
| `_TZE608_lapuuoke` | `TS0603` | `doors-garage-contact` |
| `_TZE608_xkr8gep3` | `TS0603` | `doors-garage-contact` |
| `LoraTap` | `GDC311ZBQ1` | `doors-garage-contact` |

</details>

<details>
<summary>EF00 Lights wonjj6768 (111 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports EF00 dimmers, LED drivers, and lighting devices.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZE200_0hb4rdnp` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE200_0nauxa0p` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE200_1agwnems` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE200_3p5ydos3` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE200_4mh6tyyo` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE200_579lguh2` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE200_86nbew0j` | `TS0601` | `lights-dimmer-ts0601-light` |
| `_TZE200_9cxuhakf` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE200_9i9dt8is` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE200_a0syesf5` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE200_bxoo2swd` | `TS0601` | `lights-dimmer-2` |
| `_TZE200_ctq0k47x` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE200_dcnsggv` | `TS0601` | `lights-dimmer-dcnsggvz` |
| `_TZE200_dcnsggvz` | `TS0601` | `lights-dimmer-dcnsggvz` |
| `_TZE200_dfxkcots` | `TS0601` | `lights-dimmer-options-ts0601-dfxkcots` |
| `_TZE200_drs6j6m5` | `TS0601` | `lights-dimmer-ts0601-light` |
| `_TZE200_e3oitdyu` | `TS0601` | `lights-dimmer-2` |
| `_TZE200_ebwgzdqq` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE200_fjjbhx9d` | `TS0601` | `lights-dimmer-2` |
| `_TZE200_gne0e6mk` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE200_gwkapsoq` | `TS0601` | `lights-dimmer-2` |
| `_TZE200_hmqzfqml` | `TS0601` | `fans-fan-light-switch` |
| `_TZE200_io0zdqh1` | `TS0601` | `lights-dimmer-ts0601-light` |
| `_TZE200_ip2akl4w` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE200_itp8dt7f` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE200_la2c2uo9` | `TS0601` | `lights-dimmer-options-ts0601-la2c2uo9` |
| `_TZE200_lawxy9e2` | `TS0601` | `fans-fan-speed-light-switch-lawxy9e2` |
| `_TZE200_ojzhk75b` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE200_p0gzbqct` | `TS0601` | `lights-dimmer-knob-p0gzbqct` |
| `_TZE200_qanl25yu` | `TS0601` | `fans-fan-light-switch` |
| `_TZE200_qyss8gjy` | `TS0601` | `lights-dimmer-ts0601-light` |
| `_TZE200_qzaing2g` | `TS0601` | `lights-dimmer-qzaing2g` |
| `_TZE200_r32ctezx` | `TS0601` | `fans-switch-fan-speed-r32ctezx` |
| `_TZE200_swaamsoy` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE200_tgeqdjgk` | `TS0601` | `lights-color-temperature` |
| `_TZE200_tsxpl0d0` | `TS0601` | `lights-dimmer-2` |
| `_TZE200_ubgdwsnr` | `TS110E` | `lights-dimmer-2` |
| `_TZE200_vizxbhco` | `TS0601` | `lights-dimmer-3` |
| `_TZE200_vm1gyrso` | `TS0601` | `lights-dimmer-3` |
| `_TZE200_vucankjx` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE200_w4cryh2i` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE200_whpb9yts` | `TS0601` | `lights-dimmer-whpb9yts` |
| `_TZE200_ykgar0ow` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE200_ywe90lt0` | `TS0601` | `lights-dimmer-ts0601-light` |
| `_TZE204_1v1dxkck` | `TS0601` | `lights-dimmer-3` |
| `_TZE204_2cyb66xl` | `TS0601` | `lights-dimmer-zdms16-1` |
| `_TZE204_2jnoy8dj` | `TS0601` | `fans-fan-level-light-switch` |
| `_TZE204_5cuocqty` | `TS0601` | `lights-dimmer-zdms16-1` |
| `_TZE204_68utemio` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE204_9qhuzgo0` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE204_bql5khqx` | `TS0601` | `fans-fan-level-light-switch` |
| `_TZE204_bxoo2swd` | `TS0601` | `lights-dimmer-2` |
| `_TZE204_dcnsggvz` | `TS0601` | `lights-dimmer-dcnsggvz` |
| `_TZE204_drs6j6m5` | `TS0601` | `lights-dimmer-ts0601-light` |
| `_TZE204_fjms2pi9` | `TS0601` | `lights-dimmer-2-zdms16-2` |
| `_TZE204_hlx9tnzb` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE204_huu3td85` | `TS0601` | `lights-dimmer-zdms16-1` |
| `_TZE204_jtbgusdc` | `TS0601` | `lights-dimmer-2-zdms16-2` |
| `_TZE204_lawxy9e2` | `TS0601` | `fans-fan-speed-light-switch-lawxy9e2` |
| `_TZE204_n9ctkb6j` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE204_nqqylykc` | `TS0601` | `lights-dimmer-zdms16-1` |
| `_TZE204_o9gyszw2` | `TS0601` | `lights-dimmer-2-zdms16-2` |
| `_TZE204_r32ctezx` | `TS0601` | `fans-switch-fan-speed-r32ctezx` |
| `_TZE204_tgdnh7pw` | `TS0601` | `lights-dimmer-zdms16-1` |
| `_TZE204_vevc4c6g` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE204_zenj4lxv` | `TS0601` | `lights-dimmer-2` |
| `_TZE204_znvwzxkq` | `TS0601` | `lights-dimmer-3` |
| `_TZE284_68utemio` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE284_fjms2pi9` | `TS0601` | `lights-dimmer-2-zdms16-2` |
| `_TZE284_huu3td85` | `TS0601` | `lights-dimmer-zdms16-1` |
| `_TZE284_ikul00sx` | `TS0601` | `fans-fan-level-light-dimmer` |
| `_TZE284_jtbgusdc` | `TS0601` | `lights-dimmer-2-zdms16-2` |
| `_TZE284_m1cvyneb` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE284_nqqylykc` | `TS0601` | `lights-dimmer-zdms16-1` |
| `_TZE284_oa1odmga` | `TS0601` | `lights-color-temperature-color` |
| `_TZE284_tgeqdjgk` | `TS0601` | `lights-color-temperature` |
| `_TZE284_z5jz7wpo` | `TS0601` | `fans-switch-fan-mode-ceiling-z5jz7wpo` |
| `_TZE284_znvwzxkq` | `TS0601` | `lights-dimmer-3` |
| `_TZE28C1000000_68utemio` | `TS0601` | `lights-dimmer-options-ts0601` |
| `_TZE28C1000000_jtbgusdc` | `TS0601` | `lights-dimmer-2-zdms16-2` |
| `_TZE28C1000000_z5jz7wpo` | `TS0601` | `fans-switch-fan-speed-r32ctezx` |
| `Coswall` | `X99-G-kbFan-1g-ZG-LN-11` | `fans-fan-level-light-switch` |
| `Earda` | `EDM-1ZAA-EU` | `lights-dimmer-options-ts0601` |
| `Earda` | `EDM-1ZAB-EU` | `lights-dimmer-options-ts0601` |
| `Earda` | `EDM-1ZBA-EU` | `lights-dimmer-options-ts0601` |
| `ION Industries` | `90.500.040` | `lights-dimmer-options-ts0601` |
| `ION Industries` | `90.500.090` | `lights-dimmer-options-ts0601` |
| `ION Industries` | `ID200W-ZIGB` | `lights-dimmer-options-ts0601` |
| `KnockautX` | `FMD2C018` | `lights-dimmer-2` |
| `Larkkey` | `ZSTY-SM-1DMZG-EU` | `lights-dimmer-options-ts0601` |
| `Lerlink` | `T2-Z67/T2-W67` | `fans-fan-light-switch` |
| `Lerlink` | `X706U` | `lights-dimmer-options-ts0601` |
| `Liwokit` | `Fan+Light-01` | `fans-fan-light-switch` |
| `Lonsonho` | `EDM-1ZBB-EU` | `lights-dimmer-options-ts0601` |
| `Mercator Ikuü` | `SSWD01` | `lights-dimmer-options-ts0601` |
| `Mercator Ikuü` | `SSWM-DIMZ` | `lights-dimmer-options-ts0601` |
| `Mercator Ikuü` | `SSWRM-ZB` | `lights-dimmer-options-ts0601` |
| `Moes` | `EDM-1ZBB-EU` | `lights-dimmer-options-ts0601` |
| `Moes` | `MS-105B` | `lights-dimmer-2` |
| `Moes` | `MS-105Z` | `lights-dimmer-options-ts0601` |
| `Moes` | `ZM-105B-M` | `lights-dimmer-2` |
| `Moes` | `ZS-EUD_1gang` | `lights-dimmer-options-ts0601` |
| `Moes` | `ZS-EUD_2gang` | `lights-dimmer-2` |
| `Moes` | `ZS-EUD_3gang` | `lights-dimmer-3` |
| `Moes` | `ZS-SR-EUD-1` | `lights-dimmer-options-ts0601` |
| `Moes` | `ZS-SR-EUD-2` | `lights-dimmer-2` |
| `Moes` | `ZS-SR-EUD-3` | `lights-dimmer-3` |
| `Moes` | `ZS-USD` | `lights-dimmer-options-ts0601` |
| `Zemismart` | `ZN2S-RS1E-FL / ZN2S-US1U-FL` | `fans-fan-level-light-switch` |
| `Zemismart` | `ZN2S-RS3E-DH` | `lights-dimmer-3` |
| `Zemismart` | `ZN2S-US1-SD` | `lights-dimmer-options-ts0601` |

</details>

<details>
<summary>EF00 Meters wonjj6768 (62 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports EF00 single, two and three phase energy meters.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZE200_78ioiaml` | `TS0601` | `meters-power-energy-2phase-sdm02v1` |
| `_TZE200_bcusnqt8` | `TS0601` | `meters-energy-1phase-spm01` |
| `_TZE200_d2zfgtij` | `TS0601` | `meters-energy-1phase-spm01v1gt` |
| `_TZE200_dikb3dp6` | `TS0601` | `meters-energy-3phase-spm02v3` |
| `_TZE200_gomuk3dc` | `TS0601` | `meters-energy-3phase-sdm01v15` |
| `_TZE200_iwn0gpzz` | `TS0601` | `meters-energy-1phase-spm01v25` |
| `_TZE200_nslr42tt` | `TS0601` | `meters-power-energy-voltage-current-clamp3phase` |
| `_TZE200_ny94onlb` | `TS0601` | `meters-energy-3phase-spm02v25` |
| `_TZE200_qhlxve78` | `TS0601` | `meters-energy-1phase-spm01v2` |
| `_TZE200_rks0sgb7` | `TS0601` | `meters-power-energy-voltage-current-pc311` |
| `_TZE200_s4sa1mcx` | `TS0601` | `meters-energy-3phase-sdm01v1gt` |
| `_TZE200_ugekduaj` | `TS0601` | `meters-power-energy-voltage-current-sdm01` |
| `_TZE200_v9hkz2yn` | `TS0601` | `meters-energy-3phase-spm02v2` |
| `_TZE200_ves1ycwx` | `TS0601` | `meters-energy-3phase-spm02` |
| `_TZE200_wjk6rurm` | `TS0601` | `meters-energy-3phase-spm02v1gt` |
| `_TZE200_x8diwkqb` | `TS0601` | `meters-energy-2phase-sdm02v1gt` |
| `_TZE200_x8fp01wi` | `TS0601` | `meters-switch-power-energy-clamp3phase-relay` |
| `_TZE204_78ioiaml` | `TS0601` | `meters-power-energy-2phase-sdm02v1` |
| `_TZE204_81yrt3lo` | `TS0601` | `meters-power-energy-voltage-current-pj1203a` |
| `_TZE204_ac0fhfiq` | `TS0601` | `meters-power-energy-voltage-current-bidirectional` |
| `_TZE204_cjbofhxw` | `TS0601` | `meters-power-energy-voltage-current` |
| `_TZE204_d2zfgtij` | `TS0601` | `meters-energy-1phase-spm01v1gt` |
| `_TZE204_dhotiauw` | `TS0601` | `meters-power-energy-voltage-current-2ct` |
| `_TZE204_dikb3dp6` | `TS0601` | `meters-energy-3phase-spm02v3` |
| `_TZE204_gomuk3dc` | `TS0601` | `meters-energy-3phase-sdm01v15` |
| `_TZE204_iwn0gpzz` | `TS0601` | `meters-energy-1phase-spm01v25` |
| `_TZE204_loejka0i` | `TS0601` | `meters-energy-3phase-nous-d4z` |
| `_TZE204_ny94onlb` | `TS0601` | `meters-energy-3phase-spm02v25` |
| `_TZE204_qhlxve78` | `TS0601` | `meters-energy-1phase-spm01v2` |
| `_TZE204_s4sa1mcx` | `TS0601` | `meters-energy-3phase-sdm01v1gt` |
| `_TZE204_ugekduaj` | `TS0601` | `meters-power-energy-voltage-current-sdm01` |
| `_TZE204_v9hkz2yn` | `TS0601` | `meters-energy-3phase-spm02v2` |
| `_TZE204_ves1ycwx` | `TS0601` | `meters-energy-3phase-spm02` |
| `_TZE204_wjk6rurm` | `TS0601` | `meters-energy-3phase-spm02v1gt` |
| `_TZE204_x8diwkqb` | `TS0601` | `meters-energy-2phase-sdm02v1gt` |
| `_TZE204_x8fp01wi` | `TS0601` | `meters-switch-power-energy-clamp3phase-relay` |
| `_TZE284_4hdbt6rn` | `TS0601` | `meters-power-energy-voltage-current-toqsa1` |
| `_TZE284_78ioiaml` | `TS0601` | `meters-power-energy-2phase-sdm02v1` |
| `_TZE284_81yrt3lo` | `TS0601` | `meters-power-energy-voltage-current-pj1203a` |
| `_TZE284_a14rjslz` | `TS0601` | `meters-energy-3phase-atms10013z3` |
| `_TZE284_ac0fhfiq` | `TS0601` | `meters-power-energy-voltage-current-bidirectional` |
| `_TZE284_cjbofhxw` | `TS0601` | `meters-power-energy-voltage-current` |
| `_TZE284_d2zfgtij` | `TS0601` | `meters-energy-1phase-spm01v1gt` |
| `_TZE284_dikb3dp6` | `TS0601` | `meters-energy-3phase-spm02v3` |
| `_TZE284_gomuk3dc` | `TS0601` | `meters-energy-3phase-sdm01v15` |
| `_TZE284_iwn0gpzz` | `TS0601` | `meters-energy-1phase-spm01v25` |
| `_TZE284_loejka0i` | `TS0601` | `meters-energy-3phase-nous-d4z` |
| `_TZE284_ny94onlb` | `TS0601` | `meters-energy-3phase-spm02v25` |
| `_TZE284_pglpvdar` | `TS0601` | `meters-power-energy-voltage-current-toqsa1` |
| `_TZE284_qhlxve78` | `TS0601` | `meters-energy-1phase-spm01v2` |
| `_TZE284_s4sa1mcx` | `TS0601` | `meters-energy-3phase-sdm01v1gt` |
| `_TZE284_v9hkz2yn` | `TS0601` | `meters-energy-3phase-spm02v2` |
| `_TZE284_ves1ycwx` | `TS0601` | `meters-energy-3phase-spm02` |
| `_TZE284_wjk6rurm` | `TS0601` | `meters-energy-3phase-spm02v1gt` |
| `_TZE284_x8diwkqb` | `TS0601` | `meters-energy-2phase-sdm02v1gt` |
| `_TZE28C1000000_81yrt3lo` | `TS0601` | `meters-power-energy-voltage-current-pj1203a` |
| `MatSee Plus` | `PC321-Z-TY` | `meters-power-energy-voltage-current-clamp3phase` |
| `Nous` | `D4Z` | `meters-energy-3phase-nous-d4z` |
| `Ourtop` | `ATMS100133Z` | `meters-energy-3phase-atms10013z3` |
| `OWON` | `PC321-Z-TY` | `meters-power-energy-voltage-current-clamp3phase` |
| `Tongou` | `TOSA1-01WXJAT2A` | `meters-power-energy-voltage-current-toqsa1` |
| `Tuya` | `PJ-1203-W` | `meters-power-energy-voltage-current` |

</details>

<details>
<summary>EF00 PIR Motion wonjj6768 (23 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports EF00 PIR motion sensors.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZE200_1ibpyhdc` | `TS0601` | `safety-motion-zg204zl-keep-illuminance-battery` |
| `_TZE200_3towulqd` | `TS0601` | `safety-motion-zg204zl-keep-illuminance-battery` |
| `_TZE200_auin8mzr` | `TS0601` | `safety-motion-legacy-illuminance` |
| `_TZE200_bh3n6gk8` | `TS0601` | `safety-motion-zg204zl-keep-illuminance-battery` |
| `_TZE200_f1pvdgoh` | `\x00B` | `safety-motion-pir-illuminance-battery` |
| `_TZE200_f1pvdgoh` | `TS0601` | `safety-motion-pir-illuminance-battery` |
| `_TZE200_ghynnvos` | `TS0601` | `safety-motion-pir-illuminance` |
| `_TZE200_gjldowol` | `TS0601` | `safety-motion-zg204zl-keep-illuminance-battery` |
| `_TZE200_jxyhl4eq` | `TS0601` | `safety-motion-zg204zl-keep-illuminance-battery` |
| `_TZE200_me6wtiqs` | `TS0601` | `safety-motion-pir-illuminance-battery` |
| `_TZE200_na5qlzow` | `TS0601` | `safety-motion-zg204zl-keep-illuminance-battery` |
| `_TZE200_oc7xqqbs` | `TS0601` | `safety-motion-zpir10-illuminance-battery` |
| `_TZE200_ppuj1vem` | `TS0601` | `safety-motion-zpir10-illuminance-battery` |
| `_TZE200_qxyh4r7g` | `TS0601` | `safety-motion-zg204zl-keep-illuminance-battery` |
| `_TZE200_s6hzw8g2` | `TS0601` | `safety-motion-zg204zl-keep-illuminance-battery` |
| `_TZE200_seq9cm6u` | `TS0601` | `safety-motion-bed-time-illuminance-battery` |
| `_TZE200_ttcovulf` | `TS0601` | `safety-motion-zg204zl-keep-illuminance-battery` |
| `_TZE284_9ovska9w` | `TS0601` | `safety-motion-szlm04u-illuminance-battery` |
| `_TZE284_bquwrqh1` | `TS0601` | `safety-motion-szlm04u-illuminance-battery` |
| `_TZE284_tre6haif` | `TS0601` | `safety-motion-pir-solar-battery` |
| `AOYAN` | `AY-204Z` | `safety-motion-ay204z-battery` |
| `AOYAN ` | `AY-204Z` | `safety-motion-ay204z-battery` |
| `AOYAN  ` | `AY-204Z` | `safety-motion-ay204z-battery` |

</details>

<details>
<summary>EF00 Presence Advanced wonjj6768 (33 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports advanced EF00 presence, radar, and mmWave sensors.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZ321C_4slreunp` | `TS0225` | `safety-occupancy-mtd085-illuminance` |
| `_TZ321C_fkzihax8` | `TS0225` | `safety-occupancy-mtd085-illuminance` |
| `_TZE200_2aaelwxk` | `TS0225` | `safety-presence-zg205za-illuminance` |
| `_TZE200_clrdrnya` | `TS0601` | `safety-presence-mtg075-entry-controls-illuminance` |
| `_TZE200_crq3r3la` | `CK-BL702-MWS-01(7016)` | `safety-presence-zg205za-illuminance` |
| `_TZE200_crq3r3la` | `TS0225` | `safety-presence-zg205za-illuminance` |
| `_TZE200_gkfbdvyx` | `TS0601` | `safety-presence-zym10024gv3a-move-range-illuminance` |
| `_TZE200_hl0ss9oa` | `TS0225` | `safety-presence-zg205zl-illuminance` |
| `_TZE200_mp902om5` | `TS0601` | `safety-presence-mtg075-entry-controls-illuminance` |
| `_TZE200_sbyx0lm6` | `TS0601` | `safety-presence-mtg075-entry-controls-illuminance` |
| `_TZE200_y4mdop0b` | `TS0225` | `safety-presence-zg205zl-illuminance` |
| `_TZE200_ya4ft0w4` | `TS0601` | `safety-presence-zym10024gv3-move-range-illuminance` |
| `_TZE204_7gclukjs` | `TS0601` | `safety-presence-zym10024gv2-move-range-illuminance` |
| `_TZE204_clrdrnya` | `TS0601` | `safety-presence-mtg075-entry-controls-illuminance` |
| `_TZE204_dapwryy7` | `TS0601` | `safety-presence-zg205z-illuminance` |
| `_TZE204_dtzziy1e` | `TS0601` | `safety-presence-mtg075-entry-controls-illuminance` |
| `_TZE204_e9ajs4ft` | `TS0601` | `safety-presence-ctlr1-threshold-min-delay-illuminance` |
| `_TZE204_gkfbdvyx` | `TS0601` | `safety-presence-zym10024gv3a-move-range-illuminance` |
| `_TZE204_iaeejhvf` | `TS0601` | `safety-presence-mtg075-entry-controls-illuminance` |
| `_TZE204_ijxvkhd0` | `TS0601` | `safety-presence-zym10024g-illuminance` |
| `_TZE204_mtoaryre` | `TS0601` | `safety-presence-mtg075-entry-controls-illuminance` |
| `_TZE204_nbkshs6k` | `TS0601` | `safety-presence-zym100s3-keep-illuminance` |
| `_TZE204_oqtpvx51` | `TS0601` | `safety-presence-yxzbrb58-range-delay-scene-illuminance` |
| `_TZE204_pfayrzcw` | `TS0601` | `safety-presence-mtg075-entry-controls-illuminance` |
| `_TZE204_sbyx0lm6` | `TS0601` | `safety-presence-mtg075-entry-controls-illuminance` |
| `_TZE204_sooucan5` | `TS0601` | `safety-presence-yxzbrb58-range-delay-scene-illuminance` |
| `_TZE204_uxllnywp` | `TS0601` | `safety-presence-rtzcz03z-range-illuminance` |
| `_TZE204_ya4ft0w4` | `TS0601` | `safety-presence-zym10024gv3-move-range-illuminance` |
| `_TZE284_4qznlkbu` | `TS0601` | `safety-presence-mtg075-entry-controls-illuminance` |
| `_TZE284_d4h8j2n6` | `ZP-301Z` | `safety-presence-zp301z-time-cycle-illuminance-battery` |
| `B3876M9` | `ZP-301Z` | `safety-presence-zp301z-time-cycle-illuminance-battery` |
| `HOBEIAN` | `CK-BL702-MWS-01(7016)` | `safety-presence-zg205za-illuminance` |
| `ZGAF-205L` | `CK-BL702-MWS-01(7016)` | `safety-presence-zg205zl-illuminance` |

</details>

<details>
<summary>EF00 Presence General 1 wonjj6768 (30 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports general EF00 presence, radar and mmWave sensors (group 1 of 2). See the README fingerprint table for the exact device list.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZE200_0u3bj3rc` | `TS0601` | `safety-presence-hps-duration-led` |
| `_TZE200_hyhl5y36` | `TS0601` | `safety-presence-msa201-illuminance` |
| `_TZE200_jkbljri7` | `TS0601` | `safety-presence-mirhe200-illuminance-fall` |
| `_TZE200_juzago6i` | `TS0601` | `safety-presence-pir24g-dedicated-illuminance-battery` |
| `_TZE200_lu01t0zl` | `TS0601` | `safety-presence-mirhe200-illuminance-fall` |
| `_TZE200_mgxy2d9f` | `TS0601` | `safety-motion-tamper-battery` |
| `_TZE200_mx6u6l4y` | `TS0601` | `safety-presence-hps-duration-led` |
| `_TZE200_v6ossqfy` | `TS0601` | `safety-presence-hps-duration-led` |
| `_TZE200_vrfecyku` | `TS0601` | `safety-presence-mirhe200-illuminance-fall` |
| `_TZE200_w0ap83qu` | `TS0601` | `safety-presence-illuminance-temp-humidity-battery-zg204zx` |
| `_TZE200_w0ap83qu` | `ZG-204ZX` | `safety-presence-illuminance-temp-humidity-battery-zg204zx` |
| `_TZE200_ypprdwsl` | `TS0601` | `safety-presence-mirhe200-illuminance-fall` |
| `_TZE204_aai5grix` | `TS0601` | `safety-presence-mtd285-illuminance` |
| `_TZE204_bmdsp6bs` | `TS0601` | `safety-presence-y1in-dedicated-illuminance` |
| `_TZE204_bvfld3xc` | `TS0601` | `safety-presence-mirhe200-illuminance-fall` |
| `_TZE204_debczeci` | `TS0601` | `safety-presence-basic-delay-battery` |
| `_TZE204_eaulras5` | `TS0601` | `safety-presence-pj3201a-illuminance` |
| `_TZE204_kyhbrfyl` | `TS0601` | `safety-motion-nas-ps09b2` |
| `_TZE204_laokfqwu` | `TS0601` | `safety-presence-wzm100-range-delay-illuminance` |
| `_TZE204_mhxn2jso` | `TS0601` | `safety-presence-rtsc11r-illuminance` |
| `_TZE204_muvkrjr5` | `TS0601` | `safety-presence-szr07u-range-delay` |
| `_TZE204_no6qtgtl` | `TS0601` | `safety-presence-rd24g01-range` |
| `_TZE284_1lvln0x6` | `TS0601` | `safety-presence-basic-delay-battery` |
| `_TZE284_aai5grix` | `TS0601` | `safety-presence-mtd285-illuminance` |
| `_TZE284_ajuasrmx` | `TS0601` | `safety-presence-msa201-illuminance` |
| `_TZE284_debczeci` | `TS0601` | `safety-presence-basic-delay-battery` |
| `_TZE284_gnpflcoq` | `TS0601` | `safety-presence-gnpflcoq-illuminance-temp-humidity-battery` |
| `_TZE284_ozf4e02o` | `TS0601` | `safety-presence-msa201-illuminance` |
| `C6B7KM9` | `Excellux` | `safety-presence-excellux-zg301a` |
| `HOBEIAN` | `ZG-204ZX` | `safety-presence-illuminance-temp-humidity-battery-zg204zx` |

</details>

<details>
<summary>EF00 Presence General 2 wonjj6768 (62 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports general EF00 presence, radar and mmWave sensors (group 2 of 2). See the README fingerprint table for the exact device list.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZE200_2aaelwxk` | `TS0601` | `safety-presence-zg204zm-illuminance-battery` |
| `_TZE200_4pm4pekt` | `TS0601` | `safety-presence-zg204ze-illuminance-battery` |
| `_TZE200_cq8lu23i` | `TS0601` | `safety-presence-zg204ze-illuminance-battery` |
| `_TZE200_grgol3xp` | `TS0601` | `safety-presence-zg204zv-illuminance-temp-humidity-battery` |
| `_TZE200_hdih4foa` | `TS0601` | `safety-presence-zg204zh-illuminance-temp-humidity-battery` |
| `_TZE200_holel4dk` | `TS0601` | `safety-presence-zym100l-fixed-illuminance` |
| `_TZE200_ikvncluo` | `TS0601` | `safety-presence-zym100l-fixed-illuminance` |
| `_TZE200_jva8ink8` | `TS0601` | `safety-presence-zym100l-fixed-illuminance` |
| `_TZE200_ka8l86iu` | `TS0601` | `safety-presence-zg204zk-battery` |
| `_TZE200_kb5noeto` | `TS0601` | `safety-presence-zg204zm-illuminance-battery` |
| `_TZE200_lyetpprm` | `TS0601` | `safety-presence-zym100l-fixed-illuminance` |
| `_TZE200_p9zbdqgs` | `TS0601` | `safety-presence-zg204zq-illuminance-temp-humidity-battery` |
| `_TZE200_qasjif9e` | `TS0601` | `safety-presence-zym100s2-range-illuminance` |
| `_TZE200_rhgsbacq` | `TS0601` | `safety-presence-zg204zv-illuminance-temp-humidity-battery` |
| `_TZE200_sgpeacqp` | `TS0601` | `safety-presence-zym100l-fixed-illuminance` |
| `_TZE200_tyffvoij` | `TS0601` | `safety-presence-zg204zm-illuminance-battery` |
| `_TZE200_uli8wasj` | `TS0601` | `safety-presence-zg204zv-illuminance-temp-humidity-battery` |
| `_TZE200_vuqzj1ej` | `TS0601` | `safety-presence-zg204zh-illuminance-temp-humidity-battery` |
| `_TZE200_wukb7rhc` | `TS0601` | `safety-presence-zym100l-fixed-illuminance` |
| `_TZE200_xpq2rzhq` | `TS0601` | `safety-presence-zym100l-fixed-illuminance` |
| `_TZE200_y8jijhba` | `TS0601` | `safety-presence-zg204ze-illuminance-battery` |
| `_TZE200_yflzeeqj` | `TS0601` | `safety-presence-zg204zm-illuminance-battery` |
| `_TZE200_zbfmvj13` | `TS0601` | `safety-presence-zg204zk-battery` |
| `_TZE200_ztc6ggyl` | `TS0601` | `safety-presence-zym100l-fixed-illuminance` |
| `_TZE204_e5m9c5hl` | `TS0601` | `safety-presence-zym100s1-range-illuminance` |
| `_TZE204_ex3rcdha` | `TS0601` | `safety-presence-zy-hps01-illuminance` |
| `_TZE204_fwondbzy` | `TS0601` | `safety-presence-zym100l-fixed-illuminance` |
| `_TZE204_iadro9bf` | `TS0601` | `safety-presence-zym100s2-range-illuminance` |
| `_TZE204_lbbg34rj` | `TS0601` | `safety-presence-zy-hps01-illuminance` |
| `_TZE204_qasjif9e` | `TS0601` | `safety-presence-zym100s2-range-illuminance` |
| `_TZE204_sxm7l9xa` | `TS0601` | `safety-presence-zym100s1-range-illuminance` |
| `_TZE204_xpq2rzhq` | `TS0601` | `safety-presence-zym100l-fixed-illuminance` |
| `_TZE204_xsm7l9xa` | `TS0601` | `safety-presence-zym100l-fixed-illuminance` |
| `_TZE204_ztc6ggyl` | `TS0601` | `safety-presence-zym100l-fixed-illuminance` |
| `_TZE204_ztqnh5cg` | `TS0601` | `safety-presence-zym100s2-range-illuminance` |
| `_TZE2841000000_bw4ayyeh` | `TS0601` | `safety-presence-zd24-illuminance-battery` |
| `_TZE284_bw4ayyeh` | `TS0601` | `safety-presence-zd24-illuminance-battery` |
| `_TZE284_fwondbzy` | `TS0601` | `safety-presence-zym100l-fixed-illuminance` |
| `_TZE284_hgeqeyuv` | `TS0601` | `safety-presence-zf24-move-illuminance` |
| `_TZE284_iadro9bf` | `TS0601` | `safety-presence-zym100s2-range-illuminance` |
| `_TZE284_pzm3wab5` | `TS0601` | `safety-presence-zf24-move-illuminance` |
| `_TZE284_twybxdzl` | `TS0601` | `safety-presence-zf24-move-illuminance` |
| `_TZE284_vceqncho` | `TS0601` | `safety-presence-zis01p-illuminance-battery` |
| `_TZE284_who1jxwd` | `TS0601` | `safety-presence-zis01p-illuminance-battery` |
| `_TZE284_xpq2rzhq` | `TS0601` | `safety-presence-zym100l-fixed-illuminance` |
| `_TZE28C1000000_hgeqeyuv` | `TS0601` | `safety-presence-zf24-move-illuminance` |
| `_TZE28C1000000_pzm3wab5` | `TS0601` | `safety-presence-zf24-move-illuminance` |
| `_TZE28C1000000_twybxdzl` | `TS0601` | `safety-presence-zf24-move-illuminance` |
| `AOYAN` | `AY-204ZX` | `safety-presence-zg204zk-battery` |
| `AOYAN` | `AY205Z` | `safety-presence-zg204zm-illuminance-battery` |
| `AOYAN` | `AY208Z` | `safety-presence-zg204zh-illuminance-temp-humidity-battery` |
| `AOYAN  ` | `AY204T` | `safety-presence-zg204zv-illuminance-temp-humidity-battery` |
| `HOBEIAN` | `ZG-204ZE` | `safety-presence-zg204ze-illuminance-battery` |
| `HOBEIAN` | `ZG-204ZH` | `safety-presence-zg204zh-illuminance-temp-humidity-battery` |
| `HOBEIAN` | `ZG-204ZK` | `safety-presence-zg204zk-battery` |
| `HOBEIAN` | `ZG-204ZV` | `safety-presence-zg204zv-illuminance-temp-humidity-battery` |
| `iHseno` | `TY_24G_Sensor_V2` | `safety-presence-zym100s2-range-illuminance` |
| `Moes` | `ZSS-QY-HP` | `safety-presence-zym100l-fixed-illuminance` |
| `Nova Digital` | `ZTS-MM` | `safety-presence-zy-hps01-illuminance` |
| `Tuya` | `ZY-M100-L` | `safety-presence-zym100l-fixed-illuminance` |
| `Wenzhi` | `WZ-M100-W` | `safety-presence-zym100s1-range-illuminance` |
| `ZG-204ZE` | `CK-BL702-MWS-01(7016)` | `safety-presence-zg204ze-illuminance-battery` |

</details>

<details>
<summary>EF00 Presence Switch wonjj6768 (16 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports EF00 presence sensors with switch endpoints.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZE200_ahpcyzth` | `TS0601` | `switches-presence-switch-3-zg302zm` |
| `_TZE200_bfmfhxra` | `TS0601` | `switches-presence-switch-3-zg302zm` |
| `_TZE200_cqtamhh5` | `TS0601` | `switches-presence-switch-3-zg302zl` |
| `_TZE200_df04ghrb` | `TS0601` | `switches-presence-switch-3-zg302zl` |
| `_TZE200_kccdzaeo` | `TS0601` | `switches-presence-switch-3-zg302zm` |
| `_TZE200_khzbklyh` | `TS0601` | `switches-presence-switch-3-zg302zl` |
| `_TZE200_kijxnb8q` | `TS0601` | `switches-presence-switch-3-zg302zm` |
| `_TZE200_llvwkkde` | `TS0601` | `switches-presence-switch-3-zg302zl` |
| `_TZE200_s7rsrtbg` | `TS0601` | `switches-presence-switch-3-zg302zm` |
| `_TZE200_tmszbtzq` | `TS0601` | `switches-presence-switch-3-zg302zm` |
| `_TZE200_toeldckg` | `TS0601` | `switches-presence-switch-3-zg302zl` |
| `_TZE200_xlnzk169` | `TS0601` | `switches-presence-switch-3-zg302zl` |
| `_TZE204_f2rflfa6` | `TS0601` | `safety-presence-switch-illuminance-zis04` |
| `_TZE204_izy1g1mb` | `TS0601` | `safety-presence-switch-illuminance-zis03` |
| `HOBEIAN` | `ZG-302ZL` | `switches-presence-switch-3-zg302zl` |
| `HOBEIAN` | `ZG-302ZM` | `switches-presence-switch-3-zg302zm` |

</details>

<details>
<summary>EF00 Safety wonjj6768 (99 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports EF00 smoke, CO, gas, water leak, contact, and vibration sensors.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TYST11_qtbrwrfv` | `tbrwrfv\x00` | `safety-smoke-value-self-check-result-lifecycle-battery-silence-alecto` |
| `_TZE200_0zaf1cr8` | `TS0601` | `safety-smoke-tamper-battery-low` |
| `_TZE200_2pddnnrk` | `TS0601` | `safety-water-leak-illuminance-battery-zg223z` |
| `_TZE200_5d3vhjro` | `TS0601` | `safety-smoke-battery-silence-alarm-sa12izl` |
| `_TZE200_7bztmfm1` | `TS0601` | `safety-co-detector` |
| `_TZE200_8isdky6j` | `TS0601` | `safety-gas-detector-zg225z` |
| `_TZE200_8ply8mjj` | `TS0601` | `safety-acceleration-4cqhd2ha` |
| `_TZE200_afycb3cg` | `TS0601` | `safety-acceleration-battery-zg103z` |
| `_TZE200_aj0oxo1i` | `TS0225` | `safety-gas-detector-zg225z` |
| `_TZE200_aycxwiau` | `TS0601` | `safety-smoke-test-result-battery-fault-silence-alarm-r7049` |
| `_TZE200_bxdyeaa9` | `TS0601` | `safety-smoke-test-result-battery-fault-silence-alarm-r7049` |
| `_TZE200_dnz6yvl2` | `TS0601` | `safety-smoke-battery-concentration-fault-state-silence-test-zss` |
| `_TZE200_dq1mfjug` | `TS0601` | `safety-smoke-battery-state-battery-t5p1vj8r` |
| `_TZE200_e2bedvo9` | `TS0601` | `safety-smoke-battery-concentration-fault-state-silence-test-zss` |
| `_TZE200_ft523twt` | `TS0601` | `safety-smoke-test-result-battery-fault-silence-alarm-r7049` |
| `_TZE200_fwoorn8y` | `TS0601` | `safety-contact-battery` |
| `_TZE200_ggev5fsl` | `TS0601` | `safety-gas-detector-self-test` |
| `_TZE200_hggxgsjj` | `TS0601` | `safety-acceleration-battery-zg103z` |
| `_TZE200_iba1ckek` | `TS0601` | `safety-acceleration-battery-zg103z` |
| `_TZE200_ijey4q29` | `TS0601` | `safety-contact-illuminance-battery` |
| `_TZE200_ioxkjvuz` | `TS0601` | `safety-gas-detector-self-test-result-preheat-ga01` |
| `_TZE200_iuk8kupi` | `TS0601` | `safety-gas-co-detector` |
| `_TZE200_j7sgd8po` | `TS0601` | `safety-contact-temp-humidity-battery-s8` |
| `_TZE200_jfw0a4aa` | `TS0601` | `safety-acceleration-contact-battery-zg102zm` |
| `_TZE200_jsaqgakf` | `TS0601` | `safety-water-leak-illuminance-battery-zg223z` |
| `_TZE200_jthf7vb6` | `TS0601` | `safety-water-leak-battery` |
| `_TZE200_kf2hbko4` | `TS0601` | `safety-contact-illuminance-battery` |
| `_TZE200_kltffuzl` | `TS0601` | `safety-contact-battery` |
| `_TZE200_kvpwq8z7` | `TS0601` | `safety-gas-detector-self-test` |
| `_TZE200_kzm5w4iz` | `TS0601` | `safety-acceleration-contact-battery` |
| `_TZE200_m9skfctm` | `TS0601` | `safety-smoke-battery-concentration-fault-silence-test-pa44z` |
| `_TZE200_mby4kbtq` | `TS0601` | `safety-gas-detector-value-preheat-fault-alarm-silence-gas4` |
| `_TZE200_n8dljorx` | `TS0601` | `safety-contact-battery` |
| `_TZE200_ntcy3xu1` | `TS0601` | `safety-smoke-tamper-battery-state-ntcy3xu1` |
| `_TZE200_nus5kk3n` | `TS0601` | `safety-gas-detector-self-test-result-fault-gas3` |
| `_TZE200_nvups4nh` | `TS0601` | `safety-contact-temp-humidity-battery` |
| `_TZE200_p6fuhvez` | `TS0225` | `safety-gas-detector-zg225z` |
| `_TZE200_pay2byax` | `TS0601` | `safety-contact-illuminance-battery` |
| `_TZE200_qcasmfan` | `TS0601` | `safety-smoke-tamper-battery` |
| `_TZE200_qq9mpfhw` | `TS0601` | `safety-water-leak` |
| `_TZE200_qtbrwrfv` | `TS0601` | `safety-smoke-value-self-check-result-lifecycle-battery-silence-alecto` |
| `_TZE200_rccxox8p` | `TS0601` | `safety-smoke-battery-concentration-fault-silence-test-pa44z` |
| `_TZE200_t5p1vj8r` | `TS0601` | `safety-smoke-battery-state-battery-t5p1vj8r` |
| `_TZE200_u319yc66` | `TS0601` | `safety-gas-detector-self-test` |
| `_TZE200_u6x1zyv2` | `TS0601` | `safety-water-leak-illuminance-battery-zg223z` |
| `_TZE200_uebojraa` | `TS0601` | `safety-smoke-battery-state-battery-t5p1vj8r` |
| `_TZE200_ux5v4dbd` | `TS0601` | `safety-smoke-battery-state-ux5v4dbd` |
| `_TZE200_vawy74yh` | `TS0601` | `safety-smoke-battery-state-battery-self-test-silence-hs2sa` |
| `_TZE200_vzekyi4c` | `TS0601` | `safety-smoke-battery-state-battery-t5p1vj8r` |
| `_TZE200_wzk0x7fq` | `TS0601` | `safety-acceleration-contact-battery-zg102zm` |
| `_TZE200_yh7aoahi` | `TS0601` | `safety-smoke-battery-state-battery-t5p1vj8r` |
| `_TZE200_yjryxpot` | `TS0601` | `safety-acceleration-battery-zg103z` |
| `_TZE200_ykglasuj` | `TS0601` | `safety-contact-illuminance-battery` |
| `_TZE200_yojqa8xn` | `TS0601` | `safety-gas-detector-alarm-time-ringtone` |
| `_TZE200_ytibqbra` | `TS0601` | `safety-smoke-tamper-battery-fault-silence-alarm-ytibqbra` |
| `_TZE200_ytx9fudw` | `TS0601` | `safety-contact-alarm-battery-opening-senoro` |
| `_TZE204_7bztmfm1` | `TS0601` | `safety-co-detector` |
| `_TZE204_ai4rqhky` | `TS0601` | `safety-smoke-battery-state-battery-self-test-silence-hs2sa` |
| `_TZE204_chbyv06x` | `TS0601` | `safety-gas-detector-alarm-time-ringtone` |
| `_TZE204_fncxk3ob` | `TS0601` | `safety-alarm-battery-duration-volume-ringtone-yxzbsl` |
| `_TZE204_hcxvyxa5` | `TS0601` | `safety-alarm-duration-volume-ringtone-za03` |
| `_TZE204_iuk8kupi` | `TS0601` | `safety-gas-co-detector` |
| `_TZE204_k7mfgaen` | `TS0601` | `safety-alarm-battery-duration-volume-ringtone-yxzbsl` |
| `_TZE204_kgaxpvxr` | `TS0601` | `safety-smoke-detector-battery-288wz` |
| `_TZE204_kvpwq8z7` | `TS0601` | `safety-gas-detector-self-test` |
| `_TZE204_mby4kbtq` | `TS0601` | `safety-gas-detector-value-preheat-fault-alarm-silence-gas4` |
| `_TZE204_ntcy3xu1` | `TS0601` | `safety-smoke-tamper-battery-low` |
| `_TZE204_qaxkdgyt` | `TS0601` | `safety-gas-co-detector-jkd816` |
| `_TZE204_uo8qcagc` | `TS0601` | `safety-gas-detector-value-preheat-fault-alarm-silence-gas4` |
| `_TZE204_v6iczj35` | `TS0601` | `safety-gas-detector-preheat-fault-lifecycle-dg03` |
| `_TZE204_vawy74yh` | `TS0601` | `safety-smoke-battery-state-battery-self-test-silence-hs2sa` |
| `_TZE204_yojqa8xn` | `TS0601` | `safety-gas-detector-alarm-time-ringtone` |
| `_TZE204_zougpkpy` | `TS0601` | `safety-gas-detector-alarm-time-ringtone` |
| `_TZE2841000000_rccxox8p` | `TS0601` | `safety-smoke-battery-concentration-fault-silence-test-pa44z` |
| `_TZE284_0zaf1cr8` | `TS0601` | `safety-smoke-tamper-battery-low` |
| `_TZE284_4cqhd2ha` | `TS0601` | `safety-acceleration-4cqhd2ha` |
| `_TZE284_6teua268` | `TS0601` | `safety-contact-battery-senoro-win-v2` |
| `_TZE284_6ycgarab` | `TS0601` | `safety-smoke-co-battery-state-volume-silence-alarm-smokeco` |
| `_TZE284_ai4rqhky` | `TS0601` | `safety-smoke-battery-state-battery-self-test-silence-hs2sa` |
| `_TZE284_aoah6bv8` | `TS0601` | `safety-smoke-co-battery-state-volume-silence-alarm-smokeco` |
| `_TZE284_chbyv06x` | `TS0601` | `safety-gas-detector-alarm-time-ringtone` |
| `_TZE284_e2bedvo9` | `TS0601` | `safety-smoke-battery-concentration-fault-state-silence-test-zss` |
| `_TZE284_fncxk3ob` | `TS0601` | `safety-alarm-battery-duration-volume-ringtone-yxzbsl` |
| `_TZE284_gyzlwu5q` | `TS0601` | `safety-smoke-temp-humidity-battery` |
| `_TZE284_n4ttsck2` | `TS0601` | `safety-smoke-detector-battery-288wz` |
| `_TZE284_qvzsq3s2` | `TS0601` | `safety-smoke-battery-concentration-fault-silence-test-pa44z` |
| `_TZE284_rccxox8p` | `TS0601` | `safety-smoke-battery-concentration-fault-silence-test-pa44z` |
| `_TZE284_uo8qcagc` | `TS0601` | `safety-gas-detector-value-preheat-fault-alarm-silence-gas4` |
| `_TZE284_vawy74yh` | `TS0601` | `safety-smoke-battery-state-battery-self-test-silence-hs2sa` |
| `_TZE28C1000000_chbyv06x` | `TS0601` | `safety-gas-detector-alarm-time-ringtone` |
| `AOYAN` | `AY02SZ` | `safety-acceleration-contact-battery-zg102zm` |
| `CAT0001` | `Excellux` | `safety-contact-vibration-battery-excellux` |
| `HOBEIAN` | `ZG-103Z` | `safety-acceleration-battery-zg103z` |
| `HOBEIAN` | `ZG-223Z` | `safety-water-leak-illuminance-battery-zg223z` |
| `HOBEIAN` | `ZG-226Z` | `safety-water-leak-alarm-battery-zg226z` |
| `HOBEIAN` | `ZG-228Z` | `safety-acceleration-alarm-battery-zg228z` |
| `HOBEIAN` | `ZG-229Z` | `safety-alarm-battery-zg229z` |
| `PIRIV01` | `Excellux` | `safety-motion-vibration-illuminance-battery-excellux` |
| `VABRATE` | `Excellux` | `safety-vibration-battery-excellux` |

</details>

<details>
<summary>EF00 Screen Switch wonjj6768 (8 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports EF00 screen switch panels.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZE204_08qc13ct` | `TS0601` | `switches-screen-zms206us4` |
| `_TZE204_wwaeqnrf` | `TS0601` | `switches-screen-zms206us4` |
| `_TZE204_xibaabmu` | `TS0601` | `switches-screen-zms206us4` |
| `_TZE204_y4jqpry8` | `TS0601` | `switches-screen-zms206us4` |
| `_TZE284_wwaeqnrf` | `TS0601` | `switches-screen-zms206us4` |
| `_TZE284_xibaabmu` | `TS0601` | `switches-screen-zms206us4` |
| `_TZE284_y4jqpry8` | `TS0601` | `switches-screen-zms206us4` |
| `_TZE28C1000000_y4jqpry8` | `TS0601` | `switches-screen-zms206us4` |

</details>

<details>
<summary>EF00 Sensors wonjj6768 (155 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports EF00 temperature, humidity, illuminance, air quality, pressure, and soil sensors.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TYST11_pisltm67` | `isltm67\x00` | `sensors-illuminance-battery-brightness-slux` |
| `_TZE200_01fvxamo` | `TS0201` | `sensors-temp-battery` |
| `_TZE200_2se8efxh` | `TS0601` | `sensors-soil-temp-moisture-battery-state-unit-soil-raw` |
| `_TZE200_3ejwxpmu` | `TS0601` | `sensors-aq-co2-temp-humidity` |
| `_TZE200_3xfjp0ag` | `TS0601` | `sensors-temp-humidity-battery-calibration-zg227z` |
| `_TZE200_44af8vyi` | `TS0601` | `sensors-temp-humidity-battery` |
| `_TZE200_8ygsuhe1` | `TS0601` | `sensors-aq-co2-temp-humidity-voc-formaldehyde` |
| `_TZE200_9cqcpkgb` | `TS0601` | `sensors-soil-temp-moisture-battery-state-unit-soil-raw` |
| `_TZE200_9yapgbuv` | `TS0601` | `sensors-temp-humidity-battery-state-unit-th2aaa` |
| `_TZE200_a8sdabtg` | `TS0601` | `sensors-temp-humidity-battery-calibration-zg227z` |
| `_TZE200_bjawzodf` | `TS0601` | `sensors-temp-humidity-battery` |
| `_TZE200_blfcpsxz` | `TS0601` | `sensors-aq-pm25-co2-temp-humidity-voc-formaldehyde` |
| `_TZE200_bq5c8xfe` | `TS0601` | `sensors-temp-humidity-battery` |
| `_TZE200_c2fmom5z` | `TS0601` | `sensors-aq-co2-temp-humidity-voc-formaldehyde` |
| `_TZE200_c7emyjom` | `TS0601` | `sensors-temp-humidity-battery-alarm-sensitivity-nous-szt04` |
| `_TZE200_cirvgep4` | `TS0601` | `sensors-temp-humidity-battery-state-unit-th2aaa` |
| `_TZE200_d0yu2xgi` | `TS0601` | `sensors-temp-humidity-alarm-neo-nas-ab02b0` |
| `_TZE200_d7lpruvi` | `TS0601` | `sensors-temp-humidity-battery-state-unit-th2aaa` |
| `_TZE200_d9mzkhoq` | `TS0601` | `sensors-temp-battery-pool-chlorine` |
| `_TZE200_dikkika5` | `TS0601` | `sensors-temp-humidity-battery-calibration-zg227z` |
| `_TZE200_dwcarsat` | `TS0601` | `sensors-aq-pm25-co2-temp-humidity-voc-formaldehyde` |
| `_TZE200_eanjj2pa` | `TS0601` | `sensors-temp-humidity-battery-alarm-sensitivity-nous-szt04` |
| `_TZE200_ehhrv2e3` | `TS0601` | `sensors-temp-humidity-battery-calibration-zg227z` |
| `_TZE200_ga1maeof` | `TS0601` | `sensors-soil-temp-moisture-battery-state-unit-soil-raw` |
| `_TZE200_iq4ygaai` | `TS0201` | `sensors-temp-battery` |
| `_TZE200_jt50ea5d` | `TS0601` | `sensors-temp-battery-heat-water-meter` |
| `_TZE200_khx7nnka` | `TS0601` | `sensors-illuminance-brightness-xfy` |
| `_TZE200_lhqtjwax` | `TS0601` | `sensors-temp-humidity-battery-calibration-zg227z` |
| `_TZE200_locansqn` | `TS0601` | `sensors-temp-humidity-battery-alarm-sensitivity-nous-szt04` |
| `_TZE200_lve3dvpy` | `TS0601` | `sensors-temp-humidity-battery-alarm-sensitivity-nous-szt04` |
| `_TZE200_lvkk0hdg` | `TS0601` | `sensors-liquid-level-tlc2206` |
| `_TZE200_mja3fuja` | `TS0601` | `sensors-aq-co2-temp-humidity-voc-formaldehyde` |
| `_TZE200_myd45weu` | `TS0601` | `sensors-soil-temp-moisture-battery-state-unit-soil-raw` |
| `_TZE200_nnrfa68v` | `TS0601` | `sensors-temp-humidity-battery-sensitivity-nous-e6` |
| `_TZE200_npj9bug3` | `TS0601` | `sensors-soil-temp-humidity-moisture-battery-dry` |
| `_TZE200_ogkdpgy2` | `TS0601` | `sensors-aq-co2-temp-humidity` |
| `_TZE200_pisltm67` | `TS0601` | `sensors-illuminance-battery-brightness-slux` |
| `_TZE200_pl31aqf5` | `TS0601` | `sensors-aq-zr360cdb-co2-temp-humidity` |
| `_TZE200_qoy0ekbd` | `TS0601` | `sensors-temp-humidity-battery-calibration-zg227z` |
| `_TZE200_qrztc3ev` | `TS0601` | `sensors-temp-humidity-battery-alarm-sensitivity-nous-szt04` |
| `_TZE200_qyflbnbj` | `TS0601` | `sensors-temp-humidity-battery-state-qyfl` |
| `_TZE200_rbbx5mfq` | `TS0601` | `sensors-illuminance-temp-humidity` |
| `_TZE200_ryfmq5rl` | `TS0601` | `sensors-aq-co2-temp-humidity-voc-formaldehyde` |
| `_TZE200_s1xgth2u` | `TS0601` | `sensors-temp-humidity-battery` |
| `_TZE200_snloy4rw` | `TS0601` | `sensors-temp-humidity-battery-alarm-sensitivity-nous-szt04` |
| `_TZE200_t3xd7l44` | `TS0601` | `sensors-temp-humidity-battery` |
| `_TZE200_upagmta9` | `TS0601` | `sensors-temp-humidity-battery-state-unit-th2aaa` |
| `_TZE200_utkemkbs` | `TS0601` | `sensors-temp-humidity-battery-state-unit-th2aaa` |
| `_TZE200_v1jqz5cy` | `TS0601` | `sensors-temp-battery-pool-chlorine` |
| `_TZE200_vs0skpuc` | `TS0601` | `sensors-temp-humidity-battery-calibration-zg227z` |
| `_TZE200_vvmbj46n` | `TS0601` | `sensors-temp-humidity-battery-alarm-sensitivity-th-alarm` |
| `_TZE200_vzqtvljm` | `TS0601` | `sensors-illuminance-temp-humidity-battery` |
| `_TZE200_w6n8jeuu` | `TS0601` | `sensors-temp-humidity-battery-alarm-sensitivity-th-alarm` |
| `_TZE200_whkgqxse` | `TS0601` | `sensors-temp-humidity-battery-jm-trh` |
| `_TZE200_wqashyqo` | `TS0601` | `sensors-soil-temp-humidity-moisture-battery-warning` |
| `_TZE200_wrmhp6b3` | `TS0601` | `sensors-soil-temp-humidity-moisture-battery-dry` |
| `_TZE200_wtikaxzs` | `TS0601` | `sensors-temp-humidity-battery-sensitivity-nous-e6` |
| `_TZE200_xpvamyfz` | `TS0601` | `sensors-aq-zr360cdb-co2-temp-humidity` |
| `_TZE200_y8wkaq6w` | `TS0601` | `sensors-temp-humidity-battery-calibration-zg227z` |
| `_TZE200_ydrdfkim` | `TS0601` | `sensors-temp-humidity-battery-alarm-sensitivity-nous-szt04` |
| `_TZE200_yi4jtqq1` | `TS0601` | `sensors-illuminance-brightness-xfy` |
| `_TZE200_yjjdcqsq` | `TS0601` | `sensors-temp-humidity-battery-state-unit-th2aaa` |
| `_TZE200_ysm4dsb1` | `TS0601` | `sensors-temp-humidity-battery-calibration-zg227z` |
| `_TZE200_yvx5lh6k` | `TS0601` | `sensors-aq-co2-temp-humidity-voc-formaldehyde` |
| `_TZE200_zl1kmjqx` | `TS0601` | `sensors-temp-humidity-battery` |
| `_TZE200_znbl8dj5` | `TS0601` | `sensors-temp-humidity-battery-calibration-zg227z` |
| `_TZE200_zppcgbdj` | `TS0601` | `sensors-temp-humidity-battery-sensitivity-nous-e6` |
| `_TZE204_1wnh8bqp` | `TS0601` | `sensors-temp-humidity-battery-state-unit-th2aaa` |
| `_TZE204_3ejwxpmu` | `TS0601` | `sensors-aq-co2-temp-humidity` |
| `_TZE204_7yyuo8sr` | `TS0601` | `sensors-liquid-level-872wz` |
| `_TZE204_9yapgbuv` | `TS0601` | `sensors-temp-humidity-battery-state-unit-th2aaa` |
| `_TZE204_c2fmom5z` | `TS0601` | `sensors-aq-co2-temp-humidity-voc-formaldehyde` |
| `_TZE204_cirvgep4` | `TS0601` | `sensors-temp-humidity-battery-state-unit-th2aaa` |
| `_TZE204_d7lpruvi` | `TS0601` | `sensors-temp-humidity-battery-state-unit-th2aaa` |
| `_TZE204_dwcarsat` | `TS0601` | `sensors-aq-pm25-co2-temp-humidity-voc-formaldehyde` |
| `_TZE204_jygvp6fk` | `TS0601` | `sensors-temp-humidity-battery-state-unit-th2aaa` |
| `_TZE204_khx7nnka` | `TS0601` | `sensors-illuminance-brightness-xfy` |
| `_TZE204_ksz749x8` | `TS0601` | `sensors-temp-humidity-battery-state-unit-th2aaa` |
| `_TZE204_kwi6bbk4` | `TS0601` | `sensors-temp-humidity-battery-state-unit-th2aaa` |
| `_TZE204_myd45weu` | `TS0601` | `sensors-soil-temp-moisture-battery-state-unit-soil-raw` |
| `_TZE204_ogkdpgy2` | `TS0601` | `sensors-aq-co2` |
| `_TZE204_qyflbnbj` | `TS0601` | `sensors-temp-humidity-battery-state-qyfl` |
| `_TZE204_rbbx5mfq` | `TS0601` | `sensors-illuminance-temp-humidity` |
| `_TZE204_s139roas` | `TS0601` | `sensors-temp-humidity-battery` |
| `_TZE204_upagmta9` | `TS0601` | `sensors-temp-humidity-battery-state-unit-th2aaa` |
| `_TZE204_utkemkbs` | `TS0601` | `sensors-temp-humidity-battery-state-unit-th2aaa` |
| `_TZE204_w2vunxzm` | `TS0601` | `sensors-pressure-temp-display` |
| `_TZE204_yjjdcqsq` | `TS0601` | `sensors-temp-humidity-battery-state-unit-th2aaa` |
| `_TZE204_yvx5lh6k` | `TS0601` | `sensors-aq-co2-temp-humidity-voc-formaldehyde` |
| `_TZE2841000000_0ints6wl` | `TS0601` | `sensors-soil-temp-humidity-moisture-illuminance-battery-warning` |
| `_TZE2841000000_hdml1aav` | `TS0601` | `sensors-soil-temp-humidity-moisture-illuminance-ec-battery-fertility-cal` |
| `_TZE2841000000_nhgdf6qr` | `TS0601` | `sensors-soil-temp-moisture-battery-state-unit-soil-scaled` |
| `_TZE2841000000_tgrzpqf4` | `TS0601` | `sensors-soil-temp-moisture-battery-state-unit-soil-scaled` |
| `_TZE284_0ints6wl` | `TS0601` | `sensors-soil-temp-humidity-moisture-illuminance-battery-warning` |
| `_TZE284_1wnh8bqp` | `TS0601` | `sensors-temp-humidity-battery-state-unit-th2aaa` |
| `_TZE284_2nhqasjh` | `TS0601` | `sensors-soil-temp-moisture-battery-state-unit-soil-raw` |
| `_TZE284_2se8efxh` | `TS0601` | `sensors-soil-temp-moisture-battery-state-unit-soil-raw` |
| `_TZE284_33bwcga2` | `TS0601` | `sensors-soil-temp-moisture-battery-state-unit-soil-scaled` |
| `_TZE284_3urschql` | `TS0601` | `sensors-soil-temp-moisture-battery-state-unit-brightness-soil-scaled` |
| `_TZE284_4dosadbh` | `TS0601` | `sensors-temp-humidity-battery-alarm-sensitivity-lincukoo-szt04` |
| `_TZE284_65gzcss7` | `TS0601` | `sensors-soil-temp-humidity-moisture-illuminance-battery-warning` |
| `_TZE284_8b9zpaav` | `TS0601` | `sensors-aq-co2-temp-humidity-voc-formaldehyde` |
| `_TZE284_8se38w3c` | `TS0601` | `sensors-temp-humidity-probe-battery-state-tzzt01` |
| `_TZE284_9ern5sfh` | `TS0601` | `sensors-temp-humidity-battery-unit-9ern5sfh` |
| `_TZE284_9yapgbuv` | `TS0601` | `sensors-temp-humidity-battery-state-unit-th2aaa` |
| `_TZE284_aaeasoll` | `TS0601` | `sensors-illuminance-battery-report-interval-aaeasoll` |
| `_TZE284_aao3yzhs` | `TS0601` | `sensors-soil-temp-moisture-battery-state-unit-soil-scaled` |
| `_TZE284_ajlu4cud` | `TS0601` | `sensors-water-meter-ultrasonic-ajlu4cud` |
| `_TZE284_ap9owrsa` | `TS0601` | `sensors-soil-temp-moisture-battery-state-unit-soil-scaled` |
| `_TZE284_awepdiwi` | `TS0601` | `sensors-soil-neo-sth02b2` |
| `_TZE284_cwyqwqbf` | `TS0601` | `sensors-temp-humidity-battery-state-alarm-sensitivity-cwyqwqbf` |
| `_TZE284_d7lpruvi` | `TS0601` | `sensors-temp-humidity-battery-state-unit-th2aaa` |
| `_TZE284_g2e6cpnw` | `TS0601` | `sensors-soil-ts0601-soil2` |
| `_TZE284_hdml1aav` | `TS0601` | `sensors-soil-temp-humidity-moisture-illuminance-ec-battery-fertility-cal` |
| `_TZE284_hdyjyqjm` | `TS0601` | `sensors-temp-humidity-battery-state-unit-th2aaa` |
| `_TZE284_hodyryli` | `TS0601` | `sensors-temp-humidity-probe-battery-state-clock-zt08` |
| `_TZE284_it9utkro` | `TS0601` | `sensors-aq-co2-temp-humidity-voc-formaldehyde` |
| `_TZE284_k7p2q5d9` | `TS0601` | `sensors-soil-temp-humidity-moisture-illuminance-battery-warning` |
| `_TZE284_kdqrazmy` | `TS0601` | `sensors-temp-humidity-battery` |
| `_TZE284_ksz749x8` | `TS0601` | `sensors-temp-humidity-battery-state-unit-th2aaa` |
| `_TZE284_kyyu8rbj` | `TS0601` | `sensors-liquid-level-me201wz` |
| `_TZE284_locansqn` | `TS0601` | `sensors-temp-humidity-battery-alarm-sensitivity-nous-szt04` |
| `_TZE284_mpzuabwk` | `TS0601` | `sensors-temp-humidity-battery-alarm-sensitivity-lincukoo-szt04` |
| `_TZE284_mxujdmxo` | `TS0601` | `sensors-liquid-level-me202wz` |
| `_TZE284_myd45weu` | `TS0601` | `sensors-soil-temp-moisture-battery-state-unit-soil-raw` |
| `_TZE284_nhgdf6qr` | `TS0601` | `sensors-soil-temp-moisture-battery-state-unit-soil-scaled` |
| `_TZE284_nt4pquef` | `TS0601` | `sensors-soil-temp-moisture-battery-unit-illuminance-sgs02z` |
| `_TZE284_o9ofysmo` | `TS0601` | `sensors-soil-temp-humidity-moisture-battery-air-illum` |
| `_TZE284_oitavov2` | `TS0601` | `sensors-soil-temp-moisture-battery-state-unit-soil-raw` |
| `_TZE284_qyflbnbj` | `TS0601` | `sensors-temp-humidity-battery-state-qyfl` |
| `_TZE284_rjjsib2d` | `TS0601` | `sensors-temp-humidity-battery-state-calibration-zsn03p` |
| `_TZE284_rqcuwlsa` | `TS0601` | `sensors-soil-neo-sth02b2` |
| `_TZE284_rs62zxk8` | `TS0601` | `sensors-temp-humidity-battery-alarm-sensitivity-lincukoo-szt04` |
| `_TZE284_sgabhwa6` | `TS0601` | `sensors-soil-ts0601-soil2` |
| `_TZE284_tgrzpqf4` | `TS0601` | `sensors-soil-temp-moisture-battery-state-unit-soil-scaled` |
| `_TZE284_upagmta9` | `TS0601` | `sensors-temp-humidity-battery-state-unit-th2aaa` |
| `_TZE284_utkemkbs` | `TS0601` | `sensors-temp-humidity-battery-state-unit-th2aaa` |
| `_TZE284_vvmbj46n` | `TS0601` | `sensors-temp-humidity-battery-alarm-sensitivity-th-alarm` |
| `_TZE284_wckqztdq` | `TS0601` | `sensors-soil-temp-moisture-battery-state-unit-soil-scaled` |
| `_TZE284_wtikaxzs` | `TS0601` | `sensors-temp-humidity-battery-sensitivity-nous-e6` |
| `_TZE284_xc3vwx5a` | `TS0601` | `sensors-soil-temp-humidity-moisture-battery-air-illum` |
| `_TZE284_xpvamyfz` | `TS0601` | `sensors-aq-zr360cdb-co2-temp-humidity` |
| `_TZE284_yjjdcqsq` | `TS0601` | `sensors-temp-humidity-battery-state-unit-th2aaa` |
| `_TZE284_yzr43ayq` | `TS0601` | `sensors-soil-temp-humidity-moisture-illuminance-battery-warning` |
| `A89G12C` | `Arteco` | `sensors-soil-temp-humidity-moisture-illuminance-ec-battery-fertility-zssf00` |
| `AOYAN  ` | `AY-302Z` | `sensors-soil-temp-moisture-battery-dry` |
| `AOYAN  ` | `AY-303Z` | `sensors-soil-temp-humidity-moisture-battery-dry` |
| `Arteco` | `ZS-304Z` | `sensors-soil-temp-humidity-moisture-illuminance-battery-warning` |
| `DHT0001` | `Excellux` | `sensors-temp-humidity-battery-excellux-dht` |
| `DHTA001` | `Excellux` | `sensors-temp-humidity-battery-excellux-dht` |
| `DTS1XM9` | `Excellux` | `sensors-water-quality-excellux-dts1xm9` |
| `HOBEIAN` | `ZG-303Z` | `sensors-soil-temp-humidity-moisture-battery-warning-legacy` |
| `NTCHT01` | `Excellux` | `sensors-temp-humidity-probe-excellux-full` |
| `NTCHT02` | `Excellux` | `sensors-temp-humidity-probe-excellux-full` |
| `NTCHT03` | `Excellux` | `sensors-temp-humidity-probe-excellux-full` |

</details>

<details>
<summary>EF00 Switch Panel wonjj6768 (39 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports EF00 touch panel and scene panel switches.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZE200_0j5jma9b` | `TS0601` | `switches-switch-6-tyg3-sm` |
| `_TZE200_1ozguk6x` | `TS0601` | `switches-switch-4-zts-eu` |
| `_TZE200_amp6tsvy` | `TS0601` | `switches-switch-1-zts-eu` |
| `_TZE200_g1ib5ldv` | `TS0601` | `switches-switch-2-zts-eu` |
| `_TZE200_h2rctifa` | `TS0601` | `switches-switch-6-tyg3-sm` |
| `_TZE200_hewlydpz` | `TS0601` | `switches-switch-4-backlight-hewlydpz` |
| `_TZE200_k6jhsr0q` | `TS0601` | `switches-switch-4-tyg3-sm` |
| `_TZE200_nvodulvi` | `TS0601` | `switches-switch-8-m9-sl` |
| `_TZE200_rqhnxkqu` | `TS0601` | `switches-switch-6-to6` |
| `_TZE200_tviaymwx` | `TS0601` | `switches-switch-1-zts-eu` |
| `_TZE200_tz32mtza` | `TS0601` | `switches-switch-3-zts-eu` |
| `_TZE200_vhy3iakz` | `TS0601` | `switches-switch-3-tyg3-sm` |
| `_TZE200_wunufsil` | `TS0601` | `switches-switch-2-tyg3-sm` |
| `_TZE204_7ytnacie` | `TS0601` | `switches-switch-4-colored-backlight` |
| `_TZE204_adlblwab` | `TS0601` | `switches-switch-8-adlblwab` |
| `_TZE204_ccgyhbvd` | `TS0601` | `switches-switch-3-touch-panel` |
| `_TZE204_fhv95pf1` | `TS0601` | `switches-switch-1-stairwell` |
| `_TZE204_gm8h14wy` | `TS0601` | `switches-switch-1-touch-panel` |
| `_TZE204_he9apaui` | `TS0601` | `switches-switch-2-touch-panel` |
| `_TZE204_hewlydpz` | `TS0601` | `switches-switch-4-colored-backlight` |
| `_TZE204_rkbxtclc` | `TS0601` | `switches-switch-3-colored-backlight` |
| `_TZE204_unsxl4ir` | `TS0601` | `switches-switch-4-tyg3-sm` |
| `_TZE204_y8ficeai` | `TS0601` | `switches-switch-6-touch-panel` |
| `_TZE204_zqq3cipq` | `TS0601` | `switches-switch-16-pn16` |
| `_TZE284_0kihjsys` | `TS0601` | `switches-eyzee-5gang-countdown` |
| `_TZE284_7e6v8u9f` | `TS0601` | `switches-switch-1-multifunction` |
| `_TZE284_7zazvlyn` | `TS0601` | `switches-switch-4-f3-pro` |
| `_TZE284_atuj3i0w` | `TS0601` | `switches-switch-4-lcd-panel` |
| `_TZE284_hyssaqjk` | `TS0601` | `switches-switch-6-touch-panel` |
| `_TZE284_idn2htgu` | `TS0601` | `switches-switch-4-f3-pro` |
| `_TZE284_iwyqtclw` | `TS0601` | `switches-switch-4-lcd-panel` |
| `_TZE284_nvodulvi` | `TS0601` | `switches-switch-8-m9-sl` |
| `_TZE284_tokhh9pf` | `TS0601` | `switches-switch-6-touch-panel` |
| `_TZE284_yrwmnya3` | `TS0601` | `switches-switch-4-m9-sl` |
| `_TZE284_zpvusbtv` | `TS0601` | `switches-switch-2-colored-backlight` |
| `_TZE284_zqq3cipq` | `TS0601` | `switches-switch-16-pn16` |
| `Homeetec` | `37022714` | `switches-switch-4-backlight-hewlydpz` |
| `Nova Digital` | `FZB-4` | `switches-switch-4-tyg3-sm` |
| `TZE204_unsxl4ir` | `TS0601` | `switches-switch-4-tyg3-sm` |

</details>

<details>
<summary>EF00 Switch wonjj6768 (111 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports EF00 relay switches and plugs.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZ3000_uim07oem` | `TS0601` | `switches-switch-4` |
| `_TZ3218_7fiyo3kv` | `TS000F` | `switches-switch-1-temp-humidity` |
| `_TZ3218_ya5d6wth` | `TS000F` | `switches-switch-4-temp-humidity` |
| `_TZE200_1n2kyphz` | `TS0601` | `switches-switch-4` |
| `_TZE200_2hf7x9n3` | `TS0601` | `switches-switch-3` |
| `_TZE200_2imwyigp` | `TS0601` | `switches-switch-3` |
| `_TZE200_3t91nb6k` | `TS0601` | `switches-switch-2` |
| `_TZE200_6wi2mope` | `TS0601` | `switches-switch-4` |
| `_TZE200_7deq70b8` | `TS0601` | `switches-switch-2` |
| `_TZE200_7sjncirf` | `TS0601` | `switches-switch-10` |
| `_TZE200_7tdtqgwv` | `TS0601` | `switches-switch-1` |
| `_TZE200_8eazvzo6` | `TS0601` | `switches-switch-6-power-voltage-current` |
| `_TZE200_8vxj8khv` | `TS0601` | `switches-switch-1` |
| `_TZE200_9mahtqtg` | `TS0601` | `switches-switch-6` |
| `_TZE200_aqnazj70` | `TS0601` | `switches-switch-4` |
| `_TZE200_atpwqgml` | `TS0601` | `switches-switch-3` |
| `_TZE200_bynnczcb` | `TS0601` | `switches-switch-3` |
| `_TZE200_cduqh1l0` | `TS0601` | `switches-switch-6` |
| `_TZE200_dhdstcqc` | `TS0601` | `switches-switch-2` |
| `_TZE200_di3tfv5b` | `TS0601` | `switches-switch-4` |
| `_TZE200_emxxanvi` | `TS0601` | `switches-switch-6` |
| `_TZE200_fqytfymk` | `TS0601` | `switches-switch-3` |
| `_TZE200_gbagoilo` | `TS0601` | `switches-switch-1-power-voltage-current-mg-zg01w` |
| `_TZE200_go3tvswy` | `TS0601` | `switches-switch-3` |
| `_TZE200_ji1gn7rw` | `TS0601` | `switches-switch-2` |
| `_TZE200_js3mgbjb` | `TS0601` | `switches-switch-4` |
| `_TZE200_jwsjbxjs` | `TS0601` | `switches-switch-5` |
| `_TZE200_kyfqmmyl` | `TS0601` | `switches-switch-3` |
| `_TZE200_leaqthqq` | `TS0601` | `switches-switch-5` |
| `_TZE200_mexisfik` | `TS0601` | `switches-switch-4` |
| `_TZE200_mwvfvw8g` | `TS0601` | `switches-switch-6` |
| `_TZE200_nh9m9emk` | `TS0601` | `switches-switch-2` |
| `_TZE200_nkjintbl` | `TS0601` | `switches-switch-2` |
| `_TZE200_oisqyl4o` | `TS0601` | `switches-switch-1` |
| `_TZE200_ojtqawav` | `TS0601` | `switches-switch-1` |
| `_TZE200_oyti2ums` | `TS0601` | `switches-switch-4-energy-voltage-current` |
| `_TZE200_r731zlxk` | `TS0601` | `switches-switch-6` |
| `_TZE200_raz9qavg` | `TS0601` | `switches-switch-6` |
| `_TZE200_shkxsgis` | `TS0601` | `switches-switch-4` |
| `_TZE200_vmcgja59` | `TS0601` | `switches-switch-8` |
| `_TZE200_wktrysab` | `TS0601` | `switches-switch-8` |
| `_TZE200_wnp4d4va` | `TS0601` | `switches-switch-6` |
| `_TZE200_wvovwe9h` | `TS0601` | `switches-switch-2` |
| `_TZE204_2imwyigp` | `TS0601` | `switches-switch-3` |
| `_TZE204_3t91nb6k` | `TS0601` | `switches-switch-2` |
| `_TZE204_58of2pfn` | `TS0601` | `switches-switch-4` |
| `_TZE204_6wi2mope` | `TS0601` | `switches-switch-4` |
| `_TZE204_72bewjky` | `TS0601` | `switches-switch-8` |
| `_TZE204_aagrxlbd` | `TS0601` | `switches-switch-4` |
| `_TZE204_ad2jkxwh` | `TS0601` | `switches-switch-8` |
| `_TZE204_apiu8k13` | `TS0601` | `switches-switch-1-power-energy-voltage-current-apiu` |
| `_TZE204_atpwqgml` | `TS0601` | `switches-switch-3` |
| `_TZE204_cduqh1l0` | `TS0601` | `switches-switch-6` |
| `_TZE204_dqolcpcp` | `TS0601` | `switches-switch-12` |
| `_TZE204_dvosyycn` | `TS0601` | `switches-switch-8` |
| `_TZE204_f5efvtbv` | `TS0601` | `switches-switch-4` |
| `_TZE204_g4au0afs` | `TS0601` | `switches-switch-6` |
| `_TZE204_gbagoilo` | `TS0601` | `switches-switch-1` |
| `_TZE204_gxbdnfrh` | `TS0601` | `switches-switch-6` |
| `_TZE204_hiith90n` | `TS0601` | `switches-switch-1` |
| `_TZE204_iik0pquw` | `TS0601` | `switches-switch-4` |
| `_TZE204_l8xiyymq` | `TS0601` | `switches-switch-6` |
| `_TZE204_lbhh5o6z` | `TS0601` | `switches-switch-4` |
| `_TZE204_lmgrbuwf` | `TS0601` | `switches-switch-6` |
| `_TZE204_mexisfik` | `TS0601` | `switches-switch-4` |
| `_TZE204_mvtclclq` | `TS0601` | `switches-switch-4-energy-voltage-current-usb` |
| `_TZE204_ncti2pro` | `TS0601` | `switches-switch-6` |
| `_TZE204_nh9m9emk` | `TS0601` | `switches-switch-2` |
| `_TZE204_nvxorhcj` | `TS0601` | `switches-switch-8` |
| `_TZE204_ojtqawav` | `TS0601` | `switches-switch-1` |
| `_TZE204_ptaqh9tk` | `TS0601` | `switches-switch-1` |
| `_TZE204_r731zlxk` | `TS0601` | `switches-switch-6` |
| `_TZE204_shkxsgis` | `TS0601` | `switches-switch-4` |
| `_TZE204_tdhnhhiy` | `TS0601` | `switches-switch-8` |
| `_TZE204_vmcgja59` | `TS0601` | `switches-switch-24` |
| `_TZE204_w1wwxoja` | `TS0601` | `switches-switch-6` |
| `_TZE204_wktrysab` | `TS0601` | `switches-switch-8` |
| `_TZE204_wskr3up8` | `TS0601` | `switches-switch-6` |
| `_TZE204_wvovwe9h` | `TS0601` | `switches-switch-2` |
| `_TZE21C_dohbhb5k` | `TS0001` | `switches-switch-1-temperature` |
| `_TZE21C_i2ij4rb3` | `TS0001` | `switches-switch-1-temp-humidity-scimagic` |
| `_TZE284_dqolcpcp` | `TS0601` | `switches-switch-12` |
| `_TZE284_dvosyycn` | `TS0601` | `switches-switch-8` |
| `_TZE284_f5efvtbv` | `TS0601` | `switches-switch-4` |
| `_TZE284_g1enhdsi` | `TS0601` | `switches-switch-6` |
| `_TZE284_kow4ok3t` | `TS0601` | `switches-switch-8` |
| `_TZE284_l8xiyymq` | `TS0601` | `switches-switch-6` |
| `_TZE284_lbhh5o6z` | `TS0601` | `switches-switch-4` |
| `_TZE284_mvtclclq` | `TS0601` | `switches-switch-4-energy-voltage-current-usb` |
| `_TZE284_r731zlxk` | `TS0601` | `switches-switch-6` |
| `_TZE284_roujjevx` | `TS0601` | `switches-switch-1-temperature-roujjevx` |
| `_TZE284_tdhnhhiy` | `TS0601` | `switches-switch-6` |
| `_TZE284_vmcgja59` | `TS0601` | `switches-switch-24` |
| `_TZE284_xnwxmj8z` | `TS0601` | `switches-switch-1-power-voltage-current-mg-zg01w` |
| `_TZE284_zeldawjv` | `TS0601` | `switches-switch-6` |
| `AVATTO` | `WSMD-4` | `switches-switch-4` |
| `AVATTO` | `ZGB-WS-EU` | `switches-switch-1` |
| `AVATTO` | `ZWSMD-4` | `switches-switch-4` |
| `Ekaza` | `EKAT-T3074-6WZ` | `switches-switch-6` |
| `Mercator Ikuü` | `SSW06G` | `switches-switch-6` |
| `Moes` | `WS-EUB1-ZG` | `switches-switch-1` |
| `Norklmes` | `MKS-CM-W5` | `switches-switch-1` |
| `Nova Digital` | `FZB-6` | `switches-switch-6` |
| `Nova Digital` | `NTZB-04-W-B` | `switches-switch-6` |
| `Nova Digital` | `SA-6` | `switches-switch-6` |
| `Nova Digital` | `SYZB-6W` | `switches-switch-6` |
| `Shawader` | `SMKG-1KNL-US/TZB-W` | `switches-switch-1` |
| `Somgoms` | `ZSQB-SMB-ZB` | `switches-switch-1` |
| `Tuya` | `MG-ZG04W` | `switches-switch-4` |
| `TZE204_7sjncirf` | `TS0601` | `switches-switch-10` |
| `ZYXH` | `TY-04Z` | `switches-switch-4` |

</details>

<details>
<summary>EF00 Thermostat FCU wonjj6768 (40 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports EF00 fan coil unit and legacy thermostats.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TYST11_2dpplnsn` | `dpplnsn` | `thermostats-thermostat-etop` |
| `_TYST11_c88teujp` | `88teujp` | `thermostats-thermostat-saswell` |
| `_TYST11_caj4jz0i` | `aj4jz0i` | `thermostats-thermostat-saswell` |
| `_TYST11_KGbxAXL2` | `GbxAXL2` | `thermostats-thermostat-saswell` |
| `_TYST11_wv90ladg` | `v90ladg` | `thermostats-thermostat-etop` |
| `_TYST11_yw7cahqs` | `w7cahqs` | `thermostats-thermostat-saswell` |
| `_TYST11_zuhszj9s` | `uhszj9s` | `thermostats-thermostat-saswell` |
| `_TZE200_0dvm9mva` | `TS0601` | `thermostats-thermostat-saswell` |
| `_TZE200_1drr8tab` | `TS0601` | `thermostats-fcu-thermostat-xz-akt101` |
| `_TZE200_2dpplnsn` | `TS0601` | `thermostats-thermostat-etop` |
| `_TZE200_3yp57tby` | `TS0601` | `thermostats-thermostat-saswell` |
| `_TZE200_7p8ugv8d` | `TS0601` | `thermostats-thermostat-saswell` |
| `_TZE200_9gvruqf5` | `TS0601` | `thermostats-thermostat-saswell` |
| `_TZE200_9m4kmbfu` | `TS0601` | `thermostats-thermostat-saswell` |
| `_TZE200_azqp6ssj` | `TS0601` | `thermostats-thermostat-saswell` |
| `_TZE200_c88teujp` | `TS0601` | `thermostats-thermostat-saswell` |
| `_TZE200_dzuqwsyg` | `TS0601` | `thermostats-fcu-thermostat-bac003` |
| `_TZE200_exfrnlow` | `TS0601` | `thermostats-thermostat-saswell` |
| `_TZE200_gd4rvykv` | `TS0601` | `thermostats-thermostat-saswell` |
| `_TZE200_h4cgnbzg` | `TS0601` | `thermostats-thermostat-saswell` |
| `_TZE200_snfdqllf` | `TS0601` | `thermostats-fcu-thermostat-aetz01-ac` |
| `_TZE200_wem3gxyx` | `TS0601` | `thermostats-fcu-thermostat-ae940k` |
| `_TZE200_wv90ladg` | `TS0601` | `thermostats-thermostat-etop` |
| `_TZE200_xixlazkg` | `TS0601` | `thermostats-fcu-thermostat-xixlazkg` |
| `_TZE200_yw7cahqs` | `TS0601` | `thermostats-thermostat-saswell` |
| `_TZE200_zr9c0day` | `TS0601` | `thermostats-thermostat-saswell` |
| `_TZE200_zuhszj9s` | `TS0601` | `thermostats-thermostat-saswell` |
| `_TZE204_dzuqwsyg` | `TS0601` | `thermostats-fcu-thermostat-bac003` |
| `_TZE204_ilzkxrav` | `TS0601` | `thermostats-thermostat-basic-twc-r01` |
| `_TZE204_mpbki2zm` | `TS0601` | `thermostats-fcu-thermostat-tybac006` |
| `_TZE204_mul9abs3` | `TS0601` | `thermostats-fcu-thermostat-ae669k` |
| `_TZE204_q12rv9gj` | `TS0601` | `thermostats-fcu-thermostat-hhst001` |
| `_TZE204_qujphad5` | `TS0601` | `thermostats-fcu-thermostat-tybac006` |
| `_TZE284_0dvm9mva` | `TS0601` | `thermostats-thermostat-saswell` |
| `_TZE284_3yp57tby` | `TS0601` | `thermostats-thermostat-saswell` |
| `_TZE284_4vbj3fxh` | `TS0601` | `thermostats-fcu-thermostat-l2-t-f-mf` |
| `_TZE284_9m4kmbfu` | `TS0601` | `thermostats-thermostat-saswell` |
| `_TZE284_madl8ejv` | `TS0601` | `thermostats-thermostat-sas936` |
| `_TZE284_mul9abs3` | `TS0601` | `thermostats-fcu-thermostat-ae720k` |
| `Tuya` | `BAC-003` | `thermostats-fcu-thermostat-bac003` |

</details>

<details>
<summary>EF00 Thermostat TRV 1 wonjj6768 (71 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports EF00 thermostatic radiator valves (group 1 of 2). See the README fingerprint table for the exact device list.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TYST11_8daqwrsj` | `daqwrsj` | `thermostats-alecto-smart-heat10` |
| `_TZE200_04yfvweb` | `TS0601` | `thermostats-siterwell-gs361a` |
| `_TZE200_2atgpdho` | `TS0601` | `thermostats-thermostat-classic-trv` |
| `_TZE200_2cs6g9i7` | `TS0601` | `thermostats-siterwell-gs361a` |
| `_TZE200_4eeyebrt` | `TS0601` | `thermostats-thermostat-classic-trv` |
| `_TZE200_4utwoz2` | `TS0601` | `thermostats-thermostat-trv06` |
| `_TZE200_4utwozi2` | `TS0601` | `thermostats-thermostat-trv06` |
| `_TZE200_6rdj8dzm` | `TS0601` | `thermostats-thermostat-trv06` |
| `_TZE200_7fqkphoq` | `TS0601` | `thermostats-thermostat-classic-trv` |
| `_TZE200_8daqwrsj` | `TS0601` | `thermostats-alecto-smart-heat10` |
| `_TZE200_8thwkzxl` | `TS0601` | `thermostats-thermostat-classic-trv` |
| `_TZE200_8whxpsiw` | `TS0601` | `thermostats-thermostat-classic-trv` |
| `_TZE200_9sfg7gm0` | `TS0601` | `thermostats-thermostat-classic-trv` |
| `_TZE200_9xfjixap` | `TS0601` | `thermostats-thermostat-trv06` |
| `_TZE200_a4bpgplm` | `TS0601` | `thermostats-thermostat-trv1` |
| `_TZE200_bvrlmajk` | `TS0601` | `thermostats-thermostat-trv1` |
| `_TZE200_bvu2wnxz` | `TS0601` | `thermostats-thermostat-trv06` |
| `_TZE200_ckud7u2l` | `TS0601` | `thermostats-thermostat-classic-trv` |
| `_TZE200_cpmgn2cf` | `TS0601` | `thermostats-thermostat-classic-trv` |
| `_TZE200_cwnjrr72` | `TS0601` | `thermostats-thermostat-classic-trv` |
| `_TZE200_d3z1ukqw` | `TS0601` | `thermostats-thermostat-trv06` |
| `_TZE200_do5qy8zo` | `TS0601` | `thermostats-thermostat-classic-trv` |
| `_TZE200_dv8abrrz` | `TS0601` | `thermostats-thermostat-trv1` |
| `_TZE200_hhrtiq0x` | `TS0601` | `thermostats-siterwell-gs361a` |
| `_TZE200_hvaxb2tc` | `TS0601` | `thermostats-thermostat-trv06b` |
| `_TZE200_jeaxp72v` | `TS0601` | `thermostats-siterwell-gs361a` |
| `_TZE200_jkfbph7l` | `TS0601` | `thermostats-thermostat-trv06` |
| `_TZE200_kfvq6avy` | `TS0601` | `thermostats-siterwell-gs361a` |
| `_TZE200_khah2lkr` | `TS0601` | `thermostats-thermostat-hy607w` |
| `_TZE200_lpwgshtl` | `TS0601` | `thermostats-thermostat-classic-trv` |
| `_TZE200_lrznf59v` | `TS0601` | `thermostats-siterwell-gs361a` |
| `_TZE200_ow09xlxm` | `TS0601` | `thermostats-thermostat-trv06` |
| `_TZE200_owwdxjbx` | `TS0601` | `thermostats-siterwell-gs361a` |
| `_TZE200_p3dbf6qs` | `TS0601` | `thermostats-thermostat-trv06b` |
| `_TZE200_ps5v5jor` | `TS0601` | `thermostats-siterwell-gs361a` |
| `_TZE200_pvvbommb` | `TS0601` | `thermostats-thermostat-classic-trv` |
| `_TZE200_qjp4ynvi` | `TS0601` | `thermostats-thermostat-classic-trv` |
| `_TZE200_rk1wojce` | `TS0601` | `thermostats-thermostat-classic-trv` |
| `_TZE200_rndg81sf` | `TS0601` | `thermostats-thermostat-classic-trv` |
| `_TZE200_rufdtfyv` | `TS0601` | `thermostats-thermostat-classic-trv` |
| `_TZE200_rv6iuyxb` | `TS0601` | `thermostats-thermostat-trv06` |
| `_TZE200_rxntag7i` | `TS0601` | `thermostats-thermostat-trv06` |
| `_TZE200_rxq4iti9` | `TS0601` | `thermostats-thermostat-trv06` |
| `_TZE200_suxywabt` | `TS0601` | `thermostats-thermostat-trv06` |
| `_TZE200_tbgecldg` | `TS0601` | `thermostats-thermostat-tbgecldg` |
| `_TZE200_xby0s3ta` | `TS0601` | `thermostats-thermostat-classic-trv` |
| `_TZE200_yqgbrdyo` | `TS0601` | `thermostats-thermostat-trv06` |
| `_TZE200_ywdxldoj` | `TS0601` | `thermostats-thermostat-classic-trv` |
| `_TZE200_z1tyspqw` | `TS0601` | `thermostats-thermostat-trv1` |
| `_TZE200_zivfvd7h` | `TS0601` | `thermostats-siterwell-gs361a` |
| `_TZE200_znlqjmih` | `TS0601` | `thermostats-thermostat-classic-trv` |
| `_TZE204_atdqo4nj` | `TS0601` | `thermostats-thermostat-zg-wk-da` |
| `_TZE204_cvub6xbb` | `TS0601` | `thermostats-thermostat-tgm50` |
| `_TZE204_g2ki0ejr` | `TS0601` | `thermostats-thermostat-g2ki0ejr` |
| `_TZE204_m5r5nlxc` | `TS0601` | `thermostats-thermostat-thah202001` |
| `_TZE204_mwomyz5n` | `TS0601` | `thermostats-thermostat-tgm50` |
| `_TZE204_o3x45p96` | `TS0601` | `thermostats-thermostat-trv06` |
| `_TZE204_ogx8u5z6` | `TS0601` | `thermostats-thermostat-trv06` |
| `_TZE204_tbgecldg` | `TS0601` | `thermostats-thermostat-tbgecldg` |
| `_TZE204_woww89ip` | `TS0601` | `thermostats-siterwell-gs361a` |
| `_TZE204_xalsoe3m` | `TS0601` | `thermostats-thermostat-zht002` |
| `_TZE284_c6wv4xyo` | `TS0601` | `thermostats-thermostat-trv06` |
| `_TZE284_cgr0rhza` | `TS0601` | `thermostats-thermostat-cgr0rhza` |
| `_TZE284_cvub6xbb` | `TS0601` | `thermostats-thermostat-tgm50` |
| `_TZE284_o3x45p96` | `TS0601` | `thermostats-thermostat-trv06` |
| `_TZE284_ogx8u5z6` | `TS0601` | `thermostats-thermostat-trv06` |
| `_TZE284_p3dbf6qs` | `TS0601` | `thermostats-thermostat-trv06` |
| `_TZE284_rv6iuyxb` | `TS0601` | `thermostats-thermostat-trv06` |
| `_TZE284_tbgecldg` | `TS0601` | `thermostats-thermostat-tbgecldg` |
| `_TZE284_ymldrmzx` | `TS0601` | `thermostats-thermostat-trv603wz` |
| `_TZE284_znlqjmih` | `TS0601` | `thermostats-thermostat-classic-trv` |

</details>

<details>
<summary>EF00 Thermostat TRV 2 wonjj6768 (34 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports EF00 thermostatic radiator valves (group 2 of 2). See the README fingerprint table for the exact device list.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZE200_0hg58wyk` | `TS0601` | `thermostats-thermostat-s366` |
| `_TZE200_7yoranx2` | `TS0601` | `thermostats-thermostat-tv02` |
| `_TZE200_9mjy74mp` | `TS0601` | `thermostats-thermostat-trv602` |
| `_TZE200_e9ba97vf` | `TS0601` | `thermostats-thermostat-tv02` |
| `_TZE200_eo6xhfbo` | `TS0601` | `thermostats-thermostat-gtz10` |
| `_TZE200_fsow0qsk` | `TS0601` | `thermostats-thermostat-tv02` |
| `_TZE200_hue3yfsn` | `TS0601` | `thermostats-thermostat-tv02` |
| `_TZE200_husqqvux` | `TS0601` | `thermostats-thermostat-tv02` |
| `_TZE200_k1tumq4t` | `TS0601` | `thermostats-thermostat-tv02` |
| `_TZE200_kds0pmmv` | `TS0601` | `thermostats-thermostat-tv02` |
| `_TZE200_lhzapfg9` | `TS0601` | `thermostats-thermostat-tv02` |
| `_TZE200_lllliz3p` | `TS0601` | `thermostats-thermostat-tv02` |
| `_TZE200_lnbfnyxd` | `TS0601` | `thermostats-thermostat-tv02` |
| `_TZE200_mudxchsu` | `TS0601` | `thermostats-thermostat-tv02` |
| `_TZE200_pbo8cj0z` | `TS0601` | `thermostats-thermostat-gtz10` |
| `_TZE200_py4cm3he` | `TS0601` | `thermostats-thermostat-tv02` |
| `_TZE200_rtrmfadk` | `TS0601` | `thermostats-thermostat-trv602` |
| `_TZE200_sur6q7ko` | `TS0601` | `thermostats-thermostat-tv02` |
| `_TZE200_wsbfwodu` | `TS0601` | `thermostats-thermostat-tv02` |
| `_TZE200_x9axofse` | `TS0601` | `thermostats-thermostat-tv02` |
| `_TZE204_9mjy74mp` | `TS0601` | `thermostats-thermostat-trv602` |
| `_TZE204_cvcu2p6e` | `TS0601` | `thermostats-thermostat-trv601` |
| `_TZE204_eekpf0ft` | `TS0601` | `thermostats-thermostat-tr-m3z` |
| `_TZE204_ltwbm23f` | `TS0601` | `thermostats-thermostat-trv602z` |
| `_TZE204_pcdmj88b` | `TS0601` | `thermostats-thermostat-trv4` |
| `_TZE204_qyr2m29i` | `TS0601` | `thermostats-thermostat-trv602z` |
| `_TZE204_rtrmfadk` | `TS0601` | `thermostats-thermostat-trv601` |
| `_TZE204_vjpaih9f` | `TS0601` | `thermostats-thermostat-trv14` |
| `_TZE284_eekpf0ft` | `TS0601` | `thermostats-thermostat-tr-m3z` |
| `_TZE284_ltwbm23f` | `TS0601` | `thermostats-thermostat-trv602z` |
| `_TZE284_nbv4tdaz` | `TS0601` | `thermostats-thermostat-battery-ar331pro` |
| `_TZE284_noixx2uz` | `TS0601` | `thermostats-thermostat-battery-ar331` |
| `_TZE284_pcdmj88b` | `TS0601` | `thermostats-thermostat-trv4` |
| `_TZE284_vjpaih9f` | `TS0601` | `thermostats-thermostat-trv14` |

</details>

<details>
<summary>EF00 Thermostat Wall wonjj6768 (43 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports EF00 wall and floor thermostats.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZE200_2ekuz3dz` | `TS0601` | `thermostats-thermostat-x5h` |
| `_TZE200_5toc8efa` | `TS0601` | `thermostats-bht002-fine` |
| `_TZE200_aoclfnxz` | `TS0601` | `thermostats-bht002-fine` |
| `_TZE200_edl8pz1k` | `TS0601` | `thermostats-thermostat-floor` |
| `_TZE200_g9a3awaj` | `TS0601` | `thermostats-thermostat-zwt07` |
| `_TZE200_ha0vwoew` | `TS0601` | `thermostats-thermostat-thermosphere` |
| `_TZE200_spyvfeti` | `TS0601` | `thermostats-thermostat-floor` |
| `_TZE200_u9bfwha0` | `TS0601` | `thermostats-bht002-fine` |
| `_TZE200_viy9ihs7` | `TS0601` | `thermostats-thermostat-zwt198` |
| `_TZE200_ye5jkfsb` | `TS0601` | `thermostats-bht002-fine` |
| `_TZE200_znzs7yaw` | `TS0601` | `thermostats-thermostat-hy08we` |
| `_TZE200_ztvwu4nk` | `TS0601` | `thermostats-bht002-fine` |
| `_TZE204_0hcjew5p` | `TS0601` | `thermostats-thermostat-pilot-wire-no-operating` |
| `_TZE204_3q3maeoo` | `TS0601` | `thermostats-thermostat-pilot-wire-no-operating` |
| `_TZE204_3regm3h6` | `TS0601` | `thermostats-thermostat-pilot-wire-no-operating` |
| `_TZE204_5toc8efa` | `TS0601` | `thermostats-bht002-half` |
| `_TZE204_6a4vxfnv` | `TS0601` | `thermostats-thermostat-floor` |
| `_TZE204_6kijc7nd` | `TS0601` | `thermostats-thermostat-tervix` |
| `_TZE204_6vwfjkcj` | `TS0601` | `thermostats-thermostat-pilot-wire-no-operating` |
| `_TZE204_aaeaifez` | `TS0601` | `thermostats-thermostat-zwt100` |
| `_TZE204_aoclfnxz` | `TS0601` | `thermostats-bht002-whole` |
| `_TZE204_d6i25bwg` | `TS0601` | `thermostats-thermostat-pilot-wire-no-operating` |
| `_TZE204_edl8pz1k` | `TS0601` | `thermostats-thermostat-floor` |
| `_TZE204_gops3slb` | `TS0601` | `thermostats-thermostat-zwt198` |
| `_TZE204_lzriup1j` | `TS0601` | `thermostats-thermostat-zwt198` |
| `_TZE204_oh8y8pv8` | `TS0601` | `thermostats-thermostat-zwt198` |
| `_TZE204_ouy7vpm1` | `TS0601` | `thermostats-thermostat-pilot-wire-no-operating` |
| `_TZE204_tagezcph` | `TS0601` | `thermostats-thermostat-pro900z` |
| `_TZE204_u9bfwha0` | `TS0601` | `thermostats-bht002-fine` |
| `_TZE204_wc2w9t1s` | `TS0601` | `thermostats-thermostat-bot-r9v` |
| `_TZE204_xnbkhhdr` | `TS0601` | `thermostats-thermostat-zwt198` |
| `_TZE204_zjhoqbrd` | `TS0601` | `thermostats-thermostat-zwt198` |
| `_TZE284_3regm3h6` | `TS0601` | `thermostats-thermostat-pilot-wire-no-operating` |
| `_TZE284_6kijc7nd` | `TS0601` | `thermostats-thermostat-tervix` |
| `_TZE284_aaeaifez` | `TS0601` | `thermostats-thermostat-zwt100` |
| `_TZE284_agcxaw3f` | `TS0601` | `thermostats-thermostat-battery-bot-r15w` |
| `_TZE284_gops3slb` | `TS0601` | `thermostats-thermostat-zwt198` |
| `_TZE284_khah2lkr` | `TS0601` | `thermostats-thermostat-khah2lkr` |
| `_TZE284_xnbkhhdr` | `TS0601` | `thermostats-thermostat-zwt198` |
| `_TZE284_ye5jkfsb` | `TS0601` | `thermostats-bht002-fine` |
| `_TZE284_zjhoqbrd` | `TS0601` | `thermostats-thermostat-zwt198` |
| `_TZE28C1000000_aaeaifez` | `TS0601` | `thermostats-thermostat-zwt100` |
| `AVATTO` | `WT-100-BH` | `thermostats-thermostat-zwt198` |

</details>

<details>
<summary>EF00 Valves wonjj6768 (30 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports EF00 water valves, gas valves, and irrigation controllers.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZE200_1n2zev06` | `TS0601` | `valves-valve-threshold-timer-fkv02` |
| `_TZE200_2wg5qrjy` | `TS0601` | `valves-valve-battery-timer-zvg1` |
| `_TZE200_5uodvhgc` | `TS0601` | `valves-valve-threshold-timer-fkv02` |
| `_TZE200_81isopgh` | `TS0601` | `valves-valve-battery-timer-zvg1` |
| `_TZE200_akjefhj5` | `TS0601` | `valves-valve-battery-timer-zvg1` |
| `_TZE200_fphxkxue` | `TS0601` | `valves-valve-battery-countdown-zvl-pro` |
| `_TZE200_hbnfokum` | `TS0601` | `valves-valve-position-hbnfokum` |
| `_TZE200_vuwtqx0t` | `TS0601` | `valves-valve-ultrasonic-meter` |
| `_TZE200_wt9agwf3` | `TS0601` | `valves-valve-threshold-timer-fkv02` |
| `_TZE204_4fblxpma` | `TS0601` | `valves-nas-wv03b-gallons-no-on-countdown` |
| `_TZE204_dsagrkvg` | `TS0601` | `valves-valve-battery-state-zpv01` |
| `_TZE204_nnhwcvbk` | `TS0601` | `valves-nas-wv03b-gallons` |
| `_TZE204_qtnjuoae` | `TS0601` | `valves-valve-battery-timer-zvg1` |
| `_TZE204_rzrrjkz2` | `TS0601` | `valves-nas-wv03b-gallons` |
| `_TZE204_uab532m0` | `TS0601` | `valves-nas-wv03b-gallons` |
| `_TZE204_z7a2jmyy` | `TS0601` | `valves-nas-wv03b-liters` |
| `_TZE284_4fblxpma` | `TS0601` | `valves-nas-wv03b-gallons-no-on-countdown` |
| `_TZE284_8zizsafo` | `TS0601` | `valves-valve-2-battery-timer-gx03` |
| `_TZE284_eaet5qt5` | `TS0601` | `valves-valve-2-battery-status` |
| `_TZE284_fhvpaltk` | `TS0601` | `valves-valve-2-battery-status` |
| `_TZE284_iilebqoo` | `TS0601` | `valves-valve-2-battery-timer-gx03` |
| `_TZE284_nnhwcvbk` | `TS0601` | `valves-nas-wv03b-gallons` |
| `_TZE284_qtnjuoae` | `TS0601` | `valves-valve-battery-timer-zvg1` |
| `_TZE284_rzrrjkz2` | `TS0601` | `valves-nas-wv03b-gallons` |
| `_TZE284_sdvbnmj5` | `TS0601` | `valves-valve-battery-state-zpv01` |
| `_TZE284_uab532m0` | `TS0601` | `valves-nas-wv03b-gallons` |
| `_TZE284_vuwtqx0t` | `TS0601` | `valves-valve-ultrasonic-meter` |
| `_TZE284_xuflgcnz` | `TS0601` | `valves-valve-battery-timer-zvg1` |
| `_TZE284_z7a2jmyy` | `TS0601` | `valves-nas-wv03b-liters` |
| `_TZE284_zm8zpwas` | `TS0601` | `valves-valve-battery-state-zpv01` |

</details>

<details>
<summary>Z2M EF00 Bridge wonjj6768 (2 fingerprints)</summary>

Dedicated driver for newly absorbed exact EF00 bridge fingerprints.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZE204_6fk3gewc` | `TS0601` | `bridges-wave19-weten-pci-e` |
| `_TZE284_6fk3gewc` | `TS0601` | `bridges-wave19-weten-pci-e` |

</details>

<details>
<summary>Z2M EF00 Controls Category wonjj6768 (15 fingerprints)</summary>

Category driver for newly absorbed exact EF00 remotes, keypads, and button-control fingerprints.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZE200_lhpnrfmy` | `TS0601` | `controls-wave19-box-erc2201-z` |
| `_TZE200_moycceze` | `TS0601` | `controls-wave18-immax-07505l` |
| `_TZE200_n9clpsht` | `TS0601` | `controls-wave18-immax-07505l` |
| `_TZE200_nyvavzbj` | `TS0601` | `controls-wave18-immax-07505l` |
| `_TZE200_oahqgdig` | `TS0601` | `controls-wave15-engo-ecb62zb` |
| `_TZE200_rt5dklro` | `TS0601` | `controls-wave18-daewoo-wke502z` |
| `_TZE200_zaabefnt` | `TS0601` | `controls-wave15-engo-ecb62zb` |
| `_TZE200_zqtiam4u` | `TS0601` | `controls-wave19-zemismart-zm-rm02` |
| `_TZE284_1aqlsquf` | `TS0601` | `controls-wave19-qa-qat42z2b` |
| `_TZE284_chcnj5st` | `TS0601` | `controls-wave17-lincukoo-czf02` |
| `_TZE284_gw05grph` | `TS0601` | `controls-wave17-lincukoo-czf02` |
| `_TZE284_ms97nkyy` | `TS0601` | `controls-wave19-qa-qat44z6` |
| `_TZE284_pgxndxp4` | `TS0601` | `controls-wave19-qa-qat42z3b` |
| `_TZE284_pislt0wa` | `TS0601` | `controls-wave17-lincukoo-czf02` |
| `_TZE28C1000000_jlbsptkl` | `TS0601` | `controls-wave19-tuya-presence-switch` |

</details>

<details>
<summary>Z2M EF00 Covers Category wonjj6768 (18 fingerprints)</summary>

Category driver for newly absorbed exact EF00 cover fingerprints.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZ3210_5rta89nj` | `TS0601` | `covers-wave10-moes-zc-lp01` |
| `_TZ3210_rundhkxp` | `TS030F` | `covers-wave10-moes-adcbzi01` |
| `_TZ3210_sxtfesc6` | `TS030F` | `covers-wave10-moes-adcbzi01` |
| `_TZE200_ra6wrlgv` | `TS0601` | `covers-wave15-box-erc2206z` |
| `_TZE200_sbordckq` | `TS0601` | `covers-wave19-legacy-tuya` |
| `_TZE200_swhwv3k3` | `TS0601` | `covers-wave19-legacy-tuya` |
| `_TZE200_xtrnjaoz` | `TS0601` | `covers-cover-gm25teq` |
| `_TZE204_7lb6j8wg` | `TS0601` | `covers-wave15-tuya-semicom-three` |
| `_TZE204_mpg22jc1` | `TS0601` | `covers-wave10-zemismart-zn-usc1u-ht` |
| `_TZE204_srmahpwl` | `TS0601` | `covers-wave10-moes-zs-sr-euc` |
| `_TZE204_xtrnjaoz` | `TS0601` | `covers-cover-gm25teq` |
| `_TZE210_xgzzuerd` | `TS0301` | `covers-wave10-tuya-ts0301-cover-two` |
| `_TZE284_6hrnp30w` | `TS0601` | `covers-wave10-zemismart-zmp1` |
| `_TZE284_7qc2wlqr` | `TS0601` | `covers-wave10-manhot-bl82-tyz1` |
| `_TZE284_8whfphjv` | `TS0601` | `covers-cover-gm25teq` |
| `_TZE284_hbjwgkdh` | `TS0601` | `covers-wave10-xenon-x7726` |
| `_TZE284_qoi1aqxg` | `TS0601` | `covers-wave10-moes-fwjzceh18a001` |
| `_TZE284_upt8lzi0` | `TS0601` | `covers-cover-moes-zs-sf-euc-wh-ms` |

</details>

<details>
<summary>Z2M EF00 Lights Category wonjj6768 (26 fingerprints)</summary>

Category driver for newly absorbed exact EF00 light and dimmer fingerprints.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZE200_2gtsuokt` | `TS0601` | `lights-color-temperature-skydance-wz5-cct` |
| `_TZE200_3thxjahu` | `TS0601` | `lights-color-skydance-wz5-rgbw` |
| `_TZE200_6qoazbre` | `TS0601` | `lights-dimmer-skydance-wz5-dim` |
| `_TZE200_9hghastn` | `TS0601` | `lights-color-skydance-wz5-rgb` |
| `_TZE200_9mt3kgn0` | `TS0601` | `lights-color-skydance-wz5-rgb` |
| `_TZE200_a1ovdobn` | `TS0601` | `lights-moes-zs-d1` |
| `_TZE200_aa9awrng` | `TS0601` | `lights-color-temperature-color-skydance-wz5-rgbcct` |
| `_TZE200_fcooykb4` | `TS0601` | `lights-dimmer-skydance-wz5-dim` |
| `_TZE200_g9jdneiu` | `TS0601` | `lights-color-skydance-wz5-rgbw` |
| `_TZE200_gz3n0tzf` | `TS0601` | `lights-color-temperature-skydance-wz5-cct` |
| `_TZE200_jowqowye` | `TS0601` | `lights-dimmer-mercator-siswd11-zb` |
| `_TZE200_mde0utnv` | `TS0601` | `lights-color-temperature-color-skydance-wz5-rgbcct` |
| `_TZE200_na98lvjp` | `TS0601` | `lights-color-temperature-skydance-wz5-cct` |
| `_TZE200_nthosjmx` | `TS0601` | `lights-color-temperature-skydance-wz5-cct` |
| `_TZE200_rlqamjhp` | `TS0601` | `lights-moes-zs-d2` |
| `_TZE200_s8gkrkxk` | `TS0601` | `lights-wave19-lidl-hg06467` |
| `_TZE204_8fffc3kb` | `TS0601` | `lights-wave15-gledopto-gl-spi-206p` |
| `_TZE204_sdykkwsu` | `TS0601` | `lights-wave19-avatto-zdms16-us-w2` |
| `_TZE204_zhiqbr7l` | `TS0601` | `lights-color-temperature-color-skydance-wz5-rgbcct` |
| `_TZE284_5yah8qx4` | `TS0601` | `lights-wave19-nova-topazio` |
| `_TZE284_a1ovdobn` | `TS0601` | `lights-moes-zs-d1` |
| `_TZE284_gt5al3bl` | `TS0601` | `lights-wave15-gledopto-gl-spi-206p` |
| `_TZE284_nthhgkd6` | `TS0601` | `lights-wave19-qa-qadz4din` |
| `_TZE284_vizxbhco` | `TS0601` | `lights-moes-zs-d3` |
| `_TZE28C1000000_nqqylykc` | `TS0601` | `lights-dimmer-zdms16-1` |
| `_TZE600_wxq8dpha\x00` | `TS0603` | `lights-wave19-lonsonho-vm-s02-010v` |

</details>

<details>
<summary>Z2M EF00 Meters Category wonjj6768 (5 fingerprints)</summary>

Category driver for newly absorbed exact EF00 meter and energy fingerprints.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZ3218_kwht8j5m` | `TS011F` | `meters-wave19-qa-qaszp` |
| `_TZE204_goecjd1t` | `TS0601` | `meters-zwpm16` |
| `_TZE204_jrcfsaa3` | `TS0601` | `meters-zwpm16-2` |
| `_TZE204_t9ffmdin` | `TS0601` | `meters-wave19-nous-d5z` |
| `_TZE284_2fnssffc` | `TS0601` | `meters-wave19-moes-zm6lt1` |

</details>

<details>
<summary>Z2M EF00 Presence Category wonjj6768 (21 fingerprints)</summary>

Category driver for newly absorbed exact EF00 presence and mmWave fingerprints.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZ3218_awarhusb` | `TS0225` | `safety-occupancy-wave11-linptech-es1` |
| `_TZ3218_ewrxirng` | `TS0225` | `safety-occupancy-wave11-linptech-es1` |
| `_TZ3218_t9ynfz4x` | `TS0225` | `safety-occupancy-wave11-linptech-es1` |
| `_TZE200_7hfcudw5` | `TS0601` | `safety-wave19-neo-nas-pd07` |
| `_TZE200_i0b1dbqu` | `TS0601` | `safety-wave19-javis-microwave` |
| `_TZE200_kagkgk0i` | `TS0601` | `safety-wave19-javis-microwave` |
| `_TZE200_lgstepha` | `TS0601` | `safety-wave19-javis-microwave` |
| `_TZE204_1youk3hj` | `TS0601` | `safety-presence-wave11-neo-nas-ps10b2` |
| `_TZE204_b8vxct9l` | `TS0601` | `safety-presence-wave11-szlr08t` |
| `_TZE204_bjf8qum1` | `TS0601` | `safety-presence-szlmr10-illuminance` |
| `_TZE204_khoqss0a` | `TS0601` | `safety-presence-wave11-szr07` |
| `_TZE204_lw5ny7tp` | `TS0601` | `safety-presence-wave11-szlr08` |
| `_TZE204_sndkanfr` | `TS0601` | `safety-presence-szlmr10-illuminance` |
| `_TZE284_1youk3hj` | `TS0601` | `safety-presence-wave11-neo-nas-ps10b2` |
| `_TZE284_hqys6frs` | `TS0601` | `safety-presence-wave11-r12lm-z10t` |
| `_TZE284_sndkanfr` | `TS0601` | `safety-presence-szlmr10-illuminance` |
| `_TZE284_zzm83zpz` | `TS0601` | `safety-presence-wave11-r12lm-z11t` |
| `_TZE28C1000000_ewn672ef` | `TS0601` | `safety-presence-zf24pro-temp-humidity` |
| `_TZE28C1000000_jaunkx9g` | `TS0601` | `switches-presence-wave11-tuya-2gang` |
| `_TZE28C1000000_usmqzgdm` | `TS0601` | `switches-presence-wave11-tuya-3gang` |
| `_TZE28C1000000_vosmoqsg` | `TS0601` | `safety-presence-zf24pro-temp-humidity` |

</details>

<details>
<summary>Z2M EF00 Safety Category wonjj6768 (22 fingerprints)</summary>

Category driver for newly absorbed exact EF00 safety, alarm, and siren fingerprints.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZE200_hr0tdd47` | `TS0601` | `safety-co-moes-zc-hm` |
| `_TZE200_nlrfgpny` | `TS0601` | `safety-alarm-neo-nas-ab06b2` |
| `_TZE200_rjxqso4a` | `TS0601` | `safety-co-moes-zc-hm` |
| `_TZE200_t1blo2bj` | `TS0601` | `safety-alarm-neo-nas-ab02b2` |
| `_TZE204_l4daccga` | `TS0601` | `safety-wave16-lincukoo-a08-z10t` |
| `_TZE204_nlrfgpny` | `TS0601` | `safety-alarm-neo-nas-ab06b2` |
| `_TZE204_q76rtoa9` | `TS0601` | `safety-alarm-neo-nas-ab02b2` |
| `_TZE204_qvxrkeif` | `TS0601` | `safety-gas-nous-e9` |
| `_TZE204_ra9zfiwr` | `TS0601` | `safety-wave15-lincukoo-e04cf-z10t` |
| `_TZE204_t1blo2bj` | `TS0601` | `safety-alarm-neo-nas-ab02b2` |
| `_TZE204_uc0iv1hb` | `TS0601` | `safety-gas-detector-spacetronik-zb-dg02` |
| `_TZE284_1di7ujzp` | `TS0601` | `safety-water-nous-e13` |
| `_TZE284_2qx7sivb` | `TS0601` | `safety-vibration-tuya-battery-state` |
| `_TZE284_7trh4ihp` | `TS0601` | `safety-vibration-tuya-battery-state-controls` |
| `_TZE284_8sejxcue` | `TS0601` | `safety-vibration-tuya-battery-state-controls` |
| `_TZE284_aghfucwi` | `TS0601` | `safety-vibration-tuya-battery` |
| `_TZE284_ajhu0zqb` | `TS0601` | `safety-water-lincukoo-szw08` |
| `_TZE284_iunyuzwe` | `TS0601` | `safety-water-lincukoo-w04-z10t-battery-state` |
| `_TZE284_nlrfgpny` | `TS0601` | `safety-alarm-neo-nas-ab06b2` |
| `_TZE284_rjxqso4a` | `TS0601` | `safety-co-moes-zc-hm` |
| `_TZE284_sonkaxrd` | `TS0601` | `safety-co-nous-e12` |
| `_TZE284_vbgmewta` | `TS0601` | `safety-water-lincukoo-w04-z10t-battery-ringtone` |

</details>

<details>
<summary>Z2M EF00 Sensors Category wonjj6768 (8 fingerprints)</summary>

Category driver for newly absorbed exact EF00 environment and sensor fingerprints.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZE204_fpwtjlfh` | `TS0601` | `sensors-wave16-lincukoo-ezcp04` |
| `_TZE204_hyt4iucb` | `TS0601` | `sensors-wave16-lincukoo-e02c-z10t` |
| `_TZE204_isvlaage` | `TS0601` | `sensors-wave16-lincukoo-ezc04` |
| `_TZE204_pkpfn9hc` | `TS0601` | `sensors-aq-co2-temp-humidity` |
| `_TZE2841000000_qf5mzewi` | `TS0601` | `sensors-temp-humidity-battery-alarm-onenuo-th05z` |
| `AIRPRS1` | `Excellux` | `sensors-wave16-excellux-airprs1` |
| `EZ500FL` | `Excellux` | `sensors-wave16-excellux-ez500fl` |
| `EZ500FS` | `Excellux` | `sensors-wave16-excellux-ez500fs` |

</details>

<details>
<summary>Z2M EF00 Switch Category wonjj6768 (48 fingerprints)</summary>

Category driver for newly absorbed exact EF00 switch, panel, and screen-switch fingerprints.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZE200_7a5ob7xq` | `TS0601` | `switches-switch-8` |
| `_TZE200_9dhenr94` | `TS0601` | `switches-moes-sfl02-z4` |
| `_TZE200_b0ihkhxh` | `TS0601` | `switches-switch-4` |
| `_TZE200_dq8bu0pt` | `TS0601` | `switches-moes-sfl02-z4` |
| `_TZE200_hktk6hze` | `TS0601` | `switches-moes-sfl02-z2` |
| `_TZE200_hmabvy81` | `TS0601` | `switches-moes-sfl02-z4` |
| `_TZE200_htj3hcpl` | `TS0601` | `switches-switch-6` |
| `_TZE200_o7vduidq` | `TS0601` | `switches-wave15-box-erc2202z` |
| `_TZE200_pcg0rykt` | `TS0601` | `switches-switch-7` |
| `_TZE200_rd8cdssd` | `TS0601` | `switches-moes-sfl02-z3` |
| `_TZE200_rgeapp2c` | `TS0601` | `switches-wave13-tuya-semicom-two-two` |
| `_TZE200_stvgmdjz` | `TS0601` | `switches-moes-sfl02-z1` |
| `_TZE200_tzyy0rtq` | `TS0601` | `switches-moes-sfl02-z2` |
| `_TZE200_uenof8jd` | `TS0601` | `switches-moes-sfl02-z2` |
| `_TZE200_wv9ukqca` | `TS0601` | `switches-moes-sfl02-z3` |
| `_TZE200_xo3vpoah` | `TS0601` | `switches-switch-10` |
| `_TZE200_ydkqbmpt` | `TS0601` | `switches-moes-sfl02-z1` |
| `_TZE200_yp5tsi3y` | `TS0601` | `switches-wave13-box-ews1154z` |
| `_TZE200_z3u99qxt` | `TS0601` | `switches-moes-sfl02-z1` |
| `_TZE200_zo0cfekv` | `TS0601` | `switches-moes-sfl02-z3` |
| `_TZE204_3ctwoaip` | `TS0601` | `switches-screen-zms206eu2` |
| `_TZE204_4cl0dzt4` | `TS0601` | `switches-wave14-qa-qat44z6h` |
| `_TZE204_8eazvzo6` | `TS0601` | `switches-switch-6` |
| `_TZE204_iyki9kjp` | `TS0601` | `switches-screen-zms206eu3` |
| `_TZE204_k7v0eqke` | `TS0601` | `switches-screen-zms206eu3` |
| `_TZE204_kyzjsjo3` | `TS0601` | `switches-wave14-qa-qat44z4h` |
| `_TZE204_sa2ueffe` | `TS0601` | `switches-screen-zms206us1` |
| `_TZE204_zuepxzck` | `TS0601` | `switches-screen-zms206us1` |
| `_TZE284_3ctwoaip` | `TS0601` | `switches-screen-zms206eu2` |
| `_TZE284_3xnyj4ga` | `TS0601` | `switches-wave13-nova-to-wk-one` |
| `_TZE284_59dz7ioi` | `TS0601` | `switches-wave13-manhot-mh03-3` |
| `_TZE284_7a5ob7xq` | `TS0601` | `switches-switch-8` |
| `_TZE284_a2teqi5u` | `TS0601` | `switches-screen-zms208us2` |
| `_TZE284_dmckrsxg` | `TS0601` | `switches-screen-zms206eu2` |
| `_TZE284_dnhhp8ew` | `TS0601` | `switches-wave13-manhot-mh03-2` |
| `_TZE284_e4pf6l87` | `TS0601` | `switches-screen-zms206eu3` |
| `_TZE284_esnu2jxv` | `TS0601` | `switches-wave13-manhot-mh03-4` |
| `_TZE284_exfilann` | `TS0601` | `switches-wave13-nova-to-wk-two` |
| `_TZE284_hwv3by9k` | `TS0601` | `switches-wave13-manhot-mh03-8` |
| `_TZE284_k7v0eqke` | `TS0601` | `switches-screen-zms206eu3` |
| `_TZE284_lnyz4a6v` | `TS0601` | `switches-screen-zms206us1` |
| `_TZE284_ncc7uahd` | `TS0601` | `switches-wave13-manhot-mh03-1` |
| `_TZE284_nzns7udm` | `TS0601` | `switches-switch-1-scene-qa-qat42z1b` |
| `_TZE284_udaucpdi` | `TS0601` | `switches-wave13-avatto-zbs16` |
| `_TZE284_xvywzhmi` | `TS0601` | `switches-screen-zms208us3` |
| `_TZE284_zykra2yj` | `TS0601` | `switches-wave13-manhot-mh03-6` |
| `_TZE28C1000000_e4pf6l87` | `TS0601` | `switches-screen-zms206eu3` |
| `_TZE28C1000000_xvywzhmi` | `TS0601` | `switches-screen-zms208us3` |

</details>

<details>
<summary>Z2M EF00 Thermostat Wall FCU wonjj6768 (18 fingerprints)</summary>

Category driver for newly absorbed exact EF00 wall thermostat and FCU fingerprints.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZE200_4hbx5cvx` | `TS0601` | `thermostats-wave6a-futurehome` |
| `_TZE200_awnadkan` | `TS0601` | `thermostats-wave6a-engo-eone230w` |
| `_TZE200_e5hpkc6d` | `TS0601` | `thermostats-wave6a-futurehome` |
| `_TZE200_gtouvmvl` | `TS0601` | `thermostats-wave12-engo-eone-batb` |
| `_TZE204_ca3i8m8p` | `TS0601` | `thermostats-wave6a-engo-eone230w` |
| `_TZE204_cg8hdnjv` | `TS0601` | `thermostats-wave12-engo-e25-batb` |
| `_TZE204_cmyc8g5i` | `TS0601` | `thermostats-wave12-engo-e25-230` |
| `_TZE204_djurk6p5` | `TS0601` | `thermostats-wave12-engo-eone` |
| `_TZE204_e5hpkc6d` | `TS0601` | `thermostats-wave6a-futurehome` |
| `_TZE204_glk6viwg` | `TS0601` | `thermostats-wave6a-engo-e40` |
| `_TZE204_hpkusvom` | `TS0601` | `thermostats-wave12-tuya-bac001` |
| `_TZE204_lnxdk2ch` | `TS0601` | `thermostats-wave6a-engo-e40` |
| `_TZE204_lpedvtvr` | `TS0601` | `thermostats-wave12-moes-zht-sr` |
| `_TZE204_p3lqqy2r` | `TS0601` | `thermostats-wave12-namron-touch` |
| `_TZE204_x9usygq1` | `TS0601` | `thermostats-wave12-moes-pilot` |
| `_TZE204_zxkwaztm` | `TS0601` | `thermostats-wave12-moes-zht-s03` |
| `_TZE284_4cgmagba` | `TS0601` | `thermostats-wave12-beca-bht209` |
| `_TZE284_rlytpmij` | `TS0601` | `thermostats-wave12-moes-zht-s01` |

</details>

<details>
<summary>Z2M EF00 Thermostat TRV wonjj6768 (34 fingerprints)</summary>

Category driver for newly absorbed exact EF00 TRV fingerprints.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TYST11_2dpplnsn` | `dpplnsn\x00` | `thermostats-thermostat-etop` |
| `_TYST11_8daqwrsj` | `daqwrsj\x00` | `thermostats-alecto-smart-heat10` |
| `_TYST11_c88teujp` | `88teujp\x00` | `thermostats-thermostat-saswell` |
| `_TYST11_caj4jz0i` | `aj4jz0i\x00` | `thermostats-thermostat-saswell` |
| `_TYST11_KGbxAXL2` | `GbxAXL2\x00` | `thermostats-thermostat-saswell` |
| `_TYST11_wv90ladg` | `v90ladg\x00` | `thermostats-thermostat-etop` |
| `_TYST11_yw7cahqs` | `w7cahqs\x00` | `thermostats-thermostat-saswell` |
| `_TYST11_zuhszj9s` | `uhszj9s\x00` | `thermostats-thermostat-saswell` |
| `_TZE200_4aijvczq` | `TS0601` | `thermostats-wave6a-avatto-me168` |
| `_TZE200_6y7kyjga` | `TS0601` | `thermostats-wave9-moes-brt100` |
| `_TZE200_b6wax7g0` | `TS0601` | `thermostats-wave9-moes-brt100` |
| `_TZE200_chyvmhay` | `TS0601` | `thermostats-wave9-lidl-368308` |
| `_TZE200_cxakecfo` | `TS0601` | `thermostats-wave6a-avatto-me168` |
| `_TZE200_dmfguuli` | `TS0601` | `thermostats-wave9-evanell-ez200` |
| `_TZE200_fhn3negr` | `TS0601` | `thermostats-wave12-moes-sh4` |
| `_TZE200_i48qyn9s` | `TS0601` | `thermostats-wave12-essentials-trv` |
| `_TZE200_ivdc0kwl` | `TS0601` | `thermostats-wave15-moes-ztrv-s01` |
| `_TZE200_ne4pikwm` | `TS0601` | `thermostats-wave6a-nedis-zbhtr20wt` |
| `_TZE200_qsoecqlk` | `TS0601` | `thermostats-wave9-moes-brt100` |
| `_TZE200_r5ksy7qo` | `TS0601` | `thermostats-wave6a-avatto-me168` |
| `_TZE200_rxypyjkw` | `TS0601` | `thermostats-wave9-evanell-ez200` |
| `_TZE200_uiyqstza` | `TS0601` | `thermostats-wave9-lidl-368308` |
| `_TZE200_wlosfena` | `TS0601` | `thermostats-wave19-immax-07703l` |
| `_TZE200_wnvhlcgl` | `TS0601` | `thermostats-wave19-woox-r7067` |
| `_TZE200_ybsqljjg` | `TS0601` | `thermostats-wave6a-avatto-me168` |
| `_TZE204_k6rdmisz` | `TS0601` | `thermostats-wave9-mazda-tr-m2z` |
| `_TZE204_p1qrtljn` | `TS0601` | `thermostats-wave12-tech-v2` |
| `_TZE204_r7brscr6` | `TS0601` | `thermostats-wave12-tech-v1` |
| `_TZE204_xdtnpp1a` | `TS0601` | `thermostats-wave6a-avatto-trv26` |
| `_TZE284_hcs66axl` | `TS0601` | `thermostats-wave6a-nedis-zbhtr20wt` |
| `_TZE284_k6rdmisz` | `TS0601` | `thermostats-wave9-mazda-tr-m2z` |
| `_TZE284_ne4pikwm` | `TS0601` | `thermostats-wave6a-nedis-zbhtr20wt` |
| `_TZE284_ty5neqqo` | `TS0601` | `thermostats-wave12-avatto-trv60` |
| `_TZE284_xdtnpp1a` | `TS0601` | `thermostats-wave6a-avatto-trv26` |

</details>

<details>
<summary>Z2M EF00 Valves Category wonjj6768 (19 fingerprints)</summary>

Category driver for newly absorbed exact EF00 irrigation and water-valve fingerprints.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZE200_7ytb3h8u` | `TS0601` | `valves-giex-qt06-two` |
| `_TZE200_a7sghmms` | `TS0601` | `valves-giex-qt06-two` |
| `_TZE200_anv5ujhv` | `TS0601` | `valves-qoto-qt05m` |
| `_TZE200_arge1ptm` | `TS0601` | `valves-qoto-qt05m` |
| `_TZE200_d0ypnbvn` | `TS0601` | `valves-iotperfect-pf-pm02d` |
| `_TZE200_htnnfasr` | `TS0601` | `valves-wave19-lidl-psbzs-a-one` |
| `_TZE200_nbqnmkee` | `TS0601` | `valves-wave19-frankever-fk-bv05` |
| `_TZE200_sh1btabb` | `TS0601` | `valves-giex-qt06-one` |
| `_TZE200_vrjkcam9` | `TS0601` | `valves-iotperfect-pf-pm02d` |
| `_TZE200_xlppj4f5` | `TS0601` | `valves-qoto-qt05m` |
| `_TZE204_7ytb3h8u` | `TS0601` | `valves-giex-qt06-two` |
| `_TZE204_a7sghmms` | `TS0601` | `valves-giex-qt06-two` |
| `_TZE204_a9ojznj8` | `TS0601` | `valves-neo-nas-wv03b2` |
| `_TZE204_d0ypnbvn` | `TS0601` | `valves-iotperfect-pf-pm02d` |
| `_TZE204_v5xjyphj` | `TS0601` | `valves-iotperfect-pf-pm02d` |
| `_TZE284_7ytb3h8u` | `TS0601` | `valves-giex-qt06-two` |
| `_TZE284_a9ojznj8` | `TS0601` | `valves-neo-nas-wv03b2` |
| `_TZE284_d0ypnbvn` | `TS0601` | `valves-iotperfect-pf-pm02d` |
| `_TZE284_v5xjyphj` | `TS0601` | `valves-iotperfect-pf-pm02d` |

</details>

<details>
<summary>Z2M ZCL Bridge wonjj6768 (3 fingerprints)</summary>

Dedicated driver for newly absorbed exact ZCL bridge fingerprints.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `Candeo` | `C-RFZB-HUB` | `bridges-wave19-candeo-rf-hub` |
| `HEIMAN` | `IRControl-EM` | `bridges-wave19-heiman-hs-one-ir` |
| `HEIMAN` | `IRControl2-EF-3.0` | `bridges-wave19-heiman-hs-two-ir` |

</details>

<details>
<summary>Z2M ZCL Controls Category wonjj6768 (5 fingerprints)</summary>

Category driver for newly absorbed exact ZCL remote and control fingerprints.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZ3000_9zc1ilmb` | `TS0043` | `buttons-button-3-battery` |
| `Candeo` | `C-ZB-RD1Pv2-REM` | `controllers-candeo-rd1p-rem` |
| `JetHome` | `WS7` | `buttons-jethome-ws7` |
| `Slacky-DIY` | `TS0043-M007-SlD` | `buttons-button-3-battery-remote-action-slacky` |
| `Slacky-DIY` | `TS0043-z-SlD` | `buttons-button-3-battery-remote-action-slacky` |

</details>

<details>
<summary>Z2M ZCL DALI wonjj6768 (1 fingerprints)</summary>

Dedicated driver for newly absorbed exact ZCL DALI fingerprints and dynamic endpoint children.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `Sunricher` | `Light` | `bridge-wave19-sunricher-dali-parent` |

</details>

<details>
<summary>Z2M ZCL Lights Category wonjj6768 (8 fingerprints)</summary>

Category driver for newly absorbed exact ZCL light fingerprints.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| ` Legrand\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00` | ` Dimmer switch with neutral\x00\x00\x00\x00` | `lights-dimmer` |
| `Candeo` | `C-ZB-RD1Pv2-DIM` | `lights-wave19-candeo-rd1pv2-dim` |
| `Candeo` | `C-ZB-RD1Pv2-DPM` | `lights-candeo-rd1p-dpm` |
| `eWeLi\x01\x00\x10` | `ZB-CL01` | `lights-color-temperature-color` |
| `Paulmann lamp ` | `Dimmable Light ` | `lights-dimmer` |
| `Paulmann Licht GmbH` | `RGBWW` | `lights-paulmann-rgbww` |
| `Shelly` | `Dimmer 0-1/10` | `lights-shelly-dimmer-gen4` |
| `Xiaoyan` | `DIM003` | `lights-wave19-terncy-dim003` |

</details>

<details>
<summary>Z2M ZCL Locks wonjj6768 (2 fingerprints)</summary>

Dedicated driver for newly absorbed exact ZCL lock fingerprints and lock receive handling.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `Lmiot` | `doorlock_5001` | `locks-wave18-javis-js-slk2-zb` |
| `Vensi` | `E321V000A03` | `locks-wave18-javis-js-slk2-zb` |

</details>

<details>
<summary>Z2M ZCL Sensors Category wonjj6768 (9 fingerprints)</summary>

Category driver for newly absorbed exact ZCL sensor, environment, smoke, and vibration fingerprints.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `'_TZ32101000000_5oy7cysk'` | `TS0210` | `safety-wave19-tuya-ts0210-quoted` |
| `_TZ3000_eit7p838 ` | `TS0207` | `safety-water-leak-tamper-battery-low-battery` |
| `eWeLink` | `CK-TLSR8656-Z123SE22DY-01(7035)` | `safety-wave19-ewelink-7035` |
| `eWeLink` | `CK-TLSR8656-Z123SE24DY-01(7037)` | `safety-co-detector-battery-voltage-ewelink-7037` |
| `eWeLink` | `CK-TLSR8656-Z23SE11HW-01(7019)` | `safety-water-leak-battery-low-battery` |
| `HEIMAN` | `HS2AQ-EF-3.0` | `sensors-wave19-heiman-hs2aq-ef-three` |
| `LinknLink` | `eMotion Air` | `sensors-linknlink-emotion-air` |
| `PLAID SYSTEMS` | `PS-SPRZMS-SLP3` | `sensors-wave19-plaid-spruce` |
| `Shelly` | `Presence` | `sensors-shelly-presence-gen4` |

</details>

<details>
<summary>Z2M ZCL Switch Category wonjj6768 (12 fingerprints)</summary>

Category driver for newly absorbed exact ZCL switch fingerprints.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZ3000_khtlvdfc` | `TS0013` | `switches-switch-3-ssw03g` |
| `_TZ3210_5ksufhqi` | `TS0002` | `switches-switch-2-nfzb2` |
| `AOYAN` | `AY301Z-2CH` | `switches-switch-2-ay301z-two` |
| `MLI` | `tint Smart Switch` | `switches-switch-1-mli-tint` |
| `MLI\x00` | `switch01\x00` | `switches-switch-1-mli-tint` |
| `SDevices` | `SBDV-00196` | `switches-wave14-sber-sbdv-00196` |
| `SDevices` | `SBDV-00197` | `switches-wave14-sber-sbdv-00197` |
| `SDevices` | `SBDV-00199` | `switches-wave14-sber-sbdv-00199` |
| `SDevices` | `SBDV-00200` | `switches-wave14-sber-sbdv-00200` |
| `SDevices` | `SBDV-00202` | `switches-wave14-sber-sbdv-00202` |
| `Shelly` | `EM` | `switches-shelly-em-gen4` |
| `Xiaoyan` | `TERNCY-WS07-D3` | `switches-wave14-terncy-ws07-d3` |

</details>

<details>
<summary>Z2M ZCL Thermostat wonjj6768 (2 fingerprints)</summary>

Category driver for newly absorbed exact ZCL HVAC and thermostat fingerprints.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `PirogovX` | `ZB-MIDEA-AC` | `thermostats-wave19-pirogov-zb-midea-ac` |
| `SDevices` | `SBDV-00205` | `thermostats-wave19-sber-sbdv-00205` |

</details>

<details>
<summary>ZCL Controls wonjj6768 (313 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports ZCL remotes, scene switches, security remotes, and IR controllers.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TYZB01_1xktopx6` | `TS0041A` | `buttons-button-1-battery-voltage` |
| `_TYZB01_4qw4rl1u` | `TS0041A` | `buttons-button-1-battery-voltage` |
| `_TYZB01_bngwdjsr` | `TS1001` | `controllers-dimming-remote-action` |
| `_TYZB01_cnlmkhbk` | `TS0044` | `buttons-button-4-battery-voltage` |
| `_TYZB01_hww2py6b` | `TS1001` | `controllers-dimming-remote-action` |
| `_TYZB01_ub7urdza` | `TS0041A` | `buttons-button-1-battery` |
| `_TYZB02_key8kk7r` | `TS0043` | `buttons-button-3-battery` |
| `_TYZB02_keyjhapk` | `TS0042` | `buttons-button-2-battery` |
| `_TZ1800_akzvkzqq` | `TS0211` | `buttons-doorbell-battery-tamper-low` |
| `_TZ1800_ladpngdx` | `TS0211` | `buttons-doorbell-battery-tamper-low` |
| `_TZ3000_0dumfk2z` | `TS0215A` | `security-remotes-sos-battery-voltage` |
| `_TZ3000_0ht8dnxj` | `TS004F` | `buttons-button-4-battery-voltage-operation-mode-remote-action` |
| `_TZ3000_0zrccfgx` | `TS0215A` | `security-remotes-action-battery` |
| `_TZ3000_11pg3ima` | `TS004F` | `buttons-button-4-battery-voltage-operation-mode-remote-action` |
| `_TZ3000_1fqpj6qz` | `TS004F` | `buttons-button-1-battery-operation-mode-remote-action` |
| `_TZ3000_1hypixdr` | `TS0044` | `buttons-button-4-battery-voltage` |
| `_TZ3000_1kmurvlx` | `TS0043` | `buttons-button-3-battery` |
| `_TZ3000_1yyjhvwd` | `TS0042` | `buttons-button-2-battery` |
| `_TZ3000_22ugzkme` | `TS0041` | `buttons-button-1-battery` |
| `_TZ3000_2izubafb` | `TS0215A` | `security-remotes-sos-battery-voltage` |
| `_TZ3000_402vrq2i` | `TS004F` | `buttons-button-1-battery-operation-mode-remote-action` |
| `_TZ3000_4fjiwweb` | `TS004F` | `buttons-button-1-battery-operation-mode-remote-action` |
| `_TZ3000_4fsgukof` | `TS0215A` | `security-remotes-sos-battery-voltage` |
| `_TZ3000_4upl1fcj` | `TS0041` | `buttons-button-1-battery` |
| `_TZ3000_5bpeda8u` | `TS0041` | `buttons-button-1-battery` |
| `_TZ3000_5e235jpa` | `TS0042` | `buttons-button-2-battery` |
| `_TZ3000_5kxl9esg` | `TS0726` | `scene-switches-scene-1` |
| `_TZ3000_5kxl9esg` | `TS0726_1_gang_scene_switch` | `scene-switches-scene-1` |
| `_TZ3000_5tqxpine` | `TS0044` | `buttons-button-4-battery-voltage` |
| `_TZ3000_6km7djcm` | `TS0041` | `buttons-button-1-battery` |
| `_TZ3000_8utxxtzr` | `TS0215A` | `security-remotes-action-battery` |
| `_TZ3000_9orwkl3t` | `TS0044` | `buttons-button-4-battery-voltage` |
| `_TZ3000_9r5jaajv` | `TS0215A` | `security-remotes-sos-battery-voltage` |
| `_TZ3000_9zc1limb` | `TS0043` | `buttons-button-3-battery` |
| `_TZ3000_a4xycprs` | `TS0044` | `buttons-button-4-battery-voltage` |
| `_TZ3000_a7ouggvs` | `TS0043` | `buttons-button-3-battery` |
| `_TZ3000_abci1hiu` | `TS0044` | `buttons-button-4-battery-voltage` |
| `_TZ3000_abrsvsou` | `TS004F` | `buttons-button-1-battery-operation-mode-remote-action` |
| `_TZ3000_adkvzooy` | `TS0042` | `buttons-button-2-battery` |
| `_TZ3000_adndolvx` | `TS0041` | `buttons-button-1-battery` |
| `_TZ3000_an5rjiwd` | `TS0041` | `buttons-button-1-battery` |
| `_TZ3000_axpdxqgu` | `TS0041` | `buttons-button-1-battery` |
| `_TZ3000_b3mgfu0d` | `TS004F` | `buttons-button-4-battery-voltage-operation-mode-remote-action` |
| `_TZ3000_b4awzgct` | `TS0041` | `buttons-button-1-battery` |
| `_TZ3000_bgtzm4ny` | `TS0044` | `buttons-button-4-battery-voltage` |
| `_TZ3000_bi6lpsew` | `TS0043` | `buttons-button-3-battery` |
| `_TZ3000_cllghx1k` | `TS0042` | `buttons-button-2-battery` |
| `_TZ3000_csflgqj2` | `TS004F` | `buttons-button-1-battery-operation-mode-remote-action` |
| `_TZ3000_cumqn2av` | `TS0726` | `scene-switches-4-plus-2` |
| `_TZ3000_cumqn2av` | `TS0726_4_gang_switch_and_2_scene` | `scene-switches-4-plus-2` |
| `_TZ3000_cziew6eu` | `TS0726` | `scene-switches-scene-3` |
| `_TZ3000_czuyt8lz` | `TS004F` | `buttons-button-4-battery-voltage-operation-mode-remote-action` |
| `_TZ3000_dfgbtub0` | `TS0042` | `buttons-button-2-battery` |
| `_TZ3000_dku2cfsc` | `TS0044` | `buttons-button-4-battery-voltage` |
| `_TZ3000_dziaict4` | `TS0044` | `buttons-button-4-battery-voltage` |
| `_TZ3000_ee8nrt2l` | `TS0044` | `buttons-button-4-battery-voltage` |
| `_TZ3000_egvb1p2g` | `TS004F` | `buttons-button-1-battery-operation-mode-remote-action` |
| `_TZ3000_eo3dttwe` | `TS0215A` | `security-remotes-action-battery` |
| `_TZ3000_et7afzxz` | `TS004F` | `buttons-button-4-battery-voltage-operation-mode-remote-action` |
| `_TZ3000_etufnltx` | `TS1002` | `buttons-button-4-battery-voltage-remote-action` |
| `_TZ3000_ezqbvrqz` | `TS0726` | `scene-switches-scene-2` |
| `_TZ3000_ezqbvrqz` | `TS0726_2_gang_scene_switch` | `scene-switches-scene-2` |
| `_TZ3000_fa9mlvja` | `TS0041` | `buttons-button-1-battery-voltage` |
| `_TZ3000_famkxci2` | `TS0043` | `buttons-button-3-battery` |
| `_TZ3000_filhl5b7` | `TS0041` | `buttons-button-1-battery` |
| `_TZ3000_fkvaniuu` | `TS0042` | `buttons-button-2-battery` |
| `_TZ3000_fsiepnrh` | `TS0215A` | `security-remotes-action-battery` |
| `_TZ3000_g7eeean4` | `TS0044` | `buttons-button-4-battery-voltage` |
| `_TZ3000_g9g2xnch` | `TS004F` | `buttons-button-4-battery-operation-mode-remote-action` |
| `_TZ3000_gbm10jnj` | `TS0043` | `buttons-button-3-battery` |
| `_TZ3000_gwkzibhs` | `TS004F` | `buttons-button-1-battery-operation-mode-remote-action` |
| `_TZ3000_h1c2eamp` | `TS0042` | `buttons-button-2-battery` |
| `_TZ3000_hurauima` | `TS0726` | `scene-switches-scene-4` |
| `_TZ3000_hurauima` | `TS0726_4_gang_scene_switch` | `scene-switches-scene-4` |
| `_TZ3000_i3rjdrwu` | `TS0042` | `buttons-button-2-battery` |
| `_TZ3000_icoxotza` | `TS0726` | `scene-switches-2` |
| `_TZ3000_icoxotza` | `TS0726_2_gang` | `scene-switches-2` |
| `_TZ3000_imnwsek2` | `TS0043` | `buttons-button-3-battery` |
| `_TZ3000_irwuzilv` | `TS0215A` | `security-remotes-sos-battery-voltage` |
| `_TZ3000_iszegwpd` | `TS0046` | `buttons-button-6-battery` |
| `_TZ3000_ixla93vd` | `TS004F` | `buttons-button-1-battery-operation-mode-remote-action` |
| `_TZ3000_j61x9rxn` | `TS0044` | `buttons-button-4-battery-voltage` |
| `_TZ3000_j70oanab` | `TS0044` | `buttons-button-4-battery-voltage` |
| `_TZ3000_ja5osu5g` | `TS004F` | `buttons-button-1-battery-operation-mode-remote-action` |
| `_TZ3000_jwcixnrz` | `TS0215A` | `security-remotes-action-battery` |
| `_TZ3000_kaflzta4` | `TS004F` | `buttons-button-1-battery-operation-mode-remote-action` |
| `_TZ3000_kccru4oi` | `TS0041` | `buttons-button-1-battery` |
| `_TZ3000_kfkqkjqe` | `TS0726` | `scene-switches-3` |
| `_TZ3000_kfkqkjqe` | `TS0726_3_gang` | `scene-switches-3` |
| `_TZ3000_kfu8zapd` | `TS0044` | `buttons-button-4-battery-voltage` |
| `_TZ3000_kjfzuycl` | `TS004F` | `buttons-button-1-battery-operation-mode-remote-action` |
| `_TZ3000_krwtzhfd` | `TS004F` | `buttons-button-1-battery` |
| `_TZ3000_kt6xxa4o` | `TS0726` | `scene-switches-3-advanced` |
| `_TZ3000_kt6xxa4o` | `TS0726_multi_3_gang` | `scene-switches-3-advanced` |
| `_TZ3000_kt7obmnn` | `TS0042` | `buttons-button-2-battery` |
| `_TZ3000_kxaow5ki` | `TS0041` | `buttons-button-1-battery` |
| `_TZ3000_laeia8fo` | `TS0044` | `buttons-button-4-battery-voltage` |
| `_TZ3000_lcjsewlo` | `TS0726` | `scene-switches-3` |
| `_TZ3000_lcjsewlo` | `TS0726_3_gang` | `scene-switches-3` |
| `_TZ3000_lrfvzq1e` | `TS004F` | `buttons-button-1-battery-operation-mode-remote-action` |
| `_TZ3000_m3pafcnk` | `TS0726` | `scene-switches-3-advanced` |
| `_TZ3000_m3pafcnk` | `TS0726_multi_3_gang` | `scene-switches-3-advanced` |
| `_TZ3000_m4ah6bcz` | `TS0726` | `scene-switches-1-advanced` |
| `_TZ3000_m4ah6bcz` | `TS0726_multi_1_gang` | `scene-switches-1-advanced` |
| `_TZ3000_mh9px7cq` | `TS0044` | `buttons-button-4-battery-voltage` |
| `_TZ3000_mrpevh8p` | `TS0041` | `buttons-button-1-battery` |
| `_TZ3000_mutfmn4u` | `TS0043` | `buttons-button-3-battery` |
| `_TZ3000_ngsph3oj` | `TS0043` | `buttons-button-3-battery` |
| `_TZ3000_noru9tix` | `TS0726` | `scene-switches-scene-3` |
| `_TZ3000_noru9tix` | `TS0726_3_gang_scene_switch` | `scene-switches-scene-3` |
| `_TZ3000_nrfkrgf4` | `TS0046` | `buttons-button-6-battery` |
| `_TZ3000_nuombroo` | `TS004F` | `buttons-button-4-battery-voltage-operation-mode-remote-action` |
| `_TZ3000_nxdziqzc` | `TS0215A` | `security-remotes-sos-battery-voltage` |
| `_TZ3000_ovbvmhiq` | `TS0726` | `scene-switches-1` |
| `_TZ3000_owgcnkrh` | `TS0042` | `buttons-button-2-battery` |
| `_TZ3000_p3fph1go` | `TS0215A` | `security-remotes-sos-battery-voltage` |
| `_TZ3000_p6ju8myv` | `TS0215A` | `security-remotes-action-battery` |
| `_TZ3000_pcqjmcud` | `TS004F` | `buttons-button-4-battery-operation-mode-remote-action` |
| `_TZ3000_pd9mpyh4` | `TS0044` | `buttons-button-4-battery-voltage` |
| `_TZ3000_peszejy7` | `TS0041` | `buttons-button-1-battery` |
| `_TZ3000_pftj0i7z` | `TS004F` | `buttons-button-4-battery-voltage-operation-mode-remote-action` |
| `_TZ3000_piyhhake` | `TS0041` | `buttons-button-1-battery` |
| `_TZ3000_pkfazisv` | `TS0215A` | `security-remotes-sos-battery-voltage` |
| `_TZ3000_qfhhb5y4` | `TS0045` | `buttons-button-5-battery` |
| `_TZ3000_qgwcxxws` | `TS0041` | `buttons-button-1-battery` |
| `_TZ3000_qhyadm57` | `TS0726` | `scene-switches-4-plus-2` |
| `_TZ3000_qhyadm57` | `TS0726_4_gang_switch_and_2_scene` | `scene-switches-4-plus-2` |
| `_TZ3000_qja6nq5z` | `TS004F` | `buttons-button-1-battery-operation-mode-remote-action` |
| `_TZ3000_qzjcsmar` | `TS0043` | `buttons-button-3-battery` |
| `_TZ3000_r0o2dahu` | `TS004F` | `buttons-button-6-battery-operation-mode-remote-action` |
| `_TZ3000_r2fgo9ks` | `TS0726` | `scene-switches-scene-3` |
| `_TZ3000_r2fgo9ks` | `TS0726_3_gang_scene_switch` | `scene-switches-scene-3` |
| `_TZ3000_rco1yzb1` | `TS004F` | `buttons-button-1-battery-remote-action` |
| `_TZ3000_rrjr1q0u` | `TS0043` | `buttons-button-3-battery` |
| `_TZ3000_rsqqkdxv` | `TS0041` | `buttons-button-1-battery` |
| `_TZ3000_rsylfthg` | `TS0726` | `scene-switches-scene-4` |
| `_TZ3000_rsylfthg` | `TS0726_4_gang_scene_switch` | `scene-switches-scene-4` |
| `_TZ3000_s678wazd` | `TS0726` | `scene-switches-4` |
| `_TZ3000_s678wazd` | `TS0726_4_gang` | `scene-switches-4` |
| `_TZ3000_sj7jbgks` | `TS0043` | `buttons-button-3-battery` |
| `_TZ3000_ssp0maqm` | `TS0215A` | `security-remotes-sos-battery-voltage` |
| `_TZ3000_ssup6h68` | `TS0726` | `scene-switches-2-advanced` |
| `_TZ3000_ssup6h68` | `TS0726_multi_2_gang` | `scene-switches-2-advanced` |
| `_TZ3000_t8hzpgnd` | `TS0042` | `buttons-button-2-battery` |
| `_TZ3000_tj4pwzzm` | `TS0215A` | `security-remotes-sos-battery-voltage` |
| `_TZ3000_tk3s5tyg` | `TS0041` | `buttons-button-1-battery` |
| `_TZ3000_tzvbimpq` | `TS0042` | `buttons-button-2-battery` |
| `_TZ3000_u2bbagu4` | `TS0215A` | `security-remotes-action-battery` |
| `_TZ3000_u3nv1jwk` | `TS0044` | `buttons-button-4-battery-voltage` |
| `_TZ3000_uaa99arv` | `TS0044` | `buttons-button-4-battery-voltage` |
| `_TZ3000_ufhtxr59` | `TS0044` | `buttons-button-4-battery-voltage` |
| `_TZ3000_ug1vtuzn` | `TS0215A` | `security-remotes-action-battery` |
| `_TZ3000_ugi8ky6u` | `TS004F` | `buttons-button-1-battery-operation-mode-remote-action` |
| `_TZ3000_uri7ongn` | `TS004F` | `buttons-button-1-battery-operation-mode-remote-action` |
| `_TZ3000_v8jvcwsx` | `TS0042` | `buttons-button-2-battery` |
| `_TZ3000_vm5gcsdq` | `TS0043` | `buttons-button-3-battery` |
| `_TZ3000_vn88ezar` | `TS0041` | `buttons-button-1-battery` |
| `_TZ3000_vp6clf9d` | `TS0044` | `buttons-button-4-battery-voltage` |
| `_TZ3000_w4thianr` | `TS0043` | `buttons-button-3-battery` |
| `_TZ3000_w8jwkczz` | `TS0043` | `buttons-button-3-battery` |
| `_TZ3000_wbfgbpxq` | `TS0044` | `buttons-button-4-battery-voltage` |
| `_TZ3000_wc3gjyp3` | `TS004F` | `buttons-button-1-battery-operation-mode-remote-action` |
| `_TZ3000_wkai4ga5` | `TS0044` | `buttons-button-4-battery-voltage` |
| `_TZ3000_wopf2sox` | `TS0726` | `scene-switches-1-advanced` |
| `_TZ3000_wopf2sox` | `TS0726_multi_1_gang` | `scene-switches-1-advanced` |
| `_TZ3000_wr2ucaj9` | `TS0215A` | `security-remotes-sos-battery-voltage` |
| `_TZ3000_wsspgtcd` | `TS0726` | `scene-switches-4` |
| `_TZ3000_wsspgtcd` | `TS0726_4_gang` | `scene-switches-4` |
| `_TZ3000_xabckq1v` | `TS004F` | `buttons-button-4-battery-voltage-operation-mode-remote-action` |
| `_TZ3000_xffhmvhv` | `TS004F` | `buttons-button-4-battery-voltage-operation-mode-remote-action` |
| `_TZ3000_xr7itfxq` | `TS0042` | `buttons-button-2-battery` |
| `_TZ3000_xrqsdxq6` | `TS0041` | `buttons-button-1-battery` |
| `_TZ3000_xwh1e22x` | `TS1002` | `controllers-zone-8-battery-voltage-remote-action` |
| `_TZ3000_xwuveizv` | `TS0044` | `buttons-button-4-battery-voltage` |
| `_TZ3000_yj6k7vfo` | `TS0041` | `buttons-button-1-battery` |
| `_TZ3000_yw5tvzsk` | `TS0043` | `buttons-button-3-battery` |
| `_TZ3000_zgyzgdua` | `TS0044` | `buttons-button-4-battery-voltage` |
| `_TZ3000_zsh6uat3` | `TS0215A` | `security-remotes-sos-battery-voltage` |
| `_TZ3000_ztrfrcsu` | `TS1001` | `controllers-dimming-remote-action` |
| `_TZ3000_zwszqdpy` | `TS1002` | `controllers-zone-8-battery-voltage-remote-action` |
| `_TZ3002_1s0vfmtv` | `TS0726` | `scene-switches-2` |
| `_TZ3002_1s0vfmtv` | `TS0726_2_gang` | `scene-switches-2` |
| `_TZ3002_6ahhkwyh` | `TS0726` | `scene-switches-scene-2` |
| `_TZ3002_6ahhkwyh` | `TS0726_2_gang_scene_switch` | `scene-switches-scene-2` |
| `_TZ3002_9vcekkp1` | `TS0726` | `scene-switches-1-advanced` |
| `_TZ3002_9vcekkp1` | `TS0726_multi_1_gang` | `scene-switches-1-advanced` |
| `_TZ3002_a4kvf6zd` | `TS0726` | `scene-switches-scene-2` |
| `_TZ3002_a4kvf6zd` | `TS0726_2_gang_scene_switch` | `scene-switches-scene-2` |
| `_TZ3002_aewsvjcu` | `TS0726` | `scene-switches-4-advanced` |
| `_TZ3002_aewsvjcu` | `TS0726_multi_4_gang` | `scene-switches-4-advanced` |
| `_TZ3002_eda6eitk` | `TS0726` | `scene-switches-scene-4` |
| `_TZ3002_eda6eitk` | `TS0726_4_gang_scene_switch` | `scene-switches-scene-4` |
| `_TZ3002_gdwja9a7` | `TS0726` | `scene-switches-2` |
| `_TZ3002_gdwja9a7` | `TS0726_2_gang` | `scene-switches-2` |
| `_TZ3002_hkaktryd` | `TS0726` | `scene-switches-scene-4` |
| `_TZ3002_hkaktryd` | `TS0726_4_gang_scene_switch` | `scene-switches-scene-4` |
| `_TZ3002_iedhxgyi` | `TS0726` | `scene-switches-scene-3` |
| `_TZ3002_iedhxgyi` | `TS0726_3_gang_scene_switch` | `scene-switches-scene-3` |
| `_TZ3002_jn2x20tg` | `TS0726` | `scene-switches-scene-1` |
| `_TZ3002_jn2x20tg` | `TS0726_1_gang_scene_switch` | `scene-switches-scene-1` |
| `_TZ3002_kq3kqwjt` | `TS0726` | `scene-switches-scene-3` |
| `_TZ3002_kq3kqwjt` | `TS0726_3_gang_scene_switch` | `scene-switches-scene-3` |
| `_TZ3002_l8bfzlcd` | `TS0726` | `scene-switches-1` |
| `_TZ3002_l8bfzlcd` | `TS0726_1_gang` | `scene-switches-1` |
| `_TZ3002_m3pafcnk` | `TS0726` | `scene-switches-3-advanced` |
| `_TZ3002_m3pafcnk` | `TS0726_multi_3_gang` | `scene-switches-3-advanced` |
| `_TZ3002_phu8ygaw` | `TS0726` | `scene-switches-4-advanced` |
| `_TZ3002_phu8ygaw` | `TS0726_multi_4_gang` | `scene-switches-4-advanced` |
| `_TZ3002_pw4ad2xa` | `TS0726` | `scene-switches-4` |
| `_TZ3002_pw4ad2xa` | `TS0726_4_gang` | `scene-switches-4` |
| `_TZ3002_pzao9ls1` | `TS0726` | `scene-switches-scene-4` |
| `_TZ3002_pzao9ls1` | `TS0726_4_gang_scene_switch` | `scene-switches-scene-4` |
| `_TZ3002_rbnycsav` | `TS0726` | `scene-switches-scene-3` |
| `_TZ3002_rbnycsav` | `TS0726_3_gang_scene_switch` | `scene-switches-scene-3` |
| `_TZ3002_sal078g8` | `TS0726` | `scene-switches-scene-6` |
| `_TZ3002_sal078g8` | `TS0726_switch_4g_2s` | `scene-switches-scene-6` |
| `_TZ3002_sfh0jtz0` | `TS0726` | `scene-switches-scene-6` |
| `_TZ3002_sfh0jtz0` | `TS0726_switch_4g_2s` | `scene-switches-scene-6` |
| `_TZ3002_tdf2m4ch` | `TS0726` | `scene-switches-scene-4` |
| `_TZ3002_tdf2m4ch` | `TS0726_4_gang_scene_switch` | `scene-switches-scene-4` |
| `_TZ3002_tlsvxhxc` | `TS0726` | `scene-switches-scene-2` |
| `_TZ3002_tlsvxhxc` | `TS0726_2_gang_scene_switch` | `scene-switches-scene-2` |
| `_TZ3002_u7d3nes3` | `TS0726` | `scene-switches-2` |
| `_TZ3002_u7d3nes3` | `TS0726_2_gang` | `scene-switches-2` |
| `_TZ3002_umdkr64x` | `TS0726` | `scene-switches-scene-4` |
| `_TZ3002_umdkr64x` | `TS0726_4_gang_scene_switch` | `scene-switches-scene-4` |
| `_TZ3002_uu4uircb` | `TS0726` | `scene-switches-4` |
| `_TZ3002_uu4uircb` | `TS0726_4_gang` | `scene-switches-4` |
| `_TZ3002_vaq2bfcu` | `TS0726` | `scene-switches-3-advanced` |
| `_TZ3002_vaq2bfcu` | `TS0726_multi_3_gang` | `scene-switches-3-advanced` |
| `_TZ3002_vsom92pp` | `TS0726` | `scene-switches-scene-3` |
| `_TZ3002_vsom92pp` | `TS0726_3_gang_scene_switch` | `scene-switches-scene-3` |
| `_TZ3002_xkxgfxsg` | `TS0726` | `scene-switches-scene-1` |
| `_TZ3002_xkxgfxsg` | `TS0726_1_gang_scene_switch` | `scene-switches-scene-1` |
| `_TZ3002_ybtqbyk3` | `TS0726` | `scene-switches-scene-3` |
| `_TZ3002_ybtqbyk3` | `TS0726_3_gang_scene_switch` | `scene-switches-scene-3` |
| `_TZ3002_ymv5vytn` | `TS0726` | `scene-switches-scene-2` |
| `_TZ3002_ymv5vytn` | `TS0726_2_gang_scene_switch` | `scene-switches-scene-2` |
| `_TZ3002_yptomml1` | `TS0726` | `scene-switches-4` |
| `_TZ3002_yptomml1` | `TS0726_4_gang` | `scene-switches-4` |
| `_TZ3002_zjuvw9zf` | `TS0726` | `scene-switches-scene-2` |
| `_TZ3002_zjuvw9zf` | `TS0726_2_gang_scene_switch` | `scene-switches-scene-2` |
| `_TZ300A_82iab0pn` | `TS0726` | `scene-switches-4-plus-4` |
| `_TZ300A_fhbcipep` | `TS0726` | `scene-switches-4-plus-2` |
| `_TZ300A_fhbcipep` | `TS0726_4_gang_switch_and_2_scene` | `scene-switches-4-plus-2` |
| `_TZ300A_ohjmifiz` | `TS0726` | `scene-switches-scene-2` |
| `_TZ300A_ohjmifiz` | `TS0726_2_gang_scene_switch` | `scene-switches-scene-2` |
| `_TZ300A_rncj86af` | `TS0726` | `scene-switches-scene-1` |
| `_TZ300A_rncj86af` | `TS0726_1_gang_scene_switch` | `scene-switches-scene-1` |
| `_TZ300A_vkflnsl0` | `TS0726` | `scene-switches-scene-4` |
| `_TZ300A_vkflnsl0` | `TS0726_4_gang_scene_switch` | `scene-switches-scene-4` |
| `_TZ300A_vqrs45nj` | `TS0726` | `scene-switches-scene-3` |
| `_TZ300A_vqrs45nj` | `TS0726_3_gang_scene_switch` | `scene-switches-scene-3` |
| `_TZ3290_785fbxik` | `TS1201` | `controllers-ir-transceiver` |
| `_TZ3290_7v1k4vufotpowp9z` | `TS1201` | `controllers-ir-transceiver` |
| `_TZ3290_7v1k4vufotpowp9z` | `ZS06` | `controllers-ir-transceiver` |
| `_TZ3290_8xzb2ghn` | `TS1201` | `controllers-ir-transceiver` |
| `_TZ3290_acv1iuslxi3shaaj` | `TS1201` | `controllers-ir-transceiver` |
| `_TZ3290_acv1iuslxi3shaaj` | `ZS06` | `controllers-ir-transceiver` |
| `_TZ3290_gnl5a6a5xvql7c2a` | `TS1201` | `controllers-ir-transceiver` |
| `_TZ3290_gnl5a6a5xvql7c2a` | `ZS06` | `controllers-ir-transceiver` |
| `_TZ3290_j37rooaxrcdcqo5n` | `TS1201` | `controllers-ir-transceiver` |
| `_TZ3290_jxvzqatwgsaqzx1u` | `TS1201` | `controllers-ir-transceiver` |
| `_TZ3290_lidgqyzu` | `TS1201` | `controllers-ir-transceiver-battery` |
| `_TZ3290_lypnqvlem5eq1ree` | `TS1201` | `controllers-ir-transceiver` |
| `_TZ3290_nba3knpsarkawgnt` | `TS1201` | `controllers-ir-transceiver` |
| `_TZ3290_nba3knpsarkawgnt` | `ZS06` | `controllers-ir-transceiver` |
| `_TZ3290_nkpxapoz` | `TS1201` | `controllers-ir-transceiver` |
| `_TZ3290_ot6ewjvmejq5ekhl` | `TS1201` | `controllers-ir-transceiver` |
| `_TZ3290_rlkmy85q4pzoxobl` | `TS1201` | `controllers-ir-transceiver` |
| `_TZ3290_rlkmy85q4pzoxobl` | `ZS06` | `controllers-ir-transceiver` |
| `_TZ3290_s6ezpa3j` | `TS1201` | `controllers-ir-transceiver` |
| `_TZ3290_u9xac5rv` | `TS1201` | `controllers-ir-transceiver-battery` |
| `_TZ3290_uc8lwbi2` | `TS1201` | `controllers-ir-transceiver` |
| `_TZ3290_xjpbcxn92aaxvmlz` | `TS1201` | `controllers-ir-transceiver` |
| `_TZ3290_yac64inudpovoaba` | `TS1201` | `controllers-ir-transceiver` |
| `_TZ3290_yac64inudpovoaba` | `ZS06` | `controllers-ir-transceiver` |
| `_TZ3290_yyax9ajf` | `TS1201` | `controllers-ir-transceiver` |
| `_TZ3400_key8kk7r` | `TS0043` | `buttons-button-3-battery` |
| `_TZ3400_keyjhapk` | `TS0042` | `buttons-button-2-battery` |
| `_TZ3400_keyjqthh` | `TS0041` | `buttons-button-1-battery` |
| `_TZ3400_tk3s5tyg` | `TS0041` | `buttons-button-1-battery` |
| `Candeo` | `C-ZB-RD1P-REM` | `controllers-candeo-rd1p-rem` |
| `Candeo` | `C-ZB-SR5BR` | `buttons-button-5-battery-remote-action` |
| `DSS0010` | `Excellux` | `buttons-button-1-battery-operation-mode-remote-action` |
| `eWeLink` | `CK-TLSR8656-SS5-01(7000)` | `buttons-button-1-battery-remote-action` |
| `eWeLink` | `SNZB-01` | `buttons-button-1-battery-remote-action` |
| `HEIMAN` | `ColorDimmerSw-EM-3.0` | `controllers-dimming-battery-remote-action` |
| `HEIMAN` | `DoorBell-EF-3.0` | `buttons-doorbell-battery-tamper-low` |
| `HEIMAN` | `DoorBell-EM` | `buttons-doorbell-battery-tamper-low` |
| `HEIMAN` | `RC-EF-3.0` | `security-remotes-action-battery` |
| `HEIMAN` | `RC-EM` | `security-remotes-heiman-partial-action-battery` |
| `HEIMAN` | `RC-N` | `security-remotes-heiman-partial-action-battery` |
| `HEIMAN` | `SceneSwitch-EF-3.0` | `buttons-heiman-scene-battery-remote-action` |
| `HEIMAN` | `SceneSwitch-EM-3.0` | `buttons-heiman-scene-battery-remote-action` |
| `HEIMAN` | `SOS-EF-3.0` | `buttons-button-1-battery-remote-action` |
| `HEIMAN` | `SOS-EM` | `buttons-button-1-battery-remote-action` |
| `HOBEIAN` | `ZG-101ZL` | `buttons-button-1-battery-operation-mode-remote-action` |
| `MLI` | `Remote Control` | `controllers-dimming-remote-action` |
| `Namron` | `4512772` | `buttons-button-4-battery-remote-action` |
| `Namron AS` | `4512793` | `buttons-button-3-battery` |
| `Shelly` | `1` | `buttons-shelly-one-input` |
| `Shelly` | `BLU Button Tough 1 ZB` | `buttons-button-1-battery-remote-action` |
| `Shelly` | `BLU RC Button 4 ZB` | `buttons-button-4-battery-remote-action` |
| `Shelly` | `BLU Remote Control ZB` | `buttons-button-4-battery-remote-action` |
| `Slacky-DIY` | `TS0041-M001-SlD` | `buttons-button-1-battery-remote-action` |
| `Slacky-DIY` | `TS0041-M002-SlD` | `buttons-button-1-battery-remote-action` |
| `Slacky-DIY` | `TS0041-M005-SlD` | `buttons-button-1-battery-remote-action` |
| `Slacky-DIY` | `TS0042-M003-SlD` | `buttons-button-2-battery-remote-action` |
| `Slacky-DIY` | `TS0042-M006-SlD` | `buttons-button-2-battery-remote-action` |
| `Slacky-DIY` | `TS0042-z-SlD` | `buttons-button-2-battery-remote-action` |
| `Slacky-DIY` | `TS0044-M004-SlD` | `buttons-button-4-battery-remote-action` |
| `Slacky-DIY` | `TS0044-z-SlD` | `buttons-button-4-battery-remote-action` |

</details>

<details>
<summary>ZCL Covers wonjj6768 (41 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports ZCL curtains, blinds, shades, and cover controllers.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TZ3000_1dd0d5yi` | `TS130F` | `covers-cover` |
| `_TZ3000_5iixzdo7` | `TS130F` | `covers-cover` |
| `_TZ3000_74hsp7qy` | `TS130F` | `covers-cover` |
| `_TZ3000_8h7wgocw` | `TS130F` | `covers-cover` |
| `_TZ3000_bmhwnl7s` | `TS130F` | `covers-cover-2` |
| `_TZ3000_bs93npae` | `TS130F` | `covers-cover` |
| `_TZ3000_dojqjapa` | `TS130F` | `covers-cover` |
| `_TZ3000_e3vhyirx` | `TS130F` | `covers-cover` |
| `_TZ3000_egq7y6pr` | `TS130F` | `covers-cover` |
| `_TZ3000_esynmmox` | `TS130F` | `covers-cover-2` |
| `_TZ3000_fccpjz5z` | `TS130F` | `covers-cover` |
| `_TZ3000_femsaaua` | `TS130F` | `covers-cover` |
| `_TZ3000_j1xl73iw` | `TS130F` | `covers-cover-2` |
| `_TZ3000_jwv3cwak` | `TS130F` | `covers-cover` |
| `_TZ3000_kmsbwdol` | `TS130F` | `covers-cover-2` |
| `_TZ3000_l6iqph4f` | `TS130F` | `covers-cover-2` |
| `_TZ3000_vd43bbfq` | `TS130F` | `covers-cover` |
| `_TZ3000_vw8pawxa` | `TS130F` | `covers-cover` |
| `_TZ3000_xdo0hj1k` | `TS130F` | `covers-cover-2` |
| `_TZ3000_yruungrl` | `TS130F` | `covers-cover` |
| `_TZ3000_zirycpws` | `TS130F` | `covers-cover` |
| `_TZ3210_dwytrmda` | `TS130F` | `covers-cover` |
| `_TZ3210_ol1uhvza` | `TS130F` | `covers-cover` |
| `_TZ3210_xbpt8ewc` | `TS130F` | `covers-cover` |
| `_TZB000_42ha4rsc` | `TS030F` | `covers-cover-battery` |
| `_TZE200_9caxna4s` | `TS0301` | `covers-cover-battery` |
| `Aqara` | `lumi.curtain.acn04` | `covers-cover` |
| `eWeLink` | `AM25C-1-25-ES-E-Z` | `covers-cover-battery` |
| `eWeLink` | `CK-MG22-Z310EE07DOOYA-01(7015)` | `covers-cover-battery` |
| `eWeLink` | `MYDY25Z-1` | `covers-cover-battery` |
| `eWeLink` | `ZM25-EAZ` | `covers-cover-battery` |
| `IKEA of Sweden` | `FYRTUR block-out roller blind` | `covers-cover-battery` |
| `IKEA of Sweden` | `KADRILJ roller blind` | `covers-cover-battery` |
| `IKEA of Sweden` | `PRAKTLYSING cellular blind` | `covers-cover-battery` |
| `IKEA of Sweden` | `TREDANSEN block-out cellul blind` | `covers-cover-battery` |
| `LUMI` | `lumi.curtain.acn018` | `covers-cover` |
| `LUMI` | `lumi.curtain.acn04` | `covers-cover` |
| `Sunricher` | `HK-ZCC-A` | `covers-cover` |
| `Third Reality, Inc` | `3RSB015BZ` | `covers-cover-battery` |
| `Third Reality, Inc` | `3RSB02015Z` | `covers-cover-battery` |
| `Third Reality, Inc` | `TRZB3` | `covers-cover-battery` |

</details>

<details>
<summary>ZCL EasyIoT wonjj6768 (6 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports EasyIoT IR, TTS, serial, lock, and occupancy controllers.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `easyiot` | `ZB-24GMS02` | `safety-occupancy-easyiot-24gms02` |
| `easyiot` | `ZB-IR01` | `controllers-easyiot-ir01` |
| `easyiot` | `ZB-RS232` | `controllers-easyiot-rs232` |
| `easyiot` | `ZB-RS485` | `controllers-easyiot-rs485` |
| `easyiot` | `ZB-TTS01` | `controllers-easyiot-tts01` |
| `easyiot` | `ZB-ZL01` | `locks-easyiot-zl01` |

</details>

<details>
<summary>ZCL Lights wonjj6768 (692 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports ZCL lights, dimmers, light controllers, and fan devices.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TYZB01_qezuin6k` | `TS110F` | `lights-dimmer-min` |
| `_TYZB01_v8gtiaed` | `TS110F` | `lights-dimmer-2-min` |
| `_TZ3000_49qchf10` | `TS0502A` | `lights-color-temperature` |
| `_TZ3000_4whigl8i` | `TS0501B` | `lights-dimmer` |
| `_TZ3000_5fkufhn1` | `TS0502A` | `lights-color-temperature` |
| `_TZ3000_6dwfra5l` | `TS0502B` | `lights-color-temperature` |
| `_TZ3000_7dcddnye` | `TS0501A` | `lights-dimmer` |
| `_TZ3000_7hcgjxpc` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3000_7ysdnebc` | `TS1101` | `lights-dimmer-2-ts110-min` |
| `_TZ3000_8uaoilu9` | `TS0502A` | `lights-color-temperature` |
| `_TZ3000_92chsky7` | `TS110F` | `lights-dimmer-2` |
| `_TZ3000_9cpuaca6` | `TS0505A` | `lights-color-temperature-color` |
| `_TZ3000_9evm3otq` | `TS0502A` | `lights-color-temperature` |
| `_TZ3000_bumeauzp` | `TS0502B` | `lights-color-temperature` |
| `_TZ3000_bwlvyjwk` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3000_dbou1ap4` | `TS0505A` | `lights-color-temperature-color` |
| `_TZ3000_el5kt5im` | `TS0502A` | `lights-color-temperature` |
| `_TZ3000_estfrmup` | `TS110F` | `lights-dimmer` |
| `_TZ3000_evag0pvn` | `TS0505A` | `lights-color-temperature-color` |
| `_TZ3000_g1glzzfk` | `TS0502B` | `lights-color-temperature` |
| `_TZ3000_gb5gaeca` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3000_gek6snaj` | `TS0505A` | `lights-color-temperature-color` |
| `_TZ3000_hexqj6ls` | `TS110F` | `lights-dimmer-2` |
| `_TZ3000_iivsrikg` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3000_j0gtlepx` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3000_j2w1dw29` | `TS0501A` | `lights-dimmer` |
| `_TZ3000_juq7i1fr` | `TS0501B` | `lights-dimmer` |
| `_TZ3000_kdpxju99` | `TS0505A` | `lights-color-temperature-color` |
| `_TZ3000_keabpigv` | `TS0505A` | `lights-color-temperature-color` |
| `_TZ3000_ktuoyvt5` | `TS110F` | `lights-dimmer` |
| `_TZ3000_kvwrdf47` | `TS0052` | `lights-dimmer-2-ts110-power-switch-min` |
| `_TZ3000_lxw3zcdk` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3000_mgusv51k` | `TS0052` | `lights-dimmer` |
| `_TZ3000_nbnmw9nc` | `TS0501A` | `lights-dimmer` |
| `_TZ3000_ncb6mkx8` | `TS0004` | `fans-fan-light-switch` |
| `_TZ3000_nosnx7im` | `TS0501A` | `lights-dimmer` |
| `_TZ3000_obacbukl` | `TS0503A` | `lights-color` |
| `_TZ3000_oborybow` | `TS0502A` | `lights-color-temperature` |
| `_TZ3000_odygigth` | `TS0505A` | `lights-color-temperature-color` |
| `_TZ3000_oh7jddmx` | `TS0502A` | `lights-color-temperature` |
| `_TZ3000_q50zhdsc` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3000_qd7hej8u` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3000_quqaeew6` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3000_riwp3k79` | `TS0505A` | `lights-color-temperature-color` |
| `_TZ3000_rylaozuc` | `TS0502A` | `lights-color-temperature` |
| `_TZ3000_sfibawtr` | `TS0052` | `lights-dimmer-2-ts110-power-switch-min` |
| `_TZ3000_sosdczdl` | `TS0505A` | `lights-color-temperature-color` |
| `_TZ3000_taspddvq` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3000_th6zqqy6` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3000_v1srfw9x` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3000_wr6g6olr` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3000_xfs39dbf` | `TS1101` | `lights-dimmer-ts110-min` |
| `_TZ3000_xr5m6kfg` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3000_zjtxnoft` | `TS0052` | `lights-dimmer-2-ts110-power-switch-min` |
| `_TZ3000_zw7wr5uo` | `TS0502B` | `lights-color-temperature` |
| `_TZ3210_09hzmirw` | `TS0502B` | `lights-color-temperature` |
| `_TZ3210_3mpwqzuu` | `TS110E` | `lights-dimmer-2-options-ts110` |
| `_TZ3210_4ubylghk` | `TS110E` | `lights-dimmer-2-options-ts110` |
| `_TZ3210_4whigl8i` | `TS0501` | `fans-switch-fan-mode` |
| `_TZ3210_4zinq6io` | `TS0501B` | `lights-dimmer` |
| `_TZ3210_6pwpez2j` | `TS0502C` | `lights-color-temperature` |
| `_TZ3210_778drfdt` | `TS0503B` | `lights-color` |
| `_TZ3210_9q49basr` | `TS0501B` | `lights-dimmer` |
| `_TZ3210_agjx0pxt` | `TS0501B` | `lights-dimmer` |
| `_TZ3210_b3kiq1i0` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_b8jdosxo` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_bfwvfyx1` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_c0s1xloa` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_c2iwpxf1` | `TS0502B` | `lights-color-temperature` |
| `_TZ3210_cieijuw1` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_claeh5ds` | `TS0502B` | `lights-color-temperature` |
| `_TZ3210_cyuyd5az` | `TS110E` | `lights-dimmer-ts110-power-switch-minmax` |
| `_TZ3210_d062rv7j` | `TS0501B` | `lights-dimmer` |
| `_TZ3210_dbilpfqk` | `TS0501B` | `lights-dimmer` |
| `_TZ3210_dkul5xix` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_dn5higyl` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_dwzfzfjc` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_dxroobu3` | `TS0501B` | `lights-dimmer` |
| `_TZ3210_e5t9bfdv` | `TS0501B` | `lights-dimmer` |
| `_TZ3210_ebbfkvoy` | `TS110F` | `lights-dimmer` |
| `_TZ3210_f0byevky` | `TS0503B` | `lights-color-temperature-color` |
| `_TZ3210_frm6149r` | `TS0502B` | `lights-color-temperature` |
| `_TZ3210_guijtl8k` | `TS110E` | `lights-dimmer-ts110-minmax` |
| `_TZ3210_hicxa0rh` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_hquixjeg` | `TS110E` | `lights-dimmer-ts110-minmax` |
| `_TZ3210_htdm5hvw` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_hxtfthp5` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_hzdhb62z` | `TS110E` | `lights-dimmer-ts110-power-switch` |
| `_TZ3210_hzy4rjz3` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_i680rtja` | `TS0501B` | `lights-dimmer` |
| `_TZ3210_ifga63rg` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_it1u8ahz` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_iw0zkcu8` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_iystcadi` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_jaap6jeb` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_jd3z4yig` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_jicmoite` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_jjqdqxfq` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_jtifm80b` | `TS0502B` | `lights-color-temperature` |
| `_TZ3210_k1msuvg6` | `TS110E` | `lights-dimmer-options-ts110` |
| `_TZ3210_klsm24op` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_lfbz816s` | `TS110F` | `lights-dimmer` |
| `_TZ3210_ljoasixl` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_lzqq3u4r` | `TS0501` | `fans-switch-fan-mode` |
| `_TZ3210_mcm6m1ma` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_mja6r5ix` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_mntza0sw` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_mt5xjoy6` | `TS110E` | `lights-dimmer-2-options-ts110` |
| `_TZ3210_ngqk6jia` | `TS110E` | `lights-dimmer-options-ts110-countdown30` |
| `_TZ3210_o235agwx` | `TS110E` | `lights-dimmer-options-ts110` |
| `_TZ3210_p9ao60da` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_pagajpog` | `TS110E` | `lights-dimmer-2-options-ts110` |
| `_TZ3210_pdqu9pot` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_pwauw3g2` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_qigbovcq` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_r0vzq1oj` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_r0xgkft5` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_r3wubmyh` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_r5afgmkl` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_rcggc0ys` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_s9lumfhn` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_sln7ah6r` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_sroezl0s` | `TS0504B` | `lights-color-temperature-color` |
| `_TZ3210_sw9uxoea` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_syh4kuef` | `TS0501B` | `lights-dimmer` |
| `_TZ3210_tkkb1ym8` | `TS110E` | `lights-dimmer-2-ts110-power-switch` |
| `_TZ3210_ttkgurpb` | `TS0504B` | `lights-color-temperature-color` |
| `_TZ3210_umi6vbsz` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_v5yquxma` | `TS110E` | `lights-dimmer-ts110-power-switch` |
| `_TZ3210_vfwhhldz` | `TS110E` | `lights-dimmer-2-options-ts110` |
| `_TZ3210_wbsgmojq` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_wdexaypg` | `TS110E` | `lights-dimmer-2-options-ts110` |
| `_TZ3210_weaqkhab` | `TS110E` | `lights-dimmer-options-ts110` |
| `_TZ3210_wxa85bwk` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_x13bu7za` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_xwqng7ol` | `TS0502B` | `lights-color-temperature` |
| `_TZ3210_yluvwhjc` | `TS0501B` | `lights-dimmer` |
| `_TZ3210_ysfo0wla` | `TS110E` | `lights-dimmer-ts110-power-minmax` |
| `_TZ3210_z1vlyufu` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_zbabx9wh` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_zrvxvydd` | `TS0505B` | `lights-color-temperature-color` |
| `_TZ3210_zxbtub8r` | `TS110E` | `lights-dimmer-ts110-power-switch-minmax` |
| `_TZ3218_op6ztaju` | `TS0502B` | `lights-color-temperature` |
| `_TZB210_0bkzabht` | `TS0502B` | `lights-color-temperature` |
| `_TZB210_3zfp8mki` | `TS0505B` | `lights-color-temperature-color` |
| `_TZB210_417ikxay` | `TS0505B` | `lights-color-temperature-color` |
| `_TZB210_6eed09b9` | `TS0505B` | `lights-color-temperature-color` |
| `_TZB210_ayx58ft5` | `TS0502B` | `lights-color-temperature` |
| `_TZB210_eiwanbeb` | `TS0502B` | `lights-color-temperature` |
| `_TZB210_endmggws` | `TS0505B` | `lights-color-temperature-color` |
| `_TZB210_g01ie5wu` | `TS0501B` | `lights-dimmer` |
| `_TZB210_gj0ccsar` | `TS0505B` | `lights-color-temperature-color` |
| `_TZB210_lmqquxus` | `TS0503B` | `lights-color-temperature` |
| `_TZB210_lnnkh3f9` | `TS0505B` | `lights-color-temperature-color` |
| `_TZB210_rkgngb5o` | `TS0501B` | `lights-color-temperature` |
| `_TZB210_rs0ufzwg` | `TS0505B` | `lights-color-temperature-color` |
| `_TZB210_rwy5hexp` | `TS0505B` | `lights-color-temperature-color` |
| `_TZB210_u3ri0968` | `TS0505B` | `lights-color-temperature-color` |
| `_TZB210_ue01a0s2` | `TS0502B` | `lights-color-temperature` |
| `_TZB210_uoiqhjqe` | `TS0505B` | `lights-color-temperature-color` |
| `_TZB210_w9hcix2r` | `TS0505B` | `lights-color-temperature-color` |
| `_TZB210_wxazcmsh` | `TS0505B` | `lights-color-temperature-color` |
| `_TZB210_wy1pyu1q` | `TS0505B` | `lights-color-temperature-color` |
| `_TZB210_yatkpuha` | `TS0505B` | `lights-color-temperature-color` |
| `_TZB210_zdvrsts8` | `TS0503B` | `lights-color` |
| `_TZB210_zmppwawa` | `TS0505B` | `lights-color-temperature-color` |
| `Aqara` | `lumi.dimmer.acn004` | `lights-color-temperature` |
| `Aqara` | `lumi.light.acn003` | `lights-color-temperature` |
| `Aqara` | `lumi.light.acn006` | `lights-color-temperature` |
| `Aqara` | `lumi.light.acn026` | `lights-color-temperature` |
| `Aqara` | `lumi.light.acn040` | `lights-color-temperature` |
| `Aqara` | `lumi.light.acn128` | `lights-color-temperature` |
| `Aqara` | `lumi.light.acn132` | `lights-color-temperature-color` |
| `Astuta/ZB-CCT` | `CCT Light` | `lights-color-temperature` |
| `Candeo` | `C-ZB-DM204` | `lights-dimmer` |
| `Candeo` | `C-ZB-DM204V2` | `lights-dimmer-power-voltage-current` |
| `Candeo` | `C-ZB-DM204v2` | `lights-dimmer-power-voltage-current` |
| `Candeo` | `C-ZB-LC20-CCT` | `lights-color-temperature` |
| `Candeo` | `C-ZB-LC20-Dim` | `lights-dimmer` |
| `Candeo` | `C-ZB-LC20-RGB` | `lights-color` |
| `Candeo` | `C-ZB-LC20-RGBCCT` | `lights-color-temperature-color` |
| `Candeo` | `C-ZB-LC20-RGBW` | `lights-color-temperature-color` |
| `Candeo` | `C-ZB-LC20v2-CCT` | `lights-color-temperature` |
| `Candeo` | `C-ZB-LC20v2-Dim` | `lights-dimmer` |
| `Candeo` | `C-ZB-LC20v2-RGB` | `lights-color` |
| `Candeo` | `C-ZB-LC20v2-RGBCCT` | `lights-color-temperature-color` |
| `Candeo` | `C-ZB-LC20v2-RGBW` | `lights-color-temperature-color` |
| `Candeo` | `C-ZB-RD1` | `lights-dimmer` |
| `Candeo` | `C-ZB-RD1P-DIM` | `lights-dimmer` |
| `Candeo` | `C-ZB-RD1P-DPM` | `lights-candeo-rd1p-dpm` |
| `Candeo` | `C203` | `lights-dimmer` |
| `Candeo` | `C204` | `lights-dimmer` |
| `Candeo` | `C210` | `lights-dimmer` |
| `Candeo` | `Candeo Zigbee Dimmer` | `lights-dimmer` |
| `Candeo` | `Dimmer-Switch-ZB3.0` | `lights-dimmer` |
| `Candeo` | `HK-DIM-A` | `lights-dimmer` |
| `Candeo` | `HK-LN-DIM-A` | `lights-dimmer` |
| `CTM Lyng` | `CTM_DimmerPille` | `lights-dimmer` |
| `DOMRAEM` | `CCT` | `lights-color-temperature` |
| `DOMRAEM` | `DIMMER` | `lights-dimmer` |
| `DOMRAEM` | `RGB` | `lights-color` |
| `DOMRAEM` | `RGBW` | `lights-color` |
| `DOMRAEM` | `RGBWC` | `lights-color-temperature-color` |
| `DOMRAEM` | `WW/CW` | `lights-color-temperature` |
| `eWeLi\x01\x10` | `ZB-CL01` | `lights-color-temperature-color` |
| `eWeLight` | `ZB-CL01` | `lights-color-temperature-color` |
| `eWeLight` | `ZB-CL02` | `lights-color-temperature-color` |
| `eWeLink` | `Z102LG03-1` | `lights-color-temperature-color` |
| `eWeLink` | `ZB-CL01` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-B-001P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-B-001Z` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-B-001ZS` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-B-002P` | `lights-color-temperature` |
| `GLEDOPTO` | `GL-B-003P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-B-004P` | `lights-color-temperature` |
| `GLEDOPTO` | `GL-B-007P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-B-007Z` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-B-007ZS` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-B-008P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-B-008Z` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-B-008ZS` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-C-004P` | `lights-color-temperature` |
| `GLEDOPTO` | `GL-D-001P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-D-002P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-D-003P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-D-003Z` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-D-003ZS` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-D-004P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-D-004Z` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-D-004ZS` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-D-005P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-D-005Z` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-D-005ZS` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-D-006P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-D-007P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-D-008P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-D-009P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-D-010P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-D-013P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-D-015P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-FL-001P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-FL-004P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-FL-004TZ` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-FL-004TZP` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-FL-004TZS` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-FL-005P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-FL-005TZ` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-FL-005TZP` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-FL-005TZS` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-FL-006P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-FL-006TZ` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-FL-006TZP` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-FL-006TZS` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-FL-007P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-G-003P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-G-004P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-G-005P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-S-003Z` | `lights-color` |
| `GLEDOPTO` | `GL-S-004P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-S-004Z` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-S-004ZS` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-S-005P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-S-005Z` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-S-007P` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-S-007Z` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-S-007Z(lk)` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-S-007ZS` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-S-008Z` | `lights-color-temperature-color` |
| `GLEDOPTO` | `GL-S-014P` | `lights-color-temperature-color` |
| `Heatit Controls AB` | `Dimmer-Switch-ZB3.0` | `lights-dimmer` |
| `HEIMAN` | `ColorLight` | `lights-color-temperature-color` |
| `HEIMAN` | `TemperLight` | `lights-color-temperature` |
| `Hilux` | `Dimmer-Switch-ZB3.0` | `lights-dimmer` |
| `HZC` | `Dimmer-Switch-ZB3.0` | `lights-dimmer` |
| `idinio` | `Dimmer-Switch-ZB3.0` | `lights-dimmer` |
| `IKEA of Sweden` | `FLOALT panel WS 30x30` | `lights-color-temperature` |
| `IKEA of Sweden` | `FLOALT panel WS 30x90` | `lights-color-temperature` |
| `IKEA of Sweden` | `FLOALT panel WS 60x60` | `lights-color-temperature` |
| `IKEA of Sweden` | `GUNNARP panel 40*40` | `lights-color-temperature` |
| `IKEA of Sweden` | `GUNNARP panel round` | `lights-color-temperature` |
| `IKEA of Sweden` | `JETSTROM 3030 ceiling` | `lights-color-temperature-color` |
| `IKEA of Sweden` | `JETSTROM 3030 NA wall` | `lights-color-temperature-color` |
| `IKEA of Sweden` | `JETSTROM 3030 wall` | `lights-color-temperature-color` |
| `IKEA of Sweden` | `JETSTROM 40100` | `lights-color-temperature` |
| `IKEA of Sweden` | `JETSTROM 40100 NA` | `lights-color-temperature` |
| `IKEA of Sweden` | `JETSTROM 6060` | `lights-color-temperature` |
| `IKEA of Sweden` | `JETSTROM 6060 JP` | `lights-color-temperature` |
| `IKEA of Sweden` | `JETSTROM 6060 NA` | `lights-color-temperature` |
| `IKEA of Sweden` | `JORMLIEN door WS 40x80` | `lights-color-temperature` |
| `IKEA of Sweden` | `LEPTITER Recessed spot light` | `lights-color-temperature` |
| `IKEA of Sweden` | `SURTE door WS 38x64` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E12 CWS 450lm` | `lights-color-temperature-color` |
| `IKEA of Sweden` | `TRADFRI bulb E12 CWS globe 800lm` | `lights-color-temperature-color` |
| `IKEA of Sweden` | `TRADFRI bulb E12 CWS opal 600lm` | `lights-color-temperature-color` |
| `IKEA of Sweden` | `TRADFRI bulb E12 W op/ch 400lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRI bulb E12 WS 450lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E12 WS candle 450lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E12 WS globe 450lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E12 WS opal 400lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E12 WS opal 600lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E14 CWS 470lm` | `lights-color-temperature-color` |
| `IKEA of Sweden` | `TRADFRI bulb E14 CWS globe 806lm` | `lights-color-temperature-color` |
| `IKEA of Sweden` | `TRADFRI bulb E14 CWS opal 600lm` | `lights-color-temperature-color` |
| `IKEA of Sweden` | `TRADFRI bulb E14 W op/ch 400lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRI bulb E14 WS 470lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E14 WS candle 470lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E14 WS globe 470lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E14 WS opal 400lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E14 WS opal 600lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E17 CWS 440lm` | `lights-color-temperature-color` |
| `IKEA of Sweden` | `TRADFRI bulb E17 CWS globe 810lm` | `lights-color-temperature-color` |
| `IKEA of Sweden` | `TRADFRI bulb E17 W op/ch 400lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRI bulb E17 WS 440lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E17 WS candle 440lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E17 WS globe 440lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E17 WS opal 600lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E26 CWS 800lm` | `lights-color-temperature-color` |
| `IKEA of Sweden` | `TRADFRI bulb E26 CWS 806lm` | `lights-color-temperature-color` |
| `IKEA of Sweden` | `TRADFRI bulb E26 CWS 810lm` | `lights-color-temperature-color` |
| `IKEA of Sweden` | `TRADFRI bulb E26 CWS globe 800lm` | `lights-color-temperature-color` |
| `IKEA of Sweden` | `TRADFRI bulb E26 CWS globe 806lm` | `lights-color-temperature-color` |
| `IKEA of Sweden` | `TRADFRI bulb E26 CWS globe 810lm` | `lights-color-temperature-color` |
| `IKEA of Sweden` | `TRADFRI bulb E26 CWS opal 600lm` | `lights-color-temperature-color` |
| `IKEA of Sweden` | `TRADFRI bulb E26 opal 1000lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRI bulb E26 W opal 1000lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRI bulb E26 WS clear 806lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E26 WS clear 950lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E26 WS globe 1055lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E26 WS globe 1100lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E26 WS globe 1160lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E26 WS opal 1000lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E26 WS opal 440lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E26 WS opal 980lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E26 WW 806lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRI bulb E26 WW clear 250lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRI bulb E26 WW G95 CL 440lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRI bulb E26 WW G95 CL 450lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRI bulb E26 WW G95 CL 470lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRI bulb E26 WW globe 800lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRI bulb E26 WW globe 806lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRI bulb E26 WW globe 810lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRI bulb E27 C/WS opal 600` | `lights-color-temperature-color` |
| `IKEA of Sweden` | `TRADFRI bulb E27 CWS 806lm` | `lights-color-temperature-color` |
| `IKEA of Sweden` | `TRADFRI bulb E27 CWS globe 806lm` | `lights-color-temperature-color` |
| `IKEA of Sweden` | `TRADFRI bulb E27 CWS opal 600lm` | `lights-color-temperature-color` |
| `IKEA of Sweden` | `TRADFRI bulb E27 opal 1000lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRI bulb E27 opal 470lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E27 W opal 1000lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRI bulb E27 W opal 470lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E27 WS clear 806lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E27 WS clear 950lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E27 WS globe 1055lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E27 WS opal 1000lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E27 WS opal 980lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E27 WS�clear 950lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E27 WS�opal 980lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb E27 WW 806lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRI bulb E27 WW clear 250lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRI bulb E27 WW G95 CL 470lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRI bulb E27 WW globe 806lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRI bulb GU10 CWS 345lm` | `lights-color-temperature-color` |
| `IKEA of Sweden` | `TRADFRI bulb GU10 CWS 380lm` | `lights-color-temperature-color` |
| `IKEA of Sweden` | `TRADFRI bulb GU10 W 400lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRI bulb GU10 WS 345lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb GU10 WS 380lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb GU10 WS 400lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRI bulb GU10 WW 345lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRI bulb GU10 WW 380lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRI bulb GU10 WW 400lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRI_bulb_GU10_WS_345lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbB22WSglobeopal1055lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbE12WScandleopal450lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbE12WSglobeopal470lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbE12WWcandleclear250lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRIbulbE12WWclear250lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRIbulbE14WScandleopal470lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbE14WSglobeopal470lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbE14WWclear250lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRIbulbE17WScandleopal440lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbE17WSglobeopal470lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbE17WWclear250lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRIbulbE26WSglobeclear800lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbE26WSglobeclear806lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbE26WSglobeclear810lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbE26WSglobeopal1055lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbE26WSglobeopal1100lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbE26WSglobeopal1160lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbE26WWclear250lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRIbulbE26WWglobeclear250lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRIbulbE27WSglobeclear806lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbE27WSglobeopal1055lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbE27WWclear250lm` | `lights-dimmer` |
| `IKEA of Sweden` | `TRADFRIbulbG125E26WSopal440lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbG125E26WSopal450lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbG125E26WSopal470lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbG125E27WSopal470lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbGU10WS345lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbGU10WS380lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbPAR38WS900lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbT120E26WSopal440lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbT120E26WSopal450lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbT120E26WSopal470lm` | `lights-color-temperature` |
| `IKEA of Sweden` | `TRADFRIbulbT120E27WSopal470lm` | `lights-color-temperature` |
| `Iluminize` | `DIM Lighting` | `lights-dimmer` |
| `Iluminize` | `RGBW-CCT` | `lights-color-temperature-color` |
| `Iluminize` | `RGBWW Lighting` | `lights-color-temperature-color` |
| `Innr` | `AE 260` | `lights-dimmer` |
| `Innr` | `AE 262` | `lights-dimmer` |
| `Innr` | `AE 264` | `lights-dimmer` |
| `Innr` | `AE 270 T` | `lights-color-temperature` |
| `Innr` | `AE 270 T-2` | `lights-color-temperature` |
| `Innr` | `AE 280 C` | `lights-color-temperature-color` |
| `Innr` | `AE 282 C` | `lights-color-temperature-color` |
| `Innr` | `AE 287 C` | `lights-color-temperature-color` |
| `Innr` | `BB 262` | `lights-dimmer` |
| `Innr` | `BB 282 C` | `lights-color-temperature-color` |
| `Innr` | `BB 287 C` | `lights-color-temperature-color` |
| `Innr` | `BB 287 C-2` | `lights-color-temperature-color` |
| `Innr` | `BE 220` | `lights-dimmer` |
| `Innr` | `BF 263` | `lights-dimmer` |
| `Innr` | `BF 265` | `lights-dimmer` |
| `Innr` | `BY 165` | `lights-dimmer` |
| `Innr` | `BY 178 T` | `lights-color-temperature-color` |
| `Innr` | `BY 185 C` | `lights-color-temperature-color` |
| `Innr` | `BY 265` | `lights-dimmer` |
| `Innr` | `BY 266` | `lights-dimmer` |
| `Innr` | `BY 285 C` | `lights-color-temperature-color` |
| `Innr` | `BY 286 C` | `lights-color-temperature-color` |
| `Innr` | `FL 122 C` | `lights-color-temperature-color` |
| `Innr` | `FL 230 C` | `lights-color-temperature-color` |
| `Innr` | `FL 250 C` | `lights-color-temperature-color` |
| `Innr` | `OFL 120 C` | `lights-color-temperature-color` |
| `Innr` | `OFL 122 C` | `lights-color-temperature-color` |
| `Innr` | `OFL 140 C` | `lights-color-temperature-color` |
| `Innr` | `OFL 142 C` | `lights-color-temperature-color` |
| `Innr` | `OGL 130 C` | `lights-color-temperature-color` |
| `Innr` | `OLS 210` | `lights-dimmer` |
| `Innr` | `OPL 130 C` | `lights-color-temperature-color` |
| `Innr` | `PL 110` | `lights-dimmer` |
| `Innr` | `PL 115` | `lights-dimmer` |
| `Innr` | `RB 162` | `lights-dimmer` |
| `Innr` | `RB 165` | `lights-dimmer` |
| `Innr` | `RB 172 W` | `lights-dimmer` |
| `Innr` | `RB 175 W` | `lights-dimmer` |
| `Innr` | `RB 178 T` | `lights-color-temperature` |
| `Innr` | `RB 185 C` | `lights-color-temperature-color` |
| `Innr` | `RB 246 T` | `lights-color-temperature-color` |
| `Innr` | `RB 250 C` | `lights-color-temperature-color` |
| `Innr` | `RB 251 C` | `lights-color-temperature-color` |
| `Innr` | `RB 252 C` | `lights-color-temperature-color` |
| `Innr` | `RB 255 C` | `lights-color-temperature-color` |
| `Innr` | `RB 256 C` | `lights-color-temperature-color` |
| `Innr` | `RB 262` | `lights-dimmer` |
| `Innr` | `RB 265` | `lights-dimmer` |
| `Innr` | `RB 266` | `lights-dimmer` |
| `Innr` | `RB 267` | `lights-dimmer` |
| `Innr` | `RB 272 T` | `lights-color-temperature` |
| `Innr` | `RB 278 T` | `lights-color-temperature` |
| `Innr` | `RB 279 T` | `lights-color-temperature` |
| `Innr` | `RB 282 C` | `lights-color-temperature-color` |
| `Innr` | `RB 285 C` | `lights-color-temperature-color` |
| `Innr` | `RB 286 C` | `lights-color-temperature-color` |
| `Innr` | `RB 287 C` | `lights-color-temperature-color` |
| `Innr` | `RCL 110` | `lights-dimmer` |
| `Innr` | `RCL 231 T` | `lights-color-temperature` |
| `Innr` | `RCL 232 C` | `lights-color-temperature-color` |
| `Innr` | `RF 261` | `lights-dimmer` |
| `Innr` | `RF 262` | `lights-dimmer` |
| `Innr` | `RF 263` | `lights-dimmer` |
| `Innr` | `RF 264` | `lights-dimmer` |
| `Innr` | `RF 265` | `lights-dimmer` |
| `Innr` | `RF 271 T` | `lights-color-temperature` |
| `Innr` | `RF 273 T` | `lights-color-temperature` |
| `Innr` | `RF 274 T` | `lights-color-temperature` |
| `Innr` | `RSL 110` | `lights-dimmer` |
| `Innr` | `RSL 115` | `lights-dimmer` |
| `Innr` | `ST 110` | `lights-dimmer` |
| `Innr` | `UC 110` | `lights-dimmer` |
| `KURVIA` | `ZB-CL01` | `lights-color-temperature-color` |
| `LDS` | `ZBT-CCTLight-GU100904` | `lights-color-temperature` |
| `LEDVANCE` | `A60 DIM T` | `lights-dimmer` |
| `LEDVANCE` | `A60 FIL DIM T` | `lights-dimmer` |
| `LEDVANCE` | `A60 RGBW B22D T` | `lights-color-temperature-color` |
| `LEDVANCE` | `A60 RGBW T` | `lights-color-temperature-color` |
| `LEDVANCE` | `A60 RGBW Value II` | `lights-color-temperature-color` |
| `LEDVANCE` | `A60 TW T` | `lights-color-temperature` |
| `LEDVANCE` | `A60S RGBW` | `lights-color-temperature-color` |
| `LEDVANCE` | `A60S TW` | `lights-color-temperature` |
| `LEDVANCE` | `B40 DIM T` | `lights-dimmer` |
| `LEDVANCE` | `B40 TW T` | `lights-color-temperature` |
| `LEDVANCE` | `B40 TW Z3` | `lights-color-temperature` |
| `LEDVANCE` | `B40S TW` | `lights-color-temperature` |
| `LEDVANCE` | `CLA60 RGBW JP` | `lights-color-temperature-color` |
| `LEDVANCE` | `CLA60 TW Value` | `lights-color-temperature` |
| `LEDVANCE` | `Connected Tube Value II` | `lights-dimmer` |
| `LEDVANCE` | `DR_ZBD_NFC_P_45W_220-240V_1A2` | `lights-dimmer` |
| `LEDVANCE` | `EDISON60 FIL DIM T` | `lights-dimmer` |
| `LEDVANCE` | `FLEX RGBW T` | `lights-color-temperature-color` |
| `LEDVANCE` | `FLEX RGBW Z3` | `lights-color-temperature-color` |
| `LEDVANCE` | `Gardenpole Mini RGBW Z3` | `lights-color-temperature-color` |
| `LEDVANCE` | `GARDENPOLE RGBW T` | `lights-color-temperature-color` |
| `LEDVANCE` | `GLOBE60 FIL DIM T` | `lights-dimmer` |
| `LEDVANCE` | `LEDVANCE DIM` | `lights-dimmer` |
| `LEDVANCE` | `OUTDOOR FLEX RGBW T` | `lights-color-temperature-color` |
| `LEDVANCE` | `Outdoor FLEX RGBW Z3` | `lights-color-temperature-color` |
| `LEDVANCE` | `P40 DIM T` | `lights-dimmer` |
| `LEDVANCE` | `P40 TW T` | `lights-color-temperature` |
| `LEDVANCE` | `P40 TW Value` | `lights-color-temperature` |
| `LEDVANCE` | `P40S TW` | `lights-color-temperature` |
| `LEDVANCE` | `Panel Light 2x2 TW` | `lights-color-temperature-color` |
| `LEDVANCE` | `Panel TW 620 UGR19` | `lights-color-temperature-color` |
| `LEDVANCE` | `Panel TW Z3` | `lights-color-temperature` |
| `LEDVANCE` | `PAR16 DIM T` | `lights-dimmer` |
| `LEDVANCE` | `PAR16 RGBW T` | `lights-color-temperature-color` |
| `LEDVANCE` | `PAR16 RGBW Value` | `lights-color-temperature-color` |
| `LEDVANCE` | `PAR16 TW T` | `lights-color-temperature` |
| `LEDVANCE` | `PAR16S RGBW` | `lights-color-temperature-color` |
| `LEDVANCE` | `PAR16S TW` | `lights-color-temperature` |
| `LEDVANCE` | `PL HCL300x1200 01` | `lights-color-temperature` |
| `LEDVANCE` | `PL_HCL600_01` | `lights-color-temperature` |
| `LEDVANCE` | `PL_HCL625_01` | `lights-color-temperature` |
| `LEDVANCE` | `Tibea TW Z3` | `lights-color-temperature` |
| `LEDVANCE` | `Undercabinet TW Z3` | `lights-color-temperature` |
| `Legrand` | `Dimmer switch with neutral` | `lights-dimmer` |
| `Letsleds China` | `RGBW Down Light` | `lights-color-temperature-color` |
| `Light` | `01F` | `lights-color-temperature-color` |
| `Light Solutions` | `Dimmer-Switch-ZB3.0` | `lights-dimmer` |
| `LUMI` | `lumi.dimmer.acn003` | `lights-color-temperature` |
| `LUMI` | `lumi.dimmer.acn004` | `lights-color-temperature` |
| `LUMI` | `lumi.dimmer.acn005` | `lights-color-temperature` |
| `LUMI` | `lumi.light.acn003` | `lights-color-temperature` |
| `LUMI` | `lumi.light.acn004` | `lights-color-temperature` |
| `LUMI` | `lumi.light.acn006` | `lights-color-temperature` |
| `LUMI` | `lumi.light.acn014` | `lights-color-temperature` |
| `LUMI` | `lumi.light.acn023` | `lights-color-temperature` |
| `LUMI` | `lumi.light.acn024` | `lights-color-temperature` |
| `LUMI` | `lumi.light.acn025` | `lights-color-temperature` |
| `LUMI` | `lumi.light.acn026` | `lights-color-temperature` |
| `LUMI` | `lumi.light.acn040` | `lights-color-temperature` |
| `LUMI` | `lumi.light.acn128` | `lights-color-temperature` |
| `LUMI` | `lumi.light.acn132` | `lights-color-temperature-color` |
| `LUMI` | `lumi.light.aqcn02` | `lights-color-temperature` |
| `LUMI` | `lumi.light.cbacn1` | `lights-dimmer` |
| `LUMI` | `lumi.light.cwac02` | `lights-color-temperature` |
| `LUMI` | `lumi.light.cwacn1` | `lights-color-temperature` |
| `LUMI` | `lumi.light.cwjwcn01` | `lights-color-temperature` |
| `LUMI` | `lumi.light.cwjwcn02` | `lights-color-temperature` |
| `LUMI` | `lumi.light.cwopcn01` | `lights-color-temperature` |
| `LUMI` | `lumi.light.cwopcn02` | `lights-color-temperature` |
| `LUMI` | `lumi.light.cwopcn03` | `lights-color-temperature` |
| `LUMI` | `lumi.light.rgbac1` | `lights-color-temperature-color` |
| `Megaman\x00` | `ZLL-DimmableLight` | `lights-dimmer` |
| `MLI` | `Bulb white` | `lights-color-temperature` |
| `MLI` | `Bulb white+color` | `lights-color-temperature-color` |
| `MLI` | `Candle white+color` | `lights-color-temperature-color` |
| `MLI` | `Ceiling light` | `lights-color-temperature-color` |
| `MLI` | `Desk lamp` | `lights-color-temperature-color` |
| `MLI` | `Garden light` | `lights-color-temperature-color` |
| `MLI` | `GU10 white+color` | `lights-color-temperature-color` |
| `MLI` | `LED Strip` | `lights-color-temperature-color` |
| `MLI` | `ZBT-DimmableLight` | `lights-dimmer` |
| `Namron` | `4512751` | `lights-dimmer` |
| `Namron As` | `DIM Lighting` | `lights-dimmer` |
| `Nordtronic` | `98426061` | `lights-dimmer` |
| `Nordtronic` | `WSZ 98426061` | `lights-dimmer` |
| `Nordtronic A/S` | `98426061` | `lights-dimmer` |
| `Nordtronic A/S` | `WSZ 98426061` | `lights-dimmer` |
| `NorLum Dim OP` | `DIMMER` | `lights-dimmer` |
| `OSRAM` | `A60 DIM Z3` | `lights-dimmer` |
| `OSRAM` | `A60 TW Z3` | `lights-color-temperature` |
| `OSRAM` | `B40 DIM Z3` | `lights-dimmer` |
| `OSRAM` | `Ceiling TW OSRAM` | `lights-color-temperature` |
| `OSRAM` | `CLA60 RGBW II Z3` | `lights-color-temperature-color` |
| `OSRAM` | `CLA60 RGBW OSRAM` | `lights-color-temperature-color` |
| `OSRAM` | `CLA60 RGBW Z3` | `lights-color-temperature-color` |
| `OSRAM` | `CLA60 TW OSRAM` | `lights-color-temperature` |
| `OSRAM` | `Classic A60 RGBW` | `lights-color-temperature-color` |
| `OSRAM` | `Classic A60 TW` | `lights-color-temperature` |
| `OSRAM` | `Classic A60 W clear - LIGHTIFY` | `lights-dimmer` |
| `OSRAM` | `Classic B40 TW - LIGHTIFY` | `lights-color-temperature` |
| `OSRAM` | `Connected Tube Z3` | `lights-dimmer` |
| `OSRAM` | `Control box TW` | `lights-color-temperature` |
| `OSRAM` | `Flex Outdoor RGBW` | `lights-color-temperature-color` |
| `OSRAM` | `Flex RGBW` | `lights-color-temperature-color` |
| `OSRAM` | `Gardenpole Mini RGBW OSRAM` | `lights-color-temperature-color` |
| `OSRAM` | `Gardenpole RGBW Z3` | `lights-color-temperature-color` |
| `OSRAM` | `Gardenpole RGBW-Lightify` | `lights-color-temperature-color` |
| `OSRAM` | `Gardenspot RGB` | `lights-color` |
| `OSRAM` | `Gardenspot W` | `lights-dimmer` |
| `OSRAM` | `LIGHTIFY A19 Tunable White` | `lights-color-temperature` |
| `OSRAM` | `LIGHTIFY FLEX OUTDOOR RGBW` | `lights-color-temperature-color` |
| `OSRAM` | `LIGHTIFY Flex RGBW` | `lights-color-temperature-color` |
| `OSRAM` | `LIGHTIFY Indoor Flex RGBW` | `lights-color-temperature-color` |
| `OSRAM` | `LIGHTIFY Outdoor Flex RGBW` | `lights-color-temperature-color` |
| `OSRAM` | `LIGHTIFY PAR38 ON/OFF/DIM` | `lights-dimmer` |
| `OSRAM` | `LIGHTIFY RT RGBW` | `lights-color-temperature-color` |
| `OSRAM` | `LIGHTIFY Under Cabinet TW` | `lights-color-temperature` |
| `OSRAM` | `MR16 TW OSRAM` | `lights-color-temperature` |
| `OSRAM` | `Outdoor Lantern B50 RGBW OSRAM` | `lights-color-temperature-color` |
| `OSRAM` | `Outdoor Lantern W RGBW OSRAM` | `lights-color-temperature-color` |
| `OSRAM` | `Panel TW 595 UGR22` | `lights-color-temperature` |
| `OSRAM` | `PAR 16 50 RGBW - LIGHTIFY` | `lights-color-temperature-color` |
| `OSRAM` | `PAR16 50 TW` | `lights-color-temperature` |
| `OSRAM` | `PAR16 DIM Z3` | `lights-dimmer` |
| `OSRAM` | `PAR16 RGBW Z3` | `lights-color-temperature-color` |
| `OSRAM` | `PAR16 TW Z3` | `lights-color-temperature` |
| `OSRAM` | `SubstiTube` | `lights-dimmer` |
| `OSRAM` | `Surface Light TW` | `lights-color-temperature` |
| `OSRAM` | `Zigbee 3.0 DALI CONV LI` | `lights-color-temperature` |
| `OSRAM` | `ZLO-CeilingTW-OS` | `lights-color-temperature` |
| `Paulmann` | `984.43` | `lights-dimmer` |
| `Paulmann lamp` | `CCT Light` | `lights-color-temperature` |
| `Paulmann lamp` | `Dimmable Light` | `lights-dimmer` |
| `Paulmann Licht` | `RGBW` | `lights-color` |
| `Paulmann Licht` | `RGBW Controller` | `lights-color-temperature-color` |
| `Paulmann Licht GmbH` | `CCT` | `lights-color-temperature` |
| `Paulmann Licht GmbH` | `CCT-I` | `lights-color-temperature` |
| `Paulmann Licht GmbH` | `Dimmable` | `lights-dimmer` |
| `Paulmann Licht GmbH` | `RGB` | `lights-color` |
| `Paulmann Licht GmbH` | `RGBW` | `lights-color` |
| `Philips` | `5633030P9` | `lights-color-temperature` |
| `Philips` | `8720169264212` | `lights-color-temperature-color` |
| `Philips` | `8720169264274` | `lights-color-temperature-color` |
| `Philips` | `9290012574` | `lights-color-temperature-color` |
| `Philips` | `929003099302` | `lights-color-temperature` |
| `Philips` | `929003115901` | `lights-color-temperature-color` |
| `Philips` | `929003116201` | `lights-color-temperature-color` |
| `Philips` | `929003711301` | `lights-dimmer` |
| `Philips` | `929003711401` | `lights-dimmer` |
| `Philips` | `929003777201` | `lights-color-temperature` |
| `Philips` | `929003822801` | `lights-dimmer` |
| `Philips` | `929003823001` | `lights-color-temperature` |
| `Philips` | `929003823101` | `lights-color-temperature` |
| `Philips` | `929003823201` | `lights-color-temperature` |
| `Philips` | `929003823301` | `lights-color-temperature` |
| `Philips` | `929003823401` | `lights-color-temperature` |
| `Philips` | `929003823601` | `lights-color-temperature-color` |
| `Philips` | `929003823701` | `lights-color-temperature-color` |
| `Philips` | `929003823801` | `lights-color-temperature-color` |
| `Philips` | `929003823901` | `lights-color-temperature-color` |
| `Philips` | `929003824001` | `lights-color-temperature-color` |
| `Philips` | `929003845801` | `lights-dimmer` |
| `Philips` | `929003845901` | `lights-dimmer` |
| `Philips` | `929003846001` | `lights-color-temperature` |
| `Philips` | `929003846101` | `lights-color-temperature` |
| `Philips` | `929003846201` | `lights-color-temperature-color` |
| `Philips` | `929003846301` | `lights-color-temperature-color` |
| `Philips` | `929003846401` | `lights-color-temperature` |
| `Philips` | `929003846501` | `lights-color-temperature` |
| `Philips` | `929003846601` | `lights-color-temperature-color` |
| `Philips` | `929003846701` | `lights-color-temperature-color` |
| `Philips` | `929003853701` | `lights-color-temperature-color` |
| `Philips` | `929004608003` | `lights-color-temperature-color` |
| `Philips` | `929004608004` | `lights-color-temperature-color` |
| `Philips` | `929004608101` | `lights-color-temperature-color` |
| `Philips` | `929004608103` | `lights-color-temperature-color` |
| `Philips` | `929004608201` | `lights-color-temperature-color` |
| `Samotech` | `Dimmer-Switch-ZB3.0` | `lights-dimmer` |
| `Samotech` | `HK_DIM_A` | `lights-dimmer` |
| `Seastar Intelligence` | `07073L` | `lights-color-temperature-color` |
| `Shyugj` | `Dimmer-Switch-ZB3.0` | `lights-dimmer` |
| `Shyugj` | `HK_DIM_A` | `lights-dimmer` |
| `Smart Dim` | `Dimmer-Switch-ZB3.0` | `lights-dimmer` |
| `Sunricher` | `3986` | `lights-color-temperature` |
| `Sunricher` | `CCT Lighting` | `lights-color-temperature` |
| `Sunricher` | `DIM` | `lights-dimmer-2` |
| `Sunricher` | `DIM Lighting` | `lights-dimmer` |
| `Sunricher` | `HK-DIM` | `lights-dimmer` |
| `Sunricher` | `HK-SL-DIM-A` | `lights-dimmer` |
| `Sunricher` | `HK-SL-DIM-AU-K-A` | `lights-dimmer-power-voltage-current` |
| `Sunricher` | `HK-SL-DIM-AU-R-A` | `lights-dimmer-power-voltage-current` |
| `Sunricher` | `HK-SL-DIM-CLN` | `lights-dimmer` |
| `Sunricher` | `HK-SL-DIM-EU-A` | `lights-dimmer-power-voltage-current` |
| `Sunricher` | `HK-SL-DIM-UK` | `lights-dimmer-power-voltage-current` |
| `Sunricher` | `HK-SL-DIM-US-A` | `lights-dimmer-power-voltage-current` |
| `Sunricher` | `HK-SL-RDIM-A` | `lights-dimmer-power-voltage-current` |
| `Sunricher` | `HK-ZD-CCT-A` | `lights-color-temperature` |
| `Sunricher` | `HK-ZD-DIM-A` | `lights-dimmer` |
| `Sunricher` | `Micro Smart Dimmer` | `lights-dimmer-power-voltage-current` |
| `Sunricher` | `SM311` | `lights-dimmer-power-voltage-current` |
| `Sunricher` | `SR-ZG9040A-S` | `lights-dimmer` |
| `Sunricher` | `ZG2837RAC-K4` | `lights-dimmer-power-voltage-current` |
| `Sunricher` | `ZG9101SAC-HP` | `lights-dimmer` |
| `TERNCY` | `CL001` | `lights-color-temperature` |
| `TERNCY` | `DL001` | `lights-color-temperature` |
| `Third Reality` | `3RCB02070Z` | `lights-color-temperature-color` |
| `Third Reality, Inc` | `3RSL011Z` | `lights-color-temperature` |
| `Third Reality, Inc` | `3RSL012Z` | `lights-color-temperature` |
| `YSRSAI` | `ZB-CL01` | `lights-color-temperature-color` |
| `YSRSAI` | `ZB-CL03` | `lights-color-temperature-color` |
| `ZB/Ajax Online` | `CCT Light` | `lights-color-temperature` |
| `ZigBee/CCT` | `CCT Light` | `lights-color-temperature` |

</details>

<details>
<summary>ZCL Plugs wonjj6768 (110 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports ZCL plugs, metered outlets, and power strips.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TYZB01_7yidyqxd` | `TS0108` | `plugs-switch-2` |
| `_TYZB01_ijihzffk` | `TS0101` | `plugs-switch` |
| `_TYZB01_mtunwanm` | `TS011F` | `plugs-switch-child-lock` |
| `_TZ3000_00mk2xzy` | `TS011F` | `plugs-lidl-hg06337` |
| `_TZ3000_0yxeawjt` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3000_1hwjutgo` | `TS011F` | `plugs-switch` |
| `_TZ3000_266azbg3` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3000_2putqrmw` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3000_2uollq9d` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3000_3ias4w4o` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3000_3uimvkn6` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3000_4ux0ondb` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3000_8a833yls` | `TS011F` | `plugs-switch-tuya-options` |
| `_TZ3000_8fdayfch` | `TS011F` | `plugs-switch` |
| `_TZ3000_9ni6xxld` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3000_amdymr7l` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3000_b1q8kwmh` | `TS011F` | `plugs-zemismart-zmo606-20a` |
| `_TZ3000_b28wrpvx` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3000_bfn1w0mm` | `TS011F` | `plugs-switch-tuya-options` |
| `_TZ3000_br3laukf` | `TS0101` | `plugs-switch` |
| `_TZ3000_c7nc9w3c` | `TS011F` | `plugs-wp30-power-strip` |
| `_TZ3000_cehuw1lw` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3000_cicwjqth` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3000_cjrngdr3` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3000_gjnozsaz` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3000_hyfvrar3` | `TS011F` | `plugs-switch-tuya-options` |
| `_TZ3000_j1v25l17` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3000_ko6v90pg` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3000_ksw8qtmt` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3000_lnggrqqi` | `TS011F` | `plugs-switch` |
| `_TZ3000_nzkqcvvs` | `TS011F` | `plugs-switch-tuya-options` |
| `_TZ3000_o1jzcxou` | `TS011F` | `plugs-switch-tuya-options` |
| `_TZ3000_oiymh3qu` | `TS011F` | `plugs-switch` |
| `_TZ3000_okaz9tjs` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3000_plyvnuf5` | `TS011F` | `plugs-lidl-hg06337` |
| `_TZ3000_pnzfdr9y` | `TS0101` | `plugs-switch` |
| `_TZ3000_rtcrrvia` | `TS011F` | `plugs-switch-tuya-options` |
| `_TZ3000_ss98ec5d` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3000_tvuarksa` | `TS011F` | `plugs-switch` |
| `_TZ3000_upjrsxh1` | `TS011F` | `plugs-lidl-hg06337` |
| `_TZ3000_uyrhiafs` | `TS011F` | `plugs-switch-tuya-options` |
| `_TZ3000_v1pdxuqq` | `TS011F` | `plugs-switch-tuya-options` |
| `_TZ3000_w0qqde0g` | `TS011F` | `plugs-switch-power-energy-voltage-current-ts011f-plug1-no-button` |
| `_TZ3000_wamqdr3f` | `TS011F` | `plugs-lidl-hg06337` |
| `_TZ3000_ww6drja5` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3000_wxtp7c5y` | `TS011F` | `plugs-switch-child-lock` |
| `_TZ3000_y4ona9me` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3000_ynmowqk2` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3000_ysiog9xi` | `TS011F` | `plugs-switch-tuya-options` |
| `_TZ3000_yujkchbz` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3000_zloso4jk` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3008_1a8m8wd6` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3008_iooniers` | `TS011F` | `plugs-switch-power-energy-voltage-current-ts011f-plug1` |
| `_TZ3008_qziabvzj` | `TS011F` | `plugs-switch-power-energy-voltage-current-ts011f-plug1` |
| `_TZ3008_reatplte` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3008_tary5dvv` | `TS011F` | `plugs-switch-power-energy-voltage-current-ts011f-plug1` |
| `_TZ3008_xvfd3nkp` | `TS011F` | `plugs-switch-power-energy-voltage-current-ts011f-plug1` |
| `_TZ3210_2dfy6tol` | `TS0101` | `plugs-switch` |
| `_TZ3210_2putqrmw` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3210_2uollq9d` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3210_4ux0ondb` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3210_5ct6e7ye` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3210_6cmeijtd` | `TS011F` | `plugs-nous-a11z` |
| `_TZ3210_c7nc9w3c` | `TS011F` | `plugs-wp30-power-strip` |
| `_TZ3210_cjrngdr3` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3210_ddigca5n` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3210_eymunffl` | `TS0101` | `plugs-switch` |
| `_TZ3210_iooniers` | `TS011F` | `plugs-switch-power-energy-voltage-current-ts011f-plug1` |
| `_TZ3210_jlf1nepw` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3210_nhqka112` | `TS011F` | `plugs-switch-tuya-options` |
| `_TZ3210_rwmitwj4` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `_TZ3210_tfxwxklq` | `TS0101` | `plugs-switch` |
| `_TZ3210_w0qqde0g` | `TS011F` | `plugs-switch-power-energy-voltage-current-ts011f-plug1` |
| `_TZ3210_zifx0xoj` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `AduroSmart ERIA` | `ONOFF_METER_RELAY` | `plugs-switch-power-voltage-current` |
| `AOYAN  ` | `TS011F` | `plugs-switch-power-energy-voltage-current` |
| `Bacchus` | `Water_Station` | `plugs-bacchus-water-station` |
| `Bacchus` | `Water_Station.Modkam` | `plugs-bacchus-water-station` |
| `frient A/S` | `SMRZB-153` | `switches-switch-1-power-energy-voltage-current` |
| `HEIMAN` | `SmartPlug` | `plugs-switch-power-energy-voltage-current` |
| `Heiman` | `SmartPlug` | `plugs-switch-power-energy-voltage-current` |
| `HEIMAN` | `SmartPlug-EF-3.0` | `plugs-switch-power-energy-voltage-current` |
| `HEIMAN` | `SmartPlug-N` | `plugs-switch-power-voltage-current` |
| `Innr` | `SP 242` | `plugs-switch-power-energy-voltage` |
| `Innr` | `SP 244` | `plugs-switch-power-energy-voltage` |
| `LEDVANCE` | `Outdoor Plug` | `plugs-switch` |
| `LEDVANCE` | `PLUG COMPACT EU EM T` | `plugs-switch-power-energy-voltage-current` |
| `LEDVANCE` | `PLUG COMPACT EU T` | `plugs-switch` |
| `LEDVANCE` | `PLUG COMPACT OUTDOOR EU EM T` | `plugs-switch-power-energy-voltage-current` |
| `LEDVANCE` | `PLUG OUTDOOR EU T` | `plugs-switch` |
| `LEDVANCE` | `Plug Value` | `plugs-switch` |
| `LUMI` | `lumi.ctrl_86plug` | `plugs-switch-power-energy-voltage` |
| `LUMI` | `lumi.ctrl_86plug.aq1` | `plugs-switch-power-energy-voltage` |
| `LUMI` | `lumi.plug` | `plugs-switch-power-energy-voltage` |
| `LUMI` | `lumi.plug.aeu001` | `plugs-switch-power-energy-voltage-current` |
| `LUMI` | `lumi.plug.aq1` | `plugs-switch-power-energy-voltage` |
| `LUMI` | `lumi.plug.macn01` | `plugs-switch-power-energy-voltage-current` |
| `LUMI` | `lumi.plug.maeu01` | `plugs-switch-power-energy-voltage-current` |
| `LUMI` | `lumi.plug.maus01` | `plugs-switch-power-energy-voltage-current` |
| `LUMI` | `lumi.plug.mitw01` | `plugs-switch-power-energy-voltage` |
| `LUMI` | `lumi.plug.mmeu01` | `plugs-switch-power-energy-voltage-current` |
| `LUMI` | `lumi.plug.sacn02` | `plugs-switch-power-energy-voltage-current` |
| `OSRAM` | `Plug 01` | `plugs-switch` |
| `OSRAM` | `Plug Z3` | `plugs-switch` |
| `Schneider Electric` | `SMARTPLUG/1` | `switch-power-energy` |
| `SONOFF` | `S60ZBTPG` | `plugs-switch-power-energy-voltage` |
| `Third Reality, Inc` | `3RSP019BZ` | `plugs-switch` |
| `Third Reality, Inc` | `3RSP02028BZ` | `plugs-switch-power-energy-voltage-current` |
| `Third Reality, Inc` | `3RSPE01044BZ` | `plugs-switch-power-energy-voltage-current` |
| `Zbeacon` | `TS011F` | `plugs-switch-power-energy-voltage-current` |

</details>

<details>
<summary>ZCL Sensors wonjj6768 (394 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports ZCL sensors, safety devices, sirens, and repeaters.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TYZB01_0w3d5uw3` | `TS0204` | `safety-gas-detector-tamper` |
| `_TYZB01_2jzbhomb` | `SM0202` | `safety-motion-battery-low-battery-voltage` |
| `_TYZB01_4mdqxxnn` | `TS0222` | `sensors-illuminance-battery` |
| `_TYZB01_4obovpbi` | `TS0216` | `safety-alarm-battery` |
| `_TYZB01_5nr7ncpl` | `TS0202` | `safety-motion-battery-low-battery-voltage` |
| `_TYZB01_821siati` | `TS0210` | `safety-acceleration-battery-tuya-pending` |
| `_TYZB01_8scntis1` | `TS0216` | `safety-alarm-battery` |
| `_TYZB01_bwsijaty` | `TS0219` | `safety-alarm-battery-volume` |
| `_TYZB01_cbiezpds` | `SM0201` | `sensors-temp-humidity-battery-voltage` |
| `_TYZB01_epni2jgy` | `TS0203` | `safety-contact-tamper-battery-low-battery-voltage` |
| `_TYZB01_fi5yftwv` | `TS0222` | `sensors-illuminance-temp-humidity-battery-konke-pending` |
| `_TYZB01_ftdkanlj` | `TS0222` | `sensors-illuminance-temp-humidity-battery` |
| `_TYZB01_jytabjkb` | `TS0202` | `safety-motion-battery-low-battery-voltage` |
| `_TYZB01_kvwjujy9` | `TS0222` | `sensors-illuminance-temp-humidity-battery` |
| `_TYZB01_lzrhtcxu` | `SM0201` | `sensors-temp-humidity-battery` |
| `_TYZB01_m6ec2pgj` | `TS0222` | `sensors-illuminance-battery` |
| `_TYZB01_qjqgmqxr` | `TS0202` | `safety-motion-tamper-battery-low-battery-voltage` |
| `_TYZB01_rs7ff6o7` | `TS0219` | `safety-alarm-battery-volume` |
| `_TYZB01_sbpc1zrb` | `TS0216` | `safety-alarm-battery` |
| `_TYZB01_sqmd19i1` | `TS0207` | `safety-water-leak-tamper-battery-low-battery` |
| `_TYZB01_ttvdudvx` | `TS0207` | `safety-water-leak-battery-low-battery` |
| `_TYZB01_ujfk3xd9` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TYZB01_vwqnz1sn` | `TS0202` | `safety-motion-illuminance-tamper-battery-low-battery` |
| `_TYZB01_wpmo3ja3` | `TS0212` | `safety-co-detector-battery-low-battery` |
| `_TYZB01_wqcac7lo` | `TS0205` | `safety-smoke-tamper-battery` |
| `_TYZB01_ynsiasng` | `TS0219` | `safety-alarm-battery-volume` |
| `_TYZB01_yr95mpib` | `SM0202` | `safety-motion-battery-low-battery-voltage` |
| `_TYZB01_z2umiwvq` | `SM0202` | `safety-motion-battery-low-battery-voltage` |
| `_TYZB01_zqvwka4k` | `SM0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ1800_ejwkn2h2` | `TY0203` | `safety-contact-tamper-battery` |
| `_TZ1800_fcdjzz3s` | `TY0202` | `safety-motion-tamper-battery-battery-low` |
| `_TZ1800_ho6i0zk9` | `TY0203` | `safety-contact-tamper-battery` |
| `_TZ3000_0s1izerx` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_0s9gukzt` | `TS0207` | `safety-water-leak-tamper-battery-low-battery` |
| `_TZ3000_1twfmkcc` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_26fmupbb` | `TS0203` | `safety-contact-tamper-battery-voltage` |
| `_TZ3000_2mbfxlzr` | `TS0203` | `safety-contact-battery-low-battery-voltage` |
| `_TZ3000_45y4bdjb` | `SM0212` | `safety-gas-detector-tamper-battery-low` |
| `_TZ3000_4ugnzsli` | `TS0203` | `safety-contact-battery-low-battery-voltage` |
| `_TZ3000_5k5vh43t` | `TS0207` | `network-repeater` |
| `_TZ3000_6uzkisv2` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_6ygjfyll` | `TS0202` | `safety-motion-battery-low-battery-voltage-ih012-pending` |
| `_TZ3000_7d8yme6f` | `TS0203` | `safety-contact-tamper-battery-low-battery-voltage` |
| `_TZ3000_7kscdesh` | `TS0222` | `sensors-illuminance-battery` |
| `_TZ3000_7y90pany` | `TS0222` | `sensors-illuminance-battery` |
| `_TZ3000_82ptnsd4` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_8uxxzz4b` | `TS0222` | `sensors-illuminance-battery` |
| `_TZ3000_8ybe88nf` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_8yhypbo7` | `TS0203` | `safety-contact-tamper-battery-low-battery-voltage` |
| `_TZ3000_996rpfy6` | `TS0203` | `safety-contact-battery-low-battery-voltage` |
| `_TZ3000_9kbbfeho` | `TS0222` | `sensors-illuminance-battery` |
| `_TZ3000_abaplimj` | `TS0207` | `safety-water-leak-tamper-battery-low-battery` |
| `_TZ3000_akqdg6g7` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_amqudjr0` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_awvmkayh` | `TS0207` | `safety-water-leak-tamper-battery-low-battery` |
| `_TZ3000_bgsigers` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_bguser20` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_bjawzodf` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_bjawzodf` | `TY0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_bpkijo14` | `TS0203` | `safety-contact-battery-low-battery-voltage` |
| `_TZ3000_bsvqrxru` | `TS0202` | `safety-motion-battery-low-battery-voltage` |
| `_TZ3000_c8bqthpo` | `TS0207` | `safety-water-leak-tamper-battery-low-battery` |
| `_TZ3000_ceplrhnu` | `TS0222` | `sensors-illuminance-temp-humidity-battery` |
| `_TZ3000_decxrtwa` | `TS0203` | `safety-contact-tamper-battery-low-battery-voltage` |
| `_TZ3000_do6txrcw` | `TS0222` | `sensors-illuminance-battery` |
| `_TZ3000_dowj6gyi` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_eit7p838` | `TS0207` | `safety-water-leak-tamper-battery-low-battery` |
| `_TZ3000_f2bw0b6k` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_fie1dpkm` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_fllyghyj` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_gdsvhfao` | `TS0001` | `network-repeater` |
| `_TZ3000_gntwytxo` | `TS0203` | `safety-contact-battery-low-battery-voltage` |
| `_TZ3000_gszjt2xx` | `TS0207` | `network-repeater` |
| `_TZ3000_h4wnrtck` | `TS0202` | `safety-motion-tamper-battery-low-battery-voltage` |
| `_TZ3000_hgm6k8ku` | `TS0207` | `network-repeater` |
| `_TZ3000_hktqahrq` | `TS0202` | `safety-motion-tamper-battery-low-battery-voltage` |
| `_TZ3000_hktqahrq` | `WHD02` | `safety-motion-tamper-battery-battery-low` |
| `_TZ3000_hy6ncvmw` | `TS0222` | `sensors-illuminance-battery` |
| `_TZ3000_isw9u95y` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_itnrsufe` | `TS0201` | `sensors-temp-humidity-battery-voltage-kctw1z-pending` |
| `_TZ3000_j6adk9id` | `TS0222` | `sensors-illuminance-battery` |
| `_TZ3000_jmrgyl7o` | `TS0202` | `safety-motion-tamper-battery-low-battery-voltage` |
| `_TZ3000_k4ej3ww2` | `TS0207` | `safety-water-leak-battery-low-battery` |
| `_TZ3000_kkerjand` | `TS0601` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_kky16aay` | `TS0222` | `sensors-illuminance-temp-humidity-battery` |
| `_TZ3000_kstbkt6a` | `TS0207` | `safety-water-leak-battery-low-battery` |
| `_TZ3000_kxlmv9ag` | `TS0207` | `network-repeater` |
| `_TZ3000_kyb656no` | `TS0207` | `safety-water-leak-tamper-battery-low-battery` |
| `_TZ3000_l6rsaipj` | `TS0222` | `sensors-illuminance-battery` |
| `_TZ3000_lbtpiody` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_lf56vpxj` | `TS0202` | `safety-motion-tamper-battery-low-battery-voltage` |
| `_TZ3000_lltemgsf` | `TS0202` | `safety-motion-battery-low-battery-voltage` |
| `_TZ3000_lqmvrwa2` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_lzdjjfss` | `TS0210` | `safety-acceleration-battery-tuya-pending` |
| `_TZ3000_m0vaazab` | `TS0207` | `network-repeater` |
| `_TZ3000_mcxw5ehu` | `TS0202` | `safety-motion-battery-low-battery-voltage-ih012-pending` |
| `_TZ3000_mg4dy6z6` | `TS0202` | `safety-motion-battery-low-battery-voltage` |
| `_TZ3000_misw04hq` | `TS0207` | `network-repeater` |
| `_TZ3000_mmzmkkd4` | `TS0207` | `network-repeater` |
| `_TZ3000_mqiev3jk` | `TS0207` | `safety-water-leak-tamper-battery-low-battery` |
| `_TZ3000_msl6wxk9` | `TS0202` | `safety-motion-battery-low-battery-voltage-ih012-pending` |
| `_TZ3000_mugyhz0q` | `TS0207` | `safety-water-leak-battery-low-battery` |
| `_TZ3000_mwd3c2at` | `TS0202` | `safety-motion-battery-low` |
| `_TZ3000_mxzo5rhf` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_n0lphcok` | `TS0001` | `network-repeater` |
| `_TZ3000_n0lphcok` | `TS0207` | `network-repeater` |
| `_TZ3000_n2egfsli` | `TS0203` | `safety-contact-battery-low-battery-voltage` |
| `_TZ3000_nkkl7uzv` | `TS0207` | `network-repeater` |
| `_TZ3000_nlsszmzl` | `TS0207` | `network-repeater` |
| `_TZ3000_nss8amz9` | `TS0202` | `safety-motion-battery-low-battery-voltage` |
| `_TZ3000_o4mkahkc` | `TS0202` | `safety-motion-tamper-battery-low-battery-voltage-ih012-pending` |
| `_TZ3000_ocjlo4ea` | `TS0207` | `safety-water-leak-tamper-battery-low-battery` |
| `_TZ3000_osu834un` | `TS0203` | `safety-contact-tamper-battery-voltage` |
| `_TZ3000_otvn3lne` | `TS0202` | `safety-motion-tamper-battery-low-battery-voltage` |
| `_TZ3000_oxslv1c9` | `TS0203` | `safety-contact-tamper-battery-voltage` |
| `_TZ3000_piuensvr` | `TS0207` | `network-repeater` |
| `_TZ3000_pjb1ua0m` | `TS0203` | `safety-c3007-pressure-battery-low-battery-voltage` |
| `_TZ3000_qaaysllp` | `TS0201` | `sensors-illuminance-temp-humidity-battery-lcz030-pending` |
| `_TZ3000_qomxlryd` | `TS0202` | `safety-motion-tamper-battery-low-battery-voltage` |
| `_TZ3000_qrldbmfn` | `TS0203` | `safety-contact-tamper-battery-low-battery-voltage` |
| `_TZ3000_r80pzsb9` | `TS0207` | `network-repeater` |
| `_TZ3000_rcuyhwe3` | `TS0203` | `safety-contact-battery-low-battery-voltage` |
| `_TZ3000_rdhukkmi` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_rid8lzvo` | `TS0203` | `safety-contact-tamper-battery-low-battery-voltage` |
| `_TZ3000_rusu2vzb` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_saiqcn0y` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_sgpbz53b` | `TS0207` | `network-repeater` |
| `_TZ3000_shopg9ss` | `TS0207` | `network-repeater` |
| `_TZ3000_t3vvhrmh` | `TS0203` | `safety-contact-battery-low-battery-voltage` |
| `_TZ3000_t6jriawg` | `TS0207` | `safety-water-leak-tamper-battery-low-battery` |
| `_TZ3000_t9qqxn70` | `TS0222` | `sensors-illuminance-temp-humidity-battery` |
| `_TZ3000_timx9ivq` | `TS0203` | `safety-contact-battery-voltage` |
| `_TZ3000_trdx8uxs` | `TS0001` | `network-repeater` |
| `_TZ3000_ubuikmgo` | `TS0222` | `sensors-illuminance-temp-humidity-battery` |
| `_TZ3000_udyjylt7` | `TS0203` | `safety-contact-tamper-battery-low-battery-voltage` |
| `_TZ3000_ufttklsz` | `TS0207` | `network-repeater` |
| `_TZ3000_upgcbody` | `TS0207` | `safety-water-leak-battery-low-battery` |
| `_TZ3000_utwgoauk` | `SNZB-02` | `sensors-temp-humidity-battery` |
| `_TZ3000_v1w2k9dd` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_v7chgqso` | `TS0203` | `safety-contact-tamper-battery-low-battery-voltage` |
| `_TZ3000_vdfwjopk` | `TS0219` | `safety-alarm-volume` |
| `_TZ3000_wbrlnkm9` | `TS0203` | `safety-contact-tamper-battery-low-battery-voltage` |
| `_TZ3000_wlquqiiz` | `TS0207` | `network-repeater` |
| `_TZ3000_wmlc9p9z` | `TS0207` | `network-repeater` |
| `_TZ3000_wn65ixz9` | `TS0001` | `network-repeater` |
| `_TZ3000_xr3htd96` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_yd2e749y` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_yfekcy3n` | `TS0203` | `safety-contact-battery-low-battery-voltage` |
| `_TZ3000_yujem9ee` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_yupc0pb7` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_ywagc4rj` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_zfirri2d` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_zl1kmjqx` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3000_zl1kmjqx` | `TY0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3040_6ygjfyll` | `TS0202` | `safety-motion-battery-low-battery-voltage-ih012-pending` |
| `_TZ3040_bb6xaihh` | `TS0202` | `safety-motion-tamper-battery-low-battery-voltage` |
| `_TZ3040_fwxuzcf4` | `TS0202` | `safety-motion-battery-low-battery` |
| `_TZ3040_msl6wxk9` | `TS0202` | `safety-motion-battery-low-battery` |
| `_TZ3040_wqmtjsyk` | `TS0202` | `safety-motion-tamper-battery-low-battery-voltage` |
| `_TZ3210_0aqbrnts` | `TS0202` | `safety-motion-illuminance-temp-humidity-tamper-battery` |
| `_TZ3210_alxkwn0h` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3210_cwamkvua` | `TS0202` | `safety-motion-battery-voltage` |
| `_TZ3210_jijr1sss` | `TS0202` | `safety-motion-illuminance-temp-humidity-tamper-battery` |
| `_TZ3210_jowhpxop` | `TS0203` | `safety-contact-tamper-battery-low-battery-tuya-scene-pending` |
| `_TZ3210_kjafhwd2` | `TS0210` | `safety-acceleration-battery-tuya-pending` |
| `_TZ3210_m3mxv66l` | `TS0202` | `safety-motion-illuminance-temp-humidity-tamper-battery` |
| `_TZ3210_ncw88jfq` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `_TZ3210_oekbi7o4` | `TS0202` | `safety-motion-illuminance-temp-humidity-tamper-battery` |
| `_TZ3210_ohvnwamm` | `TS0202` | `safety-motion-illuminance-temp-humidity-tamper-battery` |
| `_TZ3210_p68kms0l` | `TS0207` | `safety-rain-battery-rb-srain01` |
| `_TZ3210_rxqls8v0` | `TS0202` | `safety-motion-illuminance-temp-humidity-tamper-battery` |
| `_TZ3210_tgvtvdoc` | `TS0207` | `safety-rain-battery-rb-srain01` |
| `_TZ3210_up3pngle` | `TS0205` | `safety-smoke-tamper-battery` |
| `_TZ3210_wuhzzfqg` | `TS0202` | `safety-motion-illuminance-temp-humidity-tamper-battery` |
| `_TZ3210_zmy9hjay` | `TS0202` | `safety-motion-illuminance-temp-humidity-tamper-battery` |
| `_TZE204_myd45weu` | `TS0222` | `sensors-illuminance-temp-humidity-battery` |
| `AduroSmart Eria` | `Smart Siren` | `safety-alarm-battery` |
| `Aeotec` | `ZGA008` | `network-repeater` |
| `AOYAN` | `AY222Z` | `safety-water-leak-tamper-battery-low-battery` |
| `AOYAN  ` | `AY-101Z` | `safety-contact-tamper-battery-low-battery-voltage` |
| `AOYAN  ` | `AY222Z` | `safety-water-leak-tamper-battery-low-battery` |
| `Candeo` | `C-ZB-SEDC` | `safety-contact-battery` |
| `Candeo` | `C-ZB-SEMO` | `safety-motion-illuminance-battery-candeo-pending` |
| `Candeo` | `C-ZB-SETE` | `sensors-temp-humidity-battery` |
| `Candeo` | `C-ZB-SEWA` | `safety-water-leak-battery` |
| `Centralite` | `3157100` | `thermostats-centralite-thermostat` |
| `Centralite` | `3157100-E` | `thermostats-centralite-thermostat` |
| `computime` | `PUMM01102` | `thermostats-thermostat` |
| `Danfoss` | `0x0042` | `thermostats-thermostat-battery` |
| `Danfoss` | `0x0200` | `thermostats-thermostat-battery` |
| `Danfoss` | `0x0210` | `thermostats-thermostat-battery` |
| `Danfoss` | `0x0211` | `thermostats-thermostat-battery` |
| `Danfoss` | `0x8020` | `thermostats-thermostat-battery` |
| `Danfoss` | `0x8021` | `thermostats-thermostat-battery` |
| `Danfoss` | `0x8030` | `thermostats-thermostat-battery` |
| `Danfoss` | `0x8031` | `thermostats-thermostat-battery` |
| `Danfoss` | `0x8034` | `thermostats-thermostat-battery` |
| `Danfoss` | `0x8035` | `thermostats-thermostat-battery` |
| `Danfoss` | `0x8040` | `thermostats-thermostat-battery` |
| `Danfoss` | `0x8041` | `thermostats-thermostat-battery` |
| `Danfoss` | `devi_f` | `thermostats-thermostat` |
| `easyiot` | `ZB-GW04` | `network-repeater` |
| `easyiot` | `ZB-GW04-1v1` | `network-repeater` |
| `easyiot` | `ZB-GW04-1v2` | `network-repeater` |
| `easyiot` | `ZB-LTH01` | `sensors-illuminance-temp-humidity-battery` |
| `eCozy` | `Thermostat` | `thermostats-ecozy-thermostat` |
| `Espressif` | `ZigbeeRangeExtender` | `network-repeater` |
| `Eurotronic` | `SPZB0001` | `thermostats-thermostat-battery` |
| `eWeLink` | `CK-BL702-ROUTER-01(7018)` | `network-repeater` |
| `eWeLink` | `CK-TLSR8656-SS5-01(7002)` | `safety-motion-battery-low-battery-voltage-ewelink-pending` |
| `eWeLink` | `CK-TLSR8656-SS5-01(7003)` | `safety-contact-battery-low-battery-voltage` |
| `eWeLink` | `CK-TLSR8656-SS5-01(7014)` | `sensors-temp-humidity-battery-voltage` |
| `eWeLink` | `CK-TLSR8656-SS5-01(7019)` | `safety-water-leak-battery-low-battery` |
| `eWeLink` | `SNZB-02` | `sensors-temp-humidity-battery-voltage` |
| `eWeLink` | `SNZB-04` | `safety-contact-battery-low-battery-voltage` |
| `eWeLink` | `SNZB-05` | `safety-water-leak-battery-low-battery` |
| `Fireangel` | `Alarm_SD_Device` | `safety-co-detector-tamper-battery-low` |
| `Frient` | `HMSZB-120` | `sensors-temp-humidity-battery-voltage` |
| `frient A/S` | `SIRZB-112` | `safety-siren-frient-sirzb112` |
| `frient A/S` | `WISZB-131` | `safety-contact-temp-battery-low-battery` |
| `HEIMAN` | `319fa36e7384414a9ea62cba8f6e7626` | `safety-smoke-battery-low-battery` |
| `HEIMAN` | `358e4e3e03c644709905034dae81433e` | `safety-gas-detector-tamper-battery-low` |
| `HEIMAN` | `98293058552c49f38ad0748541ee96ba` | `safety-smoke-battery-low-battery` |
| `HEIMAN` | `b5db59bfd81e4f1f95dc57fdbba17931` | `safety-smoke-battery-low-battery` |
| `Heiman` | `b5db59bfd81e4f1f95dc57fdbba17931` | `safety-smoke-battery-low-battery` |
| `HEIMAN` | `c3442b4ac59b4ba1a83119d938f283ab` | `safety-smoke-battery-low-battery` |
| `Heiman` | `CO_CTPG` | `safety-co-detector-battery-low-battery` |
| `Heiman` | `CO_V15` | `safety-co-detector-battery-low-battery` |
| `Heiman` | `CO_V16` | `safety-co-detector-battery-low-battery` |
| `HEIMAN` | `COSensor-EF-3.0` | `safety-co-detector-battery-low-battery` |
| `HEIMAN` | `COSensor-EM` | `safety-co-detector-battery-low-battery` |
| `HEIMAN` | `COSensor-N` | `safety-co-detector-battery-low-battery` |
| `HEIMAN` | `D1-EF2-3.0` | `safety-contact-tamper-battery-low-battery` |
| `HEIMAN` | `d90d7c61c44d468a8e906ca0841e0a0c` | `safety-gas-detector-tamper-battery-low` |
| `HEIMAN` | `DOOR_TPV12` | `safety-contact-tamper-battery-low` |
| `HEIMAN` | `DOOR_TPV13` | `safety-contact-tamper-battery-low` |
| `HEIMAN` | `DoorSensor-EF-3.0` | `safety-contact-tamper-battery-low-battery` |
| `HEIMAN` | `DoorSensor-EM` | `safety-contact-tamper-battery-low-battery` |
| `HEIMAN` | `DoorSensor-N` | `safety-contact-tamper-battery-low-battery` |
| `HEIMAN` | `DoorSensor-N-3.0` | `safety-contact-tamper-battery-low-battery` |
| `HEIMAN` | `FB56-SMF02HM1.4` | `safety-smoke-battery-low-battery` |
| `HEIMAN` | `GAS_V15` | `safety-gas-detector-tamper-battery-low` |
| `Heiman` | `GAS_V15` | `safety-gas-detector-tamper-battery-low` |
| `HEIMAN` | `GASSensor-EF-3.0` | `safety-gas-detector-tamper-battery-low` |
| `HEIMAN` | `GASSensor-EFR-3.0` | `safety-gas-detector-tamper-battery-low` |
| `HEIMAN` | `GASSensor-EM` | `safety-gas-detector-tamper-battery-low` |
| `HEIMAN` | `GASSensor-EN` | `safety-gas-detector-tamper-battery-low` |
| `HEIMAN` | `GASSensor-N` | `safety-gas-detector-tamper-battery-low` |
| `HEIMAN` | `GASSensor-N-3.0` | `safety-gas-detector-tamper-battery-low` |
| `HEIMAN` | `HS15A-M` | `safety-smoke-battery-low-battery` |
| `HEIMAN` | `HS1SA-E-PLUS` | `safety-smoke-temp-battery-low-battery-heiman-pending` |
| `HEIMAN` | `HS1SA-EF-3.0` | `safety-smoke-temp-battery-low-battery-heiman-pending` |
| `HEIMAN` | `HS2AQ-EM` | `sensors-heiman-hs2aq-air-quality` |
| `HEIMAN` | `HS2AQ-EM-3.0` | `sensors-heiman-hs2aq-air-quality` |
| `HEIMAN` | `HS2SA-EF-3.0` | `safety-smoke-battery-low-battery` |
| `HEIMAN` | `HS3HT-EFA-3.0` | `sensors-temp-humidity-battery` |
| `HEIMAN` | `HS8DS-EF2-3.0` | `safety-contact-battery-low-battery` |
| `HEIMAN` | `HS9MS-E` | `safety-motion-illuminance-tamper-battery-low-battery` |
| `HEIMAN` | `HT-EF-3.0` | `sensors-temp-humidity-battery` |
| `HEIMAN` | `HT-EM` | `sensors-temp-humidity-battery` |
| `HEIMAN` | `HT-N` | `sensors-temp-humidity-battery` |
| `HEIMAN` | `HY0022` | `safety-gas-detector-tamper-battery-low` |
| `HEIMAN` | `PIR_TPV12` | `safety-motion-tamper-battery-battery-low` |
| `HEIMAN` | `PIR_TPV13` | `safety-motion-tamper-battery-low` |
| `Heiman` | `PIR_TPV13` | `safety-motion-tamper-battery-low` |
| `HEIMAN` | `PIR_TPV16` | `safety-motion-tamper-battery-low` |
| `Heiman` | `PIR_TPV16` | `safety-motion-tamper-battery-low` |
| `HEIMAN` | `PIRILLSensor-EF-3.0` | `safety-motion-battery` |
| `HEIMAN` | `PIRSensor-EF-3.0` | `safety-motion-tamper-battery-low` |
| `HEIMAN` | `PIRSensor-EM` | `safety-motion-tamper-battery-low` |
| `HEIMAN` | `PIRSensor-N` | `safety-motion-tamper-battery-low` |
| `HEIMAN` | `PIRSensor-N-3.0` | `safety-motion-tamper-battery-low` |
| `HEIMAN` | `RH3070` | `safety-gas-detector-tamper-battery-low` |
| `HEIMAN` | `SMOK_HV14` | `safety-smoke-battery-low-battery` |
| `Heiman` | `SMOK_HV14` | `safety-smoke-battery-low-battery` |
| `HEIMAN` | `SMOK_V15` | `safety-smoke-battery-low-battery` |
| `HEIMAN` | `SMOK_V16` | `safety-smoke-battery-low-battery` |
| `Heiman` | `SMOK_V16` | `safety-smoke-battery-low-battery` |
| `HEIMAN` | `SMOK_YDLV10` | `safety-smoke-battery-low-battery` |
| `Heiman` | `SMOK_YDLV10` | `safety-smoke-battery-low-battery` |
| `HEIMAN` | `SMOK_YDLV10N` | `safety-smoke-battery-low-battery` |
| `HEIMAN` | `SmokeSensor-EF-3.0` | `safety-smoke-battery-low-battery` |
| `HEIMAN` | `Smokesensor-EF2-3.0` | `safety-smoke-battery-low-battery` |
| `HEIMAN` | `SmokeSensor-EM` | `safety-smoke-battery-low-battery` |
| `HEIMAN` | `SmokeSensor-N` | `safety-smoke-battery-low-battery` |
| `HEIMAN` | `SmokeSensor-N-3.0` | `safety-smoke-battery-low-battery` |
| `HEIMAN` | `TH-EM` | `sensors-temp-humidity-battery` |
| `HEIMAN` | `TH-T_V14` | `sensors-temp-humidity-battery` |
| `HEIMAN` | `TY0202` | `safety-motion-tamper-battery-low` |
| `HEIMAN` | `TY0207` | `safety-water-leak-tamper-battery-low-battery` |
| `HEIMAN` | `Vibration-EF-3.0` | `safety-acceleration-tamper-battery-low-battery` |
| `HEIMAN` | `Vibration-EF_3.0` | `safety-acceleration-tamper-battery-low-battery` |
| `HEIMAN` | `Vibration-N` | `safety-acceleration-tamper-battery-low-battery` |
| `Heiman` | `WarningDevice` | `safety-alarm-battery` |
| `HEIMAN` | `WATER_TPV13` | `safety-water-leak-tamper-battery-low-battery` |
| `HEIMAN` | `WaterSensor-EF-3.0` | `safety-water-leak-tamper-battery-low-battery` |
| `HEIMAN` | `WaterSensor-EM` | `safety-water-leak-tamper-battery-low-battery` |
| `HEIMAN` | `WaterSensor-N` | `safety-water-leak-tamper-battery-low-battery` |
| `HEIMAN` | `WaterSensor-N-3.0` | `safety-water-leak-tamper-battery-low-battery` |
| `HEIMAN` | `WaterSensor2-EF-3.0` | `safety-water-leak-temp-battery-low-battery` |
| `Hive` | `SLR2d` | `thermostats-hive-dual-thermostat-pending` |
| `Inswift` | `ZBM-MG24` | `network-repeater` |
| `LDS` | `ZHA-PirSensor` | `safety-motion-tamper-battery-battery-low` |
| `Leedarson` | `ZHA-PIRSensor` | `safety-motion-illuminance` |
| `LINCUKOO` | `SZT06` | `sensors-temp-humidity-battery-voltage` |
| `LUMI` | `lumi.flood.acn001` | `safety-water-leak-battery-low-battery-voltage` |
| `LUMI` | `lumi.flood.agl02` | `safety-water-leak-tamper-battery-low-battery-voltage` |
| `LUMI` | `lumi.magnet.ac01` | `safety-contact-tamper-battery-voltage` |
| `LUMI` | `lumi.magnet.acn001` | `safety-contact-battery-low-battery-voltage` |
| `LUMI` | `lumi.magnet.agl02` | `safety-contact-battery-voltage` |
| `LUMI` | `lumi.motion.ac02` | `safety-motion-illuminance-battery` |
| `LUMI` | `lumi.motion.acn001` | `safety-motion-illuminance-battery` |
| `LUMI` | `lumi.motion.agl02` | `safety-motion-illuminance-battery` |
| `LUMI` | `lumi.sen_ill.agl01` | `sensors-illuminance-battery-voltage-lumi-pending` |
| `LUMI` | `lumi.sen_ill.mgl01` | `sensors-illuminance-battery-voltage-lumi-pending` |
| `LUMI` | `lumi.sens` | `sensors-temp-humidity-battery-voltage` |
| `LUMI` | `lumi.sensor_ht` | `sensors-temp-humidity-battery-voltage` |
| `LUMI` | `lumi.sensor_ht.agl02` | `sensors-temp-humidity-pressure-battery-voltage` |
| `LUMI` | `lumi.sensor_magnet` | `safety-contact-battery-voltage` |
| `LUMI` | `lumi.sensor_magnet.aq2` | `safety-contact-battery-voltage` |
| `LUMI` | `lumi.sensor_motion` | `safety-motion-battery-voltage` |
| `LUMI` | `lumi.sensor_motion.aq2` | `safety-motion-illuminance-battery` |
| `LUMI` | `lumi.sensor_wleak.aq1` | `safety-water-leak-battery-low-battery-voltage` |
| `LUMI` | `lumi.weather` | `sensors-temp-humidity-pressure-battery-voltage` |
| `NabuCasa` | `SkyConnect` | `network-repeater` |
| `NabuCasa` | `ZBT-2` | `network-repeater` |
| `Namron` | `4512771` | `safety-motion-illuminance-temp-humidity-battery` |
| `Namron` | `4512783` | `thermostats-thermostat-humidity-power-energy-current` |
| `Namron` | `4512784` | `thermostats-thermostat-humidity-power-energy-current` |
| `Namron` | `4566702` | `thermostats-thermostat-humidity-power-energy-current` |
| `Namron` | `4566703` | `thermostats-thermostat-humidity-power-energy-current` |
| `Salus Controls` | `FC600NH` | `thermostats-fcu-thermostat` |
| `Schneider Electric` | `755WSA` | `safety-smoke-temp-tamper-battery-low-battery-voltage-schneider-pending` |
| `Schneider Electric` | `CCTFR6700` | `thermostats-schneider-heating-power-energy-pending` |
| `Schneider Electric` | `CCTFR6710` | `thermostats-schneider-heating-power-energy-pending` |
| `Schneider Electric` | `Thermostat` | `thermostats-schneider-room-thermostat-pending` |
| `Schneider Electric` | `W599501` | `safety-smoke-temp-tamper-battery-low-battery-voltage-schneider-pending` |
| `Shelly` | `BLU DoorWindow ZB` | `safety-contact-illuminance-battery-low-handle-shelly` |
| `Shelly` | `BLU H&T Display ZB` | `sensors-illuminance-temp-humidity-battery` |
| `Shelly` | `BLU H&T ZB` | `sensors-temp-humidity-battery` |
| `Shelly` | `BLU Motion ZB` | `safety-motion-illuminance-battery-low-battery` |
| `Shelly` | `Dimmer` | `lights-dimmer-power-voltage-current` |
| `Shelly` | `Dimmer US` | `lights-dimmer-power-voltage-current` |
| `Shelly` | `Ecowitt WS90` | `sensors-weather-temp-humidity-pressure-illuminance-battery-ws90` |
| `Shelly` | `Flood` | `safety-water-leak-tamper-battery-low-battery-hardware-fault-shelly` |
| `Shelly` | `Flood S` | `safety-water-leak-tamper-battery-low-battery-hardware-fault-shelly` |
| `Shelly` | `Plug US` | `plugs-switch-power-energy-voltage-current` |
| `Shelly` | `Power Strip` | `plugs-shelly-power-strip-4` |
| `Shyugj` | `DoorSensor-ZB3.0` | `safety-contact-tamper-battery-low-battery` |
| `Shyugj` | `MotionSensor-ZB3.0` | `safety-motion-illuminance-tamper-battery-low-battery` |
| `Sinopé` | `TH1320ZB-04` | `thermostats-thermostat` |
| `SMLIGHT` | `SLZB-06M` | `network-repeater` |
| `SMLIGHT` | `SLZB-06MG24` | `network-repeater` |
| `SMLIGHT` | `SLZB-06MG26` | `network-repeater` |
| `SMLIGHT` | `SLZB-06MG26U` | `network-repeater` |
| `SMLIGHT` | `SLZB-07` | `network-repeater` |
| `SMLIGHT` | `SLZB-07MG24` | `network-repeater` |
| `SONOFF` | `DONGLE-E` | `network-repeater` |
| `SONOFF` | `Dongle-LMG21` | `network-repeater` |
| `SONOFF` | `Dongle-M` | `network-repeater` |
| `SONOFF` | `Dongle-PMG24` | `network-repeater` |
| `SparkFun` | `MGM240P` | `network-repeater` |
| `Sunricher` | `HK-SENSOR-4IN1-A` | `safety-occupancy-illuminance-temp-humidity-battery` |
| `Sunricher` | `HK-SENSOR-CO` | `safety-co-detector-tamper-battery-low-battery` |
| `Sunricher` | `HK-SENSOR-CT-A` | `safety-contact-battery` |
| `Sunricher` | `HK-SENSOR-CT-MINI` | `safety-contact-battery-low-battery` |
| `Sunricher` | `HK-SENSOR-GAS` | `safety-gas-detector-tamper-battery-low` |
| `Sunricher` | `HK-SENSOR-SMO` | `safety-smoke-tamper-battery-low-battery` |
| `Sunricher` | `HK-SENSOR-WT1` | `safety-water-leak-tamper-battery-low-battery` |
| `Sunricher` | `HK-SENSOR-WT2` | `safety-water-temp-tamper-battery-low-battery` |
| `Sunricher` | `TERNCY-DC01` | `safety-contact-battery` |
| `Sunricher` | `ZG9032B` | `sensors-temp-humidity-battery-zg9032b` |
| `TERNCY` | `TERNCY-DC01` | `safety-contact-temp-battery` |
| `Third Reality, Inc` | `3RDS17BZ` | `safety-contact-battery-low-battery-voltage` |
| `Third Reality, Inc` | `3RDTS01056Z` | `safety-contact-battery-low-battery` |
| `Third Reality, Inc` | `3RMS16BZ` | `safety-motion-battery-low-battery-voltage-3rms-pending` |
| `Third Reality, Inc` | `3RPS01083Z` | `safety-motion-battery-3rps-pending` |
| `Third Reality, Inc` | `3RSMR01067Z` | `safety-motion-battery-low-battery-voltage-3rsmr-pending` |
| `Third Reality, Inc` | `3RTHS0224Z` | `sensors-temp-humidity-battery-3rths-pending` |
| `Third Reality, Inc` | `3RTHS0324Z` | `sensors-temp-humidity-battery-3rths0324-pending` |
| `Third Reality, Inc` | `3RTHS24BZ` | `sensors-temp-humidity-battery-3rths-pending` |
| `Third Reality, Inc` | `3RVS01031Z` | `safety-acceleration-battery-third-reality-pending` |
| `Third Reality, Inc` | `3RWS0218Z` | `safety-water-leak-battery` |
| `Third Reality, Inc` | `3RWS18BZ` | `safety-water-leak-battery-low-battery-3rws18bz-pending` |
| `Trust` | `SmokeSensor-EM` | `safety-smoke-battery-low-battery` |
| `Trust` | `ZSDR-850` | `safety-smoke-battery-low-battery` |
| `TubesZB` | `BM24` | `network-repeater` |
| `TubesZB` | `MGM24` | `network-repeater` |
| `TUYATEC-ktge2vqt` | `RH3001` | `safety-contact-tamper-battery-low-battery` |
| `TUYATEC-smmlguju` | `RH3040` | `safety-motion-battery` |
| `Zbeacon` | `TH01` | `sensors-temp-humidity-battery-voltage` |
| `Zbeacon` | `TS0201` | `sensors-temp-humidity-battery-voltage` |
| `Zbeacon` | `TS0202` | `sensors-temp-humidity-battery-legacy-pending` |
| `Zbeacon` | `TS0203` | `sensors-temp-humidity-battery-legacy-pending` |

</details>

<details>
<summary>ZCL Switch wonjj6768 (501 fingerprints)</summary>

Development driver; report issues with hub logcat. Supports ZCL switches, plugs, DIN rail relays, and valve-like devices.

| Manufacturer | Model | Profile |
| --- | --- | --- |
| `_TYZB01_4tlksk8a` | `TS0001` | `valves-valve-indicator-mode` |
| `_TYZB01_4vgantdz` | `TS0001` | `switches-switch-1` |
| `_TYZB01_aneiicmq` | `TS0003` | `switches-switch-1` |
| `_TYZB01_digziiav` | `TS0002` | `switches-switch-2` |
| `_TYZB01_digziiav` | `TS0003` | `switches-switch-2` |
| `_TYZB01_hlla45kx` | `TS011F` | `switches-switch-2` |
| `_TYZB01_iuepbmpv` | `TS0121` | `switches-switch-1` |
| `_TYZB01_ncutbjdi` | `TS0003` | `switches-switch-1` |
| `_TYZB01_reyozfcg` | `TS0001` | `switches-switch-1` |
| `_TYZB01_rifa0wlb` | `TS0011` | `valves-valve-indicator-mode` |
| `_TYZB01_u9kkqh5o` | `TS0003` | `switches-switch-1` |
| `_TYZB01_uqkphoed` | `TS0002` | `switches-switch-2` |
| `_TYZB01_uqkphoed` | `TS0003` | `switches-switch-2` |
| `_TYZB01_ymcdbl3u` | `TS0111` | `valves-valve-indicator-mode` |
| `_TYZB01_zsl6z0pw` | `TS0002` | `switches-switch-2` |
| `_TYZB01_zsl6z0pw` | `TS0003` | `switches-switch-2` |
| `_TZ3000_01gpyda5` | `TS0002` | `switches-switch-2` |
| `_TZ3000_0ghwhypc` | `TS0001` | `switches-switch-1-power-options` |
| `_TZ3000_0q5fjqgw` | `TS0003` | `switches-switch-3` |
| `_TZ3000_18ejxno0` | `TS0012` | `switches-switch-2` |
| `_TZ3000_1adss9de` | `TS0001` | `switches-switch-1-power-options` |
| `_TZ3000_1obwwnmq` | `TS011F` | `switches-switch-3` |
| `_TZ3000_2iiimqs9` | `TS011F` | `din-rail-ts011f-metered` |
| `_TZ3000_2xlvlnez` | `TS011F` | `switches-switch-2` |
| `_TZ3000_303avxxt` | `TS011F` | `din-rail-switch-power-energy-voltage-current-threshold-no-temp` |
| `_TZ3000_3a9beq8a` | `TS0001` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_3n2minvf` | `TS0004` | `switches-switch-4` |
| `_TZ3000_3zofvcaa` | `TS011F` | `switches-switch-4` |
| `_TZ3000_46t1rvdu` | `TS0001` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_46vasa5h` | `TS011F` | `switches-switch-2` |
| `_TZ3000_4o16jdca` | `TS0003` | `switches-switch-3` |
| `_TZ3000_4rbqgcuv` | `TS0001` | `switches-switch-1-module-options` |
| `_TZ3000_4uf3d0ax` | `TS011F` | `switches-switch-3` |
| `_TZ3000_4xfqlgqo` | `TS0002` | `switches-switch-2` |
| `_TZ3000_4zf0crgo` | `TS0012` | `switches-switch-2-countdown-switch-type` |
| `_TZ3000_54hjn4vs` | `TS0002` | `switches-switch-2` |
| `_TZ3000_5af5r192` | `TS0049` | `valves-valve-battery` |
| `_TZ3000_5ajpkyq6` | `TS0004` | `switches-switch-4` |
| `_TZ3000_5gey1ohx` | `TS0002` | `switches-switch-2` |
| `_TZ3000_5ksufhqi` | `TS0002` | `switches-switch-2` |
| `_TZ3000_5ng23zjs` | `TS0001` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_5rpu3r0d` | `TS0001` | `switches-switch-1-poweron-countdown-switch-type-indicator` |
| `_TZ3000_5ucujjts` | `TS0001` | `valves-valve-indicator-mode` |
| `_TZ3000_65ajyxua` | `TS0001` | `switches-switch-1-poweron-indicator` |
| `_TZ3000_66fekqhh` | `TS0003` | `switches-switch-3` |
| `_TZ3000_6axxqqi2` | `TS0001` | `switches-switch-1-switch-type` |
| `_TZ3000_6l1pjfqe` | `TS011F` | `din-rail-ts011f-metered` |
| `_TZ3000_6s5dc9lx` | `TS011F` | `switches-switch-2` |
| `_TZ3000_785olaiq` | `TS0003` | `switches-switch-3` |
| `_TZ3000_7ed9cqgi` | `TS0002` | `switches-switch-2` |
| `_TZ3000_7issjl2q` | `TS011F` | `din-rail-ts011f-unmetered` |
| `_TZ3000_8bxrzyxz` | `TS011F` | `din-rail-ts011f-metered` |
| `_TZ3000_8n7lqbm0` | `TS0001` | `switches-switch-1` |
| `_TZ3000_8nyaanzb` | `TS011F` | `switches-switch-2` |
| `_TZ3000_92qd4sqa` | `TS011F` | `switches-switch-2` |
| `_TZ3000_9djocypn` | `TS011F` | `switches-lellki-wp33-5` |
| `_TZ3000_9tg32trw` | `TS011F` | `switches-switch-3` |
| `_TZ3000_a37eix1s` | `TS0004` | `switches-switch-4` |
| `_TZ3000_aa5t61rh` | `TS0002` | `switches-switch-2` |
| `_TZ3000_aaifmpuq` | `TS0002` | `switches-switch-2-power-options` |
| `_TZ3000_abjodzas` | `TS0011` | `switches-switch-1` |
| `_TZ3000_afgzktgb` | `TS0001` | `switches-switch-1-module-options` |
| `_TZ3000_air9m6af` | `TS011F` | `switches-lellki-wp33-5` |
| `_TZ3000_aknpkt02` | `TS0003` | `switches-switch-3` |
| `_TZ3000_aracgljk` | `TS0003` | `switches-switch-3-nfzb03` |
| `_TZ3000_ark8nv4y` | `TS0001` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_avky2mvc` | `TS0003` | `switches-switch-3` |
| `_TZ3000_avotanj3` | `TS0013` | `switches-switch-3-countdown-switch-type` |
| `_TZ3000_bbebkwjk` | `TS0001` | `switches-switch-1-ts0001-bbeb` |
| `_TZ3000_bep7ccew` | `TS011F` | `plugs-dual-metered` |
| `_TZ3000_bezfthwc` | `TS0001` | `switches-switch-1` |
| `_TZ3000_bhcpnvud` | `TS0001` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_biakwrag` | `TS0012` | `switches-switch-2` |
| `_TZ3000_bkfe0bab` | `TS011F` | `switches-switch-1` |
| `_TZ3000_blhvsaqf` | `TS0001` | `switches-switch-1-poweron-indicator` |
| `_TZ3000_bmqxalil` | `TS0001` | `switches-switch-1-poweron` |
| `_TZ3000_bppxj3sf` | `TS011F` | `switches-lellki-wp33-5` |
| `_TZ3000_bu47m8pv` | `TS0003` | `switches-switch-3-ts0003-module2` |
| `_TZ3000_bvij6kod` | `TS0003` | `switches-switch-3-nfzb03` |
| `_TZ3000_bvrlqyj7` | `TS0002` | `switches-switch-2` |
| `_TZ3000_cayepv1a` | `TS011F` | `din-rail-switch-power-energy-voltage-current-threshold` |
| `_TZ3000_cfnprab5` | `TS011F` | `switches-switch-5-tuya-options` |
| `_TZ3000_cjfmu5he` | `TS0049` | `valves-valve-battery` |
| `_TZ3000_cmcjbqup` | `TS0001` | `valves-valve-indicator-mode` |
| `_TZ3000_cpozgbrx` | `TS0001` | `switches-switch-1-countdown-indicator` |
| `_TZ3000_criiahcg` | `TS0002` | `switches-switch-2` |
| `_TZ3000_ctftgjwb` | `TS0001` | `switches-switch-1` |
| `_TZ3000_cvis4qmw` | `TS0006` | `switches-switch-6-basic` |
| `_TZ3000_cymsnfvf` | `TS011F` | `switches-switch-2` |
| `_TZ3000_dd8wwzcy` | `TS011F` | `plugs-dual-metered-outage-indicator` |
| `_TZ3000_dershnvx` | `TS0002` | `switches-switch-2` |
| `_TZ3000_djgzdba9` | `TS011F` | `switches-switch-5-tuya-options` |
| `_TZ3000_dlhhrhs8` | `TS000F` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_dlug3kbc` | `TS011F` | `switches-switch-3` |
| `_TZ3000_dov0a3p1` | `TS0001` | `switches-switch-1` |
| `_TZ3000_drc9tuqb` | `TS0001` | `switches-switch-1-countdown-indicator` |
| `_TZ3000_dyzkbcip` | `TS0003` | `switches-switch-3` |
| `_TZ3000_eei0ubpy` | `TS0002` | `switches-switch-2` |
| `_TZ3000_ehgouyvu` | `TS0001` | `switches-switch-1` |
| `_TZ3000_empogkya` | `TS0003` | `switches-switch-3` |
| `_TZ3000_eqsair32` | `TS0003` | `switches-switch-3` |
| `_TZ3000_f09j9qjb` | `TS0003` | `switches-switch-3` |
| `_TZ3000_fawk5xjv` | `TS0003` | `switches-switch-3-nfzb03` |
| `_TZ3000_fbjdkph9` | `TS0002` | `switches-switch-2` |
| `_TZ3000_fdxihpp7` | `TS0001` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_fdxihpp7` | `TS000F` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_fisb3ajo` | `TS0002` | `switches-switch-2` |
| `_TZ3000_g8n1n7lg` | `TS0001` | `switches-switch-1` |
| `_TZ3000_g92baclx` | `TS0001` | `switches-switch-1-power-options` |
| `_TZ3000_g9chy2ib` | `TS0003` | `switches-switch-3` |
| `_TZ3000_gazjngjl` | `TS011F` | `plugs-dual-outage` |
| `_TZ3000_gbshwgag` | `TS0001` | `switches-switch-1-poweron-indicator` |
| `_TZ3000_gdyjfvgm` | `TS011F` | `switches-switch-5-tuya-options` |
| `_TZ3000_gexniqbq` | `TS0004` | `switches-switch-4` |
| `_TZ3000_gjrubzje` | `TS0001` | `switches-switch-1-module-options` |
| `_TZ3000_gkesadus` | `TS0002` | `switches-switch-2` |
| `_TZ3000_gsat0axs` | `TS0001` | `switches-switch-1-power-options` |
| `_TZ3000_gtdswg8k` | `TS0001` | `switches-switch-1-switch-type` |
| `_TZ3000_gzvniqjb` | `TS0011` | `din-rail-ts011f-unmetered` |
| `_TZ3000_h1ipgkwn` | `TS0002` | `switches-switch-2` |
| `_TZ3000_h3noz0a5` | `TS0001` | `valves-valve-indicator-mode` |
| `_TZ3000_h8ngtlxy` | `TS0001` | `valves-valve-indicator-mode` |
| `_TZ3000_hbic3ka3` | `TS0003` | `switches-switch-3` |
| `_TZ3000_hbxsdd6k` | `TS0011` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_hdc8bbha` | `TS000F` | `switches-switch-1-switch-type` |
| `_TZ3000_helyqdvs` | `TS011F` | `switches-switch-2` |
| `_TZ3000_hhiodade` | `TS0011` | `switches-switch-1` |
| `_TZ3000_hktqahrq` | `TS0001` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_hktqahrq` | `TS000F` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_hojntt34` | `TS0002` | `switches-switch-2` |
| `_TZ3000_huvxrx4i` | `TS0002` | `switches-switch-2-power-options` |
| `_TZ3000_hzlsaltw` | `TS0001` | `switches-switch-1-power-options` |
| `_TZ3000_hznzbl0x` | `TS0002` | `switches-switch-2` |
| `_TZ3000_i9oy2rdq` | `TS0001` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_i9w5mehz` | `TS0002` | `switches-switch-2` |
| `_TZ3000_ibefeicf` | `TS011F` | `din-rail-switch-power-energy-voltage-current-threshold-no-temp` |
| `_TZ3000_iedbgyxt` | `TS0001` | `valves-valve-indicator-mode` |
| `_TZ3000_iktiy8ue` | `TS0001` | `switches-switch-1-power-options` |
| `_TZ3000_ikuxinvo` | `TS0001` | `switches-switch-1-power-options` |
| `_TZ3000_imaccztn` | `TS0004` | `switches-switch-4` |
| `_TZ3000_in5qxhtt` | `TS0002` | `switches-switch-2` |
| `_TZ3000_in5s3wn1` | `TS011F` | `switches-switch-5-tuya-options` |
| `_TZ3000_irrmjcgi` | `TS0002` | `switches-switch-2-power-options` |
| `_TZ3000_iv4eq7eh` | `TS0003` | `switches-switch-3` |
| `_TZ3000_iv6ph5tr` | `TS011F` | `switches-switch-2` |
| `_TZ3000_iwtv2jwo` | `TS0002` | `switches-switch-2` |
| `_TZ3000_iy2c3n6p` | `TS011F` | `switches-switch-2` |
| `_TZ3000_iymfxdis` | `TS0004` | `switches-switch-4` |
| `_TZ3000_j0ktmul1` | `TS011F` | `valves-valve-5` |
| `_TZ3000_jak16dll` | `TS011F` | `plugs-dual-metered-outage-indicator-lock` |
| `_TZ3000_jcqs2mrv` | `SM0001` | `switches-switch-1` |
| `_TZ3000_ji4araar` | `TS0011` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_jl7qyupf` | `TS0012` | `switches-switch-2-countdown-switch-type` |
| `_TZ3000_jsfzkftc` | `TS0001` | `switches-switch-1-power-options` |
| `_TZ3000_ju82pu2b` | `TS0003` | `switches-switch-3` |
| `_TZ3000_k6fvknrr` | `TS011F` | `switches-switch-2` |
| `_TZ3000_knoj8lpk` | `TS0004` | `switches-switch-4` |
| `_TZ3000_kpatq5pq` | `TS0012` | `switches-switch-2-countdown-switch-type` |
| `_TZ3000_kqvb5akv` | `TS0001` | `switches-switch-1-power-options` |
| `_TZ3000_ky0fq4ho` | `TS011F` | `din-rail-ts011f-metered` |
| `_TZ3000_kycczpw8` | `TS0001` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_kz1anoi8` | `TS0049` | `valves-haozee-hz-wt02` |
| `_TZ3000_l8fsgo6p` | `TS0011` | `switches-switch-1` |
| `_TZ3000_lepzuhto` | `TS011F` | `din-rail-switch-power-energy-voltage-current-threshold` |
| `_TZ3000_liygxtcq` | `TS0004` | `switches-switch-4` |
| `_TZ3000_ljhbw1c9` | `TS0012` | `switches-switch-2-countdown-switch-type` |
| `_TZ3000_lmlsduws` | `TS0002` | `switches-switch-2` |
| `_TZ3000_lqb7lcq9` | `TS011F` | `switches-switch-4` |
| `_TZ3000_lsunm46z` | `TS0003` | `switches-switch-3` |
| `_TZ3000_ltt60asa` | `TS0004` | `switches-switch-4` |
| `_TZ3000_lubfc1t5` | `TS0003` | `switches-switch-3` |
| `_TZ3000_lugaswf8` | `TS0002` | `switches-switch-2` |
| `_TZ3000_lvhy15ix` | `TS0003` | `switches-switch-3` |
| `_TZ3000_m8f3z8ju` | `TS000F` | `switches-switch-2` |
| `_TZ3000_m9af2l6g` | `TS000F` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_ma3mhpx2` | `TS0001` | `switches-switch-1-poweron` |
| `_TZ3000_majwnphg` | `TS0001` | `switches-switch-1-switch-type` |
| `_TZ3000_mdj7kra9` | `TS0004` | `switches-switch-4` |
| `_TZ3000_mhhxxjrs` | `TS0003` | `switches-switch-3` |
| `_TZ3000_mkhkxx1p` | `TS0001` | `switches-switch-1-power-options` |
| `_TZ3000_mlswgkc3` | `TS011F` | `switches-switch-2` |
| `_TZ3000_mmkbptmx` | `TS0004` | `switches-switch-4` |
| `_TZ3000_mq4wujmp` | `TS0049` | `valves-valve-battery` |
| `_TZ3000_mtnpt6ws` | `TS0002` | `switches-switch-2` |
| `_TZ3000_mufwv0ry` | `TS0002` | `switches-switch-2` |
| `_TZ3000_mvn6jl7x` | `TS011F` | `switches-switch-2` |
| `_TZ3000_mw1pqqqt` | `TS0003` | `switches-switch-3` |
| `_TZ3000_mx3vgyea` | `TS0001` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_mx3vgyea` | `TS000F` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_myaaknbq` | `TS0001` | `switches-switch-1-countdown-indicator` |
| `_TZ3000_mzcp0of6` | `TS0003` | `switches-switch-3` |
| `_TZ3000_n6fqajob` | `TS0001` | `switches-switch-1-module-options` |
| `_TZ3000_nivavasg` | `TS0004` | `switches-switch-4` |
| `_TZ3000_nnwehhst` | `TS0003` | `switches-switch-3` |
| `_TZ3000_nPGIPl5D` | `TS0012` | `switches-switch-2-countdown-switch-type` |
| `_TZ3000_npzfdcof` | `TS0001` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_nsa76jai` | `TS0004` | `switches-switch-4` |
| `_TZ3000_nuenzetq` | `TS0002` | `switches-switch-2` |
| `_TZ3000_nwidmc4n` | `TS0003` | `switches-switch-3` |
| `_TZ3000_o005nuxx` | `TS011F` | `switches-switch-5-tuya-options` |
| `_TZ3000_o4cjetlm` | `TS0001` | `valves-valve-indicator-mode` |
| `_TZ3000_o4cjetlm` | `TS011F` | `valves-valve-indicator-mode` |
| `_TZ3000_odzoiovu` | `TS0003` | `switches-switch-3` |
| `_TZ3000_ogjpfoyn` | `TS0049` | `valves-valve-battery` |
| `_TZ3000_ogpla3lh` | `TS0002` | `switches-switch-2` |
| `_TZ3000_ok0ggpk7` | `TS0003` | `switches-switch-3` |
| `_TZ3000_ouwfc1qj` | `TS0003` | `switches-switch-3` |
| `_TZ3000_oznonj5q` | `TS011F` | `switches-switch-3` |
| `_TZ3000_pf7swkqp` | `TS0003` | `switches-switch-3` |
| `_TZ3000_pfc7i3kt` | `TS0003` | `switches-switch-3` |
| `_TZ3000_pgq7ormg` | `TS0001` | `switches-switch-1-countdown-switch-type-indicator` |
| `_TZ3000_pl5v1yyy` | `TS011F` | `switches-switch-5-tuya-options` |
| `_TZ3000_pmsxmttq` | `TS0003` | `switches-switch-3` |
| `_TZ3000_pmz6mjyu` | `TS011F` | `switches-switch-2` |
| `_TZ3000_prits6g4` | `TS0001` | `switches-switch-1-module-options` |
| `_TZ3000_pv4puuxi` | `TS0003` | `switches-switch-3` |
| `_TZ3000_pvlvoxvt` | `TS011F` | `switches-switch-4` |
| `_TZ3000_pxfjrzyj` | `TS0002` | `switches-switch-2-power-options` |
| `_TZ3000_q6a3tepg` | `TS0001` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_q8r0bbvy` | `TS0001` | `switches-switch-1-power-options` |
| `_TZ3000_qaa59zqd` | `TS0002` | `switches-switch-2` |
| `_TZ3000_qaabwu5c` | `TS0001` | `switches-switch-1-power-options` |
| `_TZ3000_qamj2vnn` | `TS0001` | `switches-switch-1-module-options` |
| `_TZ3000_qeuvnohg` | `TS011F` | `din-rail-ts011f-metered` |
| `_TZ3000_qh6qjuan` | `TS0001` | `switches-switch-1-switch-type` |
| `_TZ3000_qiutut5y` | `TS011F` | `switches-switch-4` |
| `_TZ3000_qlai3277` | `TS0001` | `switches-switch-1-power-options` |
| `_TZ3000_qlmnxmac` | `TS011F` | `switches-switch-2` |
| `_TZ3000_qmi1cfuq` | `TS0011` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_qnejhcsu` | `TS0001` | `switches-switch-1-power-options` |
| `_TZ3000_qorepo2x` | `TS0001` | `switches-switch-1-power-options` |
| `_TZ3000_qq9ahj6z` | `TS0001` | `switches-switch-1-poweron-indicator` |
| `_TZ3000_qsp2pwtf` | `TS0001` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_qvmiyxuk` | `TS0001` | `switches-switch-1-poweron-countdown` |
| `_TZ3000_qxcnwv26` | `TS0003` | `switches-switch-3` |
| `_TZ3000_qystbcjg` | `TS011F` | `din-rail-switch-power-energy-voltage-current-threshold` |
| `_TZ3000_r9e2w7dn` | `TS0004` | `switches-switch-4` |
| `_TZ3000_raviyuvk` | `TS011F` | `switches-switch-2` |
| `_TZ3000_rfjctviq` | `TS0002` | `switches-switch-2` |
| `_TZ3000_rgpqqmbj` | `TS011F` | `switches-switch-2` |
| `_TZ3000_rhkfbfcv` | `TS0003` | `switches-switch-3` |
| `_TZ3000_rk2yzt0u` | `TS011F` | `valves-valve-indicator-mode` |
| `_TZ3000_rmjr4ufz` | `TS0001` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_rqbjepe8` | `TS011F` | `plugs-dual-metered-outage-indicator-lock` |
| `_TZ3000_rul9yxcc` | `TS011F` | `switches-switch-2` |
| `_TZ3000_ruldv5dt` | `TS0002` | `switches-switch-2` |
| `_TZ3000_ruxexjfz` | `TS0002` | `switches-switch-2` |
| `_TZ3000_sgb0xhwn` | `TS011F` | `switches-switch-2` |
| `_TZ3000_skueekg3` | `TS0001` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_skueekg3` | `TS000F` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_sznawwyw` | `TS0013` | `switches-switch-3-countdown-switch-type` |
| `_TZ3000_t3s9qmmg` | `TS0001` | `switches-switch-1` |
| `_TZ3000_t7ugva7q` | `TS0013` | `switches-switch-3-countdown-switch-type` |
| `_TZ3000_tas0zemd` | `TS0002` | `switches-switch-2` |
| `_TZ3000_tgddllx4` | `TS0001` | `switches-switch-1-power-options` |
| `_TZ3000_tqlv4ug4` | `TS0001` | `switches-switch-1-module-options` |
| `_TZ3000_tw4ztbp4` | `TS0011` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_twqctvna` | `TS011F` | `switches-switch-1` |
| `_TZ3000_txpirhfq` | `TS0011` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_tyg4yiat` | `TS0004` | `switches-switch-4` |
| `_TZ3000_tygpxwqa` | `TS0001` | `switches-switch-1-module-options` |
| `_TZ3000_u3oupgdy` | `TS0004` | `switches-switch-4` |
| `_TZ3000_uaa34g7v` | `TS0011` | `switches-switch-1` |
| `_TZ3000_udl7uyd2` | `TS0001` | `switches-switch-1` |
| `_TZ3000_uilitwsy` | `TS0003` | `switches-switch-3` |
| `_TZ3000_uwkja6z1` | `TS011F` | `plugs-dual-metered-outage-indicator-lock` |
| `_TZ3000_v4l4b0lp` | `TS0003` | `switches-switch-3` |
| `_TZ3000_v4mevirn` | `TS011F` | `switches-switch-2` |
| `_TZ3000_v7gnj3ad` | `TS0001` | `switches-switch-1-countdown-switch-type` |
| `_TZ3000_veu2v775` | `TS0001` | `switches-switch-1-module-options` |
| `_TZ3000_viqwamhn` | `TS011F` | `din-rail-ts011f-metered` |
| `_TZ3000_vjhcenzo` | `TS0003` | `switches-switch-3` |
| `_TZ3000_vmpbygs5` | `TS011F` | `switches-switch-3` |
| `_TZ3000_vsasbzkf` | `TS0003` | `switches-switch-3` |
| `_TZ3000_vzopcetz` | `TS011F` | `switches-switch-3` |
| `_TZ3000_w0ypwa1f` | `TS0001` | `valves-valve-indicator-mode` |
| `_TZ3000_w1tcofu8` | `TS0001` | `switches-switch-1-poweron` |
| `_TZ3000_wbloefbf` | `TS011F` | `switches-switch-5-tuya-options` |
| `_TZ3000_wijoqjk1` | `TS0001` | `switches-switch-1-poweron` |
| `_TZ3000_wnzoyohq` | `TS0002` | `switches-switch-2` |
| `_TZ3000_wpueorev` | `TS0001` | `valves-valve-indicator-mode` |
| `_TZ3000_wrhhi5h2` | `TS0001` | `switches-switch-1` |
| `_TZ3000_wwtnshol` | `TS0004` | `switches-switch-4` |
| `_TZ3000_wzauvbcs` | `TS011F` | `switches-switch-3` |
| `_TZ3000_x3ewpzyr` | `TS0001` | `switches-switch-1-power-options` |
| `_TZ3000_x8mbwtsz` | `TS0001` | `switches-switch-1-power-options` |
| `_TZ3000_xeumnff9` | `TS011F` | `switches-switch-2` |
| `_TZ3000_xfxpoxe0` | `TS0001` | `switches-switch-1-outage-switch-type` |
| `_TZ3000_xkap8wtb` | `TS0001` | `switches-switch-1-power-options` |
| `_TZ3000_xkap8wtb` | `TS000F` | `switches-switch-1-power-options` |
| `_TZ3000_yi0n4xfd` | `TS011F` | `din-rail-switch-power-energy-voltage-current-threshold` |
| `_TZ3000_ypgri8yz` | `TS0013` | `switches-switch-3-countdown-switch-type` |
| `_TZ3000_ywubfuvt` | `TS0002` | `switches-switch-2` |
| `_TZ3000_yxmafzmd` | `TS0002` | `switches-switch-2` |
| `_TZ3000_z6fgd73r` | `TS011F` | `switches-switch-1-power-outage` |
| `_TZ3000_zbfya6h0` | `TS0002` | `switches-switch-2` |
| `_TZ3000_zeuulson` | `TS0003` | `switches-switch-3` |
| `_TZ3000_zigisuyh` | `TS011F` | `switches-switch-2` |
| `_TZ3000_zjchz7pd` | `TS011F` | `din-rail-switch-power-energy-voltage-current-threshold-no-temp` |
| `_TZ3000_zmy1waw6` | `TS011F` | `switches-switch-1` |
| `_TZ3000_zmy4lslw` | `TS0002` | `switches-switch-2` |
| `_TZ3000_zojh9vz7` | `TS0001` | `switches-switch-1-power-options` |
| `_TZ3000_zrm3oxsh` | `TS011F` | `din-rail-switch-power-energy-voltage-current-threshold` |
| `_TZ3000_zv6x8bt2` | `TS011F` | `din-rail-switch-power-energy-voltage-current-threshold` |
| `_TZ3000_zw7yf6yk` | `TS0001` | `switches-switch-1-switch-type` |
| `_TZ3000_zwaadvus` | `TS011F` | `switches-switch-2` |
| `_TZ3000_zxrfobzw` | `TS0002` | `switches-switch-2` |
| `_TZ3210_2uk4z8ce` | `TS011F` | `switches-switch-2` |
| `_TZ3210_6smingw0` | `TS0002` | `switches-switch-2` |
| `_TZ3210_7jnk7l3k` | `TS011F` | `plugs-dual-metered-outage` |
| `_TZ3210_8n4dn1ne` | `TS011F` | `switches-switch-4` |
| `_TZ3210_9hbau615` | `TS0001` | `switches-switch-1-module-options` |
| `_TZ3210_a2erlvb8` | `TS0002` | `switches-switch-2` |
| `_TZ3210_a2erlvb8` | `TS000F` | `switches-switch-1` |
| `_TZ3210_aksyshpw` | `TS0003` | `switches-switch-3` |
| `_TZ3210_bep7ccew` | `TS011F` | `plugs-dual-metered-full-options` |
| `_TZ3210_fawk5xjv` | `TS0003` | `switches-switch-3-nfzb03` |
| `_TZ3210_fhx7lk3d` | `TS0001` | `switches-switch-1-countdown` |
| `_TZ3210_hjxqqofs\x00` | `TS000F` | `switches-switch-1` |
| `_TZ3210_imaccztn` | `TS0004` | `switches-switch-4` |
| `_TZ3210_iymfxdis` | `TS0004` | `switches-switch-4` |
| `_TZ3210_lqb7lcq9` | `TS011F` | `switches-switch-4` |
| `_TZ3210_nuenzetq` | `TS0002` | `switches-switch-2` |
| `_TZ3210_ok0ggpk7` | `TS0003` | `switches-switch-3` |
| `_TZ3210_pdnwpnz5` | `TS0002` | `switches-switch-2` |
| `_TZ3210_pfbzs1an` | `TS011F` | `plugs-dual-metered-outage` |
| `_TZ3210_ph1joc22` | `TS011F` | `switches-switch-2` |
| `_TZ3210_qjvi92wz` | `TS0014` | `switches-switch-4` |
| `_TZ3210_qlmnxmac` | `TS011F` | `plugs-dual-metered-full-options` |
| `_TZ3210_raqjcxo5` | `TS011F` | `plugs-dual-metered-outage` |
| `_TZ3210_sgb0xhwn` | `TS011F` | `switches-switch-2` |
| `_TZ3210_tqlv4ug4` | `TS0001` | `switches-switch-1-module-options` |
| `_TZ3210_urjf5u18` | `TS011F` | `switches-switch-4` |
| `_TZ3210_vbfp8eyv` | `TS011F` | `din-rail-ts011f-metered` |
| `_TZ3210_w3hl6rao` | `TS0014` | `switches-switch-4` |
| `_TZ3210_wts1g2oh` | `TS0004` | `switches-switch-4` |
| `_TZ3210_yvxjawlt` | `TS011F` | `plugs-dual-metered-outage` |
| `_TZ3210_z4hgsevd` | `TS0014` | `switches-switch-4` |
| `_TZ3218_hdc8bbha` | `TS000F` | `switches-switch-1-outage-switch-type` |
| `_TZ3218_n0jsuogs` | `TS000F` | `switches-switch-1-poweron-switch-type` |
| `_TZ3218_sgbsg6mr` | `TS000F` | `switches-switch-2-poweron-switch-type` |
| `_TZ3290_ixd9mvv4` | `TS0049` | `valves-lyai14-minimal` |
| `_TZ33000_d9yfgzur` | `TS0003` | `switches-switch-3` |
| `Aqara` | `lumi.switch.acn047` | `switches-switch-2` |
| `Aqara` | `lumi.switch.acn048` | `switches-switch-1` |
| `Aqara` | `lumi.switch.acn049` | `switches-switch-2` |
| `Aqara` | `lumi.switch.acn055` | `switches-switch-3` |
| `Aqara` | `lumi.switch.acn057` | `switches-switch-2` |
| `Aqara` | `lumi.switch.acn059` | `switches-switch-3` |
| `AVATTO` | `TS0004_1` | `switches-switch-4` |
| `AVATTO` | `ZBTS60-04` | `switches-switch-4` |
| `AVATTO` | `ZWOT12` | `switches-switch-4` |
| `AVATTO` | `ZWSM16-4` | `switches-switch-4` |
| `BTicino` | `3577C` | `switches-switch-1` |
| `BTicino` | `3584C` | `switches-switch-1` |
| `BTicino` | `FC80AC` | `switches-switch-1` |
| `BTicino` | `FC80CC` | `switches-switch-1` |
| `BTicino` | `FC80RC` | `switches-switch-1` |
| `BTicino` | `LN4570CWI` | `switches-switch-1` |
| `Candeo` | `C-ZB-SM205-2G` | `switches-switch-2` |
| `Candeo` | `C-ZB-SM30-2G` | `switches-candeo-sm30-2g` |
| `Candeo` | `C205` | `switches-switch-1` |
| `Coibeu` | `ZB414` | `switches-switch-4` |
| `easyiot` | `ZB-PSW04` | `switches-switch-4` |
| `easyiot` | `ZB-SP1000` | `controllers-easyiot-sp1000` |
| `easyiot` | `ZB-SW08` | `switches-switch-8` |
| `Elko` | `EKO07250` | `switches-switch-1` |
| `Elko` | `EKO07251` | `switches-switch-1` |
| `Elko` | `EKO07252` | `switches-switch-1` |
| `Elko` | `EKO07253` | `switches-switch-1` |
| `Elko` | `EKO20004` | `switches-switch-1` |
| `Elko` | `EKO30198` | `switches-switch-1` |
| `Elko` | `EKO30199` | `switches-switch-1` |
| `frient A/S` | `EMIZB-141` | `meters-power-energy-battery` |
| `frient A/S` | `EMIZB-151` | `meters-power-energy` |
| `Gira` | `2430-100` | `switches-switch-1` |
| `Gira` | `2435-10` | `switches-switch-1` |
| `HEIMAN` | `HS2SW1A-EF-3.0` | `switches-switch-1` |
| `HEIMAN` | `HS2SW1A-EFR-3.0` | `switches-switch-1` |
| `HEIMAN` | `HS2SW2A-EF-3.0` | `switches-switch-2` |
| `HEIMAN` | `HS2SW2A-EFR-3.0` | `switches-switch-2` |
| `HEIMAN` | `HS2SW3A-EF-3.0` | `switches-switch-3-device-temperature` |
| `HEIMAN` | `HS2SW3A-EFR-3.0` | `switches-switch-3-device-temperature` |
| `HOBEIAN` | `ZG-301Z-2CH` | `switches-switch-2` |
| `HOBEIAN` | `ZG-301Z-3CH` | `switches-switch-3` |
| `HOBEIAN` | `ZG-305Z` | `switches-switch-2` |
| `iHseno` | `_TZ3000_knoj8lpk` | `switches-switch-4` |
| `IKEA` | `E2006` | `switches-switch-1` |
| `Jung` | `ZLLHS4` | `switches-switch-1` |
| `KlikAanKlikUit` | `Built-in Switch` | `switches-switch-1` |
| `LED-Trading` | `UP-SA-9127D` | `switches-switch-2` |
| `Legrand` | `199142` | `switches-switch-1` |
| `LELLKI` | `WP33-EU` | `switches-switch-4` |
| `LUMI` | `lumi.ctrl_ln1` | `switches-switch-1` |
| `LUMI` | `lumi.ctrl_ln1.aq1` | `switches-switch-1` |
| `LUMI` | `lumi.ctrl_ln2` | `switches-switch-2` |
| `LUMI` | `lumi.ctrl_ln2.aq1` | `switches-switch-2` |
| `LUMI` | `lumi.ctrl_neutral1` | `switches-switch-1` |
| `LUMI` | `lumi.ctrl_neutral2` | `switches-switch-2` |
| `LUMI` | `lumi.plug.acn005` | `plugs-switch-2-power-energy-voltage` |
| `LUMI` | `lumi.plug.sacn03` | `plugs-switch-2-power-energy-voltage` |
| `LUMI` | `lumi.relay.c2acn01` | `switches-switch-2` |
| `LUMI` | `lumi.switch.acn029` | `switches-switch-1` |
| `LUMI` | `lumi.switch.acn030` | `switches-switch-2` |
| `LUMI` | `lumi.switch.acn031` | `switches-switch-3` |
| `LUMI` | `lumi.switch.acn040` | `switches-switch-3` |
| `LUMI` | `lumi.switch.acn047` | `switches-switch-2` |
| `LUMI` | `lumi.switch.acn048` | `switches-switch-1` |
| `LUMI` | `lumi.switch.acn049` | `switches-switch-2` |
| `LUMI` | `lumi.switch.acn054` | `switches-switch-3` |
| `LUMI` | `lumi.switch.acn055` | `switches-switch-3` |
| `LUMI` | `lumi.switch.acn056` | `switches-switch-1` |
| `LUMI` | `lumi.switch.acn057` | `switches-switch-2` |
| `LUMI` | `lumi.switch.acn058` | `switches-switch-3` |
| `LUMI` | `lumi.switch.acn059` | `switches-switch-3` |
| `LUMI` | `lumi.switch.acn061` | `switches-switch-1` |
| `LUMI` | `lumi.switch.b1lacn01` | `switches-switch-1` |
| `LUMI` | `lumi.switch.b1laus01` | `switches-switch-1` |
| `LUMI` | `lumi.switch.b1lc04` | `switches-switch-1` |
| `LUMI` | `lumi.switch.b1nacn01` | `switches-switch-1` |
| `LUMI` | `lumi.switch.b1nacn02` | `switches-switch-1` |
| `LUMI` | `lumi.switch.b1naus01` | `switches-switch-1` |
| `LUMI` | `lumi.switch.b1nc01` | `switches-switch-1` |
| `LUMI` | `lumi.switch.b2lacn01` | `switches-switch-2` |
| `LUMI` | `lumi.switch.b2laus01` | `switches-switch-2` |
| `LUMI` | `lumi.switch.b2lc04` | `switches-switch-2` |
| `LUMI` | `lumi.switch.b2nacn01` | `switches-switch-2` |
| `LUMI` | `lumi.switch.b2nacn02` | `switches-switch-2` |
| `LUMI` | `lumi.switch.b2naus01` | `switches-switch-2` |
| `LUMI` | `lumi.switch.b2nc01` | `switches-switch-2` |
| `LUMI` | `lumi.switch.b3l01` | `switches-switch-3` |
| `LUMI` | `lumi.switch.b3n01` | `switches-switch-3` |
| `LUMI` | `lumi.switch.l0acn1` | `switches-switch-1` |
| `LUMI` | `lumi.switch.l0agl1` | `switches-switch-1` |
| `LUMI` | `lumi.switch.l1acn1` | `switches-switch-1` |
| `LUMI` | `lumi.switch.l1aeu1` | `switches-switch-1` |
| `LUMI` | `lumi.switch.l2acn1` | `switches-switch-2` |
| `LUMI` | `lumi.switch.l2aeu1` | `switches-switch-2` |
| `LUMI` | `lumi.switch.l3acn1` | `switches-switch-3` |
| `LUMI` | `lumi.switch.l3acn3` | `switches-switch-3` |
| `LUMI` | `lumi.switch.n0acn2` | `switches-switch-1` |
| `LUMI` | `lumi.switch.n0agl1` | `switches-switch-1` |
| `LUMI` | `lumi.switch.n1acn1` | `switches-switch-1` |
| `LUMI` | `lumi.switch.n1aeu1` | `switches-switch-1` |
| `LUMI` | `lumi.switch.n2acn1` | `switches-switch-2` |
| `LUMI` | `lumi.switch.n2aeu1` | `switches-switch-2` |
| `LUMI` | `lumi.switch.n3acn1` | `switches-switch-3` |
| `LUMI` | `lumi.switch.n3acn3` | `switches-switch-3` |
| `LUMI` | `lumi.switch.n4acn4` | `switches-switch-3` |
| `MakeGood` | `MG-ZG04W/B/G` | `switches-switch-4` |
| `Mercator Ikuü` | `SSW04` | `switches-switch-4` |
| `MHCOZY` | `TYWB 4ch-RF` | `switches-switch-4` |
| `Moes` | `ZM4LT4` | `switches-switch-4` |
| `Nova Digital` | `SA-4` | `switches-switch-4` |
| `Nova Digital` | `TPZ-4` | `switches-switch-4` |
| `OXT` | `SWTZ27` | `switches-switch-4` |
| `Oz Smart Things` | `WSP403` | `switches-switch-1` |
| `RSH` | `SB04-Zigbee` | `switches-switch-4` |
| `Schneider Electric` | `1GANG/SWITCH/1` | `switches-switch-1` |
| `Schneider Electric` | `A3N31SR800ZB_xx_C1` | `switches-switch-1` |
| `Schneider Electric` | `A3N32SR800ZB_xx_C1` | `switches-switch-2` |
| `Schneider Electric` | `A3N33SR800ZB_xx_C1` | `switches-switch-3` |
| `Schneider Electric` | `CH10AX/SWITCH/1` | `switches-switch-1` |
| `Schneider Electric` | `CH2AX/SWITCH/1` | `switches-switch-1` |
| `Schneider Electric` | `E8331SRY800ZB` | `switches-switch-1` |
| `Schneider Electric` | `E8332SRY800ZB` | `switches-switch-2` |
| `Schneider Electric` | `E8333SRY800ZB` | `switches-switch-3` |
| `Schneider Electric` | `NHPB/SWITCH/1` | `switches-switch-1` |
| `Schneider Electric` | `PUCK/SWITCH/1` | `switches-switch-1` |
| `Schneider Electric` | `U201SRY2KWZB` | `switches-switch-1` |
| `Sibling` | `Powerswitch-ZK(W)` | `switches-switch-1` |
| `Somfy` | `ON/OFF (2CH)` | `switches-switch-2` |
| `SONOFF` | `MINI-ZBD` | `switches-switch-1-sonoff-zbmini-r2` |
| `SONOFF` | `ZBMINIR2` | `switches-switch-1-sonoff-zbmini-r2` |
| `Sunricher` | `HK-SL-RELAY-A` | `switches-switch-1` |
| `Sunricher` | `Micro Smart OnOff` | `switches-switch-1` |
| `Sunricher` | `ON/OFF` | `switches-switch-1` |
| `Sunricher` | `ON/OFF (2CH)` | `switches-switch-2` |
| `Sunricher` | `ON/OFF(2CH)` | `switches-switch-2` |
| `Sunricher` | `SR-ZG9023A-EU` | `switches-switch-5` |
| `Sunricher` | `SR-ZG9100A-S` | `switches-switch-1` |
| `Sunricher` | `SR-ZG9101SAC-HP-SWITCH-2CH` | `switches-switch-2` |
| `Sunricher` | `SR-ZG9101SAC-HP-SWITCH-B` | `switches-switch-1` |
| `Sunricher` | `ZIGBEE-SWITCH` | `switches-switch-1` |
| `TERNCY` | `TERNCY-LS01` | `switches-switch-1` |
| `TERNCY` | `TERNCY-WS01-S4` | `switches-switch-4` |
| `Third Reality` | `3RSP0186Z` | `plugs-switch` |
| `Third Reality` | `3RSPE02065Z` | `plugs-switch` |
| `Third Reality` | `3RSPJ0187Z` | `plugs-switch` |
| `Third Reality` | `3RSPU01080Z` | `plugs-switch` |
| `Third Reality` | `3RWP01073Z` | `plugs-switch-2` |
| `Third Reality, Inc` | `3RSS007Z` | `switches-switch-1` |
| `Third Reality, Inc` | `3RSS008Z` | `switches-switch-1-battery` |
| `Third Reality, Inc` | `3RSS009Z` | `switches-switch-1-battery` |
| `Tuya` | `DS-111` | `switches-switch-4` |
| `TUYATEC` | `GDKES-04TZXD` | `switches-switch-4` |
| `UHome` | `TWV` | `valves-valve-battery` |
| `Vizo` | `VZ-221S` | `switches-switch-4` |
| `Vizo` | `VZ-222S` | `switches-switch-4` |
| `Vizo` | `VZ-223S` | `switches-switch-4` |
| `zunzunbee` | `SSWZ8T` | `switches-switch-4` |

</details>

## Zigbee2MQTT Reference

Device support, fingerprints, exposes, datapoint contracts, and behavior mapping were researched with reference to the Zigbee2MQTT project and its `zigbee-herdsman-converters` repository:

- Zigbee2MQTT: https://www.zigbee2mqtt.io/
- zigbee-herdsman-converters: https://github.com/Koenkk/zigbee-herdsman-converters

This project is not affiliated with or endorsed by Zigbee2MQTT.

## License

This repository is released under the MIT License.

Portions of the device research and compatibility mapping were derived by studying Zigbee2MQTT / `zigbee-herdsman-converters`, which is also distributed under the MIT License.

Zigbee2MQTT / `zigbee-herdsman-converters` license notice:

```text
MIT License

Copyright (c) 2018 Koen Kanters
```
