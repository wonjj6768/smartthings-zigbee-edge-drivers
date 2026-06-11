-- ZCL 표준 클러스터 공통 모듈
-- EF00 tuya_common과 병렬 구조: ZCL 표준 클러스터 매핑/핸들러 전담

local zcl = {}

require "zcl_common.generated_helper"(zcl)
require "zcl_common.cluster_mapping"(zcl)
require "zcl_common.mapping_preset"(zcl)
require "zcl_common.component_helper"(zcl)
require "zcl_common.runtime"(zcl)
require "zcl_common.metering"(zcl)
require "zcl_common.attribute_handler"(zcl)
require "zcl_common.command_sender"(zcl)
require "zcl_common.ir_session"(zcl)
require "zcl_common.cluster_command_handler"(zcl)
require "zcl_common.configuration"(zcl)

return zcl
