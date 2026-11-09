local function av(l,as)
local r,K,ag,ai,an,ab,X,x,S,B=as.type_check,as.prepare_mappings,{"magic_packet","query_on_configure","query_command_id","mcu_version_request_on_configure","bind_basic_on_configure","bind_target_eui","query_interval_seconds","step_delay","initial_delay","named_mappings","named_mapping_values","named_mapping_names","named_datapoints","named_key_field"},{"query_on_announce","announce_delay","query_command_id","announce_handler"},{"config_queue","queue_delay","time_handler","force_time_updates","auto_time","time_offset","time_start","utc_time","local_time","auto_connection_status","connection_status_bytes","respond_to_mcu_version_response"},{"preference_names","use_queue"},{"named_mappings","named_datapoints","named_key_field","named_mapping_values","named_mapping_names"},as.copy_table,as.copy_keys,as.time_offset_for_start




local function ar(b)
return b.datapoints
end
local function ae(b,i)
if b.preference_map~=nil then
return b.preference_map
end
if b.preference_datapoints~=nil then
local t=b.preference_datapoints
if t==true then
t=i
end
if t==nil then
return nil
end
return l.build_preference_map(t,b.preference_key_field)end
return nil
end
local function L(b)
local H=x(b and b.named_mapping)S(H,b,X)return H
end
local function M(i,c)
if r(i)~="table"or
r(c)~="table"or
c[1]~=nil then
return c
end
local T=false
for aC,_ in pairs(c)do
if r(aC)=="string"then
T=true
break
end
end
if not T then
return c
end
local aD=x(i)for aC,ay in pairs(c)do
aD[aC]=ay
end
return aD
end
local function ad(a,i)
if a.named_mappings~=nil then
return M(i,a.named_mappings)end
if a.named_datapoints~=nil then
local u=a.named_datapoints
if u==true then
u=i
end
if u==nil then
return nil
end
if a.named_key_field~=nil then
return l.build_named_map(u,a.named_key_field)end
return u
end
if a.named_mapping_values~=nil or a.named_mapping_names~=nil then
if i==nil then
return nil
end
if a.named_key_field~=nil then
return l.build_named_map(i,a.named_key_field)end
return i
end
return nil
end
local function U(b,O)
if r(b)~="table"then
return O(b)end
if b.datapoints~=nil then
return b.datapoints
end
if b.datapoint_options~=nil then
return O(b.datapoint_options)end
return O(b)
end
local function aj(b,O)
local q=x(b)q.datapoints=U(b,O)return l.build_base_preset(q)
end
local function Y(b)
if r(b)~="table"then
return b,nil
end
local j=b.datapoint_options
if r(j)~="table"then
j=b
end
local G=j.dps
if G==nil then
G=j.dp_list
end
if G==nil and j.dp~=nil then
G={j.dp}end
if G==nil and j[1]~=nil then
G=j
end
return G,j
end
local function V(b,O)
local q=x(b)if q.datapoints==nil then
local G,j=Y(b)q.datapoints=O(G,j)end
return l.build_base_preset(q)
end
local function N(b)
b=b or{}local i,a=ar(b),L(b)local g,c=ae(b,i),ad(a,i)local z
if r(c)=="table"then
z=l.build_named_map(c,"name")for aC,ay in pairs(c)do
if r(aC)=="string"then
z[aC]=ay
end
end
end
local f=x(b.configure)S(f,b,ag)if b.zcl_clusters~=nil and f.magic_packet==nil then
f.magic_packet=false
end
if g~=nil and f.preference_map==nil then
f.preference_map=g
end
if b.preference_names~=nil and f.preference_names==nil then
f.preference_names=b.preference_names
end
if c~=nil and f.named_mappings==nil then
f.named_mappings=c
end
if a.named_mapping_values~=nil and f.named_mapping_values==nil then
f.named_mapping_values=a.named_mapping_values
end
if a.named_mapping_names~=nil and f.named_mapping_names==nil then
f.named_mapping_names=a.named_mapping_names
end
local Z=x(b.announce)S(Z,b,ai)local C=x(b.message)S(C,b,an)if i~=nil and C.datapoints==nil then
C.datapoints=i
end
local h=x(b.preferences)S(h,b,ab)if b.preference_names~=nil and h.preference_names==nil then
h.preference_names=b.preference_names
end
if i~=nil then
K(i)end
if g~=nil then
K(g)end
if c~=nil and c~=i then
K(c)end
return{datapoints=i,zcl_clusters=b.zcl_clusters,preference_map=g,named_mappings=c,named_mappings_by_name=z,configure_options=f,announce_options=Z,message_handlers=C,preferences_options=h,named_mapping_options=a}
end
local e={}
local function o(A)
if A.preference_map~=nil then
return A.preference_map
end
return A.datapoints
end
local function n(A)
if A.named_mappings~=nil then
return A.named_mappings
end
return A.datapoints
end
function e.start_configuration(self,d,ah)
return l.start_configuration(d,self.configure_options,ah)
end
function e.send_magic_packet(self,d)
return l.send_magic_packet(d)
end
function e.send_state_request(self,d,ak)
local p=ak
if p==nil then
p=self.configure_options.query_command_id
end
if p==nil then
p=self.announce_options.query_command_id
end
return l.send_state_request(d,p)
end
function e.send_mcu_version_request(self,d,af)
return l.send_mcu_version_request(d,af)
end
function e.send_connection_status(self,d,af,aB)
local m=self.message_handlers
return l.send_connection_status(d,af,aB or m.connection_status_bytes)
end
function e.send_time(self,d,aw,al)
local m=self.message_handlers
local I,E,J=aw or m.utc_time,al or m.local_time,m.time_offset


