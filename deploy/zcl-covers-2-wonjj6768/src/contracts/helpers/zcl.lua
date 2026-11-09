local q,a=require"protocol.zcl",{}
function a.duplicate_transaction(m,e,r,D)
if r==nil then return false end
local G,n,g,C,expiry=require"cosock.socket".gettime()*1000,m:get_field(D)or{},{},nil,math.huge

for _,h in ipairs(n[e]or{})do
if h[1]==r and h[2]>G then return true end
if h[2]>G then
g[#g+1]=h
if h[2]<expiry then C,expiry=#g,h[2]end
end
end
if #g>4 then table.remove(g,C)end
g[#g+1],n[e]={r,G+10000},g
m:set_field(D,n,{persist=false})return false
end
function a.passive(l)
l.minimum_interval=nil
l.maximum_interval=nil
l.reportable_change=nil
l.read_on_configure=false
return l
end
function a.identify(m,i)
if type(i)~="number"or i%1~=0 or i<1 or i>30 then return false end
return q.send_raw_cluster_command(m,3,0,string.pack("<I2",i),m:get_endpoint(3))
end
local function b(c,o)
if o~=nil then
c[#c+1]=o
end
end
function a.append_clusters(c,...)
for H=1,select("#",...)do
local h=select(H,...)if type(h)=="table"and h[1]~=nil then
for _,o in ipairs(h)do
b(c,o)end
else
b(c,h)end
end
return c
end
function a.metering_clusters(d)
d=d or{}local e,v,t,B,z,x,A,y,c=d.endpoint,d.include_switch~=false,d.include_current==true,d.power_poll or 300,d.voltage_poll or 300,d.current_poll or 300,d.energy_poll or 900,d.energy_scale or 100,{}







if v then
b(c,q.switch{endpoint=e,component=d.switch_component})end
b(c,q.power{endpoint=e,poll_interval=B})b(c,q.voltage{endpoint=e,poll_interval=z})if t then
b(c,q.current{endpoint=e,poll_interval=x,use_reported_unity_scaler=d.use_reported_unity_scaler})end
b(c,q.energy{endpoint=e,scale=y,ignore_reported_scaler=d.energy_ignore_reported_scaler,use_reported_unity_scaler=d.use_reported_unity_scaler,poll_interval=A})return c
end
function a.switch_cluster(e,w)
if e==nil and w==nil then
return q.switch()end
return q.switch{endpoint=e,component=w}
end
local function j(p,...)
local E=p and p.body and p.body.zcl_body or nil
if type(E)~="table"then return nil end
for _,I in ipairs{...}do
local i=E[I]if type(i)=="table"and i.value~=nil then return i.value end
if i~=nil then return i end
end
end
function a.resolve_rd1p_rotary_action(p,s,k,u)
if u~=2 then return nil,nil,true end
if s==q.CLUSTER_ON_OFF then
return({[0]="double_pressed",[1]="pressed",[2]="held",[3]="released"})[k],"main",true
end
if s==q.CLUSTER_LEVEL_CONTROL then
if k==3 then return"stopped_rotating","main",true end
local f
if k==5 then
f=j(p,"move_mode","movemode","mode")if f==0 then return"started_rotating_right","main",true end
if f==1 then return"started_rotating_left","main",true end
elseif k==6 then
f=j(p,"step_mode","stepmode","mode")if f==0 then return"rotating_right","main",true end
if f==1 then return"rotating_left","main",true end
end
end
return nil,nil,true
end
return a
