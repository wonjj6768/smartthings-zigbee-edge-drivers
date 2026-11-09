local i,f,u,c,w=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.zigbee.data_types",require"st.zigbee.cluster_base"local k,l=u.definition_registry()local p,G=4925,{[0]="plugged_out","off","plugged_in_charging","plugged_in_paused","plugged_in","stopped"}

local function h(a,o,e)
local g=i.mapping_meta(o)local n=g.to_device and g.to_device(e)or e
if g.data_type==c.SinglePrecisionFloat then
local A=math.floor(math.log(n,2))n=c.SinglePrecisionFloat(0,A,n/2 ^ A-1)else
n=g.data_type(n)end
a:send(w.write_manufacturer_specific_attribute(a,g.cluster_id,g.attribute_id,p,g.data_type,n):to_endpoint(1))return true
end
local function C(e,a)
local v,r,s=e==2,e~=0,os.date("!%Y-%m-%dT%H:%M:%S+00:00",os.time())
local b={f.fhChargeStatus()(a,G[e]),f.fhChargeIsCharging()(a,v and"true"or"false"),f.fhChargeIsPlugConnected()(a,r and"true"or"false")}if v and a:get_field"fh_charge_is_charging"~=true then
b[#b+1]=f.fhChargeChargingStartDatetime()(a,s)b[#b+1]=f.fhChargeChargingEndDatetime()(a,"-")elseif not v and a:get_field"fh_charge_is_charging"==true then
b[#b+1]=f.fhChargeChargingEndDatetime()(a,s)end
if r and a:get_field"fh_charge_is_connected"~=true then
b[#b+1]=f.fhChargeConnectedStartDatetime()(a,s)b[#b+1]=f.fhChargeConnectedEndDatetime()(a,"-")elseif not r and a:get_field"fh_charge_is_connected"==true then
b[#b+1]=f.fhChargeConnectedEndDatetime()(a,s)end
a:set_field("fh_charge_is_charging",v,{persist=true})a:set_field("fh_charge_is_connected",r,{persist=true})return b
end
local function y(a,e,F,o)
local attribute=i.mapping_meta(o).attribute_id
for _,B in ipairs(F.zb_rx.body.zcl_body.attr_records or{})do
local attr=B.attr_id.value
if attr>=61185 and attr<=61188 and B.data then
a:set_field("fh_charge_session_"..attr,B.data.value,{persist=true})end
end
a:set_field("fh_charge_session_"..attribute,e,{persist=true})local b,j,m={},a:get_field("fh_charge_session_".. 61187),a:get_field("fh_charge_session_".. 61188)if j~=nil then b[#b+1]=f.fhChargeEnergyMeterStart()(a,j/1000)end
if m~=nil then b[#b+1]=f.fhChargeEnergyMeterNow()(a,m/1000)end
if j~=nil and m~=nil then
b[#b+1]=f.fhChargeSessionEnergy()(a,(m-j)/1000)end
local x,z=a:get_field("fh_charge_session_".. 61185),a:get_field("fh_charge_session_".. 61186)if x~=nil and z~=nil then
b[#b+1]=f.fhChargeChargingDuration()(a,z-x)end
return b
end
local d={profile="plugs-futurehome-charge",zcl_clusters={i.cluster_attribute(27,61193,{name="fh_charge_status",endpoint=1,mfg_code=p,data_type=c.Uint8,read_only=true,read_on_configure=true,minimum_interval=5,maximum_interval=3600,reportable_change=1,
emit=function(a,e)return C(e,a)end
}),i.cluster_attribute(13,85,{name="fh_charge_setpoint_charging_current",endpoint=1,data_type=c.SinglePrecisionFloat,sender=h,emit=f.fhChargeSetpointChargingCurrent(),read_on_configure=true,minimum_interval=10,maximum_interval=3600,reportable_change=c.SinglePrecisionFloat(0,0,0)}),i.cluster_attribute(13,65,{name="fh_charge_charging_current_limit",endpoint=1,data_type=c.SinglePrecisionFloat,sender=h,emit=f.fhChargeChargingCurrentLimit(),read_on_configure=true}),i.cluster_attribute(27,61196,{name="fh_charge_auto_charge",endpoint=1,mfg_code=p,data_type=c.Uint8,emit=f.fhChargeAutoCharge(),read_on_configure=true,sender=h,
from_device=function(e)return e==1 and"ON"or"OFF"end,
to_device=function(e)return e=="ON"and 1 or 0 end
}),i.cluster_attribute(257,37,{name="fh_charge_plug_locked_permanently",endpoint=1,data_type=c.Enum8,emit=f.fhChargePlugLockedPermanently(),read_on_configure=true,sender=h,
from_device=function(e)return(type(e)=="table"and e.value or e)==2 and"LOCK"or"UNLOCK"end,
to_device=function(e)return e=="LOCK"and 2 or 0 end
}),i.cluster_attribute(257,0,{name="fh_charge_plug_lock_state",endpoint=1,data_type=c.Enum8,read_only=true,read_on_configure=true,emit=f.fhChargePlugLockState(),
from_device=function(e)return(type(e)=="table"and e.value or e)==2 and"unlocked"or"locked"end
}),i.cluster_attribute(257,65535,{name="fh_charge_force_unlock",endpoint=1,write_only=true,suppress_optimistic_state=true,
tx_command_id=1,to_device=function()return string.char(0)end
}),i.cluster_attribute(2820,772,{name="power",endpoint=1,emit=f.power(),data_type=c.Int32,read_only=true,read_on_configure=true,minimum_interval=5,maximum_interval=3600,reportable_change=1}),i.cluster_attribute(1794,0,{name="energy",endpoint=1,emit=f.energy(),data_type=c.Uint48,read_only=true,read_on_configure=true,scale=1000,ignore_reported_scaler=true,minimum_interval=60,maximum_interval=65000,reportable_change=1})},
configure=function(I,a)
for _,E in ipairs{27,13,2820,1794}do
i.bind_cluster(a,E,I.environment_info.hub_zigbee_eui,1)end
end,
parent_refresh=function(a,D)
for _,o in ipairs(D.zcl_clusters)do
local g=i.mapping_meta(o)if not g.write_only and(g.attribute_id<61185 or g.attribute_id==61193 or g.attribute_id==61196)then
if g.cluster_id==13 or g.cluster_id==257 and g.attribute_id==37 then
a:send(w.read_manufacturer_specific_attribute(a,g.cluster_id,g.attribute_id,p):to_endpoint(1))else
i.read_mapping(a,o)end
end
end
end
}for _,item in ipairs{{"start",1},{"stop",2},{"pause",3}}do
d.zcl_clusters[#d.zcl_clusters+1]=i.cluster_attribute(27,65532+item[2],{name="fh_charge_charging_"..item[1],endpoint=1,write_only=true,suppress_optimistic_state=true,
sender=function(a)
i.send_raw_cluster_command(a,27,0,string.char(item[2]),1)i.send_raw_cluster_command(a,27,1,"",1)return true
end
})end
for _,attribute in ipairs{61185,61186,61187,61188}do
d.zcl_clusters[#d.zcl_clusters+1]=i.cluster_attribute(27,attribute,{name="fh_charge_session_"..attribute,endpoint=1,mfg_code=p,data_type=c.Uint32,read_only=true,minimum_interval=(attribute==61185 or attribute==61187)and 60 or 5,maximum_interval=3600,reportable_change=1,emit=y})end
for _,item in ipairs{{1285,"voltage","voltage",f.voltage(),60},{2309,"fh_charge_voltage_phase_b","voltage",f.fhChargeVoltagePhaseB(),60},{2565,"fh_charge_voltage_phase_c","voltage",f.fhChargeVoltagePhaseC(),60},{1288,"current","current",f.current(),10},{2312,"fh_charge_current_phase_b","current",f.fhChargeCurrentPhaseB(),10},{2568,"fh_charge_current_phase_c","current",f.fhChargeCurrentPhaseC(),10}}do
d.zcl_clusters[#d.zcl_clusters+1]=i.cluster_attribute(2820,item[1],{name=item[2],endpoint=1,metering_kind=item[3],emit=item[4],data_type=c.Uint16,read_only=true,read_on_configure=true,minimum_interval=item[5],maximum_interval=65000,physical_reportable_change=item[3]=="current"and 0.05 or nil,reportable_change=item[3]=="voltage"and 1 or nil})end
l(d,{u.create_fingerprint("Futurehome","Charge")})i.attach_reporting_capabilities(k,{{1,"rpt-clr"}})return{id="zcl.plugs.futurehome",registrations=k}
