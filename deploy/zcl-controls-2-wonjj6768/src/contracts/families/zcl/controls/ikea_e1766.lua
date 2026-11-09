local x,p,y,u,J,B,H=require"protocol.zcl",require"contracts.helpers.family",require"contracts.helpers.zcl",require"st.capabilities",require"st.zigbee.data_types",require"st.zigbee.device_management",require"st.zigbee.zdo.bind_request"local f,C=p.definition_registry()local h,K="__ikea1766_version","__ikea1766_hub"
local function o(d)
if type(d)~="string"then return 2 end
local i,q,patch,D=d:match"^[v=%s]*(%d+)%.(%d+)%.(%d+)(.-)%s*$"if i==nil then return 2 end
local prerelease,n=D:match"^(.-)%+(.+)$"if D:find("+",1,true)and n==nil then return 2 end
prerelease=prerelease or D
local function l(c)
return c~=""and not c:find"[^A-Za-z0-9%.%-]"and c:sub(1,1)~="."and c:sub(-1)~="."and not c:find("..",1,true)
end
if n~=nil and not l(n)then return 2 end
if prerelease~=""then
if #prerelease>1 and prerelease:sub(1,1)=="-"then prerelease=prerelease:sub(2)end
if prerelease:sub(1,1)=="."and #patch>1 then
prerelease,patch=patch:sub(-1)..prerelease,patch:sub(1,-2)end
if not l(prerelease)then return 2 end
end
i,q,patch=tonumber(i),tonumber(q),tonumber(patch)if i>9007199254740991 or q>9007199254740991 or patch>9007199254740991 then return 2 end
if i~=2 then return i<2 and 1 or 2 end
if q~=4 then return q<4 and 1 or 2 end
return patch==0 and prerelease~=""and 1 or 2
end
local function s(c)
c=c:match"^%s*(.-)%s*$"if c==""then return 0 end
if c=="Infinity"or c=="+Infinity"then return math.huge end
if c=="-Infinity"then return-math.huge end
if c:match"^0[bB][01]+$"then return tonumber(c:sub(3),2)end
if c:match"^0[oO][0-7]+$"then return tonumber(c:sub(3),8)end
if c:match"^0[xX]%x+$"then return tonumber(c)end
if not c:find"[^%d%.eE%+%-]"then return tonumber(c)or false end
return false
end
local function k(a)
local d,L=a:get_field(h),a:get_field(K)if type(d)~="string"or d==""or L==nil then return end
local e={}for c in(d .."."):gmatch"(.-)%."do e[#e+1]=s(c)end
local m,A=e[1]and(e[1]>2 or e[1]==2 and e[2]and(e[2]>3 or e[2]==3 and e[3]and e[3]>=75)),B.build_bind_request(a,6,L,1)if not m then A.body.zdo_body=H.BindRequest(a.zigbee_eui,1,6,H.ADDRESS_MODE_16_BIT,901)end
a:send(A)
end
local function z(a)
x.read_attribute(a,0,16384,1)x.read_attribute(a,1,33,1)
end
local I={profile="buttons-ikea-e1766",magic_packet=false,initial_custom_state_query=false,button_actions={"pushed"},advanced_remote=true,
component_to_endpoint=function()return 1 end,
endpoint_to_component=function()return"main"end,
remote_action_emit_name="ikeaE1766Action",standard_action_metadata_emit_names={action_group="ikeaE1766ActionGroup"},
standard_command_action_resolver=function(N,r,F,m,a)
local g,w=r==258 and m==1 and({[0]="open",[1]="close",[2]="stop"})[F],N.body.zcl_header
if not g or w.frame_ctrl:is_mfg_specific_set()or w.frame_ctrl:is_direction_set()or y.duplicate_transaction(a,1,w.seqno.value,"__ikea1766_transactions")then return nil,"main",true end
return g,"main",true
end,
remote_action_handler=function(a,_,g)
local t=g=="open"and"button1"or g=="close"and"button2"if t then
a:emit_component_event({id=t},u.button.button.pushed{state_change=true})x.schedule_battery_refresh_after_button(a)end
end,
protocol_writers={ikea_e1766_identify=y.identify},capability_commands={{capability_id="concertmirror08464.ikeaE1766Identify",command_name="identify",mapping_name="ikea_e1766_identify",value=3},{capability_id="concertmirror08464.ikeaE1766Identify",command_name="setIdentifyTime",mapping_name="ikea_e1766_identify",argument_name="identifyTime"}},parent_refresh=z,zcl_clusters={x.cluster_attribute(0,16384,{name="ikea_e1766_version",endpoint=1,component="main",data_type=J.CharString,read_only=true,read_on_configure=false,read_on_refresh=false,
handler=function(a,d)
if type(d)~="string"then return end
local E=a:get_field(h)~=d
a:set_field(h,d,{persist=true})if E then k(a)end
end
}),x.battery{endpoint=1,component="main",read_on_configure=false,read_on_refresh=false,minimum_interval=3600,maximum_interval=65000,reportable_change=10,
from_device=function(_,a,G)
local M=G.raw_value
if M<255 then return M/o(a:get_field(h))end
end
}},
configure=function(v,a)
a:set_field(K,v.environment_info.hub_zigbee_eui,{persist=false})v:add_hub_to_zigbee_group(901)for _,r in ipairs{258,1}do x.bind_cluster(a,r,v.environment_info.hub_zigbee_eui,1)end
k(a)z(a)
end
}C(I,{p.create_fingerprint("IKEA of Sweden","TRADFRI open/close remote"),p.create_fingerprint("KE","TRADFRI open/close remote"),p.create_fingerprint("\002KE","TRADFRI open/close remote")})x.attach_reporting_capabilities(f,{{1,"rpt-twy"}})return{id="zcl.controls.ikea_e1766",registrations=f}
