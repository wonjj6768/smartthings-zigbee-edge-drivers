local zcl=require"protocol.zcl"
local emit=require"capabilities.events.all"
local device_helpers=require"contracts.helpers.family"
local capabilities=require"st.capabilities"
local data_types=require"st.zigbee.data_types"
local json=require"st.json"
local safe_xy_to_hsv=require"st.utils.safe_xy_to_hsv"
local device_definitions,register_device_definition=device_helpers.definition_registry()
local EFFECTS={candle=1,fireplace=2,colorloop=3,sunrise=9,sparkle=10,opal=11,
glisten=12,sunset=13,underwater=14,cosmos=15,sunbeam=16,enchant=17}
local STYLES={linear=0,scattered=2,mirrored=4}
local SCENES={
["blossom"]="50010400135000000039d553d2955ba5287a9f697e25fb802800",
["crocus"]="50010400135000000050389322f97f2b597343764cc664282800",
["precious"]="5001040013500000007fa8838bb9789a786d7577499a773f2800",
["narcissa"]="500104001350000000b0498a5c0a888fea89eb0b7ee15c742800",
["beginnings"]="500104001350000000b3474def153e2ad42e98232c7483292800",
["first_light"]="500104001350000000b28b7900e959d3f648a614389723362800",
["horizon"]="500104001350000000488b7d6cbb750c6642f1133cc4033c2800",
["valley_dawn"]="500104001350000000c1aa7de03a7a8ce861c7c4410d94412800",
["sunflare"]="500104001350000000d0aa7d787a7daf197590154d6c14472800",
["emerald_flutter"]="5001040013500000006a933977e34bb0d35e916468f246792800",
["memento"]="500104001350000000f87318a3e31962331ec3532cceea892800",
["resplendent"]="500104001350000000278b6d257a58efe84204273a35f5252800",
["scarlet_dream"]="500104001350000000b02c654e4c5b45ab51fb0950d6c84d2800",
["lovebirds"]="50010400135000000053ab84ea1a7e35fb7c098c73994c772800",
["smitten"]="500104001350000000fe7b70a74b6aa42b65811b60550a592800",
["glitz_and_glam"]="500104001350000000cc193cb9b845bad9521d1c77bf6c712800",
["promise"]="500104001350000000258b606eca6b28d6382db445df26812800",
["ruby_romance"]="5001040013500000000edb63cbcb6bac0c670b2d58204e572800",
["city_of_love"]="50010400135000000055830e5cf31b6aa339d2ec70908b802800",
["honolulu"]="500104001350000000dbfd59866c6378ec6c45cc765c0a822800",
["savanna_sunset"]="50010400135000000005ae65c38c6c6b4b7573ca820fc9832800",
["golden_pond"]="5001040013500000007e4a88cc4a8605db8728ec7b666c792800",
["runy_glow"]="50010400135000000095bb53ac2a56eb99591e095c54985e2800",
["tropical_twilight"]="500104001350000000408523a0b636e777524c0a71a76c6e2800",
["miami"]="50010400135000000022ec61e6d94902d83766c3305a43182800",
["cancun"]="500104001350000000a7eb54673d55944e6265fd6e26bb842800",
["rio"]="500104001350000000a26526088c51a74b58ea6b7137ba892800",
["chinatown"]="500104001350000000b33e5b408e59d90d5b4c6c6360ac792800",
["ibiza"]="500104001350000000014d6d708c73827b7b6c7a8887f98a2800",
["osaka"]="500104001350000000d649510b5c4deb7c5d8b6d6d2b9b802800",
["tokyo"]="500104001350000000d1c311665331d3451fd59c4e394c7b2800",
["motown"]="50010400135000000055730e5db3156623306c533d7a235c2800",
["fairfax"]="50010400135000000072d34a3664477d7a61581d5fc08e5b2800",
["galaxy"]="500104001350000000a6cb638b2a4f8cfa549bb9549ff73a2800",
["starlight"]="5001040013500000008d897134a9653ec854d2963ed1d4282800",
["blood moon"]="500104001350000000202a6987c8599ee647ec632779c3142800",
["artic_aurora"]="50010400135000000082548922057511046571c32d5b93192800",
["moonlight"]="50010400135000000055730e5e9320c1832e96243ebec7652800",
["nebula"]="50010400135000000026c852e106460d653ee745342964142800",
["sundown"]="500104001350000000f37c68157c6d8efa755ac5512e24332800",
["blue_lagoon"]="50010400135000000088c3623975699ea672a0c8831ada6d2800",
["palm_beach"]="5001040013500000005ec4679ba56077f85a80ea64639c6a2800",
["lake_placid"]="5001040013500000002eab69239a692d996552c54c39743a2800",
["mountain_breeze"]="500104001350000000df843d2355419195465a98674ca97b2800",
["lake_mist"]="500104001350000000e3286f39b96859f86266e54ded943f2800",
["ocean_dawn"]="5001040013500000005cf9779da97105b96b07485e32564a2800",
["frosty_dawn"]="5001040013500000006d6883bca87e3029758ec9722d6a722800",
["sunday_morning"]="5001040013500000002c586dc6f87345997c63f983f777892800",
["emerald_isle"]="500104001350000000e535628dc57ed2667d8b687d1e2a812800",
["spring_blossom"]="500104001350000000a8b75fd0c75826b851a7094d305b652800",
["midsummer_sun"]="500104001350000000002984799984dd29848eba836c0b7f2800",
["autumn_gold"]="500104001350000000435a7817aa7ba3f979a8a981f3c9852800",
["spring_lake"]="5001040013500000004a976d3347736e677561b77a4b07812800",
["winter_mountain"]="5001040013500000002c555c68c55d7c555ef165606136622800",
["midwinter"]="500104001350000000bda5532c554dbd254cd5a4428d94392800",
["amber_bloom"]="500104001350000000739d67f2bc7372ec78a0ab78be8a6f2800",
["lily"]="5001040013500000009cfc76c5ab793d4a6a1a9b586b9c522800",
["painted_sky"]="500104001350000000d1c424c3d63783384c3f7a6a83bd6d2800",
["winter_beauty"]="500104001350000000e2335ea7b4942467952db986a7ab7b2800",
["orange_fields"]="500104001350000000409c69694c79eafa88498a8fb867aa2800",
["forest_adventure"]="50010400135000000023999bbd76b363d4b674d3415fb3222800",
["blue_planet"]="50010400135000000037a7a3a403b489737b2b746e6873362800",
["soho"]="500104001350000000c52c4e220b6eed8a53d404192b04782800",
["vapor_wave"]="500104001350000000e1c32401251acb183ac31b8051ea842800",
["magneto"]="50010400135000000077b3286d9340b9e3662d99943c9b852800",
["tyrell"]="500104001350000000ef4419a898370ea84698353574434e2800",
["disturbia"]="50010400135000000084f371a4845e6998388c3b4f57ce582800",
["hal"]="50010400135000000075f351a6244cf6dc5d480c658cda862800",
["golden_star"]="5001040013500000007a4a8702eb8372ac7892cd61d51e5c2800",
["under_the_tree"]="5001040013500000001de498b9a3cc0c9b8563bb6cc1ae5d2800",
["silent_night"]="5001040013500000009e296a245a6f660a75086b70953b6e2800",
["rosy_sparkle"]="500104001350000000810967c63a6cb2aa5ea7094eddd73c2800",
["festive_fun"]="5001040013500000005a9318de53123e9414fdcc67839d612800",
["colour_burst"]="500104001350000000f2731ff0c6266a6c64246e57d4f98f2800",
["crystalline"]="5001040013500000006ea96a92a85e58074e18543d9cf3332800",}
local function rgb_to_xy(red,green,blue,gamma)
if gamma then
local function correct(value)return value>0.04045 and((value+0.055)/1.055)^ 2.4 or value/12.92 end
red,green,blue=correct(red),correct(green),correct(blue)
end
local x=red*0.664511+green*0.154324+blue*0.162028
local y=red*0.283881+green*0.668433+blue*0.047685
local sum=x+y+red*0.000088+green*0.07231+blue*0.986039
if sum==0 then return 0,0 end
return x/sum,y/sum
end
local function color_to_xy(value,gamma)
if type(value)=="string"and value:match("^#?%x%x%x%x%x%x$")then
local hex=value:gsub("^#","")
return rgb_to_xy(tonumber(hex:sub(1,2),16)/255,tonumber(hex:sub(3,4),16)/255,tonumber(hex:sub(5,6),16)/255,gamma)
end
if type(value)=="string"then value=json.decode(value)end
if type(value)~="table"then return nil end
if value.x~=nil and value.y~=nil then return tonumber(value.x),tonumber(value.y),true end
if value.hex~=nil then return color_to_xy(value.hex,gamma)end
if value.rgb~=nil then
local r,g,b=value.rgb:match("^([^,]+),([^,]+),([^,]+)$")
return rgb_to_xy(tonumber(r)/255,tonumber(g)/255,tonumber(b)/255,gamma)
end
if value.r~=nil and value.g~=nil and value.b~=nil then return rgb_to_xy(value.r/255,value.g/255,value.b/255,gamma)end
for _,format in ipairs({"hsv","hsb","hsl"})do
if value[format]~=nil then
local h,s,third=value[format]:match("^([^,]+),([^,]+),([^,]+)$")
value={h=tonumber(h),s=tonumber(s),[format=="hsl"and"l"or"v"]=tonumber(third)}
break
end
end
if value.hue==nil and value.h==nil and value.saturation==nil and value.s==nil then return nil end
local hue,saturation=tonumber(value.hue or value.h)or 0,tonumber(value.saturation or value.s)or 100
if value.l~=nil then
local lightness=tonumber(value.l)/100
local brightness=lightness+saturation/100*math.min(lightness,1-lightness)
saturation=brightness==0 and 0 or 200*(1-lightness/brightness)
value.v=brightness*100
end
hue,saturation=(hue%360)/60,saturation/100
local brightness=tonumber(value.brightness or value.v or value.b or value.value)or 100
brightness=brightness/100
local sector,fraction=math.floor(hue),hue%1
local low,falling,rising=brightness*(1-saturation),brightness*(1-saturation*fraction),brightness*(1-saturation*(1-fraction))
local rgb=({{brightness,rising,low},{falling,brightness,low},{low,brightness,rising},
{low,falling,brightness},{rising,low,brightness},{brightness,low,falling}})[sector+1]
return rgb_to_xy(rgb[1],rgb[2],rgb[3],gamma)
end
local function xy_to_hex(x,y)
if y==0 then return"#000000"end
local X,Z=x/y,(1-x-y)/y
local red,green,blue=X*1.656492-0.354851-Z*0.255038,
-X*0.707196+1.655397+Z*0.036152,X*0.051713-0.121364+Z*1.01153
local maximum=math.max(red,green,blue,1)
return string.format("#%02x%02x%02x",math.floor(math.max(0,red/maximum)*255+0.5),
math.floor(math.max(0,green/maximum)*255+0.5),math.floor(math.max(0,blue/maximum)*255+0.5))
end
local function publish(device,context,emitter,value)
device:emit_component_event(context.component or{id=context.component_id or"main"},emitter(device,value))
end
local function read_native_state(device,endpoint)
zcl.read_attribute(device,0xFC03,2,endpoint,0x100B)
end
local function receive_native_state(device,value,context)
local flags,position=string.unpack("<I2",value)
if flags&1~=0 then local raw;raw,position=string.unpack("B",value,position);publish(device,context,emit.switch(),raw~=0)end
if flags&2~=0 then local raw;raw,position=string.unpack("B",value,position);publish(device,context,emit.level(),math.floor(raw*100/254+0.5))end
if flags&4~=0 then local raw;raw,position=string.unpack("<I2",value,position);if raw>0 then publish(device,context,emit.color_temperature(),math.floor(1000000/raw+0.5))end end
if flags&8~=0 then
local x,y;x,y,position=string.unpack("<I2I2",value,position)
local hue,saturation=safe_xy_to_hsv(x,y)
publish(device,context,emit.color_hue(),hue);publish(device,context,emit.color_saturation(),saturation)
end
if flags&0x10~=0 then position=position+2 end
if flags&0x20~=0 then
local raw;raw,position=string.unpack("B",value,position)
local effect=raw==0 and"none"or nil
for name,code in pairs(EFFECTS)do if code==raw then effect=name end end
if effect~=nil then device:set_field("philips_flux_effect",effect,{persist=true});publish(device,context,emit.hueFluxEffect(),effect)end
end
if flags&0x100~=0 then
local size,count,style=value:byte(position,position+2)
local colors={}
for index=0,(count>>4)-1 do
local a,b,c=value:byte(position+5+index*3,position+7+index*3)
colors[#colors+1]=xy_to_hex(((b&15)*256+a)/4095*0.7347,(c*16+(b>>4))/4095*0.8264)
end
device:set_field("philips_flux_gradient",colors,{persist=true})
publish(device,context,emit.hueFluxGradient(),json.encode(colors))
local style_name=style==2 and"scattered"or style==4 and"mirrored"or"linear"
device:set_field("philips_flux_style",style_name,{persist=true})
publish(device,context,emit.hueFluxGradientStyle(),style_name)
position=position+size+1
end
if flags&0x80~=0 then
local raw;raw,position=string.unpack("B",value,position)
publish(device,context,emit.hueFluxEffectSpeed(),raw/255)
end
if flags&0x40~=0 then
local scale,offset=value:byte(position,position+1)
if scale<=248 then publish(device,context,emit.hueFluxGradientScale(),scale/8)end
if offset<=248 then publish(device,context,emit.hueFluxGradientOffset(),offset/8)end
end
end
local function gradient_payload(colors,style,transition)
if type(colors)~="table"or #colors<1 or #colors>9 then return nil end
local payload={}
for index=#colors,1,-1 do
if type(colors[index])~="string"or not colors[index]:match("^#?%x%x%x%x%x%x$")then return nil end
local x,y=color_to_xy(colors[index],false)
x,y=math.floor(x*4095/0.7347+0.5),math.floor(y*4095/0.8264+0.5)
payload[#payload+1]=string.char(x&255,((y&15)<<4)|(x>>8),y>>4)
end
if transition~=nil and tonumber(transition)==nil then return nil end
local fade=transition==nil and 4 or math.max(0,math.min(65535,math.floor(tonumber(transition)*10+0.5)))
return string.pack("<I2I2BBBB",0x150,fade,4+#colors*3,#colors<<4,STYLES[style]or 0,0)
.."\0"..table.concat(payload)..string.char(#colors<<3,0)
end
local function send_setting(device,mapping,value,context)
local name,endpoint=mapping.name,device:get_endpoint(0xFC03)
local function native(payload)return zcl.send_raw_cluster_command(device,0xFC03,0,payload,endpoint,nil,0x100B)end
if name=="philips_flux_identify"then return zcl.send_raw_cluster_command(device,3,0,string.pack("<I2",3),device:get_endpoint(3))end
if name=="philips_flux_effect"then
local standard=({blink=0,breathe=1,okay=2,channel_change=11,finish_effect=254,stop_effect=255})[value]
local effect=value
local sent
if value=="none"or value=="stop_hue_effect"or value=="finish_effect"or value=="stop_effect"then
sent,effect=native(string.char(0x20,0,0)),"none"
if standard~=nil then zcl.send_raw_cluster_command(device,3,0x40,string.char(standard,0),device:get_endpoint(3))end
elseif EFFECTS[value]~=nil then
sent=native(string.char(0x21,0,1,EFFECTS[value]))
device.thread:call_with_delay(1,function()read_native_state(device,endpoint)end)
elseif standard~=nil then
local transmitted=zcl.send_raw_cluster_command(device,3,0x40,string.char(standard,0),device:get_endpoint(3))
sent=transmitted
else return false end
if sent~=false then device:set_field("philips_flux_effect",effect,{persist=true});publish(device,context,emit.hueFluxEffect(),effect)end
return sent
end
if name=="philips_flux_effect_speed"then return native(string.char(0x80,0,math.floor(value*255)))end
if name=="philips_flux_gradient_scale"or name=="philips_flux_gradient_offset"then
local scale,offset=name=="philips_flux_gradient_scale"and value or 1,name=="philips_flux_gradient_offset"and value or 0
return native(string.char(0x40,0,math.floor(scale*8+0.5),math.floor(offset*8+0.5)))
end
if name=="philips_flux_effect_color"then
local x,y,literal_xy=color_to_xy(value,true)
if x==nil or y==nil then return false end
if not literal_xy then x,y=math.floor(x*10000+0.5)/10000,math.floor(y*10000+0.5)/10000 end
local active=EFFECTS[device:get_field("philips_flux_effect")]
local payload=string.pack("<I2I2I2",active~=nil and 0x28 or 8,math.floor(math.max(0,math.min(1,x))*65535),math.floor(math.max(0,math.min(1,y))*65535))
if active~=nil then payload=payload ..string.char(active)end
local sent=native(payload)
if active~=nil then device.thread:call_with_delay(1,function()read_native_state(device,endpoint)end)end
return sent
end
if name=="philips_flux_gradient_scene"then
local hex=SCENES[value]
if hex==nil then return false end
return native((hex:gsub("%x%x",function(pair)return string.char(tonumber(pair,16))end)))
end
local colors,transition,style=nil,nil,device:get_field("philips_flux_style")or"linear"
if name=="philips_flux_gradient_style"then
style,colors=value,device:get_field("philips_flux_gradient")
elseif name=="philips_flux_gradient"then
local decoded=json.decode(value)
if type(decoded)~="table"then return false end
colors,transition=decoded.colors or decoded,decoded.transition
else return false end
local payload=gradient_payload(colors,style,transition)
if payload==nil then return false end
local sent=native(payload)
if sent~=false then
device:set_field("philips_flux_gradient",colors,{persist=true})
if name=="philips_flux_gradient_style"then device:set_field("philips_flux_style",style,{persist=true});publish(device,context,emit.hueFluxGradientStyle(),style)end
end
return sent
end
local function send_hue(device,_,value,context)
return zcl.send_raw_cluster_command(device,0x0300,0x40,string.pack("<I2BI2BB",math.floor(value*65535/100+0.5),0,0,0,0),context.endpoint)
end
local function send_color(device,_,value,context)
return zcl.send_raw_cluster_command(device,0x0300,0x43,string.pack("<I2BI2BB",math.floor(value.hue*65535/100+0.5),math.floor(value.saturation*254/100+0.5),0,0,0),context.endpoint)
end
local philips_flux={
profile="lights-philips-flux",
auto_on_before_light_command=false,
placeholder_custom_states=false,
initial_custom_state_query=false,
color_temperature_range={minimum=1000,maximum=20000},
capability_commands={
{capability_id="concertmirror08464.hueFluxStartupColorTemperature",command_name="usePreviousStartupColorTemperature",mapping_name="philips_flux_startup_color_temperature",value="previous"},},
zcl_clusters={
zcl.switch({configure_reporting=false}),
zcl.level({configure_reporting=false,to_device=function(value)local raw=math.floor(value*254/100+0.5);return raw==1 and 2 or raw end}),
zcl.color_temperature({configure_reporting=false,to_device=function(value)return math.max(50,math.min(1000,math.floor(1000000/value+0.5)))end}),
zcl.color_saturation({configure_reporting=false}),
zcl.color_hue({configure_reporting=false,sender=send_hue}),
zcl.color({sender=send_color}),
zcl.cluster_attribute(0x0300,0x4000,{name="philips_flux_enhanced_hue",read_only=true,data_type=data_types.Uint16,emit=emit.color_hue(),from_device=function(value)return math.floor(value*100/65535+0.5)end}),
zcl.cluster_attribute(0xFC03,2,{name="philips_flux_native_state",read_only=true,data_type=data_types.OctetString,mfg_code=0x100B,handler=receive_native_state}),
zcl.cluster_attribute(6,0x4003,{name="philips_flux_power_on_behavior",data_type=data_types.Enum8,emit=emit.hueFluxPowerOnBehavior(),converter={
from=function(value)return({[0]="off",[1]="on",[2]="toggle",[255]="previous"})[value]end,
to=function(value)return({off=0,on=1,toggle=2,previous=255})[value]end,
}}),
zcl.cluster_attribute(0x0300,0x4010,{name="philips_flux_startup_color_temperature",data_type=data_types.Uint16,emit=emit.hueFluxStartupColorTemperature(),
from_device=function(value)if value==65535 then return"previous"elseif value>=50 and value<=1000 then return tostring(value)end end,
to_device=function(value)
if value=="previous"then return 65535 end
local raw=tonumber(value)
if raw~=nil and raw>=50 and raw<=1000 and raw%1==0 then return raw end
end}),
},
configure=function(_,device)
for _,attribute in ipairs({0x400A,0x400B,0x400C})do zcl.read_attribute(device,0x0300,attribute)end
end,
runtime_start=function(device)
device:emit_component_event({id="main"},capabilities.colorTemperature.colorTemperatureRange({value={minimum=1000,maximum=20000},unit="K"}))
return true
end,
parent_refresh=function(device)
for _,item in ipairs({{6,0},{8,0},{6,0x4003},{0x0300,0},{0x0300,1},{0x0300,3},{0x0300,4},{0x0300,7},{0x0300,8},{0x0300,0x4000},{0x0300,0x4010}})do
zcl.read_attribute(device,item[1],item[2])
end
read_native_state(device)
return true
end,
}
for _,mapping in ipairs(zcl.color_xy({}))do philips_flux.zcl_clusters[#philips_flux.zcl_clusters+1]=mapping end
for index,item in ipairs({
{"effect","hueFluxEffect"},{"effect_speed","hueFluxEffectSpeed"},{"effect_color","hueFluxEffectColor"},
{"gradient","hueFluxGradient"},{"gradient_scene","hueFluxGradientScene"},{"gradient_style","hueFluxGradientStyle"},
{"gradient_scale","hueFluxGradientScale"},{"gradient_offset","hueFluxGradientOffset"},{"identify","hueFluxIdentify"},
})do
philips_flux.zcl_clusters[#philips_flux.zcl_clusters+1]=zcl.cluster_attribute(0xFC03,0xFFFF-index,{
name="philips_flux_"..item[1],write_only=true,suppress_optimistic_state=true,sender=send_setting,emit=emit[item[2]](),})
end
register_device_definition(philips_flux,{
device_helpers.create_fingerprint("Signify Netherlands B.V.","929004610603"),})
return{
id="zcl.lights.philips_flux",
registrations=device_definitions,}
