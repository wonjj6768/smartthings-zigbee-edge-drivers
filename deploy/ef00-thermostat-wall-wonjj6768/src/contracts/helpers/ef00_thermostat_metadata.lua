local b,c=require"st.capabilities",{}
function c.attach(a,h,f,e,g)
a.thermostat_supported_modes=h
a.heating_setpoint_range={minimum=f,maximum=e,step=g,unit="C"}
a.runtime_start=function(d)
d:emit_component_event({id="main"},b.thermostatMode.supportedThermostatModes(a.thermostat_supported_modes,{visibility={displayed=false}}))d:emit_component_event({id="main"},b.thermostatHeatingSetpoint.heatingSetpointRange{value={minimum=a.heating_setpoint_range.minimum,maximum=a.heating_setpoint_range.maximum,step=a.heating_setpoint_range.step},unit=a.heating_setpoint_range.unit})
end
return a
end
function c.attach_setpoint_only(a,f,e,g)
a.heating_setpoint_range={minimum=f,maximum=e,step=g,unit="C"}
a.runtime_start=function(d)
d:emit_component_event({id="main"},b.thermostatHeatingSetpoint.heatingSetpointRange{value={minimum=a.heating_setpoint_range.minimum,maximum=a.heating_setpoint_range.maximum,step=a.heating_setpoint_range.step},unit=a.heating_setpoint_range.unit})
end
return a
end
return c
