-- ~/.config/nvim/lua/snippets/python.lua
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local d = ls.dynamic_node

-- ---------------- Utilities ----------------

local function trim(x)
	return (x:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function get_indent_count(s_)
	local indent = s_:match("^(%s*)")
	return indent and #indent or 0
end

local function current_line_indent()
	local line = vim.api.nvim_get_current_line()
	return line:match("^(%s*)") or ""
end

local function split_top_level_commas(param_str)
	local out, cur = {}, {}
	local dp, db, dc = 0, 0, 0 -- (), [], {}

	for ch in param_str:gmatch(".") do
		if ch == "(" then
			dp = dp + 1
		elseif ch == ")" then
			dp = math.max(0, dp - 1)
		elseif ch == "[" then
			db = db + 1
		elseif ch == "]" then
			db = math.max(0, db - 1)
		elseif ch == "{" then
			dc = dc + 1
		elseif ch == "}" then
			dc = math.max(0, dc - 1)
		end

		if ch == "," and dp == 0 and db == 0 and dc == 0 then
			local piece = trim(table.concat(cur))
			if piece ~= "" then
				table.insert(out, piece)
			end
			cur = {}
		else
			table.insert(cur, ch)
		end
	end

	local last = trim(table.concat(cur))
	if last ~= "" then
		table.insert(out, last)
	end
	return out
end

local function find_nearest_def_row_and_line()
	local bufnr = 0
	local row = vim.api.nvim_win_get_cursor(0)[1] -- 1-indexed
	for r = row, 1, -1 do
		local line = vim.api.nvim_buf_get_lines(bufnr, r - 1, r, false)[1]
		if line and line:match("^%s*def%s+") then
			return r, line
		end
	end
	return nil, nil
end

local function parse_def_signature(def_line)
	-- Single-line def parser.
	local params, ret = {}, nil
	local inside = def_line:match("%((.*)%)")
	if not inside then
		return params, ret
	end

	ret = def_line:match("%)%s*%-%>%s*([^:]+)%s*:")
	if ret then
		ret = trim(ret)
	end
	if ret == "None" or ret == "NoReturn" then
		ret = "None"
	end

	for _, p in ipairs(split_top_level_commas(inside)) do
		p = trim(p)
		if p ~= "" and p ~= "/" then
			local name = p:match("^%*%*?%s*([%a_][%w_]*)") or p:match("^([%a_][%w_]*)")
			local ann = p:match(":%s*([^=]+)")
			if ann then
				ann = trim(ann)
				ann = trim(ann:gsub("%s*=%s*.*$", ""))
			end
			if name and name ~= "" and name ~= "self" and name ~= "cls" then
				table.insert(params, { name = name, ann = ann })
			end
		end
	end

	return params, ret
end

local function collect_raised_exceptions(def_row, def_line)
	local bufnr = 0
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local def_indent = get_indent_count(def_line)
	local out, seen = {}, {}

	local function add_exc(name)
		if not name or name == "" then
			return
		end
		if not seen[name] then
			seen[name] = true
			table.insert(out, name)
		end
	end

	for r = def_row + 1, #lines do
		local line = lines[r]

		if (line:match("^%s*def%s+") or line:match("^%s*class%s+")) and get_indent_count(line) <= def_indent then
			break
		end

		if not line:match("^%s*$") and not line:match("^%s*#") then
			if line:match("^%s*raise%s*$") then
				add_exc("Exception")
			else
				local rest = line:match("^%s*raise%s+(.+)$")
				if rest then
					rest = trim(rest)
					local exc = rest:match("^([%a_][%w_%.]*)%s*%(") or rest:match("^([%a_][%w_%.]*)")
					add_exc(exc or "Exception")
				end
			end
		end
	end

	return out
end

local function function_returns_value(def_row, def_line)
	local bufnr = 0
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local def_indent = get_indent_count(def_line)

	for r = def_row + 1, #lines do
		local line = lines[r]

		if (line:match("^%s*def%s+") or line:match("^%s*class%s+")) and get_indent_count(line) <= def_indent then
			break
		end

		local expr = line:match("^%s*return%s+(.+)$")
		if expr and trim(expr) ~= "" then
			return true
		end
	end

	return false
end

-- ---------------- Docstring builder ----------------

local function build_numpy_docstring()
	local def_row, def_line = find_nearest_def_row_and_line()
	local params, ret, raises = {}, nil, {}
	local returns_value = false

	if def_line then
		params, ret = parse_def_signature(def_line)
		raises = collect_raised_exceptions(def_row, def_line)
		returns_value = function_returns_value(def_row, def_line)
	end

	-- IMPORTANT:
	-- We assume you expand this snippet at the function-body indent.
	-- So DO NOT emit leading IND at the start of lines (it would double-indent).
	local IND4 = "    " -- continuation indent inside docstring (relative)

	local nodes = {}
	local ins = 1

	-- Helpers: use 2-element arrays so LuaSnip inserts a newline after each line.
	local function push_line(str)
		table.insert(nodes, t({ str, "" }))
	end

	local function push_blank()
		table.insert(nodes, t({ "", "" })) -- truly empty line
	end

	-- Opening
	push_line('"""')

	-- Summary (no extra indent; you're already in the right column)
	table.insert(nodes, i(ins, "Short description."))
	ins = ins + 1
	table.insert(nodes, t({ "", "" })) -- end summary line
	push_blank()

	-- Parameters
	if #params > 0 then
		push_line("Parameters")
		push_line("----------")
		push_blank()

		for _, p in ipairs(params) do
			local type_hint = (p.ann and p.ann ~= "") and p.ann or "TYPE"
			push_line(string.format("%s : %s", p.name, type_hint))

			-- description line indented one level inside docstring block
			table.insert(nodes, t(IND4))
			table.insert(nodes, i(ins, "Description."))
			ins = ins + 1
			table.insert(nodes, t({ "", "" })) -- end description line
			push_blank()
		end
	end

	-- Raises
	if #raises > 0 then
		push_line("Raises")
		push_line("------")
		push_blank()

		for _, exc in ipairs(raises) do
			push_line(exc)
			table.insert(nodes, t(IND4))
			table.insert(nodes, i(ins, "Description."))
			ins = ins + 1
			table.insert(nodes, t({ "", "" }))
			push_blank()
		end
	end

	-- Returns
	local include_returns = false
	local return_type = nil

	if ret and ret ~= "" and ret ~= "None" then
		include_returns = true
		return_type = ret
	elseif returns_value then
		include_returns = true
		return_type = "TYPE"
	end

	if include_returns then
		push_line("Returns")
		push_line("-------")
		push_blank()

		push_line(return_type)
		table.insert(nodes, t(IND4))
		table.insert(nodes, i(ins, "Description."))
		ins = ins + 1
		table.insert(nodes, t({ "", "" }))
	end

	-- Closing
	push_line('"""')

	return sn(nil, nodes)
end
-- ---------------- Register snippet ----------------

ls.add_snippets("python", {
	s("doc", {
		d(1, function()
			return build_numpy_docstring()
		end, {}),
	}),
})

ls.add_snippets("quarto", {
	s("doc", {
		d(1, function()
			return build_numpy_docstring()
		end, {}),
	}),
})

ls.add_snippets("markdown", {
	s("doc", {
		d(1, function()
			return build_numpy_docstring()
		end, {}),
	}),
})
