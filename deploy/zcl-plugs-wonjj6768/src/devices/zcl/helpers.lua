local zcl = require "zcl_common"
local zcl_device_helpers = {}
local function append_cluster(clusters, cluster)
if cluster ~= nil then
clusters[#clusters + 1] = cluster
end
end
function zcl_device_helpers.append_clusters(clusters, ...)
for index = 1, select("#", ...) do
local entry = select(index, ...)
if type(entry) == "table" and entry[1] ~= nil then
for _, cluster in ipairs(entry) do
append_cluster(clusters, cluster)
end
else
append_cluster(clusters, entry)
end
end
return clusters
end
function zcl_device_helpers.metering_clusters(options)
options = options or {}
local endpoint = options.endpoint
local include_switch = options.include_switch ~= false
local include_current = options.include_current == true
local power_poll = options.power_poll or 300
local voltage_poll = options.voltage_poll or 300
local current_poll = options.current_poll or 300
local energy_poll = options.energy_poll or 900
local energy_scale = options.energy_scale or 100
local clusters = {}
if include_switch then
append_cluster(clusters, zcl.switch({
endpoint = endpoint,
component = options.switch_component,
}))
end
append_cluster(clusters, zcl.power({
endpoint = endpoint,
poll_interval = power_poll,
}))
append_cluster(clusters, zcl.voltage({
endpoint = endpoint,
poll_interval = voltage_poll,
}))
if include_current then
append_cluster(clusters, zcl.current({
endpoint = endpoint,
poll_interval = current_poll,
}))
end
append_cluster(clusters, zcl.energy({
endpoint = endpoint,
scale = energy_scale,
poll_interval = energy_poll,
}))
return clusters
end
function zcl_device_helpers.switch_cluster(endpoint, component)
if endpoint == nil and component == nil then
return zcl.switch()
end
return zcl.switch({
endpoint = endpoint,
component = component,
})
end
return zcl_device_helpers
