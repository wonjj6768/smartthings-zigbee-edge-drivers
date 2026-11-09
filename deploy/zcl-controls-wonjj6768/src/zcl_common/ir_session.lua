local function at(ao)
local C,t,aR,ar=require"runtime.capability_metadata",require"runtime.capability_binding",require"log",{}require"st.json".configure(ar,{use_native=false})local ac,Y,X,v,i,aA,ay,G,R,x,o,l,k,j,I,Q=C.by_emit_name.learn_ir_code,C.by_emit_name.learned_ir_code,C.by_emit_name.ir_code_to_send,57348,60672,1,56,"__ir_learning","__ir_next_seq","__ir_outgoing_messages","__ir_incoming_bytes","__ir_incoming_length","__ir_incoming_seq","__ir_incoming_position","__ir_last_learned_code","__ir_last_sent_code"







local function encode_le16(h)
local av=math.max(0,math.min(65535,math.floor(h or 0)))return string.pack("<I2",av)
end
local function encode_le32(h)
local av=math.max(0,math.min(0xFFFFFFFF,math.floor(h or 0)))return string.pack("<I4",av)
end
local function w(z,s)
s=s or 1
if type(z)~="string"or #z<s+1 then
return nil
end
local b1,b2=string.byte(z,s)or 0,string.byte(z,s+1)or 0

return b1+(b2<<8)
end
local function N(z,s)
s=s or 1
if type(z)~="string"or #z<s+3 then
return nil
end
local b1,b2,b3,b4=string.byte(z,s)or 0,string.byte(z,s+1)or 0,string.byte(z,s+2)or 0,string.byte(z,s+3)or 0



return b1+
(b2<<8)+
(b3<<16)+
(b4<<24)
end
local function aq(u)
if type(u)~="string"then
return 0
end
local az=0
for O=1,#u do
az=(az+(string.byte(u,O)or 0))%256
end
return az
end
local function ak(aw)
if type(aw)~="string"or aw==""then
return""end
local ae,p,H,O="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",{},#aw,1

while O<=H do
local a,b,c=string.byte(aw,O)or 0,string.byte(aw,O+1)or 0,string.byte(aw,O+2)or 0


