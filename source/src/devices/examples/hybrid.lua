-- EF00 + ZCL 혼합 기기 정의 예제
-- 참고용 템플릿입니다. registry.lua에 등록하지 않았으므로 런타임에는 영향이 없습니다.
--
-- 복붙 후 실제 기기로 쓰려면:
-- 1. fingerprint를 실기기 값으로 바꾸고
-- 2. 실등록용으로 쓸 파일은 devices/hybrid/init.lua에 연결된 모듈에 넣으세요.

local tuya = require "tuya_common"
local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"

local device_definitions, register_device_definition = device_helpers.definition_registry()

-- Example 1. EF00 제어 + ZCL 전력/에너지 측정
local hybrid_plug = {
  datapoints = {
    tuya.dp_on_off(1, { name = "switch" }),
  },
  zcl_clusters = {
    zcl.power(),
    zcl.energy({ scale = 1000 }),
  },
}

register_device_definition(hybrid_plug, device_helpers.create_fingerprints("TS011F", {
  "_TZ3000_example_hybrid_plug",
}))

return device_definitions
