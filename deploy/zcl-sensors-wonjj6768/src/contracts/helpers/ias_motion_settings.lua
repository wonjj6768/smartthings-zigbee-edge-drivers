local q,d,h,M=require"protocol.zcl",require"st.zigbee.data_types",require"st.zigbee.cluster_base",{}
function M.passive(g)
g.minimum_interval=nil
g.maximum_interval=nil
g.reportable_change=nil
g.read_on_configure=false
return g
end
function M.battery(o)
local l={endpoint=1,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,
from_device=function(c,_,e)
if e.raw_value==255 then return nil end
return c
end
}if o then return q.battery(l)end
return M.passive(q.battery(l))
end
function M.voltage()
return q.battery_voltage{endpoint=1,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,
from_device=function(c,_,e)
if e.raw_value==255 then return nil end
return c
end
}
end
function M.battery_alarm(b)
return q.cluster_attribute(1,62,{name="battery_alarm_state",endpoint=1,data_type=d.Bitmap32,read_only=true,read_on_configure=false,emit=b,
from_device=function(c)
if type(c)=="table"then c=c.value end
return bit32.band(c,15744015)~=0
end
})
end
function M.keep_alive(b)
return function(a,t,e)
if e.command_id~=0 then return end
local i="__ih012_rt01_keep_alive"local f=a:get_field(i)if f then f:cancel()end
a:set_field(i,nil)if t then
a:set_field(i,a.thread:call_with_delay(125,function()
a:set_field(i,nil)a:emit_event(b(a,false))
end,"IH012 RT01 occupancy keep alive"))
end
end
end
function M.mapping(b,j,n,p)
local k={}for u,c in pairs(p)do k[c]=u end
return q.cluster_attribute(1280,n,{name=j,endpoint=1,data_type=d.Uint8,write_type=d.Uint8,emit=b,read_on_configure=false,
from_device=function(u)return p[u]end,
to_device=function(c)return k[c]end
})
end
function M.vibration_timeout(b)
return function(a,_,e)
if e.command_id~=0 then return end
local i="__ts0210_vibration_timeout"local f=a:get_field(i)if f then f:cancel()end
a:set_field(i,nil)local m=tonumber(a.preferences.vibrationTimeout)or 90
if m>0 then
a:set_field(i,a.thread:call_with_delay(m,function()
a:set_field(i,nil)a:emit_event(b(a,false))
end,"TS0210 vibration timeout"))
end
end
end
function M.sensitivity(b,j)
return M.mapping(b,j,19,{[0]="low","medium","high"})
end
function M.keep_time(b,j)
return M.mapping(b,j,61441,{[0]="30","60","120"})
end
function M.refresh(a)
local s=h.read_attribute(a,d.ClusterId(1280),d.AttributeId(19))s.body.zcl_body.attr_ids={d.AttributeId(19),d.AttributeId(61441),d.AttributeId(2)}a:send(s:to_endpoint(1))
end
function M.magic_packet(a)
local s=h.read_attribute(a,d.ClusterId(0),d.AttributeId(4))s.body.zcl_body.attr_ids={}for _,w in ipairs{4,0,1,5,7,65534}do
s.body.zcl_body.attr_ids[#s.body.zcl_body.attr_ids+1]=d.AttributeId(w)end
a:send(s:to_endpoint(1))
end
return M
