local z,q,O,aj,C,az,ag=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.capabilities",require"st.zigbee.data_types",require"st.json",require"st.utils.safe_xy_to_hsv"local S,B=O.definition_registry()local T,aD,aC={candle=1,fireplace=2,colorloop=3,sunrise=9,sparkle=10,opal=11,glisten=12,sunset=13,underwater=14,cosmos=15,sunbeam=16,enchant=17},{linear=0,scattered=2,mirrored=4},{blossom="50010400135000000039d553d2955ba5287a9f697e25fb802800",crocus="50010400135000000050389322f97f2b597343764cc664282800",precious="5001040013500000007fa8838bb9789a786d7577499a773f2800",narcissa="500104001350000000b0498a5c0a888fea89eb0b7ee15c742800",beginnings="500104001350000000b3474def153e2ad42e98232c7483292800",first_light="500104001350000000b28b7900e959d3f648a614389723362800",horizon="500104001350000000488b7d6cbb750c6642f1133cc4033c2800",valley_dawn="500104001350000000c1aa7de03a7a8ce861c7c4410d94412800",sunflare="500104001350000000d0aa7d787a7daf197590154d6c14472800",emerald_flutter="5001040013500000006a933977e34bb0d35e916468f246792800",memento="500104001350000000f87318a3e31962331ec3532cceea892800",resplendent="500104001350000000278b6d257a58efe84204273a35f5252800",scarlet_dream="500104001350000000b02c654e4c5b45ab51fb0950d6c84d2800",lovebirds="50010400135000000053ab84ea1a7e35fb7c098c73994c772800",smitten="500104001350000000fe7b70a74b6aa42b65811b60550a592800",glitz_and_glam="500104001350000000cc193cb9b845bad9521d1c77bf6c712800",promise="500104001350000000258b606eca6b28d6382db445df26812800",ruby_romance="5001040013500000000edb63cbcb6bac0c670b2d58204e572800",city_of_love="50010400135000000055830e5cf31b6aa339d2ec70908b802800",honolulu="500104001350000000dbfd59866c6378ec6c45cc765c0a822800",savanna_sunset="50010400135000000005ae65c38c6c6b4b7573ca820fc9832800",golden_pond="5001040013500000007e4a88cc4a8605db8728ec7b666c792800",runy_glow="50010400135000000095bb53ac2a56eb99591e095c54985e2800",tropical_twilight="500104001350000000408523a0b636e777524c0a71a76c6e2800",miami="50010400135000000022ec61e6d94902d83766c3305a43182800",cancun="500104001350000000a7eb54673d55944e6265fd6e26bb842800",rio="500104001350000000a26526088c51a74b58ea6b7137ba892800",chinatown="500104001350000000b33e5b408e59d90d5b4c6c6360ac792800",ibiza="500104001350000000014d6d708c73827b7b6c7a8887f98a2800",osaka="500104001350000000d649510b5c4deb7c5d8b6d6d2b9b802800",tokyo="500104001350000000d1c311665331d3451fd59c4e394c7b2800",motown="50010400135000000055730e5db3156623306c533d7a235c2800",fairfax="50010400135000000072d34a3664477d7a61581d5fc08e5b2800",galaxy="500104001350000000a6cb638b2a4f8cfa549bb9549ff73a2800",starlight="5001040013500000008d897134a9653ec854d2963ed1d4282800",["blood moon"]="500104001350000000202a6987c8599ee647ec632779c3142800",artic_aurora="50010400135000000082548922057511046571c32d5b93192800",moonlight="50010400135000000055730e5e9320c1832e96243ebec7652800",nebula="50010400135000000026c852e106460d653ee745342964142800",sundown="500104001350000000f37c68157c6d8efa755ac5512e24332800",blue_lagoon="50010400135000000088c3623975699ea672a0c8831ada6d2800",palm_beach="5001040013500000005ec4679ba56077f85a80ea64639c6a2800",lake_placid="5001040013500000002eab69239a692d996552c54c39743a2800",mountain_breeze="500104001350000000df843d2355419195465a98674ca97b2800",lake_mist="500104001350000000e3286f39b96859f86266e54ded943f2800",ocean_dawn="5001040013500000005cf9779da97105b96b07485e32564a2800",frosty_dawn="5001040013500000006d6883bca87e3029758ec9722d6a722800",sunday_morning="5001040013500000002c586dc6f87345997c63f983f777892800",emerald_isle="500104001350000000e535628dc57ed2667d8b687d1e2a812800",spring_blossom="500104001350000000a8b75fd0c75826b851a7094d305b652800",midsummer_sun="500104001350000000002984799984dd29848eba836c0b7f2800",autumn_gold="500104001350000000435a7817aa7ba3f979a8a981f3c9852800",spring_lake="5001040013500000004a976d3347736e677561b77a4b07812800",winter_mountain="5001040013500000002c555c68c55d7c555ef165606136622800",midwinter="500104001350000000bda5532c554dbd254cd5a4428d94392800",amber_bloom="500104001350000000739d67f2bc7372ec78a0ab78be8a6f2800",lily="5001040013500000009cfc76c5ab793d4a6a1a9b586b9c522800",painted_sky="500104001350000000d1c424c3d63783384c3f7a6a83bd6d2800",winter_beauty="500104001350000000e2335ea7b4942467952db986a7ab7b2800",orange_fields="500104001350000000409c69694c79eafa88498a8fb867aa2800",forest_adventure="50010400135000000023999bbd76b363d4b674d3415fb3222800",blue_planet="50010400135000000037a7a3a403b489737b2b746e6873362800",soho="500104001350000000c52c4e220b6eed8a53d404192b04782800",vapor_wave="500104001350000000e1c32401251acb183ac31b8051ea842800",magneto="50010400135000000077b3286d9340b9e3662d99943c9b852800",tyrell="500104001350000000ef4419a898370ea84698353574434e2800",disturbia="50010400135000000084f371a4845e6998388c3b4f57ce582800",hal="50010400135000000075f351a6244cf6dc5d480c658cda862800",golden_star="5001040013500000007a4a8702eb8372ac7892cd61d51e5c2800",under_the_tree="5001040013500000001de498b9a3cc0c9b8563bb6cc1ae5d2800",silent_night="5001040013500000009e296a245a6f660a75086b70953b6e2800",rosy_sparkle="500104001350000000810967c63a6cb2aa5ea7094eddd73c2800",festive_fun="5001040013500000005a9318de53123e9414fdcc67839d612800",colour_burst="500104001350000000f2731ff0c6266a6c64246e57d4f98f2800",crystalline="5001040013500000006ea96a92a85e58074e18543d9cf3332800"}
local function L(ah,I,blue,P)
if P then
local function ac(d)return d>0.04045 and((d+0.055)/1.055)^ 2.4 or d/12.92 end
ah,I,blue=ac(ah),ac(I),ac(blue)end
local x,y=ah*0.664511+I*0.154324+blue*0.162028,ah*0.283881+I*0.668433+blue*0.047685

