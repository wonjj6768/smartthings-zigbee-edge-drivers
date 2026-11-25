local function bB(H,aW)
local bT,by,ax,aL,bP,a,u,aT,bF,ae,ay,as,an,aA=aW.log,require"st.capabilities",require"runtime.capability_metadata",require"runtime.battery_refresh",require"runtime.utf8_text",aW.type_check,aW.table_insert,aW.normalize_transaction,aW.persist_opt,setmetatable({},{__mode="k"}),setmetatable({},{__mode="k"}),setmetatable({},{__mode="k"}),setmetatable({},{__mode="k"}),"__tuya_mapping_bucket"




local M
local p=ax.driver_message
local function aR(h)
local aJ=a(h)if aJ=="string"then
return h
end
if aJ=="number"or aJ=="boolean"then
return tostring(h)end
if aJ=="table"then
local bs,bK={},0
for ap,e in pairs(h)do
bK=bK+1
if bK>4 then
bs[#bs+1]="..."break
end
bs[#bs+1]=tostring(ap).."="..tostring(e)end
return table.concat(bs,", ")end
return tostring(h)
end
local function aI(b,f,t,h)
if a(b)~="table"then
return
end
local aY=ax.by_emit_name[a(f)=="table"and f.name or nil]if aY==nil or aY.emit_name==p.emit_name then
return
end
local bp=by[p.capability_id]local ba=bp and bp[p.attribute_name]or nil
if a(ba)~="function"then
bT.error(string.format("[%s] Debug driver message binding missing: %s.%s",b.label or b.id or"device",p.capability_id or"unknown",p.attribute_name or"unknown"))return
end
local N,bQ=aY.label or aY.emit_name or"custom state",a(t)=="table"and a(t.dp)=="number"and string.format("dp=%d",t.dp)or"dp=?"local bi,bx=string.format("RX %s (%s): %s",N,bQ,aR(h)),p.maximum_length or 512
bi=bP.truncate(bi,bx)if bi==nil then
return
end
b:emit_event(ba{value=bi})
end
local function k(N)
bT.warn(string.format("Tuya %s ignored",N))
end
local function am(h)
return a(h)=="table"and h[aA]==true
end
local function w(bh,ap,s)
if ap==nil then
return
end
local aX=bh[ap]if aX==nil then
bh[ap]=s
return
end
if am(aX)then
u(aX,s)return
end
bh[ap]={[aA]=true,aX,s}
end
local function aH(c)
if a(c)~="table"then
return nil
end
if a(c.converter)=="table"then
return c.converter
end
return nil
end
local function aK(c,B)
if a(c)~="table"then
return a(B)=="string"and B or nil
end
return c.key or c.preference or c.name or(a(B)=="string"and B or nil)
end
local function af(c)
if a(c)~="table"then
return nil
end
local m,bj=aH(c),a(c.converter)=="function"and c.converter or nil
return{from_device=a(c.from_device)=="function"and c.from_device or
(m and a(m.from)=="function"and m.from or bj),to_device=a(c.to_device)=="function"and c.to_device or
(m and a(m.to)=="function"and m.to or nil),read_only=c.read_only==true,write_only=c.write_only==true,field=(a(c.field)=="string"or a(c.field)=="function")and c.field or nil,fields=(a(c.fields)=="table"or a(c.fields)=="function")and c.fields or nil,handler=a(c.handler)=="function"and c.handler or nil,emit=a(c.emit)=="function"and c.emit or nil,endpoint=(a(c.endpoint)=="number"or a(c.endpoint)=="function")and c.endpoint or nil,component=(a(c.component)=="string"or a(c.component)=="function")and c.component or nil,persist=bF(c.persist)}
end
local function O(q)
if a(q)~="number"or q%1~=0 then
return nil
end
return q
end
local function U(b,d)
if a(d)~="table"then
return nil
end
local i=d.component_id or d.component
if a(i)=="string"and i~=""then
return i
end
local q=O(d.endpoint or d.src_endpoint)if q~=nil and a(b.get_component_id_for_endpoint)=="function"then
local o=b:get_component_id_for_endpoint(q)if a(o)=="string"and o~=""then
return o
end
end
return nil
end
local function J(b,d)
if a(d)~="table"then
return nil
end
local q=O(d.endpoint or d.src_endpoint)if q~=nil then
return q
end
local i=d.component_id or d.component
if a(i)=="string"and i~=""and a(b.get_endpoint_for_component_id)=="function"then
local o=b:get_endpoint_for_component_id(i)if a(o)=="table"then
o=o[1]end
return O(o)end
return nil
end
local function ag(v,b,d)
if v==nil then
return nil
end
local q=v.endpoint
if a(q)=="function"then
q=q(b,d,v)end
return O(q)
end
local function V(v,b,d)
if v==nil then
return nil
end
local i=v.component
if a(i)=="function"then
i=i(b,d,v)end
if a(i)=="string"and i~=""then
return i
end
return nil
end
local function aq(b,c,d,h)
local f={mapping=c,value=h}if a(d)=="table"then
for ap,e in pairs(d)do
f[ap]=e
end
end
if f.dp==nil and a(c)=="table"then
f.dp=c.dp
end
local v=af(c)local q=ag(v,b,f)if q==nil then
q=J(b,f)end
local i=V(v,b,f)if i==nil then
if q~=nil and a(b.get_component_id_for_endpoint)=="function"then
i=b:get_component_id_for_endpoint(q)else
i=U(b,f)end
end
f.endpoint=q
f.component_id=i
f.component=i and b.profile and b.profile.components and b.profile.components[i]or nil
return f
end
local function aw(d)
if a(d)~="table"then
return nil
end
local i=d.component_id or d.component
if a(i)=="string"and i~=""then
return i
end
return nil
end
local function ab(c,b,d)
if a(c)~="table"then
return 0
end
local v=af(c)local al,S,F,K,W=ag(v,b,d),V(v,b,d),J(b,d),U(b,d),aw(d)if F==nil and K~=nil and a(b.get_endpoint_for_component_id)=="function"then
F=J(b,{component_id=K})end
if K==nil and F~=nil and a(b.get_component_id_for_endpoint)=="function"then
K=b:get_component_id_for_endpoint(F)end
if al~=nil then
if F==nil or F~=al then
return-1
end
end
if S~=nil and W~=nil then
if W~=S then
return-1
end
end
local aj=0
if al~=nil then
aj=aj+2
end
if S~=nil and W~=nil then
aj=aj+1
end
return aj
end
local function Z(I,b,d)
if I==nil then
return nil
end
if not am(I)then
if ab(I,b,d)>=0 then
return I
end
return nil
end
local R
local C=-1
for _,c in ipairs(I)do
local aj=ab(c,b,d)if aj>C then
R=c
C=aj
end
end
return R
end
local function Q(I,b,d)
if I==nil or not am(I)then
return Z(I,b,d)end
local R,C={},-1
for _,c in ipairs(I)do
local aj=ab(c,b,d)if aj>C then
R={c}C=aj
elseif aj>=0 and aj==C then
R[#R+1]=c
end
end
if C<0 or #R==0 then
return nil
end
if #R==1 then
return R[1]end
return R
end
local function bf(Y,b,d)
local o=Y
if a(o)=="function"then
o=o(b,d)end
if a(o)=="string"and o~=""then
return o
end
return nil
end
local function bg(bS,b,d)
local o=bS
if a(o)=="function"then
o=o(b,d)end
if a(o)=="table"then
return o
end
return nil
end
local function aE(b,ar,d)
if ar==nil then
return
end
aL.maybe_schedule_after_event(b,ar)if d.component~=nil and a(b.emit_component_event)=="function"then
b:emit_component_event(d.component,ar)return
end
if d.endpoint~=nil and a(b.emit_event_for_endpoint)=="function"then
b:emit_event_for_endpoint(d.endpoint,ar)return
end
b:emit_event(ar)
end
local function T(bb,A,ap)
local d={}if a(bb)=="table"then
for Y,e in pairs(bb)do
d[Y]=e
end
end
if A~=nil and d.values==nil then
d.values=A
end
if ap~=nil then
d.name=ap
d.key=ap
d.preference=ap
end
return d
end
local function aV(g)
if a(g)~="table"then
return
end
ae[g]=nil
ay[g]=nil
as[g]=nil
end
local function G(g)
if a(g)~="table"then
return nil,nil
end
local aD=an[g]==true
if aD then
local y,E=ay[g],as[g]if y~=nil and E~=nil then
return y,E
end
end
local y,E={},{}if M(g)then
for _,s in ipairs(g)do
if a(s)=="table"then
local dp=s.dp
if a(dp)=="number"then
w(y,dp,s)end
local l=aK(s)if a(l)=="string"then
w(E,l,s)end
end
end
else
for B,s in pairs(g)do
if a(B)=="number"then
w(y,B,s)end
if a(s)=="table"then
local dp=s.dp
if a(dp)=="number"then
w(y,dp,s)end
local l=aK(s,B)if a(l)=="string"then
w(E,l,s)end
elseif a(s)=="function"and a(B)=="string"then
w(E,B,s)end
end
end
if aD then
ay[g]=y
as[g]=E
end
return y,E
end
local function ah(e,N)
if a(e)~="table"then
k(N)return nil
end
local bz=e.datatype
local function aS(h)
return a(h)=="number"and h>=0 and h<=255 and h%1==0
end
local function bR(h)
return a(h)=="number"and h>=0 and h<=65535 and h%1==0
end
if not aS(e.dp)or not aS(bz)then
k(N)return nil
end
if e.command_id~=nil and not aS(e.command_id)then
k(N)return nil
end
if e.transaction~=nil and not bR(e.transaction)then
k(N)return nil
end
if e.to_device~=nil and a(e.to_device)~="function"then
k(N)return nil
end
local m=aH(e)if m~=nil then
if m.from~=nil and a(m.from)~="function"then
k(N)return nil
end
if m.to~=nil and a(m.to)~="function"then
k(N)return nil
end
end
if e.skip~=nil and a(e.skip)~="function"then
k(N)return nil
end
if e.match_response~=nil and a(e.match_response)~="function"then
k(N)return nil
end
if e.match_transaction~=nil and a(e.match_transaction)~="boolean"then
k(N)return nil
end
if e.response_dp~=nil and not aS(e.response_dp)then
k(N)return nil
end
if e.response_dps~=nil and a(e.response_dps)~="table"then
k(N)return nil
end
if e.response_dps~=nil then
for _,bG in ipairs(e.response_dps)do
if not aS(bG)then
k(N)return nil
end
end
end
local v,au=af(e),e.response_dps
if au~=nil and next(au)==nil then
au=nil
end
return{dp=e.dp,datatype=bz,value=e.value,command_id=e.command_id,transaction=aT(e.transaction),signed=e.signed==true,to_device=v and v.to_device or nil,skip=e.skip,batch_key=e.batch_key,match_transaction=e.match_transaction~=false,response_dp=e.response_dp,response_dps=au,match_response=e.match_response}
end
local function bl(A)
if a(A)~="table"then
return nil
end
local bN={}for _,h in ipairs(A)do
u(bN,h)end
return bN
end
M=function(g)
if a(g)~="table"then
return false
end
local aD=an[g]==true
if aD then
local bM=ae[g]if bM~=nil then
return bM
end
end
local bJ=a(g[1])=="table"and g[1].dp~=nil
if aD then
ae[g]=bJ
end
return bJ
end
local function bw(g,b,d)
if a(g)~="table"then
return nil
end
local dp=a(d)=="table"and d.dp or d
if M(g)then
local y=G(g)return Q(y and y[dp]or nil,b,d)end
local bc=g[dp]if bc~=nil then
return Q(bc,b,d)end
local y=G(g)return Q(y and y[dp]or nil,b,d)
end
local function ac(g,ap,b,d)
if a(g)~="table"or a(ap)~="string"then
return nil
end
local bc=g[ap]if bc~=nil then
return Z(bc,b,d)end
local _,E=G(g)return Z(E and E[ap]or nil,b,d)
end
local function aZ(b,t,c,d)
if a(c)~="table"then
return t.value
end
local v=af(c)if v==nil or v.write_only then
return t.value
end
local f,h=aq(b,c,d or t,t.value),t.value
if v.from_device then
h=v.from_device(h,b,t,f)end
if v.field then
local ai=bf(v.field,b,f)if ai~=nil then
b:set_field(ai,h,v.persist)end
end
local br=bg(v.fields,b,f)if br~=nil and a(h)=="table"then
for ai,bu in pairs(br)do
local ap=bu==true and ai or bu
if a(ai)=="string"and a(ap)=="string"and h[ap]~=nil then
b:set_field(ai,h[ap],v.persist)end
end
end
if h==nil then
return h
end
local l=aK(c)if l=="battery"or l=="battery_voltage"then
aL.note_report(b)end
if v.handler then
v.handler(b,h,t,f)end
if v.emit then
local ar=v.emit(b,h,t,f)if ar then
if a(ar)=="table"and ar[1]~=nil then
for _,e in ipairs(ar)do
aE(b,e,f)end
else
aE(b,ar,f)end
aI(b,f,t,h)end
end
return h
end
local function bt(b,z)
if #z==0 then
return nil
end
if #z==1 then
local e=z[1]return H.send_datapoint(b,e.dp,e.datatype,e.value,e.command_id,e.signed,e.transaction)end
local bq,bk=z[1].command_id,z[1].transaction

for bh=2,#z do
if z[bh].command_id~=bq or z[bh].transaction~=bk then
local az
for _,e in ipairs(z)do
az=H.send_datapoint(b,e.dp,e.datatype,e.value,e.command_id,e.signed,e.transaction)if az==nil then
return nil
end
end
return az
end
end
return H.send_datapoints(b,z,bq,bk)
end
local X
local function aB(bD,aa,b,g,A,aO,d)
if a(aa)~="function"then
return bD
end
local bC=T(d,A)
local function aC(l,h)
local D=T(bC,A,l)local c=ac(g,l,b,D)if c==nil then
return
end
for _,e in ipairs(X(b,c,h,D))do
aa(bD,e)end
end
if a(aO)=="table"then
for _,l in ipairs(aO)do
local h=A and A[l]if h~=nil then
aC(l,h)end
end
elseif a(A)=="table"then
for l,h in pairs(A)do
aC(l,h)end
end
return bD
end
local function aM(b,c,h,d)
local e=ah(c,"send mapping")if not e then
return nil
end
local v=af(c)if v and v.read_only then
return nil
end
local f=aq(b,c,d,h)if e.skip and e.skip(b,h,e,f)then
return nil
end
local bI=h
if e.to_device then
bI=e.to_device(h,b,e,f)end
return{dp=e.dp,datatype=e.datatype,value=bI,command_id=e.command_id,transaction=e.transaction,signed=e.signed,batch_key=e.batch_key,match_transaction=e.match_transaction,response_dp=e.response_dp,response_dps=e.response_dps,match_response=e.match_response}
end
X=function(b,c,h,d)
if a(c)=="function"then
local e,z=c(b,h,d),{}if e==nil then
return z
end
if e[1]~=nil then
for _,bH in ipairs(e)do
local aF=ah(bH,"send mapping result")if aF then
u(z,aF)end
end
return z
end
local aF=ah(e,"send mapping result")if aF then
u(z,aF)end
return z
end
if a(c)~="table"then
return{}end
if c[1]~=nil and c.dp==nil then
local z={}for _,e in ipairs(c)do
local bo=aM(b,e,h,d)if bo then
u(z,bo)end
end
return z
end
local bo=aM(b,c,h,d)if bo then
return{bo}end
return{}
end
function H.apply_datapoint_mapping(b,t,L,d)
local x=d or t
if a(x)~="table"then
x={dp=t.dp}elseif x.dp==nil then
x.dp=t.dp
end
local c=bw(L,b,x)if c==nil then
return false
end
if a(c)=="function"then
c(b,t,x)return true
end
if a(c)~="table"then
return false
end
if c[1]~=nil then
for _,e in ipairs(c)do
aZ(b,t,e,x)end
else
aZ(b,t,c,x)end
return true
end
function H.send_mapping(b,c,h,d)
return bt(b,X(b,c,h,d))
end
function H.send_named_mapping(b,g,l,h,d)
local c=ac(g,l,b,d)if c==nil then
return nil
end
return H.send_mapping(b,c,h,T(d,nil,l))
end
function H.send_named_mappings(b,g,A,aO,d)
local z={}aB(z,u,b,g,A,aO,d)return bt(b,z)
end
local function aG(P,e)
if not e.batch_key then
u(P,e)return
end
local at,bd=P[#P],{dp=e.dp,datatype=e.datatype,value=e.value,command_id=e.command_id,transaction=e.transaction,signed=e.signed}if at and
at.batch_key==e.batch_key and
at.command_id==e.command_id and
at.transaction==e.transaction and
at.match_transaction==e.match_transaction and
at.match_response==e.match_response and
at.items then
u(at.items,bd)if e.response_dp~=nil then
at.response_dps=at.response_dps or{}u(at.response_dps,e.response_dp)elseif e.response_dps then
at.response_dps=at.response_dps or{}for _,dp in ipairs(e.response_dps)do
u(at.response_dps,dp)end
end
return
end
local s={items={bd},command_id=e.command_id,batch_key=e.batch_key,transaction=e.transaction,match_transaction=e.match_transaction,match_response=e.match_response}if e.response_dp~=nil then
s.response_dps={e.response_dp}elseif e.response_dps then
s.response_dps=bl(e.response_dps)end
u(P,s)
end
local function av(b,ad,j,r)
local aP=b.preferences or{}local D=T(nil,aP,ad)local c,h,bO=ac(j,ad,b,D),aP[ad],r and r[ad]or nil
if c==nil or h==nil or h==bO then
return false
end
return H.send_mapping(b,c,h,D)~=nil
end
local function aQ(aP,r,l)
if r==nil then
return true
end
return aP[l]~=r[l]
end
function H.build_preference_config_queue(b,j,n,r)
local P,aP={},b.preferences or{}
local function aa(l)
local D=T(nil,aP,l)local c,h=ac(j,l,b,D),aP[l]if c==nil or h==nil or not aQ(aP,r,l)then
return
end
for _,e in ipairs(X(b,c,h,D))do
aG(P,e)end
end
if a(n)=="table"then
for _,l in ipairs(n)do
aa(l)end
elseif a(j)=="table"then
if M(j)then
for _,c in ipairs(j)do
local l=c.preference or c.key or c.name
if a(l)=="string"then
aa(l)end
end
else
for l,_ in pairs(j)do
aa(l)end
end
end
return P
end
function H.build_named_mapping_config_queue(b,g,A,aO,d)
local P={}aB(P,aG,b,g,A,aO,d)return P
end
local function ao(L,Y,aN)
if a(L)~="table"then
return{}end
local bm={}for B,s in pairs(L)do
if a(s)=="function"and a(B)=="string"then
bm[B]=s
elseif a(s)=="table"then
local l=s[Y]if l==nil and a(aN)=="table"then
for _,bv in ipairs(aN)do
l=s[bv]if l~=nil then
break
end
end
end
if l==nil and a(B)=="string"then
l=B
end
if a(l)=="string"then
bm[l]=s
end
end
end
return bm
end
local function ak(Y)
if Y=="key"then
return{"name","preference"}end
if Y=="name"then
return{"key","preference"}end
if Y=="preference"then
return{"key","name"}end
return nil
end
function H.build_named_map(L,be)
local Y=be or"key"return ao(L,Y,ak(Y))
end
function H.build_preference_map(L,be)
local Y=be or"preference"return ao(L,Y,ak(Y))
end
local function bn(g)
if a(g)~="table"then
return g
end
aV(g)an[g]=true
G(g)return g
end
aW.prepare_mappings=bn
function H.start_preference_config_queue(b,j,n,r)
local P=H.build_preference_config_queue(b,j,n,r)return H.start_config_queue(b,P)
end
function H.start_named_mapping_config_queue(b,g,A,aO,d)
local P=H.build_named_mapping_config_queue(b,g,A,aO,d)return H.start_config_queue(b,P)
end
function H.send_preferences(b,j,r,n)
local bL=false
if a(n)=="table"then
for _,l in ipairs(n)do
if av(b,l,j,r)then
bL=true
end
end
elseif a(j)=="table"then
if M(j)then
for _,c in ipairs(j)do
local l=c.preference or c.key or c.name
if a(l)=="string"and av(b,l,j,r)then
bL=true
end
end
else
for l,_ in pairs(j or{})do
if av(b,l,j,r)then
bL=true
end
end
end
end
return bL
end
function H.apply_preferences_changed(b,j,r,aU)
aU=aU or{}local n=a(aU.preference_names)=="table"and aU.preference_names or nil
local P=H.build_preference_config_queue(b,j,n,r)if #P==0 then
return false
end
if aU.use_queue then
return H.start_config_queue(b,P)end
return H.send_preferences(b,j,r,n)
end
end
return bB
