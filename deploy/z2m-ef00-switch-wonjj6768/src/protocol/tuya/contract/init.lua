local internal=require "protocol.tuya.contract.internal"
local function dp_on_off(dp,name_or_options,options)
local explicit_emit=
type(name_or_options)=="table" and name_or_options.emit or
type(options)=="table" and options.emit or
nil
if explicit_emit==nil then
error("protocol.tuya.contract.dp_on_off requires an explicit emit option",2)
end
return internal.dp_on_off(dp,name_or_options,options)
end
local contract={
dp_binary=internal.dp_binary,
dp_raw=internal.dp_raw,
dp_numeric=internal.dp_numeric,
dp_enum=internal.dp_enum,
dp_on_off=dp_on_off,
dp_countdown=internal.dp_countdown,
dp_occupancy=internal.dp_occupancy,
dp_battery=internal.dp_battery,
dp_illuminance=internal.dp_illuminance,
converter={
from_to=internal.converter.from_to,
lookup_from_to=internal.converter.lookup_from_to,
invert_bool_pair=internal.converter.invert_bool_pair,
true_false0=internal.converter.true_false0,
},
}
return contract