local aG=x+y+ah*0.000088+I*0.07231+blue*0.986039
if aG==0 then return 0,0 end
return x/aG,y/aG
end
local function M(d,P)
if type(d)=="string"and d:match"^#?%x%x%x%x%x%x$"then
local ap=d:gsub("^#","")return L(tonumber(ap:sub(1,2),16)/255,tonumber(ap:sub(3,4),16)/255,tonumber(ap:sub(5,6),16)/255,P)end
if type(d)=="string"then d=az.decode(d)end
if type(d)~="table"then return nil end
if d.x~=nil and d.y~=nil then return tonumber(d.x),tonumber(d.y),true end
if d.hex~=nil then return M(d.hex,P)end
if d.rgb~=nil then
local r,g,b=d.rgb:match"^([^,]+),([^,]+),([^,]+)$"return L(tonumber(r)/255,tonumber(g)/255,tonumber(b)/255,P)end
if d.r~=nil and d.g~=nil and d.b~=nil then return L(d.r/255,d.g/255,d.b/255,P)end
for _,ak in ipairs{"hsv","hsb","hsl"}do
if d[ak]~=nil then
local h,s,aI=d[ak]:match"^([^,]+),([^,]+),([^,]+)$"d={h=tonumber(h),s=tonumber(s),[ak=="hsl"and"l"or"v"]=tonumber(aI)}break
end
end
if d.hue==nil and d.h==nil and d.saturation==nil and d.s==nil then return nil end
local aq,saturation=tonumber(d.hue or d.h)or 0,tonumber(d.saturation or d.s)or 100
if d.l~=nil then
local K=tonumber(d.l)/100
local f=K+saturation/100*math.min(K,1-K)saturation=f==0 and 0 or 200*(1-K/f)d.v=f*100
end
aq,saturation=(aq%360)/60,saturation/100
local f=tonumber(d.brightness or d.v or d.b or d.value)or 100
f=f/100
local aF,al=math.floor(aq),aq%1
local ar,ad,am=f*(1-saturation),f*(1-saturation*al),f*(1-saturation*(1-al))local aE=({{f,am,ar},{ad,f,ar},{ar,f,am},{ar,ad,f},{am,ar,f},{f,ar,ad}})[aF+1]return L(aE[1],aE[2],aE[3],P)
end
local function ay(x,y)
if y==0 then return"#000000"end
local X,Z=x/y,(1-x-y)/y
local ah,I,blue=X*1.656492-0.354851-Z*0.255038,-X*0.707196+1.655397+Z*0.036152,X*0.051713-0.121364+Z*1.01153
local af=math.max(ah,I,blue,1)return string.format("#%02x%02x%02x",math.floor(math.max(0,ah/af)*255+0.5),math.floor(math.max(0,I/af)*255+0.5),math.floor(math.max(0,blue/af)*255+0.5))
end
local function m(e,i,aB,d)
e:emit_component_event(i.component or{id=i.component_id or"main"},aB(e,d))
end
local function w(e,G)
z.read_attribute(e,64515,2,G,4107)
end
local function Q(e,d,i)
local D,position=string.unpack("<I2",d)if D&1~=0 then local p;p,position=string.unpack("B",d,position);m(e,i,q.switch(),p~=0)end
if D&2~=0 then local p;p,position=string.unpack("B",d,position);m(e,i,q.level(),math.floor(p*100/254+0.5))end
if D&4~=0 then local p;p,position=string.unpack("<I2",d,position);if p>0 then m(e,i,q.color_temperature(),math.floor(1000000/p+0.5))end end
if D&8~=0 then
local x,y;x,y,position=string.unpack("<I2I2",d,position)local aq,saturation=ag(x,y)m(e,i,q.color_hue(),aq);m(e,i,q.color_saturation(),saturation)end
if D&16~=0 then position=position+2 end
if D&32~=0 then
local p;p,position=string.unpack("B",d,position)local effect=p==0 and"none"or nil
for name,aJ in pairs(T)do if aJ==p then effect=name end end
if effect~=nil then e:set_field("philips_flux_effect",effect,{persist=true});m(e,i,q.hueFluxEffect(),effect)end
end
if D&256~=0 then
local aM,aH,E=d:byte(position,position+2)local colors={}for J=0,(aH>>4)-1 do
local a,b,c=d:byte(position+5+J*3,position+7+J*3)colors[#colors+1]=ay(((b&15)*256+a)/4095*0.7347,(c*16+(b>>4))/4095*0.8264)end
e:set_field("philips_flux_gradient",colors,{persist=true})m(e,i,q.hueFluxGradient(),az.encode(colors))local ab=E==2 and"scattered"or E==4 and"mirrored"or"linear"e:set_field("philips_flux_style",ab,{persist=true})m(e,i,q.hueFluxGradientStyle(),ab)position=position+aM+1
end
if D&128~=0 then
local p;p,position=string.unpack("B",d,position)m(e,i,q.hueFluxEffectSpeed(),p/255)end
if D&64~=0 then
local ai,aa=d:byte(position,position+1)if ai<=248 then m(e,i,q.hueFluxGradientScale(),ai/8)end
if aa<=248 then m(e,i,q.hueFluxGradientOffset(),aa/8)end
end
end
local function W(colors,E,transition)
if type(colors)~="table"or #colors<1 or #colors>9 then return nil end
local n={}for J=#colors,1,-1 do
if type(colors[J])~="string"or not colors[J]:match"^#?%x%x%x%x%x%x$"then return nil end
local x,y=M(colors[J],false)x,y=math.floor(x*4095/0.7347+0.5),math.floor(y*4095/0.8264+0.5)n[#n+1]=string.char(x&255,((y&15)<<4)|(x>>8),y>>4)end
if transition~=nil and tonumber(transition)==nil then return nil end
local aK=transition==nil and 4 or math.max(0,math.min(65535,math.floor(tonumber(transition)*10+0.5)))return string.pack("<I2I2BBBB",336,aK,4+#colors*3,#colors<<4,aD[E]or 0,0).."\0"..table.concat(n)..string.char(#colors<<3,0)
end
local function an(e,ae,d,i)
local name,G=ae.name,e:get_endpoint(64515)
local function H(n)return z.send_raw_cluster_command(e,64515,0,n,G,nil,4107)end
if name=="philips_flux_identify"then return z.send_raw_cluster_command(e,3,0,string.pack("<I2",3),e:get_endpoint(3))end
if name=="philips_flux_effect"then
local R,effect=({blink=0,breathe=1,okay=2,channel_change=11,finish_effect=254,stop_effect=255})[d],d
local N
if d=="none"or d=="stop_hue_effect"or d=="finish_effect"or d=="stop_effect"then
N,effect=H(string.char(32,0,0)),"none"if R~=nil then z.send_raw_cluster_command(e,3,64,string.char(R,0),e:get_endpoint(3))end
elseif T[d]~=nil then
N=H(string.char(33,0,1,T[d]))
e.thread:call_with_delay(1,function()w(e,G)end)
elseif R~=nil then
local ao=z.send_raw_cluster_command(e,3,64,string.char(R,0),e:get_endpoint(3))N=ao
else return false end
if N~=false then e:set_field("philips_flux_effect",effect,{persist=true});m(e,i,q.hueFluxEffect(),effect)end
return N
end
if name=="philips_flux_effect_speed"then return H(string.char(128,0,math.floor(d*255)))end
if name=="philips_flux_gradient_scale"or name=="philips_flux_gradient_offset"then
local ai,aa=name=="philips_flux_gradient_scale"and d or 1,name=="philips_flux_gradient_offset"and d or 0
return H(string.char(64,0,math.floor(ai*8+0.5),math.floor(aa*8+0.5)))end
if name=="philips_flux_effect_color"then
local x,y,at=M(d,true)if x==nil or y==nil then return false end
if not at then x,y=math.floor(x*10000+0.5)/10000,math.floor(y*10000+0.5)/10000 end
local Y=T[e:get_field"philips_flux_effect"]local n=string.pack("<I2I2I2",Y~=nil and 40 or 8,math.floor(math.max(0,math.min(1,x))*65535),math.floor(math.max(0,math.min(1,y))*65535))if Y~=nil then n=n ..string.char(Y)end
local N=H(n)
if Y~=nil then e.thread:call_with_delay(1,function()w(e,G)end)end
return N
end
if name=="philips_flux_gradient_scene"then
local ap=aC[d]if ap==nil then return false end
return H((ap:gsub("%x%x",function(aL)return string.char(tonumber(aL,16))end)))
end
local colors,transition,E=nil,nil,e:get_field"philips_flux_style"or"linear"if name=="philips_flux_gradient_style"then
E,colors=d,e:get_field"philips_flux_gradient"elseif name=="philips_flux_gradient"then
local U=az.decode(d)if type(U)~="table"then return false end
colors,transition=U.colors or U,U.transition
else return false end
local n=W(colors,E,transition)if n==nil then return false end
local N=H(n)if N~=false then
e:set_field("philips_flux_gradient",colors,{persist=true})if name=="philips_flux_gradient_style"then e:set_field("philips_flux_style",E,{persist=true});m(e,i,q.hueFluxGradientStyle(),E)end
end
return N
end
local function aA(e,_,d,i)
return z.send_raw_cluster_command(e,768,64,string.pack("<I2BI2BB",math.floor(d*65535/100+0.5),0,0,0,0),i.endpoint)
end
local function au(e,_,d,i)
return z.send_raw_cluster_command(e,768,67,string.pack("<I2BI2BB",math.floor(d.hue*65535/100+0.5),math.floor(d.saturation*254/100+0.5),0,0,0),i.endpoint)
end
local t={profile="lights-philips-flux",auto_on_before_light_command=false,initial_custom_state_query=false,color_temperature_range={minimum=1000,maximum=20000},capability_commands={{capability_id="concertmirror08464.hueFluxStartupColorTemperature",command_name="usePreviousStartupColorTemperature",mapping_name="philips_flux_startup_color_temperature",value="previous"}},zcl_clusters={z.switch{configure_reporting=false},
z.level{configure_reporting=false,to_device=function(d)local p=math.floor(d*254/100+0.5);return p==1 and 2 or p end},
z.color_temperature{configure_reporting=false,to_device=function(d)return math.max(50,math.min(1000,math.floor(1000000/d+0.5)))end},
z.color_saturation{configure_reporting=false},z.color_hue{configure_reporting=false,sender=aA},z.color{sender=au},
z.cluster_attribute(768,16384,{name="philips_flux_enhanced_hue",read_only=true,data_type=C.Uint16,emit=q.color_hue(),from_device=function(d)return math.floor(d*100/65535+0.5)end}),
z.cluster_attribute(64515,2,{name="philips_flux_native_state",read_only=true,data_type=C.OctetString,mfg_code=4107,handler=Q}),z.cluster_attribute(6,16387,{name="philips_flux_power_on_behavior",data_type=C.Enum8,emit=q.hueFluxPowerOnBehavior(),converter={
from=function(d)return({[0]="off",[1]="on",[2]="toggle",[255]="previous"})[d]end,
to=function(d)return({off=0,on=1,toggle=2,previous=255})[d]end
}}),z.cluster_attribute(768,16400,{name="philips_flux_startup_color_temperature",data_type=C.Uint16,emit=q.hueFluxStartupColorTemperature(),
from_device=function(d)if d==65535 then return"previous"elseif d>=50 and d<=1000 then return tostring(d)end end,
to_device=function(d)
if d=="previous"then return 65535 end
local p=tonumber(d)if p~=nil and p>=50 and p<=1000 and p%1==0 then return p end
end})
},
configure=function(_,e)
for _,ax in ipairs{16394,16395,16396}do z.read_attribute(e,768,ax)end
end,
runtime_start=function(e)
e:emit_component_event({id="main"},aj.colorTemperature.colorTemperatureRange{value={minimum=1000,maximum=20000},unit="K"})return true
end,
parent_refresh=function(e)
for _,item in ipairs{{6,0},{8,0},{6,16387},{768,0},{768,1},{768,3},{768,4},{768,7},{768,8},{768,16384},{768,16400}}do
z.read_attribute(e,item[1],item[2])end
w(e)return true
end
}for _,ae in ipairs(z.color_xy{})do t.zcl_clusters[#t.zcl_clusters+1]=ae end
for J,item in ipairs{{"effect","hueFluxEffect"},{"effect_speed","hueFluxEffectSpeed"},{"effect_color","hueFluxEffectColor"},{"gradient","hueFluxGradient"},{"gradient_scene","hueFluxGradientScene"},{"gradient_style","hueFluxGradientStyle"},{"gradient_scale","hueFluxGradientScale"},{"gradient_offset","hueFluxGradientOffset"},{"identify","hueFluxIdentify"}}do
t.zcl_clusters[#t.zcl_clusters+1]=z.cluster_attribute(64515,65535-J,{name="philips_flux_"..item[1],write_only=true,suppress_optimistic_state=true,sender=an,emit=q[item[2]]()})end
B(t,{O.create_fingerprint("Signify Netherlands B.V.","929004610603")})return{id="zcl.lights.philips_flux",registrations=S}
