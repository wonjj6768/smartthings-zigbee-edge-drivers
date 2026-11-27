local M={}
function M.dispatch(a,b)
if type(a)=="function"and a()==true then
return true
end
if type(b)=="function"then
return b()==true
end
return false
end
return M
