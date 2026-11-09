local ag,ad,B,d,c=require"protocol.zcl",require"capabilities.events.all",require"st.zigbee.cluster_base",require"st.zigbee.data_types",{}c.MANUFACTURER_CODE=5264
c.PROFILE_ID=49153
c.ENDPOINT=239
c.RPC_CLUSTER=64513
c.WIFI_CLUSTER=64514
c.LIGHT_LEVEL_CLUSTER=64545
local q,h="_shelly_gen4_full_wifi_ssid",{status={id=0,data_type=d.CharString},ip={id=1,data_type=d.CharString},action_code={id=2,data_type=d.Uint8},dhcp={id=3,data_type=d.Boolean},enabled={id=4,data_type=d.Boolean},ssid={id=5,data_type=d.CharString},password={id=6,data_type=d.CharString},static_ip={id=7,data_type=d.CharString},net_mask={id=8,data_type=d.CharString},gateway={id=9,data_type=d.CharString},name_server={id=10,data_type=d.CharString}}
local function N(s)
return assert(ad[s],"missing custom capability emitter: "..tostring(s))()
end
local function H(o,l)
l=l or c.ENDPOINT
if type(o.to_endpoint)=="function"then
o=o:to_endpoint(l)end
if o.address_header and o.address_header.profile then
o.address_header.profile.value=c.PROFILE_ID
end
return o
end
local function C(b,o,l)
b:send(H(o,l))return true
end
local function i(b,A,w,S,value,l)
return C(b,B.write_manufacturer_specific_attribute(b,A,w,c.MANUFACTURER_CODE,S,value),l)
end
local function G(b,A,w,l)
return C(b,B.read_manufacturer_specific_attribute(b,A,w,c.MANUFACTURER_CODE),l)
end
local function t(value)
local W=value==true or value==1
return W and"true"or"false"
end
local function p(value)
if value=="true"or value==true or value==1 then return true end
if value=="false"or value==false or value==0 then return false end
return nil
end
local function n(value)
if type(value)~="string"or value==""then return nil end
return value
end
local function v(value)
if type(value)~="string"then return nil end
return value
end
local function f(b)
if type(b)~="table"or type(b.get_field)~="function"then
return nil
end
local value=b:get_field(q)return n(value)
end
local function r(b,value)
value=n(value)if value==nil or type(b)~="table"or type(b.set_field)~="function"then
return false
end
if f(b)~=value then
b:set_field(q,value,{persist=true})end
return true
end
local function z(value,b)
local u=n(value)if u==nil then return nil end
local E=f(b)if E~=nil and E:sub(1,#u)==u then
return E
end
if E==nil or #u>#E then
r(b,u)end
return u
end
local function R(e,M)
return function(b,_,value)
local encoded=value
if e.data_type==d.Boolean then
encoded=p(value)elseif e.data_type==d.CharString then
if type(value)~="string"or(value==""and not M)then
encoded=nil
end
end
if encoded==nil then return false end
i(b,c.WIFI_CLUSTER,e.id,e.data_type,encoded)i(b,c.WIFI_CLUSTER,h.action_code.id,d.Uint8,1)if e.id==h.ssid.id then
r(b,encoded)end
return true
end
end
local function K(s,T,j,L,g)
g=g or{}local e=assert(h[j],"unknown Shelly Wi-Fi attribute: "..tostring(j))local F=ag.cluster_attribute(c.WIFI_CLUSTER,e.id,{name=s,endpoint=c.ENDPOINT,emit=N(T),data_type=e.data_type,write_type=e.data_type,mfg_code=c.MANUFACTURER_CODE,profile_id=c.PROFILE_ID,read_only=L~=true,sender=L==true and R(e,g.allow_empty==true)or nil,from_device=j=="ssid"and z or
((j=="status"or j=="ip")and v or
(e.data_type==d.Boolean and t or n))})if g.suppress_optimistic_state==true then
F.suppress_optimistic_state=true
end
if g.write_only==true then
F.write_only=true
end
return F
end
function c.append_wifi_mappings(D,Y,O)
local ac={{"wifi_status","WifiStatus","status",false},{"ip_address","IpAddress","ip",false},{"dhcp_enabled","DhcpEnabled","dhcp",false},{"wifi_enabled","WifiEnabled","enabled",true},{"wifi_ssid","WifiSsid","ssid",true},{"wifi_password","WifiPassword","password",true,true,true},{"static_ip","StaticIp","static_ip",true,false,false,true},{"net_mask","NetMask","net_mask",true,false,false,true},{"gateway","Gateway","gateway",true,false,false,true},{"name_server","NameServer","name_server",true,false,false,true}}for _,spec in ipairs(ac)do
D[#D+1]=K(Y.."_"..spec[1],O..spec[2],spec[3],spec[4],{suppress_optimistic_state=spec[5]==true,write_only=spec[6]==true,allow_empty=spec[7]==true})end
return D
end
function c.refresh_wifi(b)
c.begin_wifi_refresh(b)for _,s in ipairs{"status","ip","enabled","dhcp","ssid","static_ip","net_mask","gateway","name_server"}do
local e=h[s]G(b,c.WIFI_CLUSTER,e.id)end
return true
end
function c.begin_wifi_refresh(b)
return i(b,c.WIFI_CLUSTER,h.action_code.id,d.Uint8,0)
end
function c.get_known_full_wifi_ssid(b)
return f(b)
end
local function P(value)
if type(value)=="boolean"then return value and"true"or"false"end
if type(value)=="number"then return tostring(value)end
if type(value)~="string"then return nil end
return'"'..value:gsub('\\','\\\\'):gsub('"','\\"'):gsub('\b','\\b'):gsub('\f','\\f'):gsub('\n','\\n'):gsub('\r','\\r'):gsub('\t','\\t')..'"'
end
local function Q(path,value)
local encoded=P(value)if encoded==nil then return nil end
for ab=#path,1,-1 do
encoded='{"'..path[ab]..'":'..encoded ..'}'end
return encoded
end
local function x(method,params_json)
return'{"id":1,"method":"'..method ..'","params":'..params_json..'}'
end
function c.send_rpc_message(b,y)
if type(y)~="string"or y==""then return false end
i(b,c.RPC_CLUSTER,1,d.Uint32,#y)for U=1,#y,40 do
i(b,c.RPC_CLUSTER,0,d.CharString,y:sub(U,U+39))end
return true
end
local function k(s,Z)
return{protocol="zcl",cluster_id=c.RPC_CLUSTER,name=s,endpoint=c.ENDPOINT,mfg_code=c.MANUFACTURER_CODE,write_only=true,sender=Z}
end
function c.rpc_presence_setting(s,path,g)
g=g or{}
return k(s,function(b,_,value)
if g.reject_value~=nil and value==g.reject_value then return false end
if type(g.to_device)=="function"then value=g.to_device(value)end
local config=Q(path,value)if config==nil then return false end
return c.send_rpc_message(b,x("Presence.SetConfig",'{"config":'..config..'}'))
end)
end
function c.rpc_presence_zone_delay(s,field)
return k(s,function(b,_,value)
value=tonumber(value)if value==nil then return false end
value=math.max(0,math.min(3600,math.floor(value+0.5)))local I='{"id":200,"config":{"'..field ..'":'..tostring(value)..'}}'return c.send_rpc_message(b,x("PresenceZone.SetConfig",I))
end)
end
function c.rpc_eco_mode(s)
return k(s,function(b,_,value)
value=p(value)if value==nil then return false end
local I='{"config":{"device":{"eco_mode":'..(value and"true"or"false")..'}}}'return c.send_rpc_message(b,x("Sys.SetConfig",I))
end)
end
function c.boolean_from_device(value)
return t(value)
end
function c.boolean_to_device(value)
return p(value)
end
return c
