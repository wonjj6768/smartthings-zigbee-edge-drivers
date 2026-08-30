local tuya={
EF00_CLUSTER=0xEF00,
GET_DATA=0x01,
SET_DATA_RESPONSE=0x02,
REPORT_STATUS=0x05,
ACTIVE_STATUS_REPORT=0x06,
MCU_VERSION_RESPONSE=0x11,
SET_TIME=0x24,
CONNECTION_STATUS=0x25,
}
require "protocol.tuya.runtime.read_only_datapoints"(tuya)
function tuya.build_base_preset(options)
local preset={
zcl_clusters=options and options.zcl_clusters or nil,
datapoints=options and options.datapoints or nil,
}
function preset:start_configuration(...)return false end
function preset:start_query_timer(...)return false end
function preset:stop_query_timer(...)return false end
function preset:send_magic_packet(...)return false end
function preset:send_state_request(...)return false end
function preset:send_named_mapping(...)return false end
function preset:apply_message(device,message)
return tuya.apply_read_only_datapoints(device,message,self.datapoints)
end
function preset:apply_preferences_changed(...)return false end
return preset
end
return tuya
