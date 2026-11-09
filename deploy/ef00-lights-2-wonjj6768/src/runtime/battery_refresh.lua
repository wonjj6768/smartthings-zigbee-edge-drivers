local h,b,e,f,d,c=require"st.capabilities",{},24*60*60,"__battery_refresh_last_report_at","__battery_refresh_last_request_at","__battery_refresh_timer"
local i
local g
local function w()
return os.time()
end
local function k(a)
local o=a:get_field(c)if o~=nil and type(o.cancel)=="function"then
pcall(function()
o:cancel()
end)
end
a:set_field(c,nil,{persist=false})
end
function b.set_requester(u,v)
i=u
g=v
end
local function j(a)
if type(i)~="function"then
return false
end
if type(g)=="function"then
return g(a)==true
end
return true
end
function b.has_battery(a)
if type(a)~="table"then
return false
end
if type(a.supports_capability_by_id)=="function"and a:supports_capability_by_id(h.battery.ID,"main")then
return true
end
local q=a.profile and a.profile.components or nil
if type(q)~="table"then
return false
end
for l,_ in pairs(q)do
if type(l)=="string"and type(a.supports_capability_by_id)=="function"and a:supports_capability_by_id(h.battery.ID,l)then
return true
end
end
return false
end
function b.note_report(a)
if type(a)=="table"and type(a.set_field)=="function"then
a:set_field(f,w(),{persist=true})end
end
function b.should_request(a)
if not j(a)or not b.has_battery(a)then
return false
end
local t,p=w(),a:get_field(f)if type(p)=="number"and t-p<e then
return false
end
local m=a:get_field(d)if type(m)=="number"and t-m<e then
return false
end
return true
end
function b.request_if_due(a)
if not b.should_request(a)then
return false
end
a:set_field(d,w(),{persist=true})return i(a)
end
function b.schedule_after_button(a)
if type(a)~="table"or a.thread==nil or type(a.thread.call_with_delay)~="function"then
return false
end
if not b.should_request(a)then
return false
end
a:set_field(d,w(),{persist=true})
a.thread:call_with_delay(1,function()
if j(a)and b.has_battery(a)then
i(a)end
end,"battery read after button")
return true
end
function b.maybe_schedule_after_event(a,n)
local s,r=n and n.capability and n.capability.ID or nil,n and n.attribute and n.attribute.NAME or nil

if s==h.button.ID and r=="button"then
return b.schedule_after_button(a)end
return false
end
function b.start_daily(a)
if type(a)~="table"or a.thread==nil or type(a.thread.call_on_schedule)~="function"then
return false
end
if not b.has_battery(a)or not j(a)then
k(a)return false
end
k(a)
local o=a.thread:call_on_schedule(e,function()
b.request_if_due(a)
end,"battery voltage daily read")
a:set_field(c,o,{persist=false})return o~=nil
end
return b
