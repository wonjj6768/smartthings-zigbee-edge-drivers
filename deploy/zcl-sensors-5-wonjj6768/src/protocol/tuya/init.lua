local d={EF00_CLUSTER=61184,GET_DATA=1,SET_DATA_RESPONSE=2,REPORT_STATUS=5,ACTIVE_STATUS_REPORT=6,MCU_VERSION_RESPONSE=17,SET_TIME=36,CONNECTION_STATUS=37}
function d.build_base_preset(a)
a=a or{}local b={zcl_clusters=a.zcl_clusters,datapoints=a.datapoints}
function b:start_configuration(...)return false end
function b:send_magic_packet(...)return false end
function b:send_state_request(...)return false end
function b:apply_message(...)return false end
function b:apply_announce(c)
if type(a.announce_handler)~="function"then return false end
return a.announce_handler(c,a)~=false
end
function b:apply_preferences_changed(...)return false end
return b
end
return d