if J~=nil then
return l.send_time_with_offset(d,J,I,E)end
local D=m.time_start
if D=="off"then
return false
end
if D~=nil then
local aq=B(D)if aq~=0 then
return l.send_time_with_offset(d,aq,I,E)end
end
return l.send_time(d,I,E)
end
function e.send_time_with_offset(self,d,az,aw,al)
local m,y=self.message_handlers,az

if y==nil then
y=m.time_offset
end
if y==nil and m.time_start~=nil then
y=B(m.time_start)end
return l.send_time_with_offset(d,y,aw or m.utc_time,al or m.local_time)
end
function e.apply_time_request(self,d,Q)
local m=self.message_handlers
local J=m.time_offset
if J~=nil then
return l.apply_time_request_with_offset(d,Q,J,m.utc_time,m.local_time)end
local D=m.time_start
if D=="off"then
return false
end
if D~=nil then
local aq=B(D)if aq~=0 then
return l.apply_time_request_with_offset(d,Q,aq,m.utc_time,m.local_time)end
end
return l.apply_time_request(d,Q,m.utc_time,m.local_time)
end
function e.apply_connection_status_request(self,d,Q)
return l.apply_connection_status_request(d,Q,self.message_handlers.connection_status_bytes)
end
function e.start_query_timer(self,d,au,ak)
local f=self.configure_options
return l.start_query_timer(d,au or f.query_interval_seconds,ak or f.query_command_id)
end
function e.stop_query_timer(self,d)
return l.stop_query_timer(d)
end
function e.apply_announce(self,d)
return l.apply_announce(d,self.announce_options)
end
function e.apply_message(self,d,Q)
return l.apply_message(d,Q,self.message_handlers)
end
function e.apply_preferences_changed(self,d,F)
local g=o(self)if g==nil then
return false
end
return l.apply_preferences_changed(d,g,F,self.preferences_options)
end
function e.send_preferences(self,d,F,w)
local g=o(self)if g==nil then
return false
end
local h=self.preferences_options
return l.send_preferences(d,g,F,w or h.preference_names)
end
function e.build_preference_config_queue(self,d,F,w)
local g=o(self)if g==nil then
return{}end
local h=self.preferences_options
return l.build_preference_config_queue(d,g,w or h.preference_names,F)
end
function e.start_preference_config_queue(self,d,F,w)
local g=o(self)if g==nil then
return false
end
local h=self.preferences_options
return l.start_preference_config_queue(d,g,w or h.preference_names,F)
end
function e.send_named_mapping(self,d,name,aH,P)
local c=n(self)if c==nil then
return nil
end
local a,R=self.named_mapping_options,aH

