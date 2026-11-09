local a,H={},{"previous","blink","breathe","okay","channel_change","finish_effect","stop_effect","s","off","on","toggle","colorloop","disabled","enabled","stop_colorloop","shellyDimmerActionGroup","shellyDimmerActionLevel","shellyDimmerActionTransition","shellyDimmerActionRate","shellyDimmerActionStepSize","double_pressed","held","released","false","true","ON","OFF","effect","doNotDisturb","initial","customized","paulmannRgbwwStartupCct","paulmannRgbwwPowerOnBehavior","paulmannRgbwwEffect","shellyDimmerAction","shellyDimmerDhcpEnabled","shellyDimmerWifiEnabled","shellyDimmerPowerOnBehavior","shellyDimmerEffect","identify","shellyDimmerWifiStatus","shellyDimmerIpAddress","shellyDimmerWifiSsid","shellyDimmerWifiPassword","shellyDimmerStaticIp","shellyDimmerNetMask","shellyDimmerGateway","shellyDimmerNameServer","mired","candeoRd1pDpmOnLevel","onLevel","candeoRd1pDpmStartupLevel","startupLevel","candeoRd1pDpmOnTransitionTime","candeoRd1pDpmOffTransitionTime","candeoRotaryDimOnLevel","candeoRotaryDimStartupLevel","candeoRotaryDimOnTransition","candeoRotaryDimOffTransition","terncyDimRatedCurrent","terncyDimStartupCalibration","terncyDimMinKelvin","terncyDimMaxKelvin","hueFluxEffectSpeed","hueFluxGradientScale","hueFluxGradientOffset","candeoRd1pDpmAction","pressed","started_rotating_left","started_rotating_right","rotating_right","rotating_left","stopped_rotating","candeoRd1pDpmPowerBehavior","powerOnBehavior","on_2","on_3","on_4","off_2","off_3","off_4","toggle_2","toggle_3","toggle_4","brightness_move_to_level_4","brightness_move_up_4","brightness_move_down_4","brightness_step_up_4","brightness_step_down_4","brightness_stop_4","open_4","close_4","stop_4","candeoRotaryDimAction","candeoRotaryDimExtraCommands","candeoRotaryDimPowerBehavior","terncyDimIoReversed","terncyDimLightCurve","fast_start","uniform","slow_start","luumrG9Effect","luumrG9DoNotDisturb","ts0505bHsEffect","ts0505bHsDoNotDisturb","ts0505bHsColorPowerOnBehavior","colorPowerOnBehavior","ts0503bHsEffect","ts0503bHsDoNotDisturb","ts0503bHsColorPowerOnBehavior","hueFluxEffect","candle","fireplace","sunset","sunrise","sparkle","glisten","underwater","cosmos","sunbeam","enchant","stop_hue_effect","hueFluxGradientScene","blossom","crocus","precious","narcissa","beginnings","first_light","horizon","valley_dawn","sunflare","emerald_flutter","memento","resplendent","scarlet_dream","lovebirds","smitten","glitz_and_glam","promise","ruby_romance","city_of_love","honolulu","savanna_sunset","golden_pond","runy_glow","tropical_twilight","cancun","chinatown","motown","fairfax","galaxy","starlight","blood moon","artic_aurora","moonlight","nebula","sundown","blue_lagoon","palm_beach","lake_placid","mountain_breeze","lake_mist","ocean_dawn","frosty_dawn","sunday_morning","emerald_isle","spring_blossom","midsummer_sun","autumn_gold","spring_lake","winter_mountain","midwinter","amber_bloom","painted_sky","winter_beauty","orange_fields","forest_adventure","blue_planet","vapor_wave","magneto","tyrell","disturbia","golden_star","under_the_tree","silent_night","rosy_sparkle","festive_fun","colour_burst","crystalline","hueFluxGradientStyle","linear","scattered","mirrored","hueFluxPowerOnBehavior","hueFluxIdentify","ecodoRepeaterDoNotDisturb","lastPowerResponseTime","hueFluxEffectColor","hueFluxGradient","hueFluxStartupColorTemperature"}
local function b(g)
if type(g)=="number"then return H[g]end
return g
end
local function p(g)local suffix=b(g);if suffix==nil then return nil end;return"concertmirror08464."..suffix end
local t={}
local function q(k)
if type(k)~="number"then return{}end
local x=t[k]if x~=nil then return x end
local n={}t[k]=n
return n
end
local function s(D,k)
if type(D)~="table"then return nil end
local n=q(k)for A,g in ipairs(D)do n[A]=b(g)end
return n
end
local function i(g,E)
if g==nil then return E end
if g==0 then return nil end
return b(g)
end
local function m(attribute_name)
if type(attribute_name)~="string"or attribute_name==""then return nil end
return"set"..attribute_name:sub(1,1):upper()..attribute_name:sub(2)
end
local function J(g)
if type(g)~="table"then return nil end
local n=q(g[6])n.minimum=g[1]n.maximum=g[2]n.step=g[3]n.unit=b(g[4])n.allowed_values=s(g[5],g[7])return n
end
local function w(j,k)
if j==nil and k==nil then return nil end
local n=q(k)n.allowed_values=j
return n
end
local function G(f)
local attribute_name=b(f[4])return{kind="numeric",emit_name=b(f[1]),range_key=b(f[2]),capability_id=p(f[3]),attribute_name=attribute_name,range_attribute_name=b(f[5]),command_name=i(f[6],m(attribute_name)),argument_name=i(f[7],attribute_name),mapping_name=b(f[8]),label=b(f[9]),default_range=J(f[10]),event_minimum=f[11],event_maximum=f[12],event_unit=b(f[13])}
end
local function K(f)
local attribute_name,u,r=b(f[4]),s(f[10],f[12]),s(f[11],f[14])local d=w(r,f[13])return{kind="enum",emit_name=b(f[1]),range_key=b(f[2]),capability_id=p(f[3]),attribute_name=attribute_name,supported_attribute_name=b(f[5]),command_name=i(f[6],m(attribute_name)),argument_name=i(f[7],attribute_name),mapping_name=b(f[8]),label=b(f[9]),supported_values=u,default_range=d}
end
local function M(f)
local attribute_name=b(f[3])return{kind="text",emit_name=b(f[1]),capability_id=p(f[2]),attribute_name=attribute_name,command_name=i(f[4],m(attribute_name)),argument_name=i(f[5],attribute_name),mapping_name=b(f[6]),label=b(f[7]),maximum_length=f[8]}
end
local function z(L,F)
local n={}for _,f in ipairs(L)do n[#n+1]=F(f)end
return n
end
a.numeric=z({{32,nil,32,32,nil,nil,nil,"paulmann_rgbww_startup_color_temperature","Paulmann Rgbww Startup Cct",{153,65535,1,49,nil,1},nil,nil,49},{50,nil,50,51,nil,nil,nil,"candeo_rd1p_dpm_on_level","Candeo Rd1p Dpm On Level",{0,255,1,nil,nil,2}},{52,nil,52,53,nil,nil,nil,"candeo_rd1p_dpm_startup_level","Candeo Rd1p Dpm Startup Level",{0,255,1,nil,nil,3}},{54,nil,54,"onTransitionTime",nil,nil,nil,"candeo_rd1p_dpm_on_transition_time","Candeo Rd1p Dpm On Transition Time",{0,6553.5,0.1,8,nil,4},nil,nil,8},{55,nil,55,"offTransitionTime",nil,nil,nil,"candeo_rd1p_dpm_off_transition_time","Candeo Rd1p Dpm Off Transition Time",{0,6553.5,0.1,8,nil,5},nil,nil,8},{16,nil,16,16,nil,0,0,16,"Shelly Dimmer Action Group",{1,65527,1,nil,nil,6}},{17,nil,17,17,nil,0,0,17,"Shelly Dimmer Action Level",{0,255,1,nil,nil,7}},{18,nil,18,18,nil,0,0,18,"Shelly Dimmer Action Transition",{0,6553.5,0.1,8,nil,8},nil,nil,8},{19,nil,19,19,nil,0,0,19,"Shelly Dimmer Action Rate",{0,255,1,nil,nil,9}},{20,nil,20,20,nil,0,0,20,"Shelly Dimmer Action Step Size",{0,255,1,nil,nil,10}},{56,nil,56,51,nil,nil,nil,"candeoRotaryDim_on_level","Candeo Rotary Dim On Level",{0,255,1,nil,nil,11}},{57,nil,57,53,nil,nil,nil,"candeoRotaryDim_startup_level","Candeo Rotary Dim Startup Level",{0,255,1,nil,nil,12}},{58,nil,58,"onTransition",nil,nil,nil,"candeoRotaryDim_on_transition","Candeo Rotary Dim On Transition",{0,6553.5,0.1,8,nil,13},nil,nil,8},{59,nil,59,"offTransition",nil,nil,nil,"candeoRotaryDim_off_transition","Candeo Rotary Dim Off Transition",{0,6553.5,0.1,8,nil,14},nil,nil,8},{60,nil,60,"ratedCurrent",nil,nil,nil,"terncyDim_rated_current","Terncy Dim Rated Current",{120,4950,1,"mA",nil,15},nil,nil,"mA"},{61,nil,61,"startupCalibration",nil,nil,nil,"terncyDim_startup_calibration","Terncy Dim Startup Calibration",{0,5000,1,nil,nil,16}},{62,nil,62,"minKelvin",nil,nil,nil,"terncyDim_min_kelvin","Terncy Dim Min Kelvin",{1000,10000,1,"K",nil,17},nil,nil,"K"},{63,nil,63,"maxKelvin",nil,nil,nil,"terncyDim_max_kelvin","Terncy Dim Max Kelvin",{1000,10000,1,"K",nil,18},nil,nil,"K"},{64,nil,64,"effectSpeed",nil,nil,nil,"philips_flux_effect_speed","Hue Flux Effect Speed",{0,1,nil,nil,nil,19}},{65,nil,65,"gradientScale",nil,nil,nil,"philips_flux_gradient_scale","Hue Flux Gradient Scale",{0,31,nil,nil,nil,20}},{66,nil,66,"gradientOffset",nil,nil,nil,"philips_flux_gradient_offset","Hue Flux Gradient Offset",{0,31,nil,nil,nil,21}}},G)a.enum=z({{33,nil,33,33,nil,nil,nil,"paulmann_rgbww_power_on_behavior","Paulmann Rgbww Power On Behavior",{9,10,11,1},{9,10,11,1},22,23,22},{34,nil,34,34,nil,nil,nil,"paulmann_rgbww_effect","Paulmann Rgbww Effect",{2,3,4,5,6,7,12,15},{2,3,4,5,6,7,12,15},24,25,24},{67,nil,67,"dpmAction",nil,0,0,"candeo_rd1p_dpm_action","Candeo Rd1p Dpm Action",{68,21,22,23,69,70,71,72,73},{68,21,22,23,69,70,71,72,73},26,27,26},{74,nil,74,75,nil,nil,nil,"candeo_rd1p_dpm_power_on_behavior","Candeo Rd1p Dpm Power Behavior",{9,10,11,1},{9,10,11,1},28,29,28},{35,nil,35,35,nil,0,0,"shelly_dimmer_action","Shelly Dimmer Action",{76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93},{76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93},30,31,30},{36,nil,36,36,nil,0,0,"shelly_dimmer_dhcp_enabled","Shelly Dimmer Dhcp Enabled",{24,25},{24,25},32,33,32},{37,nil,37,37,nil,nil,nil,"shelly_dimmer_wifi_enabled","Shelly Dimmer Wifi Enabled",{24,25},{24,25},34,35,34},{38,nil,38,38,nil,nil,nil,"shelly_dimmer_power_on_behavior","Shelly Dimmer Power On Behavior",{9,10,11,1},{9,10,11,1},36,37,36},{39,nil,39,39,nil,nil,nil,"shelly_dimmer_effect","Shelly Dimmer Effect",{2,3,4,5,6,7},{2,3,4,5,6,7},38,39,38},{94,nil,94,"action",nil,0,0,"candeoRotaryDim_action","Candeo Rotary Dim Action",{21,22,23},{21,22,23},40,41,40},{95,nil,95,"extraCommands",nil,nil,nil,"candeoRotaryDim_extra_commands","Candeo Rotary Dim Extra Commands",{26,27},{26,27},42,43,42},{96,nil,96,"powerBehavior",nil,nil,nil,"candeoRotaryDim_power_behavior","Candeo Rotary Dim Power Behavior",{9,10,11,1},{9,10,11,1},44,45,44},{97,nil,97,"ioReversed",nil,nil,nil,"terncyDim_io_reversed","Terncy Dim Io Reversed",{26,27},{26,27},46,47,46},{98,nil,98,"lightCurve",nil,nil,nil,"terncyDim_light_curve","Terncy Dim Light Curve",{99,100,101},{99,100,101},48,49,48},{102,nil,102,28,nil,nil,nil,"luumr_g9_effect","Luumr G9Effect",{2,3,4,5,6,7},{2,3,4,5,6,7},50,51,50},{103,nil,103,29,nil,nil,nil,"luumr_g9_do_not_disturb","Luumr G9Do Not Disturb",{13,14},{13,14},52,53,52},{104,nil,104,28,nil,nil,nil,"ts0505bHs_effect","Ts0505b Hs Effect",{2,3,4,5,6,7,12,15},{2,3,4,5,6,7,12,15},54,55,54},{105,nil,105,29,nil,nil,nil,"ts0505bHs_do_not_disturb","Ts0505b Hs Do Not Disturb",{13,14},{13,14},56,57,56},{106,nil,106,107,nil,nil,nil,"ts0505bHs_color_power_on_behavior","Ts0505b Hs Color Power On Behavior",{30,1,31},{30,1,31},58,59,58},{108,nil,108,28,nil,nil,nil,"ts0503bHs_effect","Ts0503b Hs Effect",{2,3,4,5,6,7,12,15},{2,3,4,5,6,7,12,15},60,61,60},{109,nil,109,29,nil,nil,nil,"ts0503bHs_do_not_disturb","Ts0503b Hs Do Not Disturb",{13,14},{13,14},62,63,62},{110,nil,110,107,nil,nil,nil,"ts0503bHs_color_power_on_behavior","Ts0503b Hs Color Power On Behavior",{30,1,31},{30,1,31},64,65,64},{111,nil,111,28,nil,nil,nil,"philips_flux_effect","Hue Flux Effect",{2,3,4,5,112,113,12,114,115,116,"opal",117,118,119,120,121,"none",6,7,122},{2,3,4,5,112,113,12,114,115,116,"opal",117,118,119,120,121,"none",6,7,122},66,67,66},{123,nil,123,"gradientScene",nil,nil,nil,"philips_flux_gradient_scene","Hue Flux Gradient Scene",{124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,"miami",148,"rio",149,"ibiza","osaka","tokyo",150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,"lily",175,176,177,178,179,"soho",180,181,182,183,"hal",184,185,186,187,188,189,190},{124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,"miami",148,"rio",149,"ibiza","osaka","tokyo",150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,"lily",175,176,177,178,179,"soho",180,181,182,183,"hal",184,185,186,187,188,189,190},68,69,68},{191,nil,191,"gradientStyle",nil,nil,nil,"philips_flux_gradient_style","Hue Flux Gradient Style",{192,193,194},{192,193,194},70,71,70},{195,nil,195,75,nil,nil,nil,"philips_flux_power_on_behavior","Hue Flux Power On Behavior",{9,10,11,1},{9,10,11,1},72,73,72},{196,nil,196,40,nil,nil,nil,"philips_flux_identify","Hue Flux Identify",{40},{40},74,75,74},{197,nil,197,29,nil,nil,nil,"ecodo_do_not_disturb","Ecodo Repeater Do Not Disturb",{14,13},{14,13},76,77,76}},K)a.text=z({{"last_power_response_time",198,198,0,0,nil,"Last power response time",64},{41,41,41,0,0,"shelly_dimmer_wifi_status","Shelly Dimmer Wifi Status",255},{42,42,42,0,0,"shelly_dimmer_ip_address","Shelly Dimmer Ip Address",255},{43,43,43,nil,nil,"shelly_dimmer_wifi_ssid","Shelly Dimmer Wifi Ssid",255},{44,44,44,nil,nil,"shelly_dimmer_wifi_password","Shelly Dimmer Wifi Password",255},{45,45,45,nil,nil,"shelly_dimmer_static_ip","Shelly Dimmer Static Ip",255},{46,46,46,nil,nil,"shelly_dimmer_net_mask","Shelly Dimmer Net Mask",255},{47,47,47,nil,nil,"shelly_dimmer_gateway","Shelly Dimmer Gateway",255},{48,48,48,nil,nil,"shelly_dimmer_name_server","Shelly Dimmer Name Server",255},{199,199,"effectColor",nil,nil,"philips_flux_effect_color","Hue Flux Effect Color",16383},{200,200,"gradient",nil,nil,"philips_flux_gradient","Hue Flux Gradient",16383},{201,201,"startupColorTemperature",nil,nil,"philips_flux_startup_color_temperature","Hue Flux Startup Color Temperature",16383}},M)a.driver_message={attribute_name="driverMessage",capability_id="concertmirror08464.driverMessage",emit_name="driver_message",label="Driver message",maximum_length=512}a.by_range_key={}a.by_emit_name={}a.by_capability_id={}
local function o(y)
for _,e in ipairs(y)do
a.by_emit_name[e.emit_name]=e
if type(e.capability_id)=="string"and e.capability_id~=""then a.by_capability_id[e.capability_id]=e end
if type(e.range_key)=="string"and e.range_key~=""then a.by_range_key[e.range_key]=e end
end
end
o(a.numeric)o(a.enum)o(a.text)a.by_emit_name[a.driver_message.emit_name]=a.driver_message
a.by_capability_id[a.driver_message.capability_id]=a.driver_message
local function l(j)
if type(j)~="table"then return nil end
local B={}for A,g in ipairs(j)do B[A]=g end
return B
end
function a.resolve_range(v,e)
if type(e)~="table"then return nil end
local d,C=type(e.default_range)=="table"and e.default_range or nil,type(v)=="table"and v.presence_capability_ranges or nil

local h=type(C)=="table"and C[e.range_key]or nil
if type(h)~="table"then h=d end
if type(h)~="table"then return nil end
return{minimum=type(h.minimum)=="number"and h.minimum or(d and d.minimum or nil),maximum=type(h.maximum)=="number"and h.maximum or(d and d.maximum or nil),step=type(h.step)=="number"and h.step or(d and d.step or nil),unit=type(h.unit)=="string"and h.unit or(d and d.unit or nil),allowed_values=type(h.allowed_values)=="table"and l(h.allowed_values)or l(d and d.allowed_values or nil)}
end
return a
