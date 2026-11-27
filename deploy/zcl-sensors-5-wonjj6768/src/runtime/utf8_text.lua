local b,g,i={},type(utf8)=="table"and utf8.len or nil,type(utf8)=="table"and utf8.offset or nil

local function d(a)
if type(a)~="number"or a<0
or a%1~=0 then
return nil
end
return a
end
function b.length(c)
if type(c)~="string"or type(g)~="function"then
return nil
end
return g(c)
end
function b.fits(c,a)
local f,e=d(a),b.length(c)return f~=nil and e~=nil and e<=f
end
function b.truncate(c,a)
local f,e=d(a),b.length(c)if f==nil or e==nil then
return nil
end
if e<=f then
return c
end
local h=i(c,f+1)if h==nil then
return nil
end
return c:sub(1,h-1)
end
return b
