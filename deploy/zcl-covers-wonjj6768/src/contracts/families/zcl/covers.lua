local f,b=require"protocol.zcl",require"contracts.helpers.family"local h,a=b.definition_registry()
local function d()
return{
from=function(g)
if type(g)~="number"then
return g
end
return 100-math.max(0,math.min(100,g))
end,
to=function(g)
if type(g)~="number"then
return g
end
return 100-math.max(0,math.min(100,g))
end
}
end
local function c()
return{
from=function(g)
if type(g)~="number"then
return g
end
if g<=0 then
return"open"end
if g>=100 then
return"closed"end
return"partially open"
end
}
end
local i,k,e={profile="covers-cover",zcl_clusters={f.tuya_magic_packet(),f.cover_position(),f.window_shade_state(),f.cover_state()}},{profile="covers-cover-2",zcl_clusters={f.tuya_magic_packet(),f.cover_position{endpoint=1,component="main"},f.window_shade_state{endpoint=1,component="main"},f.cover_state{endpoint=1,component="main"},f.cover_position{endpoint=2,component="shade2"},f.window_shade_state{endpoint=2,component="shade2"},f.cover_state{endpoint=2,component="shade2"}}},{profile="covers-cover-battery",zcl_clusters={f.cover_position{converter=d()},f.window_shade_state{converter=c()},f.cover_state(),f.battery()}}a(i,b.create_fingerprints("TS130F",{"_TZ3000_bs93npae","_TZ3000_dojqjapa","_TZ3000_8h7wgocw","_TZ3000_e3vhyirx","_TZ3000_femsaaua","_TZ3000_5iixzdo7","_TZ3000_yruungrl","_TZ3000_jwv3cwak","_TZ3000_74hsp7qy","_TZ3210_dwytrmda","_TZ3210_jrhczaaa","_TZ3000_vw8pawxa","_TZ3210_xbpt8ewc","_TZ3000_egq7y6pr","_TZ3000_fccpjz5z","_TZ3000_vd43bbfq","_TZ3000_zirycpws","_TZ3210_ol1uhvza"}))a(i,{b.create_fingerprint("Aqara","lumi.curtain.acn04"),b.create_fingerprint("LUMI","lumi.curtain.acn04"),b.create_fingerprint("LUMI","lumi.curtain.acn018")})a(i,b.create_fingerprints("TS130F",{"_TZ3000_1dd0d5yi"}))a(k,b.create_fingerprints("TS130F",{"_TZ3000_bmhwnl7s","_TZ3000_esynmmox","_TZ3000_j1xl73iw","_TZ3000_kmsbwdol","_TZ3000_l6iqph4f","_TZ3000_wvedmwyp","_TZ3000_xdo0hj1k"}))a(e,b.create_fingerprints("TS0301",{"_TZE200_9caxna4s"}))a(e,b.create_fingerprints("TS030F",{"_TZB000_42ha4rsc"}))a(e,{b.create_fingerprint("IKEA of Sweden","FYRTUR block-out roller blind"),b.create_fingerprint("IKEA of Sweden","KADRILJ roller blind"),b.create_fingerprint("IKEA of Sweden","PRAKTLYSING cellular blind"),b.create_fingerprint("IKEA of Sweden","TREDANSEN block-out cellul blind")})local l,j={profile="covers-cover",zcl_clusters={f.cover_position(),f.window_shade_state(),f.cover_state()}},{profile="covers-cover-battery",zcl_clusters={f.cover_position{converter=d()},f.window_shade_state{converter=c()},f.cover_state(),f.battery()}}a({profile="covers-cover-battery",zcl_clusters={f.cover_position(),f.window_shade_state(),f.cover_state(),f.battery()}},{b.create_fingerprint("eWeLink","AM25C-1-25-ES-E-Z"),b.create_fingerprint("eWeLink","CK-MG22-Z310EE07DOOYA-01(7015)"),b.create_fingerprint("eWeLink","MYDY25Z-1"),b.create_fingerprint("eWeLink","ZM25-EAZ")})a(l,{b.create_fingerprint("Sunricher","HK-ZCC-A")})a(j,{b.create_fingerprint("Third Reality, Inc","TRZB3")})a(j,{b.create_fingerprint("Third Reality, Inc","3RSB015BZ"),b.create_fingerprint("Third Reality, Inc","3RSB02015Z")})f.attach_reporting_capabilities(h,{{1,"rpt-tci"},{2,"rpt-tci"},{3,"rpt-tci"},{4,"rpt-tuv",{zr010200081="Position",zr010200082="PositionTwo"}},{5,"rpt-txq"},{6,"rpt-txq"},{7,"rpt-txq"},{8,"rpt-txq"},{9,"rpt-tci"},{10,"rpt-txq"},{11,"rpt-txq"}})return{id="zcl.covers",registrations=h}
