local a,H={},{"A","kWh","V","UNLOCK","true","false","fhChargeSetpointChargingCurrent","fhChargeChargingCurrentLimit","fhChargeSessionEnergy","fhChargeEnergyMeterStart","fhChargeEnergyMeterNow","fhChargeChargingDuration","fhChargeVoltagePhaseB","fhChargeVoltagePhaseC","fhChargeCurrentPhaseB","fhChargeCurrentPhaseC","fhChargeStatus","plugged_out","plugged_in_charging","plugged_in_paused","plugged_in","stopped","fhChargeChargingStart","start","fhChargeChargingStop","stop","fhChargeChargingPause","pause","fhChargeAutoCharge","fhChargePlugLockedPermanently","LOCK","fhChargeForceUnlock","fhChargePlugLockState","locked","unlocked","fhChargeIsCharging","fhChargeIsPlugConnected","lastPowerResponseTime","fhChargeChargingStartDatetime","fhChargeChargingEndDatetime","fhChargeConnectedStartDatetime","fhChargeConnectedEndDatetime"}
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
a.numeric=z({{7,nil,7,"setpointChargingCurrent",nil,nil,nil,"fh_charge_setpoint_charging_current","Fh Charge Setpoint Charging Current",{0,32,nil,1,nil,1},nil,nil,1},{8,nil,8,"chargingCurrentLimit",nil,nil,nil,"fh_charge_charging_current_limit","Fh Charge Charging Current Limit",{6,32,nil,1,nil,2},nil,nil,1},{9,nil,9,"sessionEnergy",nil,0,0,"fh_charge_session_energy","Fh Charge Session Energy",{nil,nil,nil,2,nil,3},nil,nil,2},{10,nil,10,"energyMeterStart",nil,0,0,"fh_charge_energy_meter_start","Fh Charge Energy Meter Start",{nil,nil,nil,2,nil,4},nil,nil,2},{11,nil,11,"energyMeterNow",nil,0,0,"fh_charge_energy_meter_now","Fh Charge Energy Meter Now",{nil,nil,nil,2,nil,5},nil,nil,2},{12,nil,12,"chargingDuration",nil,0,0,"fh_charge_charging_duration","Fh Charge Charging Duration",{nil,nil,nil,"s",nil,6},nil,nil,"s"},{13,nil,13,"voltagePhaseB",nil,0,0,"fh_charge_voltage_phase_b","Fh Charge Voltage pHase B",{nil,nil,nil,3,nil,7},nil,nil,3},{14,nil,14,"voltagePhaseC",nil,0,0,"fh_charge_voltage_phase_c","Fh Charge Voltage pHase C",{nil,nil,nil,3,nil,8},nil,nil,3},{15,nil,15,"currentPhaseB",nil,0,0,"fh_charge_current_phase_b","Fh Charge Current pHase B",{nil,nil,nil,1,nil,9},nil,nil,1},{16,nil,16,"currentPhaseC",nil,0,0,"fh_charge_current_phase_c","Fh Charge Current pHase C",{nil,nil,nil,1,nil,10},nil,nil,1}},G)a.enum=z({{17,nil,17,"status",nil,0,0,"fh_charge_status","Fh Charge Status",{18,"off",19,20,21,22},{18,"off",19,20,21,22},11,12,11},{23,nil,23,"chargingStart",nil,nil,nil,"fh_charge_charging_start","Fh Charge Charging Start",{24},{24},13,14,13},{25,nil,25,"chargingStop",nil,nil,nil,"fh_charge_charging_stop","Fh Charge Charging Stop",{26},{26},15,16,15},{27,nil,27,"chargingPause",nil,nil,nil,"fh_charge_charging_pause","Fh Charge Charging Pause",{28},{28},17,18,17},{29,nil,29,"autoCharge",nil,nil,nil,"fh_charge_auto_charge","Fh Charge Auto Charge",{"ON","OFF"},{"ON","OFF"},19,20,19},{30,nil,30,"plugLockedPermanently",nil,nil,nil,"fh_charge_plug_locked_permanently","Fh Charge Plug Locked Permanently",{31,4},{31,4},21,22,21},{32,nil,32,"forceUnlock",nil,nil,nil,"fh_charge_force_unlock","Fh Charge Force Unlock",{4},{4},23,24,23},{33,nil,33,"plugLockState",nil,0,0,"fh_charge_plug_lock_state","Fh Charge Plug Lock State",{34,35},{34,35},25,26,25},{36,nil,36,"isCharging",nil,0,0,"fh_charge_is_charging","Fh Charge Is Charging",{5,6},{5,6},27,28,27},{37,nil,37,"isPlugConnected",nil,0,0,"fh_charge_is_plug_connected","Fh Charge Is Plug Connected",{5,6},{5,6},29,30,29}},K)a.text=z({{"last_power_response_time",38,38,0,0,nil,"Last power response time",64},{39,39,"chargingStartDatetime",0,0,"fh_charge_charging_start_datetime","Fh Charge Charging Start Datetime",25},{40,40,"chargingEndDatetime",0,0,"fh_charge_charging_end_datetime","Fh Charge Charging End Datetime",25},{41,41,"connectedStartDatetime",0,0,"fh_charge_connected_start_datetime","Fh Charge Connected Start Datetime",25},{42,42,"connectedEndDatetime",0,0,"fh_charge_connected_end_datetime","Fh Charge Connected End Datetime",25}},M)a.driver_message={attribute_name="driverMessage",capability_id="concertmirror08464.driverMessage",emit_name="driver_message",label="Driver message",maximum_length=512}a.by_range_key={}a.by_emit_name={}a.by_capability_id={}
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
