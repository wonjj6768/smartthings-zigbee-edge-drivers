local o,b,B,y=require"protocol.zcl",require"contracts.helpers.family",require"capabilities.events.all",require"st.capabilities"local n,a=b.definition_registry()
local function h(t)
if type(t)~="number"then
return t
end
local r=math.floor((((t-2.0)/1.0)*100)+0.5)if r<0 then
return 0
end
if r>100 then
return 100
end
return r
end
local function k()
return{o.cluster_attribute(o.CLUSTER_POWER_CONFIGURATION,o.ATTR_BATTERY_PERCENTAGE_REMAINING,{name="battery",endpoint=1,emit=B.battery(),scale=2}),o.cluster_attribute(o.CLUSTER_POWER_CONFIGURATION,o.ATTR_BATTERY_VOLTAGE,{name="battery",endpoint=1,emit=B.battery(),scale=10,from_device=h})}
end
local function g()
return o.cluster_attribute(o.CLUSTER_POWER_CONFIGURATION,o.ATTR_BATTERY_VOLTAGE,{name="battery_voltage",endpoint=1,emit=B.voltage(),scale=10})
end
local function c(s,q)
local j=k()local d={profile=s,button_actions={"pushed","double","held"},zcl_clusters={o.tuya_magic_packet(),j[1],j[2]}}if q==true then
d.zcl_clusters[#d.zcl_clusters+1]=g()end
return d
end
local m,p,e,z,A,l,D,E=c"buttons-button-1-battery",c("buttons-button-1-battery-voltage",true),c("buttons-button-1-battery-voltage",true),c"buttons-button-2-battery",c"buttons-button-3-battery",c("buttons-button-4-battery-voltage",true),c"buttons-button-5-battery",c"buttons-button-6-battery"e.button_actions={"pushed","double"}a(m,b.create_fingerprints("TS0041",{"_TZ3000_mrpevh8p","_TZ3000_5bpeda8u","_TZ3000_b4awzgct","_TZ3000_qgwcxxws","_TZ3000_6km7djcm","_TZ3000_4upl1fcj","_TZ3000_filhl5b7","_TZ3000_yj6k7vfo"}))a(m,b.create_fingerprints("TS0041",{"_TZ3000_rsqqkdxv","_TZ3000_22ugzkme","_TZ3000_kxaow5ki","_TZ3000_adndolvx","_TZ3000_piyhhake","_TZ3400_keyjqthh","_TZ3000_an5rjiwd","_TZ3400_tk3s5tyg","_TZ3000_tk3s5tyg","_TZ3000_xrqsdxq6","_TZ3000_peszejy7","_TZ3000_vn88ezar","_TZ3000_kccru4oi"}))a(p,b.create_fingerprints("TS0041A",{"_TYZB01_4qw4rl1u","_TYZB01_1xktopx6"}))a(m,b.create_fingerprints("TS0041A",{"_TYZB01_ub7urdza"}))a(m,b.create_fingerprints("TS004F",{"_TZ3000_krwtzhfd"}))a(e,b.create_fingerprints("TS0041",{"_TZ3000_fa9mlvja"}))a(z,b.create_fingerprints("TS0042",{"_TZ3000_dfgbtub0","_TZ3000_cllghx1k"}))a(z,b.create_fingerprints("TS0042",{"_TZ3000_kt7obmnn","_TZ3000_adkvzooy","_TZ3000_fkvaniuu","_TZ3000_t8hzpgnd","_TZ3000_tzvbimpq","_TZ3000_i3rjdrwu","_TYZB02_keyjhapk","_TZ3400_keyjhapk","_TZ3000_h1c2eamp","_TZ3000_owgcnkrh","_TZ3000_v8jvcwsx","_TZ3000_xr7itfxq","_TZ3000_1yyjhvwd"}))a(A,b.create_fingerprints("TS0043",{"_TZ3000_1kmurvlx","_TZ3000_9zc1limb"}))a(A,b.create_fingerprints("TS0043",{"_TZ3000_vm5gcsdq","_TZ3000_mutfmn4u","_TZ3000_ngsph3oj","_TZ3000_famkxci2","_TYZB02_key8kk7r","_TZ3000_w8jwkczz","_TZ3400_key8kk7r","_TZ3000_qzjcsmar","_TZ3000_bi6lpsew","_TZ3000_imnwsek2","_TZ3000_rrjr1q0u","_TZ3000_w4thianr","_TZ3000_a7ouggvs","_TZ3000_yw5tvzsk","_TZ3000_7uglqmvv"}))a(l,b.create_fingerprints("TS0044",{"_TZ3000_a4xycprs","_TZ3000_dziaict4","_TZ3000_j61x9rxn","_TZ3000_mh9px7cq","_TZ3000_5tqxpine","_TZ3000_u3nv1jwk","_TZ3000_bgtzm4ny","_TZ3000_kfu8zapd","_TZ3000_ee8nrt2l","_TZ3000_xwuveizv"}))a(l,b.create_fingerprints("TS0044",{"_TZ3000_g7eeean4","_TZ3000_j70oanab","_TZ3000_zgyzgdua","_TZ3000_9orwkl3t","_TZ3000_pd9mpyh4","_TZ3000_wbfgbpxq","_TZ3000_ufhtxr59","_TZ3000_wkai4ga5","_TZ3000_abci1hiu","_TZ3000_vp6clf9d","_TZ3000_dku2cfsc","_TYZB01_cnlmkhbk","_TZ3000_uaa99arv","_TZ3000_laeia8fo","_TZ3000_1hypixdr"}))a(D,b.create_fingerprints("TS0045",{"_TZ3000_qfhhb5y4"}))a(E,b.create_fingerprints("TS0046",{"_TZ3000_iszegwpd","_TZ3000_nrfkrgf4"}))
local function f(s,x)
local d=c(s)d.zcl_clusters[2]=o.cluster_attribute(1,33,{name="battery",endpoint=1,read_only=true,read_on_configure=false,emit=B.battery(),
from_device=function(i)
i=type(i)=="table"and i.value or i
if i<255 then return math.floor(i/2+0.5)end
end
})d.zcl_clusters[3]=nil
d.datapoints={}for button=1,x do
d.datapoints[#d.datapoints+1]={dp=button,datatype=2,receive_datatypes={2,4},read_only=true,name="moes_button_"..button,component=button==1 and"main"or"button"..button,
from_device=function(i)return({[0]="pushed",[1]="double",[2]="held"})[i]end,
emit=function(_,i)return y.button.button(i,{state_change=true})end
}end
return d
end
local u,v,w=f("buttons-button-1-battery",1),f("buttons-button-2-battery",2),f("buttons-button-3-battery",3)a(u,b.create_fingerprints("TS0041",{"_TZ3000_axpdxqgu"}))a(v,b.create_fingerprints("TS0042",{"_TZ3000_5e235jpa"}))a(w,b.create_fingerprints("TS0043",{"_TZ3000_gbm10jnj","_TZ3000_sj7jbgks"}))return{id="zcl.controls.remotes",registrations=n}
