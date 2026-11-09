local q,u,d=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family"local l,a=d.definition_registry()local b,c,e,h=1796,2,1,65520



local function g(p,_,j,m)
j=math.floor(tonumber(j))local n=string.char(1,0,1,0,2,33,j%256,math.floor(j/256)%256)return q.send_raw_cluster_command(p,b,c,n,m.endpoint or 1,nil,nil,true)
end
local function k(p,_,j,m)
j=math.floor(tonumber(j))local n=string.char(1,0,2,0,1,32,j%256)return q.send_raw_cluster_command(p,b,c,n,m.endpoint or 1,nil,nil,true)
end
local function i(o)
local f=o and o.body and o.body.zcl_body and o.body.zcl_body.body_bytes or nil
if type(f)~="string"or #f<7 then
return nil
end
if string.byte(f,3)~=128 or string.byte(f,4)~=0 then
return nil
end
return tostring(string.byte(f,7))
end
local t,r,s={profile="controllers-easyiot-sp1000",zcl_clusters={q.cluster_attribute(b,nil,{name="easyiot_sp1000_play_voice",write_only=true,numeric_range={minimum=1,maximum=999,step=1},sender=g}),q.cluster_attribute(b,nil,{name="easyiot_sp1000_volume",write_only=true,numeric_range={minimum=1,maximum=30,step=1},sender=k}),q.cluster_attribute(b,h,{name="easyiot_sp1000_status",read_only=true,command_id=e,command_extractor=i,emit=u.easyiotSp1000Status()})}},{profile="switches-switch-4",zcl_clusters=q.multi_switch(4,{configure_reporting=false,index_offset=1})},{profile="switches-switch-8",zcl_clusters=q.multi_switch(8,{configure_reporting=false,index_offset=1})}a(t,{d.create_fingerprint("easyiot","ZB-SP1000")})a(r,{d.create_fingerprint("easyiot","ZB-PSW04")})a(s,{d.create_fingerprint("easyiot","ZB-SW08")})return{id="zcl.switches.easyiot",registrations=l}
