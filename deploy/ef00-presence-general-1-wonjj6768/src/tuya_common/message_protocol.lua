local function aV(n,f)
local bj,aD,aI,bc,aZ,v,aB,ax,aA,aX,bi,aw,aq,Y,Q,aJ,ay,av,al,az,ak,d,U,string_pack,aM,h,R,b,aH,bh,aP,af,D,C,ah,M,W,bf,ao,P,J=f.data_types,f.constants,f.zcl_messages,f.messages,f.generic_body,f.log,f.TUYA_CLUSTER,f.TUYA_ENDPOINT_FIELD,f.MAGIC_PACKET_ATTRS,f.SET_DATA,f.QUERY_DATA,f.MCU_VERSION_REQUEST,f.SET_TIME,f.CONNECTION_STATUS,f.DEFAULT_MCU_VERSION_TRANSACTION,f.DP_TYPE_RAW,f.DP_TYPE_BOOL,f.DP_TYPE_VALUE,f.DP_TYPE_STRING,f.DP_TYPE_ENUM,f.DP_TYPE_BITMAP,f.string_byte,f.string_char,f.string_pack,f.string_sub,f.string_len,f.math_floor,f.type_check,f.table_insert,f.os_time,f.next_packet_id,f.resolve_cluster_endpoint,f.extract_payload,f.extract_command_id,f.extract_source_endpoint,f.build_basic_read_attributes_message,f.raw_bytes,f.pack_bitmap,f.normalize_transaction,{[0]="not_set",[1]="over_current_threshold",[3]="over_voltage_threshold"},{[0]="OFF",[1]="ON"}






































local aj
local m
local aE
local Z
local aK
local A
local K
local B
local function aO(e)
return b(e)=="number"and e>=0 and e<=255 and e%1==0
end
local function y(e,bx)
if b(e)~="number"then
v.warn(string.format("Tuya %s expects number, got %s",bx,b(e)))return nil
end
local E=R(e)if E~=e or E<0 or E>0xFFFFFFFF then
v.warn(string.format("Tuya %s expects integer in range 0..0xFFFFFFFF, got %s",bx,tostring(e)))return nil
end
return E
end
local function p(e,bv)
if e==nil then
return bv
end
return e
end
aj=function(e)
local bg=W(e)if bg~=nil then
return bg
end
v.warn(string.format("Tuya bytes expects string or byte array, got %s",b(e)))return nil
end
function n.parse_phase_variant1(e,phase)
local c=W(e)if c==nil or h(c)<15 then
v.warn"Tuya phase_variant1 expects at least 15 bytes"return nil
end
local ap,am,suffix=m(c,14,2)/10,m(c,12,2)/1000,b(phase)=="string"and phase~=""and"_"..phase or""

return{["voltage"..suffix]=ap,["current"..suffix]=am}
end
function n.parse_phase_variant2(e,phase,aG)
local c=W(e)if c==nil or h(c)<8 then
v.warn"Tuya phase_variant2 expects at least 8 bytes"return nil
end
local ap,aW=m(c,1,2)/10,aG and 3 or 2

local am,ac=m(c,6-aW,aW)/1000,m(c,9-aW,aW)
if aG then
if ac>0x99999A then
ac=ac-16777216
elseif ac>=8388608 then
ac=ac-0x99999A
end
end
local suffix=b(phase)=="string"and phase~=""and"_"..phase or""return{["voltage"..suffix]=ap,["current"..suffix]=am,["power"..suffix]=ac}
end
function n.parse_phase_variant3(e,phase)
local c=W(e)if c==nil or h(c)<8 then
v.warn"Tuya phase_variant3 expects at least 8 bytes"return nil
end
local ap,am,ac,suffix=m(c,1,2)/10,m(c,3,3)/1000,m(c,6,3),b(phase)=="string"and phase~=""and"_"..phase or""

