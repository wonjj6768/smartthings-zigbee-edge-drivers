local tuya=require "protocol.tuya"
return{
panel_off_on_converter=tuya.converter.lookup_from_to({off=false,on=true}),
}
