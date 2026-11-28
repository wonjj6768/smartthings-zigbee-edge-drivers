local function ay(ap)
local D,u,aX,aw=require"runtime.capability_metadata",require"runtime.capability_binding",require"log",{}require"st.json".configure(aw,{use_native=false})local af,ab,aa,w,i,aG,aE,I,U,y,F,K,p,m,k,j,M,T=D.by_emit_name.learn_ir_code,D.by_emit_name.learned_ir_code,D.by_emit_name.ir_code_to_send,57348,60672,1,56,"__ir_learning","__ir_next_seq","__ir_outgoing_messages","__ir_send_queue","__ir_send_timeout","__ir_incoming_bytes","__ir_incoming_length","__ir_incoming_seq","__ir_incoming_position","__ir_last_learned_code","__ir_last_sent_code"







local function encode_le16(h)
local aA=math.max(0,math.min(65535,math.floor(h or 0)))return string.pack("<I2",aA)
end
local function encode_le32(h)
local aA=math.max(0,math.min(0xFFFFFFFF,math.floor(h or 0)))return string.pack("<I4",aA)
end
local function x(A,t)
t=t or 1
if type(A)~="string"or #A<t+1 then
return nil
end
local b1,b2=string.byte(A,t)or 0,string.byte(A,t+1)or 0

return b1+(b2<<8)
end
local function Q(A,t)
t=t or 1
if type(A)~="string"or #A<t+3 then
return nil
end
local b1,b2,b3,b4=string.byte(A,t)or 0,string.byte(A,t+1)or 0,string.byte(A,t+2)or 0,string.byte(A,t+3)or 0



return b1+
(b2<<8)+
(b3<<16)+
(b4<<24)
end
local function av(v)
if type(v)~="string"then
return 0
end
local aF=0
for R=1,#v do
aF=(aF+(string.byte(v,R)or 0))%256
end
return aF
end
local function ao(aB)
if type(aB)~="string"or aB==""then
return""end
local ah,q,J,R="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",{},#aB,1

while R<=J do
local a,b,c=string.byte(aB,R)or 0,string.byte(aB,R+1)or 0,string.byte(aB,R+2)or 0


