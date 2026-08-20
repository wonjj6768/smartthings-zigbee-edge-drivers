-- ZCL 명령 핸들러 우선순위 정책
-- 명시 핸들러가 처리하지 않은 명령만 정의 기반 매핑으로 전달합니다.

local M = {}

function M.dispatch(explicit_handler, mapped_handler)
  if type(explicit_handler) == "function" and explicit_handler() == true then
    return true
  end

  if type(mapped_handler) == "function" then
    return mapped_handler() == true
  end

  return false
end

return M
