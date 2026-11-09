local F,h,t,B=require"st.capabilities",require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family"local e=h.converter
local G,x=B.definition_registry()
local function k(b,ab,aa)
if b<ab then return ab end
if b>aa then return aa end
return b
end
local function r(b)
return math.floor(b+0.5)
end
local function S(b)
local ad={}for W=1,#b,2 do
ad[#ad+1]=string.char(tonumber(b:sub(W,W+1),16))end
return table.concat(ad)
end
local ag,af,N,y,E={ice_land_blue="01150a5252e000006400c16100b43000b55200c463",glacier_express="01160a64646000006400925f00c660",sea_of_clouds="0117035e5e6000006400382f001e5c00d545011a64",fireworks_at_sea="0118026464e000006400b239010a64012d64013f64",firefly_night="011a034b4be000006400e039010953",grass_land="011c0a5a5ae0000052009d64008e64",northern_lights="011d035252e000006400ae6400a66400c16400cc64",late_autumn="011e0a5252e000006400196400225e002c5b001464000c64",game="011f025f5f6000006401106400d26400ad64008b64",holiday="01200a55556000006400c258013e3300ff46011d64",party="01220464646000006400d75c00bc5300371e002c3f01613f",trend="01230264646000006401084b00b12f00cd57",meditation="01250343436000006400b735009b5400cd61",dating="0126015959e000006401194701493d00cd61002664",valentines_day="012a01646460000064011564010564014564012f64",neon_world="01370a5a5a6000006400335800186401004500e35e00ac30"},{rock="0101000364320100006400006400786400f064003c6400b464012c64000000",jazz="0101000264320100006400005000785000f050003c5000b450012c50000000",classic="0101001264320100006400006400786400f064003c6400b464012c64000000",rolling="0101011264320100006400006400786400f064003c6400b464012c64000000",energy="0101021264320100006400006400786400f064003c6400b464012c64000000",spectrum="0101031264320100006400006400786400f064003c6400b464012c64000000"},{},{},{}for H,ao in pairs(ag)do
local Q=S(ao)N[H]=Q
E[Q]=H
end
for H,ao in pairs(af)do y[H]=S(ao)end
local s,j,o,d="gl_spi_music_mode","gl_spi_music_sensitivity","gl_spi_hue","gl_spi_saturation"
local function f(a,ae,T,P,ak)
local b=type(a.get_field)=="function"and a:get_field(ae)or nil
if b==nil and type(a.get_latest_state)=="function"then
b=a:get_latest_state("main",T,P)end
if b==nil then return ak end
return b
end
local function i(a,ae,b)
if type(a.set_field)=="function"then
a:set_field(ae,b,{persist=false})end
return b
end
local function V(b,a)
if type(b)~="string"or #b<4 then return nil end
for H,Q in pairs(y)do
if b:sub(1,4)==Q:sub(1,4)then return i(a,s,H)end
end
return nil
end
local function R(b)
return type(b)=="string"and E[b]or nil
end
local function p(a,D)
local m,aj={{dp=1,datatype=h.DP_TYPE_BOOL,value=true}},f(a,"gl_spi_work_mode","concertmirror08464.glSpiWorkMode","workMode",nil)if aj~=D then
m[#m+1]={dp=2,datatype=h.DP_TYPE_ENUM,value=({white=0,colour=1,scene=2,music=3})[D]}i(a,"gl_spi_work_mode",D)end
return m
end
local function u(a,w,g)
if type(a.emit_event)~="function"then return end
a:emit_event(F.colorControl.hue(k(r(w),0,100)))a:emit_event(F.colorControl.saturation(k(r(g),0,100)))
end
local function U(a,X,n,q)
local w,g=k(tonumber(X)or 0,0,100),k(tonumber(n)or 0,0,100)i(a,o,w)i(a,d,g)u(a,w,g)local Z,C,A=r(w*3.6)%360,k(r(g*10),0,1000),k(r(10+q*990/100),10,1000)
return string.char(0,1,1,20,0,math.floor(Z/256),Z%256,math.floor(C/256),C%256,math.floor(A/256),A%256)
end
local function l(a,b,q)
local m,I=p(a,"white"),k(r(tonumber(b)or 0),0,1000)i(a,"gl_spi_color_temp_raw",I)q=q or f(a,"gl_spi_brightness","switchLevel","level",100)m[#m+1]={dp=4,datatype=h.DP_TYPE_VALUE,value=I}m[#m+1]={dp=3,datatype=h.DP_TYPE_VALUE,value=k(r(10+q*990/100),10,1000)}i(a,"gl_spi_brightness",q)return m
end
local function v(a,b)
if type(b)~="table"then return nil end
local X,n=b.hue,b.saturation

if X==nil or n==nil then return nil end
if tonumber(n)==0 and not b.keep_colour then
local ac=l(a,f(a,"gl_spi_color_temp_raw","concertmirror08464.glSpiColorTempRaw","colorTempRaw",500))if ac==nil then return nil end
i(a,o,k(tonumber(X)or 0,0,100))i(a,d,0)u(a,f(a,o,"colorControl","hue",0),0)return ac
end
local m,q=p(a,"colour"),b.level or f(a,"gl_spi_brightness","switchLevel","level",100)m[#m+1]={dp=61,datatype=h.DP_TYPE_RAW,value=U(a,X,n,q)}i(a,"gl_spi_brightness",q)return m
end
local function L(a,b)
local q,D=k(tonumber(b)or 0,0,100),f(a,"gl_spi_work_mode","concertmirror08464.glSpiWorkMode","workMode","colour")if D=="white"then
return l(a,f(a,"gl_spi_color_temp_raw","concertmirror08464.glSpiColorTempRaw","colorTempRaw",0),q)end
return v(a,{hue=f(a,o,"colorControl","hue",0),saturation=f(a,d,"colorControl","saturation",100),level=q,keep_colour=true})
end
local function ah(a,b)
return v(a,{hue=b,saturation=f(a,d,"colorControl","saturation",100)})
end
local function M(a,b)
return v(a,{hue=f(a,o,"colorControl","hue",0),saturation=b})
end
local function K(a,H,b)
local D,c=f(a,s,"concertmirror08464.glSpiMusicMode","musicMode","rock"),tonumber(f(a,j,"concertmirror08464.glSpiMusicSensitivity","musicSensitivity",50))or 50
if H=="gl_spi_music_mode"then D=b else c=tonumber(b)or c end
local base=y[D]if base==nil then return nil end
c=k(r(c),1,100)i(a,s,D)i(a,j,c)local Q,m,J=base:sub(1,5)..string.char(c)..base:sub(7),p(a,"music"),f(a,"switch","switch","switch",nil)for W,al in ipairs(m)do
if W~=1 or(J~="on"and J~=true)then
if h.send_datapoint(a,al.dp,al.datatype,al.value)==nil then return nil end
end
end
return{dp=52,datatype=h.DP_TYPE_RAW,value=Q}
end
local function z(b,ai)
if type(b)~="string"or #b<11 or b:byte(2)==0 then return nil end
return b:byte(ai)*256+b:byte(ai+1)
end
local O,Y={RGB=0,RBG=1,GRB=2,GBR=3,BRG=4,BGR=5,RGBW=6,RBGW=7,GRBW=8,GBRW=9,BRGW=10,BGRW=11,WRGB=12,WRBG=13,WGRB=14,WGBR=15,WBRG=16,WBGR=17},{WS2801=0,LPD6803=1,LPD8803=2,WS2811=3,TM1814B=4,TM1934A=5,SK6812=6,SK9822=7,UCS8904B=8,WS2805=9}local an={profile="lights-wave15-gledopto-gl-spi-206p",package_group="pixel-light",magic_packet=true,query_on_configure=false,time_start="off",auto_on_before_light_command=false,datapoints={h.dp_on_off(1,{name="switch",transaction=1,emit=t.switch()}),h.dp_enum(2,{name="gl_spi_work_mode",field="gl_spi_work_mode",transaction=1,converter=e.lookup_from_to{white=0,colour=1,scene=2,music=3},
to_device=function(b,a)
i(a,"gl_spi_work_mode",b)return({white=0,colour=1,scene=2,music=3})[b]
end,
emit=t.glSpiWorkMode()}),h.dp_numeric(3,{name="brightness",read_only=true,transaction=1,
converter=e.from_only(function(b,a)
if f(a,"gl_spi_work_mode","concertmirror08464.glSpiWorkMode","workMode",nil)~="white"then return nil end
return i(a,"gl_spi_brightness",k(r((b-10)*100/990),0,100))
end),
emit=t.level()}),h.dp_raw(61,{
name="paint_hue",read_only=true,transaction=1,converter=e.from_only(function(b,a)
local I=z(b,6)if I then return i(a,o,k(r(I/3.6),0,100))end
end),emit=t.color_hue()
}),h.dp_raw(61,{
name="paint_saturation",read_only=true,transaction=1,converter=e.from_only(function(b,a)
local I=z(b,8)if I then return i(a,d,k(r(I/10),0,100))end
end),emit=t.color_saturation()
}),h.dp_raw(61,{
name="paint_brightness",read_only=true,transaction=1,converter=e.from_only(function(b,a)
local I=z(b,10)if I then
i(a,"gl_spi_work_mode","colour")return i(a,"gl_spi_brightness",k(r((I-10)*100/990),0,100))end
end),emit=t.level()
}),h.dp_numeric(4,{name="gl_spi_color_temp_raw",field="gl_spi_color_temp_raw",transaction=1,emit=t.glSpiColorTempRaw()}),h.dp_numeric(7,{name="gl_spi_countdown",transaction=1,emit=t.glSpiCountdown()}),h.dp_raw(51,{name="gl_spi_scene",transaction=1,
converter=e.from_to(R,function(b)return N[b]end),
emit=t.glSpiScene()}),h.dp_raw(52,{name="gl_spi_music_mode",transaction=1,
converter=e.from_to(V,function(b)return y[b]end),
emit=t.glSpiMusicMode()}),h.dp_raw(52,{name="gl_spi_music_sensitivity",read_only=true,transaction=1,
converter=e.from_only(function(b,a)
if type(b)~="string"or #b<6 then return nil end
local c=b:byte(6)if c>=1 and c<=100 then
return i(a,j,c)end
end),
emit=t.glSpiMusicSensitivity()}),h.dp_numeric(53,{name="gl_spi_pixel_count",transaction=1,emit=t.glSpiPixelCount()}),h.dp_enum(101,{name="gl_spi_bead_sequence",transaction=1,converter=e.lookup_from_to(O),emit=t.glSpiBeadSequence()}),h.dp_enum(102,{name="gl_spi_chip_type",transaction=1,converter=e.lookup_from_to(Y),emit=t.glSpiChipType()}),h.dp_binary(103,{name="gl_spi_do_not_disturb",transaction=1,converter=e.lookup_from_to{ON=true,OFF=false},emit=t.glSpiDoNotDisturb()})},named_mapping={named_mappings={brightness=L,color=v,color_hue=ah,color_saturation=M,
gl_spi_color_temp_raw=function(a,b)return l(a,b)end,
gl_spi_music_mode=function(a,b)return K(a,"gl_spi_music_mode",b)end,
gl_spi_music_sensitivity=function(a,b)return K(a,"gl_spi_music_sensitivity",b)end
}},
runtime_start=function(a)
if type(a.get_latest_state)=="function"then
local X,n=a:get_latest_state("main","colorControl","hue"),a:get_latest_state("main","colorControl","saturation")if X==nil or n==nil then
u(a,f(a,o,"colorControl","hue",0),f(a,d,"colorControl","saturation",100))end
end
return true
end
}x(an,B.create_fingerprints("TS0601",{"_TZE204_8fffc3kb","_TZE284_gt5al3bl","_TZE28C1000000_gt5al3bl"}))return{id="ef00.lights.wave15_gledopto",registrations=G}
