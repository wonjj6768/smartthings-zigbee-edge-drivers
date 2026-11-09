local function bh(l,p)
local bm,bd,v,B,r,w,br,aO,aV,aP,d,A,bj,aW,aL,aH,au,R,Y,af,ae,aE,ar,X,ag,K,ao=p.log,p.BASIC_CLUSTER,p.PERSIST_FALSE,p.CONFIG_QUEUE_FIELD,p.CONFIG_QUEUE_CALLBACK_FIELD,p.QUERY_INTERVAL_TIMER_FIELD,p.SET_TIME,p.CONNECTION_STATUS,p.REPORT_COMMANDS,require"st.zigbee.device_management",p.type_check,p.table_insert,p.table_remove,p.extract_payload,p.extract_command_id,p.extract_transaction,p.prepare_mappings,p.time_offset_for_start,"magic_packet","query_state","mcu_version",p.MCU_VERSION_RESPONSE,"bind_basic","config_queue","query_timer","tuya_next_forced_time_update",60*60


















local s
local u
local Q
local F
local function n(ba,ap,bn)
local q=ba
if q==nil then
q=ap
end
if d(q)~="number"or q<0 then
bm.warn(string.format("Tuya %s expects non-negative number, got %s",bn,tostring(q)))return nil
end
return q
end
local function am(ba,ap,bn)
local q=ba
if q==nil then
q=ap
end
if d(q)~="number"or q<=0 then
bm.warn(string.format("Tuya %s expects positive number, got %s",bn,tostring(q)))return nil
end
return q
end
local function ax(b,aK)
local h=b.bind_target_eui
if d(h)=="string"and h~=""then
return h
end
if d(aK)=="table"and d(aK.environment_info)=="table"then
local ac=aK.environment_info.hub_zigbee_eui
if d(ac)=="string"and ac~=""then
return ac
end
end
return nil
end
local function al(b)
local bi,bq={},d(b.named_mapping)=="table"and b.named_mapping or nil
if bq~=nil then
for bp,ba in pairs(bq)do
bi[bp]=ba
end
end
local bo={"named_mappings","named_datapoints","named_key_field","named_mapping_values","named_mapping_names"}for _,bp in ipairs(bo)do
if b[bp]~=nil then
bi[bp]=b[bp]end
end
return bi
end
local function ay(a,h)
if d(h)~="string"or h==""then
return false
end
local at=aP.build_bind_request(a,bd,h)if at==nil then
bm.warn"Tuya bind_basic_on_configure failed to build bind request"return false
end
a:send(at)return true
end
local function ah(aZ,aX)
if d(aZ)~="table"or d(aX)~="table"then
return aZ
end
for _,L in ipairs(aX)do
A(aZ,L)end
return aZ
end
local function D(a,o,x,aB)
if o[aB+1]then
a.thread:call_with_delay(x,function()
u(a,o,x,aB+1)
end)
end
end
s=function(a,m,V,bk,aY)
if V=="off"then
return false
end
local aM=R(V)if aM~=0 then
return l.apply_time_request_with_offset(a,m,aM,bk,aY)end
return l.apply_time_request(a,m,bk,aY)
end
u=function(a,o,x,bt)
local aB=bt or 1
local H=o[aB]if not H then
return false
end
if H.kind==Y then
l.send_magic_packet(a)elseif H.kind==af then
l.send_state_request(a,H.command_id)elseif H.kind==ae then
l.send_mcu_version_request(a)elseif H.kind==ar then
ay(a,H.bind_target_eui)elseif H.kind==X then
return l.start_config_queue(a,H.queue,{
on_complete=function(success)
if success then
D(a,o,x,aB)end
end
})elseif H.kind==ag then
l.start_query_timer(a,H.interval_seconds,H.command_id)end
D(a,o,x,aB)return true
end
function l.apply_announce(a,b)
b=b or{}local bl=false
if d(b.announce_handler)=="function"then
bl=b.announce_handler(a,b)~=false
end
if not b.query_on_announce then
return bl
end
local bf=n(b.announce_delay,0.5,"announce_delay")if bf==nil then
return false
end
a.thread:call_with_delay(bf,function()
l.send_state_request(a,b.query_command_id)
end)
return true
end
function l.stop_query_timer(a)
local aN=a:get_field(w)if aN and aN.cancel then
pcall(function()
aN:cancel()
end)
end
a:set_field(w,nil,v)return true
end
function l.start_query_timer(a,aT,k,at)
local bb=am(aT,nil,"query_interval_seconds")if bb==nil then
return false
end
l.stop_query_timer(a)local aN=nil
aN=a.thread:call_with_delay(bb,function()
if at~=nil then at(a)else l.send_state_request(a,k)end
l.start_query_timer(a,bb,k,at)
end)
a:set_field(w,aN,v)return true
end
function l.start_configuration(a,b,aK)
b=b or{}local o,x,aq={},n(b.step_delay,1,"step_delay"),n(b.initial_delay,0,"initial_delay")if x==nil or aq==nil then
return false
end
local e,y,aU=al(b),b.preference_map,d(b.preference_names)=="table"and b.preference_names or nil

