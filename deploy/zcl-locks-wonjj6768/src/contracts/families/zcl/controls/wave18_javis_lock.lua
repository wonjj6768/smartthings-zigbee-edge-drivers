local N,J,y,E=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.zigbee.data_types"local s,f=y.definition_registry()local B,k,l,v,p,h,e,C,g=0,16896,"__wave18_javis_lock_timer","__wave18_javis_action_user","__wave18_javis_action_source","__wave18_javis_action_source_name","__javis_recent_reports",{[0]="pairing",[1]="keypad",[2]="rfid_card_unlock",[3]="touch_unlock"},assert(J.javisSlkAction,"missing Wave18 JAVIS action emitter")()


local function d(...)
local F=g(...)if F~=nil then F.state_change=true end
return F
end
local q=assert(J.javisSlkState,"missing Wave18 JAVIS state emitter")()
local function i(value,a,m)
if type(value)~="string"then
return nil
end
local t=m and m.zb_rx and m.zb_rx.body.zcl_header
local D=t and t.seqno and t.seqno.value
if t and t.cmd.value==10 and D~=nil then
local z,M,A,u,K=a:get_field(e)or{},tostring(m.endpoint)..":"..tostring(m.mfg_code),string.char(D)..value,{},os.time()
for _,c in ipairs(z[M]or{})do
if K>=c.at and K-c.at<10 then
if c.signature==A then return nil end
u[#u+1]=c
end
end
table.insert(u,1,{signature=A,at=K})u[6]=nil
z[M]=u
a:set_field(e,z)end
local O,I=string.byte(value,4),string.byte(value,6)a:set_field(v,O,{persist=false})a:set_field(p,I,{persist=false})a:set_field(h,C[I],{persist=false})return"unlock"
end
local function n(a,_,j)
local x,b=type(j)=="table"and j.endpoint or"unknown",a:get_field(l)if type(b)~="table"then b={}end
local c=b[x]if c~=nil and type(c.cancel)=="function"then
c:cancel()end
local G
G=a.thread:call_with_delay(2,function()
local o=a:get_field(l)if type(o)~="table"or o[x]~=G then return end
local r=d(a,"lock")if r~=nil then a:emit_event(r)end
local w=q(a,"LOCK")if w~=nil then a:emit_event(w)end
end,"wave18 javis delayed lock")
b[x]=G
a:set_field(l,b,{persist=false})
end
local L={profile="locks-wave18-javis-js-slk2-zb",package_group="wave18-javis-lock",zcl_clusters={N.cluster_attribute(B,k,{name="javis_unlock_report",read_only=true,from_device=i,handler=n,emit=d}),N.cluster_attribute(1,33,{name="battery",component="main",data_type=E.Uint8,read_only=true,scale=2,emit=J.battery()})}}f(L,{{manufacturer="Lmiot",model="doorlock_5001"},{manufacturer="Vensi",model="E321V000A03"}})return{id="zcl.controls.wave18_javis_lock",registrations=s}