local n=(a<<16)+(b<<8)+c
p[#p+1]=ae:sub((n>>18)+1,(n>>18)+1)p[#p+1]=ae:sub(((n>>12)&63)+1,((n>>12)&63)+1)if O+1<=H then
p[#p+1]=ae:sub(((n>>6)&63)+1,((n>>6)&63)+1)else
p[#p+1]="="end
if O+2<=H then
p[#p+1]=ae:sub((n&63)+1,(n&63)+1)else
p[#p+1]="="end
O=O+3
end
return table.concat(p)
end
local function r(f)
return type(f)=="table"and type(f.ir_endpoint)=="number"and f.ir_endpoint or aA
end
local function g(d,aK,aL,u,aF)
return ao.send_raw_cluster_command(d,aK,aL,u,aF,nil,nil,true)
end
local function V(h,aG)
if h==nil or h==ar.null then return aG end
return h
end
local as={keyorder={"key_num","delay","key1","num","freq","type","key_code"}}
local function ab(M,B)
B=B or{}return ar.encode({key_num=1,delay=V(B.delay,300),key1={num=V(B.num,1),freq=V(B.freq,38000),type=V(B.type,1),key_code=M}},as)
end
local function au(B)
local aC=B.timings
if #aC==0 then return end
local ai=V(B.modulation,38000)if type(ai)~="number"or ai<=30000 then return end
local z={}for _,h in ipairs(aC)do
if h==ar.null then h=0
elseif type(h)=="boolean"then h=h and 1 or 0
elseif type(h)=="string"and h:match"^%s*$"then h=0 end
h=tonumber(h)if h==nil or h~=h or math.abs(h)==math.huge then return end
h=math.floor(math.abs(h))if h>65535 then return end
z[#z+1]=string.pack("<I2",h)end
local aT,ag=table.concat(z),{}for s=1,#aT,32 do
local part=aT:sub(s,s+31)ag[#ag+1]=string.char(#part-1)..part
end
return ab(ak(table.concat(ag)),{num=1+V(B.repeat_count,0),freq=ai})
end
local function aj(M)
local W=M:match"^%s*(.-)%s*$"if W==""then return end
if W:sub(1,1)=="{"and W:sub(-1)=="}"then
local A,e,ba=ar.decode(W,1,ar.null)if not ba and type(A)=="table"and W:sub(e):match"^%s*$"then
local an=type(A.timings)=="table"and getmetatable(A.timings)if an and an.__jsontype=="array"then
local ok,u=pcall(au,A)if ok and u then return u end
elseif A.key_num~=nil and A.key1~=nil then
return ar.encode(A,as)elseif A.key_code~=nil then
return ab(A.key_code,A)end
end
end
return ab(W)
end
local function L(d)
for _,aP in ipairs{o,l,k,j}do
d:set_field(aP,nil,{persist=false})end
end
local function J(d)
local ah=type(d)=="table"and d:get_field(x)or nil
if type(ah)~="table"then
ah={}d:set_field(x,ah,{persist=false})end
return ah
end
local function aI(d)
local q=type(d)=="table"and d:get_field(R)or 0
if type(q)~="number"then
q=0
end
q=(q+1)%65536
d:set_field(R,q,{persist=false})return q
end
local function D(d,aQ)
t.emit_state(d,"main",ac,aQ)
end
local function T(d,M)
t.emit_state(d,"main",Y,M or"")
end
local function S(d,M)
t.emit_state(d,"main",X,M or"")
end
function ao.emit_ir_state(d,f)
if type(f)~="table"or f.ir_controller~=true then
return
end
local aH=d:get_field(G)==true
D(d,aH and"start"or"stop")T(d,d:get_field(I)or"")S(d,d:get_field(Q)or"")
end
function ao.start_ir_learning(d,f)
if ao.send_raw_cluster_command==nil then
return false
end
d:set_field(G,true,{persist=false})D(d,"start")return g(d,v,0,'{"study":0}',r(f))
end
function ao.stop_ir_learning(d,f)
if ao.send_raw_cluster_command==nil then
return false
end
d:set_field(G,false,{persist=false})D(d,"stop")return g(d,v,0,'{"study":1}',r(f))
end
function ao.send_ir_code(d,f,M)
if ao.send_raw_cluster_command==nil or type(M)~="string"or M==""then
return false
end
local u=aj(M)if u==nil then return false end
local q=aI(d)L(d)d:set_field(x,{[q]=u},{persist=false})d:set_field(Q,M,{persist=false})S(d,M)return g(d,i,0,encode_le16(q)..
encode_le32(#u)..
encode_le32(0)..
encode_le16(v)..
string.char(1)..
string.char(2)..
encode_le16(0),r(f))
end
local function Z(d,f,q,e)
return g(d,i,2,encode_le16(q)..encode_le32(e)..string.char(ay),r(f))
end
local function al(d,f,q,e)
local aJ=J(d)local ax=aJ[q]if type(ax)~="string"then
aR.warn(string.format("missing pending IR message for seq=%s",tostring(q)))return false
end
local aB,aE=e+1,math.min(#ax,e+50)
local part=ax:sub(aB,aE)local az=aq(part)return g(d,i,3,string.char(0)..
encode_le16(q)..
encode_le32(e)..
string.char(#part)..
part..
string.char(az),r(f))
end
local function af(d,e,part,m)
local F=d:get_field(o)if type(F)~="string"then
F=string.rep("\0",m)elseif #F<m then
F=F..string.rep("\0",m-#F)end
local aM,am=e>0 and F:sub(1,e)or"",e+#part+1
local suffix=am<=#F and F:sub(am)or""local ap=aM..part..suffix
d:set_field(o,ap,{persist=false})return ap
end
function ao.handle_ir_transmit_command(d,f,U)
if ao.send_raw_cluster_command==nil then
return false
end
local E,y=U and U.body and U.body.zcl_header and U.body.zcl_header.cmd and U.body.zcl_header.cmd.value or nil,U and U.body and U.body.zcl_body and U.body.zcl_body.body_bytes or nil

if type(E)~="number"or type(y)~="string"then
return false
end
if E==0 then
local q,H,aW,aD,aX,aZ,aY=w(y,1),N(y,3),N(y,7)or 0,w(y,11)or v,string.byte(y,13)or 0,string.byte(y,14)or 0,w(y,15)or 0




if q==nil or H==nil then
return false
end
d:set_field(o,"",{persist=false})d:set_field(l,H,{persist=false})d:set_field(k,q,{persist=false})d:set_field(j,0,{persist=false})d:set_field(x,{},{persist=false})g(d,i,1,string.char(0)..
encode_le16(q)..
encode_le32(H)..
encode_le32(aW)..
encode_le16(aD)..
string.char(aX)..
string.char(aZ)..
encode_le16(aY),r(f))Z(d,f,q,0)return true
end
if E==2 then
local q,e=w(y,1),N(y,3)if q==nil or e==nil or #y<7 then
return false
end
return al(d,f,q,e)end
if E==3 then
local q,e,P=w(y,2),N(y,4),string.byte(y,8)if q==nil or e==nil or P==nil or #y<9+P then
return false
end
if d:get_field(k)~=q or d:get_field(j)~=e then return false end
local part,az=y:sub(9,8+P),string.byte(y,9+P)or 0
if aq(part)~=az then
aR.warn(string.format("IR chunk CRC mismatch seq=%s position=%s",tostring(q),tostring(e)))return false
end
local m=d:get_field(l)if type(m)~="number"then return false end
part=part:sub(1,math.max(0,m-e))local ap=af(d,e,part,m)d:set_field(j,e+#part,{persist=false})if e+#part<m then
Z(d,f,q,e+#part)else
g(d,i,4,string.char(0)..encode_le16(q)..encode_le16(0),r(f))d:set_field(o,ap:sub(1,m),{persist=false})end
return true
end
if E==4 then
local q=w(y,2)if q==nil then
return false
end
local aN=g(d,i,5,encode_le16(q)..encode_le16(0),r(f))if aN then
J(d)[q]=nil
if d:get_field(k)==q then L(d)end
end
return aN
end
if E==5 then
local q=w(y,1)if q==nil or d:get_field(k)~=q then return false end
local ad,H=d:get_field(o)or"",d:get_field(l)if #ad<H then ad=ad ..string.rep("\0",H-#ad)end
local p=ak(ad)d:set_field(I,p,{persist=false})L(d)T(d,p)ao.stop_ir_learning(d,f)return true
end
return false
end
end
return at
