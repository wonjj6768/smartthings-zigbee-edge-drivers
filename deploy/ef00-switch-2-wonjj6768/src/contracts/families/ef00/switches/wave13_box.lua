local f,j,e=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family"local a=f.converter
local h,b=e.definition_registry()
local function c(name)
return assert(j[name],"missing Wave13 custom emitter: "..name)()
end
local i={}for d=1,10 do i["scene_"..tostring(d)]=d-1 end
local g={}for d=1,10 do g["scene_"..tostring(d)]=d+9 end
local k={profile="switches-wave13-box-ews1154z",package_group="switch-panel",magic_packet=true,query_on_configure=false,datapoints={f.dp_on_off(19,{name="switch",component="main",emit=j.switch()}),f.dp_enum(102,{name="box_ews_record_rf",converter=a.lookup_from_to{record=0},emit=c"boxEwsRecordRf"}),f.dp_enum(102,{name="box_ews_clear_rf",converter=a.lookup_from_to{clear=1},emit=c"boxEwsClearRf"}),f.dp_enum(103,{name="box_ews_rf_status",read_only=true,converter=a.lookup_from_to{ok=0,error=1},emit=c"boxEwsRfStatus"}),f.dp_enum(104,{name="box_ews_record_scene",converter=a.lookup_from_to(i),emit=c"boxEwsRecordScene"}),f.dp_enum(104,{name="box_ews_clear_scene",converter=a.lookup_from_to(g),emit=c"boxEwsClearScene"}),f.dp_enum(105,{name="box_ews_rf_scene_status",read_only=true,converter=a.lookup_from_to{ok=0,error=1},emit=c"boxEwsRfSceneStatus"})}}for d=1,10 do
k.datapoints[#k.datapoints+1]=f.dp_enum(d,{name="box_ews_scene_action",read_only=true,
converter=a.from_only(function(l)
return tonumber(l)==0 and("scene_"..tostring(d))or nil
end),
emit=c"boxEwsSceneAction"})end
b(k,e.create_fingerprints("TS0601",{"_TZE200_yp5tsi3y"}))return{id="ef00.switches.wave13.box",registrations=h}
