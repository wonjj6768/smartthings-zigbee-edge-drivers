local M={}
function M.dispatch(explicit_handler,mapped_handler)
if type(explicit_handler)=="function" and explicit_handler()==true then
return true
end
if type(mapped_handler)=="function" then
return mapped_handler()==true
end
return false
end
return M
