local zcl=require "protocol.zcl"
return{
water_battery_low_battery_sensor={
profile="safety-water-leak-battery-low-battery",
zcl_clusters={
zcl.water(),
zcl.battery_low(),
zcl.battery(),
},
},
}