local n=(a<<16)+(b<<8)+c
q[#q+1]=ah:sub((n>>18)+1,(n>>18)+1)q[#q+1]=ah:sub(((n>>12)&63)+1,((n>>12)&63)+1)if R+1<=J then
q[#q+1]=ah:sub(((n>>6)&63)+1,((n>>6)&63)+1)else
q[#q+1]="="end
if R+2<=J then
q[#q+1]=ah:sub((n&63)+1,(n&63)+1)else
q[#q+1]="="end
R=R+3
end
return table.concat(q)
end
local function r(f)
return type(f)=="table"and type(f.ir_endpoint)=="number"and f.ir_endpoint or aG
end
local function g(d,aQ,aR,v,aL)
return ap.send_raw_cluster_command(d,aQ,aR,v,aL,nil,nil,true)
end
local function Y(h,aM)
if h==nil or h==aw.null then return aM end
return h
end
local ax={keyorder={"key_num","delay","key1","num","freq","type","key_code"}}
local function ae(N,C)
C=C or{}return aw.encode({key_num=1,delay=Y(C.delay,300),key1={num=Y(C.num,1),freq=Y(C.freq,38000),type=Y(C.type,1),key_code=N}},ax)
end
local function az(C)
local aI=C.timings
if #aI==0 then return end
local al=Y(C.modulation,38000)if type(al)~="number"or al<=30000 then return end
local A={}for _,h in ipairs(aI)do
if h==aw.null then h=0
elseif type(h)=="boolean"then h=h and 1 or 0
elseif type(h)=="string"and h:match"^%s*$"then h=0 end
h=tonumber(h)if h==nil or h~=h or math.abs(h)==math.huge then return end
h=math.floor(math.abs(h))if h>65535 then return end
A[#A+1]=string.pack("<I2",h)end
local aZ,aj=table.concat(A),{}for t=1,#aZ,32 do
local part=aZ:sub(t,t+31)aj[#aj+1]=string.char(#part-1)..part
end
return ae(ao(table.concat(aj)),{num=1+Y(C.repeat_count,0),freq=al})
end
local function am(N)
local Z=N:match"^%s*(.-)%s*$"if Z==""then return end
if Z:sub(1,1)=="{"and Z:sub(-1)=="}"then
local B,e,bg=aw.decode(Z,1,aw.null)if not bg and type(B)=="table"and Z:sub(e):match"^%s*$"then
local at=type(B.timings)=="table"and getmetatable(B.timings)if at and at.__jsontype=="array"then
local ok,v=pcall(az,B)if ok and v then return v end
elseif B.key_num~=nil and B.key1~=nil then
return aw.encode(B,ax)elseif B.key_code~=nil then
return ae(B.key_code,B)end
end
end
return ae(Z)
end
local function P(d)
for _,aV in ipairs{p,m,k,j}do
d:set_field(aV,nil,{persist=false})end
end
local function s(d)
local ak=type(d)=="table"and d:get_field(y)or nil
if type(ak)~="table"then
ak={}d:set_field(y,ak,{persist=false})end
return ak
end
local function aO(d)
local l=type(d)=="table"and d:get_field(U)or 0
if type(l)~="number"then
l=0
end
l=(l+1)%65536
d:set_field(U,l,{persist=false})return l
end
local function E(d,aW)
u.emit_state(d,"main",af,aW)
end
local function W(d,N)
u.emit_state(d,"main",ab,N or"")
end
local function V(d,N)
u.emit_state(d,"main",aa,N or"")
end
function ap.emit_ir_state(d,f)
if type(f)~="table"or f.ir_controller~=true then
return
end
local aN=d:get_field(I)==true
E(d,aN and"start"or"stop")W(d,d:get_field(M)or"")V(d,d:get_field(T)or"")
end
function ap.start_ir_learning(d,f)
if ap.send_raw_cluster_command==nil then
return false
end
d:set_field(I,true,{persist=false})E(d,"start")return g(d,w,0,'{"study":0}',r(f))
end
function ap.stop_ir_learning(d,f)
if ap.send_raw_cluster_command==nil then
return false
end
d:set_field(I,false,{persist=false})E(d,"stop")return g(d,w,0,'{"study":1}',r(f))
end
local function ar(d)
local aP=d:get_field(K)if aP~=nil then d.thread:cancel_timer(aP)end
d:set_field(K,nil,{persist=false})local an=d:get_field(F)or{}local aD=table.remove(an,1)d:set_field(F,#an>0 and an or nil,{persist=false})if aD then ap.send_ir_code(d,aD.preset,aD.code)end
end
function ap.send_ir_code(d,f,N)
if ap.send_raw_cluster_command==nil or type(N)~="string"or N==""then
return false
end
local v=am(N)if v==nil then return false end
if next(s(d))~=nil then
local an=d:get_field(F)or{}an[#an+1]={preset=f,code=N}d:set_field(F,an,{persist=false})return true
end
local l=aO(d)P(d)d:set_field(y,{[l]=v},{persist=false})d:set_field(T,N,{persist=false})V(d,N)
d:set_field(K,d.thread:call_with_delay(8,function()
local L=s(d)if L[l]~=nil then
L[l]=nil
ar(d)end
end,"IR send timeout"),{persist=false})
return g(d,i,0,encode_le16(l)..
encode_le32(#v)..
encode_le32(0)..
encode_le16(w)..
string.char(1)..
string.char(2)..
encode_le16(0),r(f))
end
local function ac(d,f,l,e)
return g(d,i,2,encode_le16(l)..encode_le32(e)..string.char(aE),r(f))
end
local function aq(d,f,l,e)
local L=s(d)local aC=L[l]if type(aC)~="string"then
aX.warn(string.format("missing pending IR message for seq=%s",tostring(l)))return false
end
local aH,aK=e+1,math.min(#aC,e+50)
local part=aC:sub(aH,aK)local aF=av(part)return g(d,i,3,string.char(0)..
encode_le16(l)..
encode_le32(e)..
string.char(#part)..
part..
string.char(aF),r(f))
end
local function ai(d,e,part,o)
local H=d:get_field(p)if type(H)~="string"then
H=string.rep("\0",o)elseif #H<o then
H=H..string.rep("\0",o-#H)end
local aS,as=e>0 and H:sub(1,e)or"",e+#part+1
local suffix=as<=#H and H:sub(as)or""local au=aS..part..suffix
d:set_field(p,au,{persist=false})return au
end
function ap.handle_ir_transmit_command(d,f,X)
if ap.send_raw_cluster_command==nil then
return false
end
local G,z=X and X.body and X.body.zcl_header and X.body.zcl_header.cmd and X.body.zcl_header.cmd.value or nil,X and X.body and X.body.zcl_body and X.body.zcl_body.body_bytes or nil

if type(G)~="number"or type(z)~="string"then
return false
end
if G==0 then
local l,J,bc,aJ,bd,bf,be=x(z,1),Q(z,3),Q(z,7)or 0,x(z,11)or w,string.byte(z,13)or 0,string.byte(z,14)or 0,x(z,15)or 0




if l==nil or J==nil then
return false
end
d:set_field(p,"",{persist=false})d:set_field(m,J,{persist=false})d:set_field(k,l,{persist=false})d:set_field(j,0,{persist=false})d:set_field(y,{},{persist=false})g(d,i,1,string.char(0)..
encode_le16(l)..
encode_le32(J)..
encode_le32(bc)..
encode_le16(aJ)..
string.char(bd)..
string.char(bf)..
encode_le16(be),r(f))ac(d,f,l,0)return true
end
if G==2 then
local l,e=x(z,1),Q(z,3)if l==nil or e==nil or #z<7 then
return false
end
return aq(d,f,l,e)end
if G==3 then
local l,e,S=x(z,2),Q(z,4),string.byte(z,8)if l==nil or e==nil or S==nil or #z<9+S then
return false
end
if d:get_field(k)~=l or d:get_field(j)~=e then return false end
local part,aF=z:sub(9,8+S),string.byte(z,9+S)or 0
if av(part)~=aF then
aX.warn(string.format("IR chunk CRC mismatch seq=%s position=%s",tostring(l),tostring(e)))return false
end
local o=d:get_field(m)if type(o)~="number"then return false end
part=part:sub(1,math.max(0,o-e))local au=ai(d,e,part,o)d:set_field(j,e+#part,{persist=false})if e+#part<o then
ac(d,f,l,e+#part)else
g(d,i,4,string.char(0)..encode_le16(l)..encode_le16(0),r(f))d:set_field(p,au:sub(1,o),{persist=false})end
return true
end
if G==4 then
local l=x(z,2)if l==nil then
return false
end
local aT=g(d,i,5,encode_le16(l)..encode_le16(0),r(f))if aT then
local L=s(d)if L[l]~=nil then
L[l]=nil
ar(d)end
if d:get_field(k)==l then P(d)end
end
return aT
end
if G==5 then
local l=x(z,1)if l==nil or d:get_field(k)~=l then return false end
local ag,J=d:get_field(p)or"",d:get_field(m)if #ag<J then ag=ag ..string.rep("\0",J-#ag)end
local q=ao(ag)d:set_field(M,q,{persist=false})P(d)W(d,q)ap.stop_ir_learning(d,f)return true
end
return false
end
end
return ay
