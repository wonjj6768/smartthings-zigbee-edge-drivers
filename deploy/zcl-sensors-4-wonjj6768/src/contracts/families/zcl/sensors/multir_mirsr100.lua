local s,K,h,e,x=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.zigbee.zcl.clusters",require"st.zigbee.data_types"local n,B=h.definition_registry()local t,N,y,q=K.mirSr100SwitchAction(),{stop=0,burglar=1,fire=2,emergency=3,police_panic=4,fire_panic=5,emergency_panic=6},{low=0,medium=1,high=2,very_high=3},{mode=true,level=true,strobe=true,duration=true,strobeDutyCycle=true,strobeLevel=true}
local function o(b,H,G)
return type(b)=="number"and b==b and b>=H and b<=G
end
local function r(a,P,F)
P.body.zcl_header.frame_ctrl:set_disable_default_response()a:send(P:to_endpoint(a:get_endpoint(F)))return true
end
local function I(a,c)
if c==nil then c={}elseif c=="stop"then c={mode="stop"}end
if type(c)~="table"then return false end
for D in pairs(c)do if not q[D]then return false end end
local L,E,l,p,j,v=N[c.mode or"emergency"],y[c.level or"medium"],y[c.strobeLevel or"high"],c.strobe,c.duration,c.strobeDutyCycle
if p==nil then p=false end
if j==nil then j=10 end
if v==nil then v=0 end
if L==nil or E==nil or l==nil or type(p)~="boolean"or
not o(j,0,65535)or not o(v,0,10)then return false end
local O=(L<<4)|(p and 4 or 0)|E
return r(a,e.IASWD.server.commands.StartWarning(a,O,math.modf(j),math.modf(v*10),l),1282)
end
local function C(a,d)
if type(d)=="number"then d={onTime=d}end
if d==nil then d={}end
if type(d)~="table"then return false end
for D in pairs(d)do if D~="onTime"and D~="offWaitTime"then return false end end
local m,k=d.onTime,d.offWaitTime
if m==nil then m=0 end
if k==nil then k=0 end
if not o(m,0,6553.4)or not o(k,0,6553.4)then return false end
return r(a,e.OnOff.server.commands.OnWithTimedOff(a,0,math.floor(m*10+0.5),math.floor(k*10+0.5)),6)
end
local function u(Q)
local A=Q.body.zcl_body.zone_status
return{raw_value=A.value,typed_value=A}
end
local M=s.switch{configure_reporting=false,read_on_configure=false,read_on_refresh=true,reporting_defaults={minimum_interval=0,maximum_interval=65000},
sender=function(a,_,b)
if b==true then return r(a,e.OnOff.server.commands.On(a),6)end
if b==false then return r(a,e.OnOff.server.commands.Off(a),6)end
return false
end
}local i=s.tamper()i.minimum_interval,i.maximum_interval,i.reportable_change=nil,nil,nil
i.read_on_configure,i.read_on_refresh=false,true
local z={profile="safety-multir-mirsr100",zcl_clusters={M,s.cluster_attribute(6,0,{name="mir_sr100_switch_action",data_type=x.Boolean,read_only=true,read_on_configure=false,read_on_refresh=false,
from_device=function(b,a)
if a.preferences.stateAction~=true then return nil end
return(b==true or b==1)and"on"or"off"
end,
emit=function(a,b)
local w=t(a,b)if w then w.state_change=true end
return w
end
}),s.cluster_attribute(1280,2,{name="mir_sr100_alarm",data_type=x.Bitmap16,read_only=true,read_on_configure=false,read_on_refresh=true,emit=K.mirSr100Alarm(),
from_device=function(b)
if type(b)=="table"then b=b.value end
if type(b)~="number"then return nil end
return(b&1)~=0 and"alarm"or"clear"
end,
command_id=0,command_extractor=u}),i},protocol_writers={mir_sr100_warning=I,
mir_sr100_toggle=function(a)
return r(a,e.OnOff.server.commands.Toggle(a),6)
end,
mir_sr100_timed_on=C},capability_commands={{capability_id="concertmirror08464.mirSr100Warning",command_name="warning",mapping_name="mir_sr100_warning",argument_name="warning"},{capability_id="concertmirror08464.mirSr100Warning",command_name="stop",mapping_name="mir_sr100_warning",value="stop"},{capability_id="concertmirror08464.mirSr100Toggle",command_name="toggle",mapping_name="mir_sr100_toggle"},{capability_id="concertmirror08464.mirSr100TimedOn",command_name="onWithTimedOff",mapping_name="mir_sr100_timed_on",argument_name="timing"},{capability_id="concertmirror08464.mirSr100TimedOn",command_name="setOnTime",mapping_name="mir_sr100_timed_on",argument_name="onTime"}},
configure=function(J,a)
local g={}for _,f in pairs(a.zigbee_endpoints or{})do
if a:supports_server_cluster(6,f.id)then g[#g+1]=f.id end
end
table.sort(g)for _,f in ipairs(g)do
s.bind_cluster(a,6,J.environment_info.hub_zigbee_eui,f)s.configure_reporting(a,{cluster=6,attribute=0,data_type=x.Boolean,minimum_interval=0,maximum_interval=65000},f,{auto_endpoint=true})a:send(e.OnOff.attributes.OnOff:read(a):to_endpoint(f))end
end
}B(z,{h.create_fingerprint("MultIR","MIR-SR100")})s.attach_reporting_capabilities(n,{{1,"rpt-may"}})return{id="zcl.sensors.multir_mirsr100",registrations=n}
