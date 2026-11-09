local j,b,z,o=require"protocol.zcl",require"contracts.helpers.family",require"capabilities.events.all",require"st.zigbee.device_management"local g,a=b.definition_registry()
local function f(s)
if type(s)~="number"then
return s
end
local r=math.floor((((s-2.0)/1.0)*100)+0.5)if r<0 then
return 0
end
if r>100 then
return 100
end
return r
end
local function e()
return j.cluster_attribute(j.CLUSTER_POWER_CONFIGURATION,j.ATTR_BATTERY_VOLTAGE,{name="battery",endpoint=1,emit=z.battery(),scale=10,from_device=f,read_on_configure=true})
end
local function l(u)
return function(y,w)
for _,v in ipairs(u)do
w:send(o.build_bind_request(w,v,y.environment_info.hub_zigbee_eui,1))end
end
end
local function d(x,n)
local q={j.battery{endpoint=1,read_on_configure=true}}if n and n.battery_voltage then
q[#q+1]=e()end
return{profile=x,security_remote=true,button_actions={"pushed"},zcl_clusters=q,configure=l(n and n.bind_clusters or{j.CLUSTER_POWER_CONFIGURATION})}
end
local h={j.CLUSTER_POWER_CONFIGURATION,10,0,1281,j.CLUSTER_IAS_ZONE}local i,m=d("security-remotes-sos-battery",{battery_voltage=true,bind_clusters=h}),j.cluster_attribute(j.CLUSTER_POWER_CONFIGURATION,j.ATTR_BATTERY_VOLTAGE,{name="battery_voltage",endpoint=1,emit=z.voltage(),scale=10})i.profile="security-remotes-sos-battery-voltage"i.zcl_clusters[#i.zcl_clusters+1]=m
local t,p,k,c=d("security-remotes-action-battery",{battery_voltage=true,bind_clusters=h}),{profile="buttons-button-1-battery-remote-action",advanced_remote=true,button_actions={"pushed","double","held"},ias_zone_action_map={[0]="off",[1]="single",[2]="double",[3]="hold"},standard_action_button_events={single="pushed",double="double",hold="held"},zcl_clusters={j.battery{endpoint=1,read_on_configure=true}},configure=l{j.CLUSTER_POWER_CONFIGURATION}},d("security-remotes-action-battery",{bind_clusters={j.CLUSTER_POWER_CONFIGURATION}}),d("security-remotes-heiman-partial-action-battery",{bind_clusters={j.CLUSTER_POWER_CONFIGURATION}})c.security_remote_action_emit_name="heiman_rc_partial_security_action"c.arm_mode_action_map={[0]="disarm",[1]="arm_partial_zones",[3]="arm_all_zones"}a(i,b.create_fingerprints("TS0215A",{"_TZ3000_4fsgukof","_TZ3000_wr2ucaj9","_TZ3000_zsh6uat3","_TZ3000_tj4pwzzm","_TZ3000_2izubafb","_TZ3000_pkfazisv","_TZ3000_0dumfk2z","_TZ3000_ssp0maqm","_TZ3000_p3fph1go","_TZ3000_9r5jaajv","_TZ3000_nxdziqzc","_TZ3000_irwuzilv","_TZ3000_gjiggmio"}))a(p,{b.create_fingerprint("HEIMAN","SOS-EF-3.0"),b.create_fingerprint("HEIMAN","SOS-EM")})a(t,b.create_fingerprints("TS0215A",{"_TZ3000_p6ju8myv","_TZ3000_0zrccfgx","_TZ3000_fsiepnrh","_TZ3000_ug1vtuzn","_TZ3000_eo3dttwe","_TZ3000_jwcixnrz","_TZ3000_u2bbagu4","_TZ3000_8utxxtzr"}))a(k,{b.create_fingerprint("HEIMAN","RC-EF-3.0")})a(c,{b.create_fingerprint("HEIMAN","RC-EM"),b.create_fingerprint("HEIMAN","RC-N")})j.attach_reporting_capabilities(g,{{1,"rpt-tnq"},{2,"rpt-tfs"},{3,"rpt-toee"},{4,"rpt-toee"},{5,"rpt-rqo"}})return{id="zcl.controls.security",registrations=g}
