local capabilities=require "st.capabilities"
local metadata={}
function metadata.attach(definition,modes,minimum,maximum,step)
definition.thermostat_supported_modes=modes
definition.heating_setpoint_range={
minimum=minimum,
maximum=maximum,
step=step,
unit="C",
}
definition.runtime_start=function(device)
device:emit_component_event(
{id="main"},
capabilities.thermostatMode.supportedThermostatModes(
definition.thermostat_supported_modes,
{visibility={displayed=false}}
)
)
device:emit_component_event(
{id="main"},
capabilities.thermostatHeatingSetpoint.heatingSetpointRange({
value={
minimum=definition.heating_setpoint_range.minimum,
maximum=definition.heating_setpoint_range.maximum,
step=definition.heating_setpoint_range.step,
},
unit=definition.heating_setpoint_range.unit,
})
)
end
return definition
end
return metadata
