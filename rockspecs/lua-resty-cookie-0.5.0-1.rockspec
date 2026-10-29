package = "lua-resty-cookie"
version = "0.5.0-1"

source = {
  url = "git+https://git.hanada.info/hanada/lua-resty-cookie",
  tag = "0.5.0",
}

description = {
  summary = "Lua library for HTTP cookie manipulations for OpenResty/ngx_lua",
  homepage = "https://git.hanada.info/hanada/lua-resty-cookie",
  license = "BSD",
}

dependencies = {
  "lua >= 5.1",
}

build = {
  type = "builtin",
  modules = {
    ["resty.cookie"] = "lib/resty/cookie.lua"
  }
}
