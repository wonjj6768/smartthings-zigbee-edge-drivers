local p,c,u,r=require"protocol.tuya",require"contracts.helpers.family",require"capabilities.events.all",require"st.capabilities"local q=p.converter
local n,a=c.definition_registry()
local function f(s)
if s==1 then return"main"end
return"switch"..tostring(s)
end
local function b(t,o)
local d={profile=t,package_group="switch-panel",datapoints={},query_on_configure=false}for v=1,o do
d.datapoints[#d.datapoints+1]=p.dp_on_off(v,{name="switch",component=f(v)})end
local g={13,16,101}if o>1 then g[#g+1]=102 end
for _,v in ipairs(g)do
d.datapoints[#d.datapoints+1]=p.dp_on_off(v,{name="switch",component=f(#d.datapoints+1)})end
return d
end
local i=b("switches-switch-4",1)a(i,c.create_fingerprints("TS0601",{"_TZE200_b0ihkhxh"}))local j=b("switches-switch-6",2)a(j,c.create_fingerprints("TS0601",{"_TZE200_htj3hcpl"}))local k=b("switches-switch-7",3)a(k,c.create_fingerprints("TS0601",{"_TZE200_pcg0rykt"}))local l=b("switches-switch-8",4)a(l,c.create_fingerprints("TS0601",{"_TZE200_7a5ob7xq","_TZE284_7a5ob7xq"}))local m=b("switches-switch-10",6)a(m,c.create_fingerprints("TS0601",{"_TZE200_xo3vpoah"}))
local function e()
return r.button.button.pushed{state_change=true}
end
local h={profile="switches-switch-1-scene-qa-qat42z1b",package_group="switch-panel",button_actions={"pushed"},query_on_configure=false,time_start="off",datapoints={p.dp_on_off(24,{name="switch",component="main",emit=u.switch()}),p.dp_enum(5,{name="scene_action",component="main",read_only=true,converter=q.from_only(q.constant"pushed"),emit=e}),p.dp_numeric(101,{name="qat42z1b_backlight_brightness",component="main",emit=u.qatOneBacklightBrightness()})}}a(h,c.create_fingerprints("TS0601",{"_TZE284_nzns7udm"}))return{id="ef00.switch.panel.z2m_absorption",registrations=n}