return{["voltage"..suffix]=ap,["current"..suffix]=am,["power"..suffix]=ac}
end
function n.parse_threshold(e)
local c=W(e)if c==nil or h(c)<8 then
v.warn"Tuya threshold expects at least 8 bytes"return nil
end
return{threshold_1_protection=J[d(c,2)],threshold_1=P[d(c,1)],threshold_1_value=m(c,3,2),threshold_2_protection=J[d(c,6)],threshold_2=P[d(c,5)],threshold_2_value=m(c,7,2)}
end
function n.send_magic_packet(j)
local r=M(j,aA)if not r then
return false
end
j:send(r)return true
end
m=function(c,bp,ba)
if b(c)~="string"then
v.warn(string.format("Tuya parse_uint expects string, got %s",b(c)))return nil
end
local l,L=p(bp,1),ba
if b(l)~="number"or l%1~=0 or l<1 then
v.warn(string.format("Tuya parse_uint expects positive integer offset, got %s",tostring(l)))return nil
end
if L==nil then
L=h(c)-l+1
end
if b(L)~="number"or L%1~=0 or L<1 then
v.warn(string.format("Tuya parse_uint expects positive integer length, got %s",tostring(L)))return nil
end
if l+L-1>h(c)then
v.warn(string.format("Tuya parse_uint out of range: offset=%d len=%d buffer_len=%d",l,L,h(c)))return nil
end
if L==1 then
return d(c,l)elseif L==2 then
return(d(c,l)*256)+d(c,l+1)elseif L==4 then
return(d(c,l)*16777216)+
(d(c,l+1)*65536)+
(d(c,l+2)*256)+
d(c,l+3)end
local e=0
for i=0,L-1 do
e=e*256+d(c,l+i)end
return e
end
aE=function(c,bp,ba)
if b(c)~="string"then
v.warn(string.format("Tuya parse_int expects string, got %s",b(c)))return nil
end
local l,L=p(bp,1),ba
if L==nil then
if b(l)~="number"or l%1~=0 then
v.warn(string.format("Tuya parse_int expects integer offset, got %s",tostring(l)))return nil
end
L=h(c)-l+1
end
local at=m(c,l,L)if at==nil then
return nil
end
local aS=2 ^(L*8)local bw=aS/2
if at>=bw then
return at-aS
end
return at
end
Z=function(g,e,aF)
if g==ay then
if e==true or e==1 then
return U(1)end
if e==false or e==0 then
return U(0)end
v.warn(string.format("Tuya BOOL expects boolean or 0/1, got %s",tostring(e)))return nil
end
if g==av then
if b(e)~="number"then
v.warn(string.format("Tuya VALUE expects number, got %s",b(e)))return nil
end
local q=R(e+0.5)if aF or q<0 then
if q<-0x80000000 then q=-0x80000000 end
if q>0x7FFFFFFF then q=0x7FFFFFFF end
if q<0 then
q=q+4294967296
end
else
if q<0 then q=0 end
if q>0xFFFFFFFF then q=0xFFFFFFFF end
end
return string_pack(">I4",q)end
if g==az then
if b(e)~="number"then
v.warn(string.format("Tuya ENUM expects number, got %s",b(e)))return nil
end
local ab=R(e)if ab~=e or ab<0 or ab>255 then
v.warn(string.format("Tuya ENUM expects byte integer, got %s",tostring(e)))return nil
end
return U(ab)end
if g==ak then
if b(e)=="number"then
local bs=bf(e)if bs~=nil then
return bs
end
v.warn(string.format("Tuya BITMAP expects non-negative integer up to 0xFFFFFFFF, got %s",tostring(e)))return nil
end
if b(e)=="string"then
return e
end
v.warn(string.format("Tuya BITMAP expects number or string, got %s",b(e)))return nil
end
if g==aJ then
local aT=aj(e)if aT==nil then
return nil
end
return aT
end
if g==al then
if b(e)~="string"then
v.warn(string.format("Tuya type %d expects string, got %s",g,b(e)))return nil
end
return e
end
v.warn(string.format("Unsupported Tuya datatype: %d",g))return nil
end
aK=function(g,value_bytes)
if b(value_bytes)~="string"then
return nil
end
if g==ay then
local ar=d(value_bytes,1)if ar==0 then
return false
end
if ar==1 then
return true
end
v.warn(string.format("Tuya BOOL payload expects 0x00 or 0x01, got %s",tostring(ar)))return nil
elseif g==av then
if #value_bytes==4 then return aE(value_bytes)end
return m(value_bytes)elseif g==az then
return d(value_bytes,1)elseif g==ak then
return m(value_bytes)elseif g==aJ or g==al then
return value_bytes
end
return nil
end
function n.build_datapoint(dp,g,e,aF)
if not aO(dp)or not aO(g)then
v.warn(string.format("Tuya datapoint expects byte dp/datatype, got dp=%s datatype=%s",tostring(dp),tostring(g)))return nil
end
local value_bytes=Z(g,e,aF)if not value_bytes then
return nil
end
local ag=h(value_bytes)if ag>65535 then
v.warn(string.format("Tuya datapoint value too long: %d",ag))return nil
end
return U(dp,g)..string_pack(">I2",ag)..value_bytes
end
function n.build_datapoints(bo)
local by={}for _,bn in ipairs(bo or{})do
local a=n.build_datapoint(bn.dp,bn.datatype,bn.value,bn.signed)if not a then
return nil
end
aH(by,a)end
return table.concat(by)
end
local function O(j,s)
local E=ao(s)if s~=nil and E==nil then
v.warn(string.format("Tuya transaction expects number, got %s",b(s)))return nil
end
if E~=nil then
return E
end
return aP(j)
end
function n.send_raw(j,x,a)
if not aO(x)then
v.warn(string.format("Tuya command id expects byte value, got %s",tostring(x)))return false
end
if a==nil then
a=""end
if b(a)~="string"then
v.warn(string.format("Tuya raw payload expects string, got %s",b(a)))return false
end
local aY=af(j,aB,ax)if not aY then
v.warn"Tuya cluster endpoint not found"return false
end
local au=aI.ZclHeader{cmd=bj.ZCLCommandId(x)}au.frame_ctrl:set_cluster_specific()au.frame_ctrl:set_disable_default_response()local aN,bb=bc.AddressHeader(aD.HUB.ADDR,aD.HUB.ENDPOINT,j:get_short_address(),aY,aD.HA_PROFILE_ID,aB),aI.ZclMessageBody{zcl_header=au,zcl_body=aZ.GenericBody(a)}j:send(bc.ZigbeeMessageTx{address_header=aN,body=bb})return true
end
function n.send_datapoint(j,dp,g,e,x,aF,s)
local dp_payload=n.build_datapoint(dp,g,e,aF)if not dp_payload then
return nil
end
local w=O(j,s)if w==nil then
return nil
end
local aC=x
if aC==nil then
aC=aX
end
if not n.send_raw(j,aC,string_pack(">I2",w)..dp_payload)then
return nil
end
return w
end
function n.send_datapoints(j,bo,x,s)
local dps_payload=n.build_datapoints(bo)if not dps_payload then
return nil
end
local w=O(j,s)if w==nil then
return nil
end
local aC=x
if aC==nil then
aC=aX
end
if not n.send_raw(j,aC,string_pack(">I2",w)..dps_payload)then
return nil
end
return w
end
function n.send_state_request(j,x)
local aC=x
if aC==nil then
aC=bi
end
return n.send_raw(j,aC,"")
end
function n.send_mcu_version_request(j,s)
local H=s
if H==nil then
H=Q
end
local w=O(j,H)if w==nil then
return nil
end
if not n.send_raw(j,aw,string_pack(">I2",w))then
return nil
end
return w
end
A=function(u)
local status=u==nil and"\x01"or aj(u)if status==nil then
return nil
end
if h(status)~=1 then
v.warn(string.format("Tuya connection status expects exactly one status byte, got %d",h(status)))return nil
end
return string_pack("<I2",1)..status
end
function n.send_connection_status(j,s,u)
local a=A(u)if a==nil then
return false
end
return n.send_raw(j,Y,a)
end
K=function(z,t)
local X=y(p(z,bh()),"utc_time")if X==nil then
return nil
end
local T=y(p(t,X),"local_time")if T==nil then
return nil
end
local time_bytes=string_pack(">I4I4",X,T)return string_pack("<I2",h(time_bytes))..time_bytes
end
B=function(I,z,t)
local l=y(p(I,0),"time_offset")if l==nil then
return nil
end
local ad=y(p(z,bh()),"utc_time")if ad==nil or ad<l then
v.warn(string.format("Tuya time offset underflow: utc=%s offset=%s",tostring(ad),tostring(l)))return nil
end
local aa=y(p(t,ad),"local_time")if aa==nil or aa<l then
v.warn(string.format("Tuya time offset underflow: local=%s offset=%s",tostring(aa),tostring(l)))return nil
end
local X,T=ad-l,aa-l

