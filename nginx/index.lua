--[[
-- File        : index.lua
-- Copyright   : 2019 Enzo Haussecker
-- License     : Apache 2.0 with LLVM Exception
-- Maintainer  : Enzo Haussecker <enzo@dfinity.org>
-- Stability   : Experimental
]]

local bignum = require 'openssl.bignum'
local cbor = require 'org.conman.cbor'
local hex = require 'hex'
local http = require 'socket.http'
local ltn12 = require 'ltn12'
local rand = require 'openssl.rand'

local HOST = '127.0.0.1'
local PORT = 8001
local CANISTER = '12744825594756334163'

local function bignum_to_cbor(n)	
  local tag = ''
  if n >= bignum.new('0') then
    tag = string.char(0x1B)
  else
    tag = string.char(0x3B)
    n = bignum.new('-1') - n
  end
  local bin = n:tobin()
  local len = string.len(bin)
  local pad = string.rep(string.char(0x00), 8 - len)
  return tag .. pad .. bin
end

bignum.interpose('__tocbor', bignum_to_cbor)

local message = {
  canister_id = bignum.new(CANISTER),
  request_type = 'query',
  method_name = 'index',
  arg = hex.decode('4449444C0000'),
  nonce = rand.bytes(32)
}

local body = cbor.encode(message)

local data = ''

local function collect(chunk)
  if chunk ~= nil then
    data = data .. chunk
  end
  return true
end

http.TIMEOUT = 30

local ok, statusCode = http.request {
  url = string.format('http://%s:%d/api/v1/read', HOST, PORT),
  method = 'POST',
  headers = {
    ['Content-Length'] = string.len(body),
    ['Content-Type'] = 'application/cbor'
  },
  source = ltn12.source.string(body),
  sink = collect
}

if ok and statusCode == 200 then
  local html = string.sub(cbor.decode(data, 4)['reply']['arg'], 9)
  ngx.header['Content-Length'] = string.len(html)
  ngx.header['Content-Type'] = 'text/html'
  ngx.print(html)
else
  return ngx.exit(statusCode)
end
