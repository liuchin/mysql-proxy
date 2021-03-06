--[[ $%BEGINLICENSE%$
 Copyright (c) 2009, 2012, Oracle and/or its affiliates. All rights reserved.

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License as
 published by the Free Software Foundation; version 2 of the
 License.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 02110-1301  USA

 $%ENDLICENSE%$ --]]

local proto = assert(require("mysql.proto"))

---
-- if the assert()ions in -test.lua fail, the default behaviour of the proxy
-- will jump in and we will forward the query to the backend. That's us. 
--
-- We will answer the query. Our answer is "failed" 

function connect_server()
	-- emulate a server
	proxy.response = {
		type = proxy.MYSQLD_PACKET_RAW,
		packets = {
			proto.to_challenge_packet({
				server_version = 50114
			})
		}
	}
	return proxy.PROXY_SEND_RESULT
end

function read_query(packet)
	if packet:byte() ~= proxy.COM_QUERY then 
		proxy.response = {
			type = proxy.MYSQLD_PACKET_OK
		}
		return proxy.PROXY_SEND_RESULT
	end

	proxy.response = {
		type = proxy.MYSQLD_PACKET_OK,
		resultset = {
			fields = {
				{ name = "Result", type = proxy.MYSQL_TYPE_STRING },
			},
			rows = { { "failed" }  }
		}
	}

	return proxy.PROXY_SEND_RESULT
end

