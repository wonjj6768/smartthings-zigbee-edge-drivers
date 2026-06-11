-- ZCL 전용 기기 정의 예제
-- 참고용 템플릿입니다. registry.lua에 등록하지 않았으므로 런타임에는 영향이 없습니다.
--
-- 복붙 후 실제 기기로 쓰려면:
-- 1. fingerprint를 실기기 값으로 바꾸고
-- 2. 필요하면 profile을 추가하고
-- 3. 실등록용으로 쓸 파일은 devices/zcl/init.lua에 연결된 모듈에 넣으세요.
--
-- 작성 규칙:
-- 단일 엔드포인트 기기는 보통 component = "main" 을 생략해도 됩니다.
-- 멀티 엔드포인트 기기나 같은 name을 여러 번 쓰는 경우에는
-- component 또는 endpoint를 명시해서 매핑을 구분해야 합니다.

local tuya = require "tuya_common"
local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"

local device_definitions, register_device_definition = device_helpers.definition_registry()

-- Example 1. ZCL 전용 센서
-- 순수 ZCL 리스트는 이제 EF00와 같은 방식으로 바로 등록할 수 있습니다.
local zcl_temp_humidity_sensor = {
  zcl.temperature(),
  zcl.humidity(),
  zcl.battery(),
}

register_device_definition(zcl_temp_humidity_sensor, device_helpers.create_fingerprints("TS0201", {
  "_TZ3000_example_th",
}))

-- Example 2. ZCL 전용 커버
-- cover_position은 읽기/보고용, cover_state는 open/close/pause 송신용 이름입니다.
-- profile에 windowShadePreset/windowShadeTiltLevel 이 있으면 cover_position/cover_tilt를 함께 쓸 수 있습니다.
local zcl_cover = {
  profile = "window-cover",
  zcl_clusters = {
    zcl.cover_position(),
    zcl.cover_state(),
  },
}

register_device_definition(zcl_cover, device_helpers.create_fingerprints("TS130F", {
  "_TZ3000_example_cover",
}))

-- Example 3. 디머
-- zcl.level()은 0~254 <-> 0~100 변환을 기본 적용합니다.
local zcl_dimmer = {
  zcl.switch(),
  zcl.level(),
}

register_device_definition(zcl_dimmer, device_helpers.create_fingerprints("DIMMER-DEMO", {
  "_TZ3000_example_dimmer",
}))

-- Example 4. 난방 전용 서모스탯
-- system_mode는 off/auto/cool/heat/emergency heat 문자열과 enum 값을 변환합니다.
local zcl_thermostat = {
  profile = "thermostat",
  zcl_clusters = {
    zcl.local_temperature(),
    zcl.heating_setpoint(),
    zcl.system_mode(),
  },
}

register_device_definition(zcl_thermostat, device_helpers.create_fingerprints("THERMO-DEMO", {
  "_TZ3000_example_thermo",
}))

-- Example 5. 2구 스위치
-- 같은 name("switch")를 여러 번 쓰는 경우에는 component를 명시해야
-- 수신/송신 모두 올바른 채널로 매핑됩니다.
local zcl_switch_2gang = {
  profile = "switch-2",
  zcl_clusters = zcl.multi_switch(2),
}

register_device_definition(zcl_switch_2gang, device_helpers.create_fingerprints("ZCL-SWITCH-2", {
  "_TZ3000_example_switch2",
}))

-- Example 6. IAS 접점 센서
-- IAS Zone status 비트(Alarm1)를 contact capability로 변환합니다.
local zcl_contact_sensor = {
  profile = "contact-battery",
  zcl_clusters = {
    zcl.contact(),
    zcl.battery(),
    zcl.tamper({ read_on_configure = false }),
  },
}

register_device_definition(zcl_contact_sensor, device_helpers.create_fingerprints("IAS-CONTACT", {
  "_TZ3000_example_contact",
}))

-- Example 7. IAS 누수 센서
local zcl_water_sensor = {
  profile = "water-leak",
  zcl_clusters = {
    zcl.water(),
    zcl.battery(),
  },
}

register_device_definition(zcl_water_sensor, device_helpers.create_fingerprints("IAS-WATER", {
  "_TZ3000_example_water",
}))

return device_definitions
