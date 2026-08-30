local zcl=require "protocol.zcl"
local device_helpers=require "contracts.helpers.family"
local device_definitions,register_device_definition=device_helpers.definition_registry()
local ir_controller={
profile="controllers-ir-transceiver",
ir_controller=true,
ir_endpoint=1,
zcl_clusters={},
}
local ir_controller_battery={
profile="controllers-ir-transceiver-battery",
ir_controller=true,
ir_endpoint=1,
zcl_clusters={
zcl.battery(),
},
}
register_device_definition(ir_controller,device_helpers.create_fingerprints("TS1201",{
"_TZ3290_785fbxik",
"_TZ3290_7v1k4vufotpowp9z",
"_TZ3290_rlkmy85q4pzoxobl",
"_TZ3290_jxvzqatwgsaqzx1u",
"_TZ3290_lypnqvlem5eq1ree",
"_TZ3290_uc8lwbi2",
"_TZ3290_nba3knpsarkawgnt",
"_TZ3290_8xzb2ghn",
"_TZ3290_s6ezpa3j",
"_TZ3290_ot6ewjvmejq5ekhl",
"_TZ3290_j37rooaxrcdcqo5n",
"_TZ3290_nkpxapoz",
"_TZ3290_yac64inudpovoaba",
"_TZ3290_acv1iuslxi3shaaj",
"_TZ3290_gnl5a6a5xvql7c2a",
"_TZ3290_xjpbcxn92aaxvmlz",
"_TZ3290_yyax9ajf",
}))
register_device_definition(ir_controller_battery,device_helpers.create_fingerprints("TS1201",{
"_TZ3290_u9xac5rv",
"_TZ3290_lidgqyzu",
}))
register_device_definition(ir_controller,device_helpers.create_fingerprints("ZS06",{
"_TZ3290_7v1k4vufotpowp9z",
"_TZ3290_acv1iuslxi3shaaj",
"_TZ3290_gnl5a6a5xvql7c2a",
"_TZ3290_rlkmy85q4pzoxobl",
"_TZ3290_nba3knpsarkawgnt",
"_TZ3290_yac64inudpovoaba",
}))
return{
id="zcl.controls.ir",
registrations=device_definitions,
}
