local a=require"protocol.zcl"return{water_battery_low_battery_sensor={profile="safety-water-leak-battery-low-battery",zcl_clusters={a.water(),a.battery_low(),a.battery()}}}