return K(X,T)
end
function n.send_time(j,z,t)
local a=K(z,t)if a==nil then
return false
end
return n.send_raw(j,aq,a)
end
function n.send_time_with_offset(j,I,z,t)
local a=B(I,z,t)if a==nil then
return false
end
return n.send_raw(j,aq,a)
end
function n.apply_time_request(j,r,z,t)
if C(r)~=aq then
return false
end
return n.send_time(j,z,t)==true
end
function n.apply_time_request_with_offset(j,r,I,z,t)
if C(r)~=aq then
return false
end
return n.send_time_with_offset(j,I,z,t)==true
end
function n.apply_connection_status_request(j,r,u)
if C(r)~=Y then
return false
end
local bC=n.parse_connection_status(r)if bC==nil then
return false
end
return n.send_connection_status(j,nil,u)==true
end
function n.parse_connection_status(r)
local a=D(r)if not a or h(a)<2 then
return nil
end
local S,br,u=d(a,1)+d(a,2)*256,h(a)-2,""

if br>0 and S>0 then
u=aM(a,3,math.min(h(a),S+2))end
return{payload_size=S,status_length=S,status_bytes=u,payload=a}
end
function n.parse_mcu_version_response(r)
local a=D(r)if not a or h(a)<3 then
return nil
end
local aQ,aR,V=d(a,1),d(a,2),d(a,3)local bA,bB,bz=R(V/64),R((V%64)/16),V%16
return{transaction_hi=aQ,transaction_lo=aR,version_raw=V,version=string.format("%d.%d.%d",bA,bB,bz),payload=a}
end
function n.parse_datapoint(c,bm)
local a,o=D(c),p(bm,3)if not a then
return nil
end
if b(o)~="number"or o%1~=0 or o<1 then
v.warn(string.format("Tuya parse_datapoint expects positive integer index, got %s",tostring(o)))return nil
end
local F=h(a)if F<o+3 then
if F>=o then
v.warn(string.format("Tuya DP header truncated at index %d (payload_len=%d)",o,F))end
return nil
end
local dp,g,ba,aL=d(a,o),d(a,o+1),(d(a,o+2)*256)+d(a,o+3),o+4
local as=aL+ba
if as-1>F then
v.warn(string.format("Tuya DP payload truncated: dp=%d datatype=%d len=%d index=%d payload_len=%d",dp,g,ba,o,F))return nil
end
local value_bytes=aM(a,aL,as-1)local aU=aK(g,value_bytes)return{dp=dp,datatype=g,length=ba,value_bytes=value_bytes,value=aU,int_value=m(value_bytes),signed_value=aE(value_bytes),next_index=as}
end
function n.parse_datapoints(c,bm)
local a=D(c)if a==nil then
return nil
end
local ae=p(bm,3)if b(ae)~="number"or ae%1~=0 or ae<1 then
v.warn(string.format("Tuya parse_datapoints expects positive integer index, got %s",tostring(ae)))return nil
end
local F,N=h(a),{}while ae<=F do
local an=n.parse_datapoint(a,ae)if not an then
return nil
end
aH(N,an)ae=an.next_index
end
return N
end
function n.parse_datapoint_report(r)
local a=D(r)if not a then
return nil
end
if h(a)<2 then
v.warn(string.format("Tuya report too short (payload_len=%d)",h(a)))return nil
end
local bl,N={command_id=C(r),endpoint=ah(r),status=d(a,1),transaction=d(a,2),payload=a,datapoints={}},n.parse_datapoints(a,3)if N==nil then
return nil
end
for _,an in ipairs(N)do
an.endpoint=bl.endpoint
end
bl.datapoints=N
return bl
end
end
return aV
