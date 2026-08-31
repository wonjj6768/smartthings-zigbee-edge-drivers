local helpers={}
local function indexed_entries(source,context,allow_named_fields)
context=context or "mapping list"
local list={}
if type(source)~="table" then
error(string.format("%s must be a table",context))
end
local maximum_index=0
local indexed_count=0
for key in pairs(source)do
if type(key)=="number" then
if key < 1 or key % 1 ~=0 then
error(string.format("%s has invalid numeric index %s",context,tostring(key)))
end
maximum_index=math.max(maximum_index,key)
indexed_count=indexed_count + 1
elseif not allow_named_fields then
error(string.format("%s has unexpected named field %s",context,tostring(key)))
end
end
if maximum_index ~=indexed_count then
error(string.format(
"%s must be a dense list (highest index %d, entries %d)",
context,
maximum_index,
indexed_count
))
end
for index=1,maximum_index do
list[index]=source[index]
end
return list
end
local function append_entries(target,entries)
target=target or{}
for _,entry in ipairs(entries)do
target[#target + 1]=entry
end
return target
end
local function has_named_fields(value)
if type(value)~="table" then
return false
end
for key in pairs(value)do
if type(key)~="number" then
return true
end
end
return false
end
local function is_zcl_mapping(entry)
if type(entry)~="table" or entry.cluster_id==nil then
return false
end
return entry.attribute_id ~=nil or(entry.write_only==true and type(entry.sender)=="function")
end
local function is_datapoint_mapping(entry)
return type(entry)=="table" and entry.dp ~=nil and entry.datatype ~=nil
end
local function split_mapping_entries(entries,context)
context=context or "mapping list"
local datapoints={}
local zcl_clusters={}
local unknown={}
for index,entry in ipairs(entries)do
local is_zcl=is_zcl_mapping(entry)
local is_datapoint=is_datapoint_mapping(entry)
if is_zcl and is_datapoint then
error(string.format("%s[%d] mixes datapoint and ZCL fields",context,index))
elseif is_zcl then
zcl_clusters[#zcl_clusters + 1]=entry
elseif is_datapoint then
datapoints[#datapoints + 1]=entry
else
unknown[#unknown + 1]=entry
end
end
return datapoints,zcl_clusters,unknown
end
local function mapping_count_error(context,count,kind)
error(string.format("%s contains %d %s mapping(s)",context,count,kind))
end
local function normalize_structured_entry(definitions_or_table)
local entry={}
for key,value in pairs(definitions_or_table)do
if type(key)~="number" and key ~="fingerprints" then
entry[key]=value
end
end
local profile=tostring(entry.profile)
local list=indexed_entries(definitions_or_table,"family profile " .. profile,true)
local datapoints,zcl_clusters,unknown=split_mapping_entries(list,"family profile " .. profile)
if #unknown > 0 then
mapping_count_error("family profile " .. profile,#unknown,"unknown indexed")
end
local function validate_named_mapping_list(field_name,expected_kind)
local mappings=entry[field_name]
if mappings==nil then
return
end
local context=string.format("family profile %s %s",profile,field_name)
local dense=indexed_entries(mappings,context,false)
local found_datapoints,found_zcl,found_unknown=split_mapping_entries(dense,context)
if #found_unknown > 0 then
mapping_count_error(context,#found_unknown,"incomplete or nested")
end
local wrong_mappings=expected_kind=="datapoint" and found_zcl or found_datapoints
if #wrong_mappings > 0 then
local wrong_kind=expected_kind=="datapoint" and "ZCL" or "datapoint"
mapping_count_error(context,#wrong_mappings,wrong_kind)
end
entry[field_name]=dense
end
validate_named_mapping_list("datapoints","datapoint")
validate_named_mapping_list("zcl_clusters","zcl")
if #datapoints > 0 then
entry.datapoints=append_entries(entry.datapoints,datapoints)
end
if #zcl_clusters > 0 then
entry.zcl_clusters=append_entries(entry.zcl_clusters,zcl_clusters)
end
return entry
end
function helpers.create_fingerprint(manufacturer_name,model_name)
return{manufacturer=manufacturer_name,model=model_name}
end
function helpers.create_fingerprints(model_name,manufacturer_names)
local fingerprints={}
for _,manufacturer_name in ipairs(manufacturer_names)do
local manufacturer,model=string.match(manufacturer_name,"^(.-):(.+)$")
if manufacturer==nil then
manufacturer,model=manufacturer_name,model_name
end
fingerprints[#fingerprints + 1]=helpers.create_fingerprint(manufacturer,model)
end
return fingerprints
end
function helpers.definition_registry()
local device_definitions={}
local function register_device_definition(definitions_or_table,fingerprint_list)
local entry=nil
if has_named_fields(definitions_or_table)then
entry=normalize_structured_entry(definitions_or_table)
else
local root_entries=indexed_entries(definitions_or_table,"device definition",true)
local datapoints,zcl_clusters,unknown=split_mapping_entries(root_entries,"device definition")
if #unknown > 0 then
mapping_count_error("device definition",#unknown,"incomplete or nested")
end
entry={}
if #datapoints > 0 then
entry.datapoints=datapoints
end
if #zcl_clusters > 0 then
entry.zcl_clusters=zcl_clusters
end
end
entry.fingerprints=fingerprint_list
device_definitions[#device_definitions + 1]=entry
end
return device_definitions,register_device_definition
end
return helpers
