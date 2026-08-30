local utf8_text = {}

local utf8_length = type(utf8) == "table" and utf8.len or nil
local utf8_offset = type(utf8) == "table" and utf8.offset or nil

local function normalized_limit(maximum_length)
  if type(maximum_length) ~= "number"
    or maximum_length < 0
    or maximum_length % 1 ~= 0 then
    return nil
  end

  return maximum_length
end

function utf8_text.length(value)
  if type(value) ~= "string" or type(utf8_length) ~= "function" then
    return nil
  end

  return utf8_length(value)
end

function utf8_text.fits(value, maximum_length)
  local limit = normalized_limit(maximum_length)
  local length = utf8_text.length(value)
  return limit ~= nil and length ~= nil and length <= limit
end

function utf8_text.truncate(value, maximum_length)
  local limit = normalized_limit(maximum_length)
  local length = utf8_text.length(value)
  if limit == nil or length == nil then
    return nil
  end
  if length <= limit then
    return value
  end

  local boundary = utf8_offset(value, limit + 1)
  if boundary == nil then
    return nil
  end

  return value:sub(1, boundary - 1)
end

return utf8_text