local j,G,Z,h,S=e.named_mappings,d(e.named_mapping_values)=="table"and e.named_mapping_values or nil,d(e.named_mapping_names)=="table"and e.named_mapping_names or nil,ax(b,aK),{}


if y==nil and b.preference_datapoints then
local t=b.preference_datapoints
if t==true then
t=b.datapoints
end
if t~=nil then
y=l.build_preference_map(t,b.preference_key_field)end
end
if y~=nil then
au(y)end
if j==nil and e.named_datapoints then
local z=e.named_datapoints
if z==true then
z=b.datapoints
end
if z~=nil then
if e.named_key_field~=nil then
j=l.build_named_map(z,e.named_key_field)else
j=z
end
end
end
if j==nil and(G~=nil or Z~=nil)and b.datapoints~=nil then
if e.named_key_field~=nil then
j=l.build_named_map(b.datapoints,e.named_key_field)else
j=b.datapoints
end
end
if j~=nil then
au(j)end
if b.magic_packet~=false then
A(o,{kind=Y})end
if b.query_on_configure then
A(o,{kind=af,command_id=b.query_command_id})end
if b.mcu_version_request_on_configure then
A(o,{kind=ae})end
if b.bind_basic_on_configure then
if h~=nil then
A(o,{kind=ar,bind_target_eui=h})else
bm.warn"Tuya bind_basic_on_configure requires bind_target_eui or driver.environment_info.hub_zigbee_eui"end
end
if y~=nil then
ah(S,l.build_preference_config_queue(a,y,aU))end
if j~=nil and G~=nil then
ah(S,l.build_named_mapping_config_queue(a,j,G,Z))end
if #S>0 then
A(o,{kind=X,queue=S})end
if b.query_interval_seconds then
A(o,{kind=ag,interval_seconds=b.query_interval_seconds,command_id=b.query_command_id})end
if #o==0 then
return false
end
if aq>0 then
a.thread:call_with_delay(aq,function()
u(a,o,x,1)
end)
return true
end
return u(a,o,x,1)
end
local function aI(a,m,c)
if type(c.time_handler)=="function"then
return c.time_handler(a,m,c)end
if c.auto_time==false then
return false
end
local N=c.time_offset
if N then
return l.apply_time_request_with_offset(a,m,N,c.utc_time,c.local_time)end
if c.time_start then
return s(a,m,c.time_start,c.utc_time,c.local_time)end
return l.apply_time_request(a,m,c.utc_time,c.local_time)
end
local function O(a,m,c)
if c.auto_connection_status==false then
return false
end
return l.apply_connection_status_request(a,m,c.connection_status_bytes)
end
local function J(a,bs)
a:set_field(K,(bs or os.time())+ao,v)
end
local function aw(a,m,c)
if c.force_time_updates~=true or c.time_start=="off"then
return false
end
local bs,aR=os.time(),a:get_field(K)if aR~=nil and aR>=bs then
return false
end
J(a,bs)if type(c.time_handler)=="function"then
return c.time_handler(a,m,c)==true
end
local N=c.time_offset
if N~=nil then
return l.send_time_with_offset(a,N,c.utc_time,c.local_time)==true
end
local V=c.time_start
if V~=nil then
local aM=R(V)if aM~=0 then
return l.send_time_with_offset(a,aM,c.utc_time,c.local_time)==true
end
end
return l.send_time(a,c.utc_time,c.local_time)==true
end
local function aC(a,m,c,as,k)
local C=l.parse_datapoint_report(m)if not C then
bm.warn(string.format("Failed to parse Tuya report for command 0x%02X",k))return false
end
if c.config_queue~=false then
F(a,m,c.queue_delay,C)end
for _,ab in ipairs(C.datapoints)do
if as then
l.apply_datapoint_mapping(a,ab,as,{frame=C,endpoint=ab.endpoint or C.endpoint})end
end
return true
end
function l.apply_message(a,m,c)
c=c or{}local as,k=c.datapoints,aL(m)
if not k then
return false
end
local ak=aw(a,m,c)if k==br then
if ak then
return true
end
if aI(a,m,c)then
J(a)return true
end
end
if k==aO then
if ak then
return true
end
if O(a,m,c)then
return true
end
end
if k==aE and c.respond_to_mcu_version_response==true then
return l.send_mcu_version_request(a,l.DEFAULT_MCU_VERSION_TRANSACTION)~=nil
end
if aV[k]==true then
return aC(a,m,c,as,k)end
return false
end
local function aJ(aS,bg)
if aS==nil or bg==nil then
return false
end
if aS==bg then
return true
end
return(aS%256)==bg
end
local function aF(P,C)
local i={}if C and C.datapoints and #C.datapoints>0 then
for _,ab in ipairs(C.datapoints)do
i[ab.dp]=true
end
return i
end
if P then
local ab=l.parse_datapoint(P,3)if ab~=nil then
i[ab.dp]=true
end
end
return i
end
local function U(i,dp)
return dp~=nil and i[dp]==true
end
local function ai(f)
local g={}
local function az(dp)
if d(dp)=="number"then
g[dp]=true
end
end
if f.response_dp~=nil then
az(f.response_dp)return g
end
if d(f.response_dps)=="table"then
for _,dp in ipairs(f.response_dps)do
az(dp)end
if next(g)~=nil then
return g
end
end
if f.dp~=nil then
az(f.dp)return g
end
if d(f.items)=="table"then
for _,L in ipairs(f.items)do
if d(L)=="table"then
az(L.dp)end
end
end
return g
end
local function W(f,i)
local g=f.expected_response_dps
if d(g)~="table"then
g=ai(f)f.expected_response_dps=g
end
if next(g)==nil then
return false
end
local M=f.matched_response_dps
if d(M)~="table"then
M={}f.matched_response_dps=M
end
local aQ=false
for dp,_ in pairs(i)do
if U(g,dp)then
M[dp]=true
aQ=true
end
end
if not aQ then
return false
end
for dp,_ in pairs(g)do
if not U(M,dp)then
return false
end
end
return true
end
local function av(f,ad,P,C)
if f.match_response then
return f.match_response(ad,P,f,C)==true
end
if f.match_transaction and f.packet_id~=nil then
local aG=aH(ad)if not aJ(f.packet_id,aG)then
return false
end
end
local i=aF(P,C)if next(i)==nil then
return f.match_transaction and f.packet_id~=nil
end
return W(f,i)
end
local function aj(a)
a:set_field(B,nil,v)a:set_field(r,nil,v)
end
local function aA(b)
if d(b)=="function"then
return b
end
if d(b)=="table"and d(b.on_complete)=="function"then
return b.on_complete
end
return nil
end
local function I(a,success)
local aa=a:get_field(r)aj(a)if d(aa)=="function"then
local ok,bv=pcall(aa,success==true)if not ok then
bm.warn(string.format("Tuya config queue callback failed: %s",tostring(bv)))end
end
return success==true
end
local function E(a)
if Q(a)then
return true
end
return I(a,false)
end
function l.start_config_queue(a,T,b)
local aX,aa=T or{},aA(b)if #aX==0 then
aj(a)if d(aa)=="function"then
pcall(aa,false)end
return false
end
a:set_field(B,aX,v)a:set_field(r,aa,v)return E(a)
end
Q=function(a)
local T=a:get_field(B)if not T or #T==0 then
return false
end
local L=T[1]local k=L.command_id
if L.items then
local an=l.send_datapoints(a,L.items,k,L.transaction)if an~=nil then
L.packet_id=an
return true
end
return false
end
local an=l.send_datapoint(a,L.dp,L.datatype,L.value,k,L.signed,L.transaction)if an~=nil then
L.packet_id=an
return true
end
return false
end
F=function(a,ad,bf,C)
local P,T=aW(ad),a:get_field(B)if not P or not T or #T==0 then
return false
end
C=C or l.parse_datapoint_report(ad)local f=T[1]if not av(f,ad,P,C)then
return false
end
bj(T,1)if #T==0 then
return I(a,true)end
local aD=n(bf,0.5,"config_queue_delay")if aD==nil then
return I(a,false)end
a.thread:call_with_delay(aD,function()
E(a)
end)
return true
end
end
return bh
