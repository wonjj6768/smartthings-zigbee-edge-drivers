local a=require"protocol.tuya.contract.internal"
local function e(g,b,c)
local d=
type(b)=="table"and b.emit or
type(c)=="table"and c.emit or
nil
if d==nil then
error("protocol.tuya.contract.dp_on_off requires an explicit emit option",2)end
return a.dp_on_off(g,b,c)
end
local f={dp_binary=a.dp_binary,dp_raw=a.dp_raw,dp_numeric=a.dp_numeric,dp_enum=a.dp_enum,dp_on_off=e,dp_countdown=a.dp_countdown,dp_occupancy=a.dp_occupancy,dp_battery=a.dp_battery,dp_illuminance=a.dp_illuminance,converter={from_to=a.converter.from_to,lookup_from_to=a.converter.lookup_from_to,invert_bool_pair=a.converter.invert_bool_pair,true_false0=a.converter.true_false0}}return f