if R==nil and
r(name)=="string"and
r(a.named_mapping_values)=="table"then
R=a.named_mapping_values[name]end
return l.send_named_mapping(d,c,name,R,P)
end
function e.send_named_mappings(self,d,at,ax,P)
local c=n(self)if c==nil then
return nil
end
local a=self.named_mapping_options
return l.send_named_mappings(d,c,at or a.named_mapping_values,ax or a.named_mapping_names,P)
end
function e.build_named_mapping_config_queue(self,d,at,ax,P)
local c=n(self)if c==nil then
return{}end
local a=self.named_mapping_options
return l.build_named_mapping_config_queue(d,c,at or a.named_mapping_values,ax or a.named_mapping_names,P)
end
function e.start_named_mapping_config_queue(self,d,at,ax,P)
local c=n(self)if c==nil then
return false
end
local a=self.named_mapping_options
return l.start_named_mapping_config_queue(d,c,at or a.named_mapping_values,ax or a.named_mapping_names,P)
end
function e.build_driver_template(self,b)
b=b or{}
local function s(ah,d,aI)
self:apply_message(d,aI)
end
local aJ=l.EF00_CLUSTER
local aa={supported_capabilities=b.supported_capabilities,zigbee_handlers={cluster={[aJ]={[l.GET_DATA]=s,[l.SET_DATA_RESPONSE]=s,[l.REPORT_STATUS]=s,[l.ACTIVE_STATUS_REPORT]=s,[l.SET_TIME]=s,[l.CONNECTION_STATUS]=s}}},lifecycle_handlers={
init=function(ah,d)
d:set_find_child(function()return d end)
end,
doConfigure=function(ah,d)
self:start_configuration(d,ah)
end
},capability_handlers={refresh={
refresh=function(ah,d)
self:send_state_request(d)
end
}},health_check=false}if b.preferences then
aa.lifecycle_handlers.infoChanged=function(_,d,_,aG)
if aG.old_st_store then
self:apply_preferences_changed(d,aG.old_st_store.preferences)end
end
end
if b.lifecycle_handlers then
for k,v in pairs(b.lifecycle_handlers)do
aa.lifecycle_handlers[k]=v
end
end
if b.capability_handlers then
for k,v in pairs(b.capability_handlers)do
aa.capability_handlers[k]=v
end
end
if b.sub_drivers then
aa.sub_drivers=b.sub_drivers
end
return aa
end
local function ap(A,aE)
return function(aF,...)
if aF==A then
return aE(A,...)end
return aE(A,aF,...)
end
end
local ao={"start_configuration","send_magic_packet","send_state_request","send_mcu_version_request","send_connection_status","send_time","send_time_with_offset","apply_time_request","apply_connection_status_request","start_query_timer","stop_query_timer","apply_announce","apply_message","apply_preferences_changed","send_preferences","build_preference_config_queue","start_preference_config_queue","send_named_mapping","send_named_mappings","build_named_mapping_config_queue","start_named_mapping_config_queue","build_driver_template"}
function l.build_base_preset(b)
local H=N(b)for _,name in ipairs(ao)do
H[name]=ap(H,e[name])end
return H
end
local am={"sensor","temperature_sensor","temperature_humidity_sensor","illuminance_sensor","contact_sensor","occupancy_sensor","environment_sensor","soil_sensor","soil_fertility_sensor","gas_sensor","smoke_sensor","carbon_monoxide_sensor","gas_carbon_monoxide_sensor","switch","temperature","humidity","battery","battery_state","battery_state_low_medium_high","contact","occupancy","illuminance","temperature_unit","child_lock","power_on_behavior","power_outage_memory","switch_type","switch_type_button","switch_type_curtain","switch_mode","backlight_mode","backlight_mode_low_medium_high","backlight_mode_off_on","indicator_mode","indicator_mode_none_relay_pos","brightness","action","countdown","voltage","current","power","energy","ac_frequency","phase_variant1","phase_variant2","phase_variant3","threshold","color_temperature","color_hue","color_saturation","color_data","cover_position","cover_position_inverted","do_not_disturb","inching_switch","local_temperature","current_heating_setpoint","occupied_heating_setpoint","occupied_cooling_setpoint","local_temperature_calibration","open_window_temperature","comfort_temperature","eco_temperature","holiday_temperature","max_temperature_limit","min_temperature_limit","deadzone_temperature","inlet_water_temperature","outlet_water_temperature","open_window_time","system_mode","running_state","fan_mode","fan_speed","frost_protection","window_detection","open_window","window_open","boost_heating","scale_protection","eco_mode","valve_state","valve_state_unknown_open_closed","temperature_sensor_select","temperature_sensor_select_internal_external_both","temperature_calibration","humidity_calibration","max_temperature_alarm","min_temperature_alarm","max_humidity_alarm","min_humidity_alarm","temperature_alarm","humidity_alarm","soil_moisture","soil_calibration","temperature_sampling","report_interval","soil_sampling","soil_warning","illuminance_calibration","water_warning","soil_fertility","soil_fertility_calibration","soil_fertility_warning_setting","soil_fertility_warning","gas","gas_value","smoke","smoke_concentration","self_test_result","self_test_state","fault_alarm","silence","alarm_time","alarm_volume","alarm_ringtone","preheat","alarm_switch","device_fault","gas_fault_status","tamper","battery_low","pir_sensitivity","hold_time","keep_time","alarm","presence","motion_state","indicator","fading_time","illuminance_interval","static_detection_distance","static_detection_sensitivity","motion_detection_mode","motion_detection_sensitivity","target_distance","carbon_monoxide","co","co2","voc","pm25","formaldehyde","water_consumed","reverse_water_consumed","month_consumption","daily_consumption","flow_rate","instantaneous_flow_rate","cumulative_heat","battery_voltage","meter_id","water_meter_faults","water_meter_report_period","boost_time","boost_timeset_countdown","switch_module","switch_config","button_switch_config","curtain_switch_config","button_switch_module","curtain_switch_module","meter","gang_switch_config","gang_button_switch_config","gang_curtain_switch_config","gang_switch_module","gang_button_switch_module","gang_curtain_switch_module","light","color_light","gang_light","cover","thermostat","trv","fan","siren","lock","air_quality_sensor","water_meter","radar_presence_sensor","plug","button_plug","curtain_plug","gang_plug","gang_button_plug","gang_curtain_plug"}for _,name in ipairs(am)do
l["build_"..name .."_preset"]=function(b)
return aj(b,l["build_"..name .."_datapoints"])
end
end
local W={"gang_switch","gang_child_lock","gang_power_on_behavior","gang_switch_mode","gang_switch_type","gang_switch_type_button","gang_switch_type_curtain","gang_brightness","gang_countdown","phase_variant1_meter","phase_variant2_meter","phase_variant3_meter"}for _,name in ipairs(W)do
l["build_"..name .."_preset"]=function(b)
return V(b,l["build_"..name .."_datapoints"])
end
end
function l.build_driver(name,A,b)
local aA=require"st.zigbee"return aA(name,A:build_driver_template(b))
end
end
return av
