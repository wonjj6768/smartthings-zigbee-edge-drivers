local q,c,n,k=require"protocol.zcl",require"contracts.helpers.family",require"st.capabilities",require"st.zigbee.constants"local f,b=c.definition_registry()
local function p(a)
if type(a)=="boolean"then
return a
end
if type(a)=="table"and type(a.is_alarm1_set)=="function"then
return a:is_alarm1_set()end
if type(a)=="table"and a.value~=nil then
a=a.value
end
if type(a)~="number"then
return nil
end
return a%2~=0
end
local function l(a)
if type(a)=="table"and a.value~=nil then
a=a.value
end
return a==32768 or a==32772
end
local function i(m)
local e=m and m.body and m.body.zcl_body and m.body.zcl_body.zone_status or nil
if e==nil then
return nil
end
return{raw_value=e.value or e,typed_value=e}
end
local function o(_,a)
if a==true then
return n.button.button.pushed{state_change=true}end
end
local function d(j)
return{profile="buttons-doorbell-battery-tamper-low",button_actions={"pushed"},button_count=1,zcl_clusters={q.ias_zone{name="doorbell_button",emit=o,from_device=j,prefer_typed_value=true,ias_configure_method=k.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=i},q.tamper(),q.battery_low(),q.battery()}}
end
local h,g=d(p),d(l)b(h,c.create_fingerprints("TS0211",{"_TZ1800_akzvkzqq","_TZ1800_ladpngdx"}))b(g,{c.create_fingerprint("HEIMAN","DoorBell-EF-3.0"),c.create_fingerprint("HEIMAN","DoorBell-EM")})q.attach_reporting_capabilities(f,{{1,"rpt-tgx"},{2,"rpt-tgx"}})return{id="zcl.controls.doorbell",registrations=f}
