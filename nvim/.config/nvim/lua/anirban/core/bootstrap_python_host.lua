-- Sets up a dedicated venv for neovim with the pynvim package installed.
-- This makes sure that neovim doesn't look through every python installation on the $PATH when it opens a *.py file
-- for the first time. This phenomenon slows down opening of py file for the first time.

-- lua/bootstrap_python_host.lua
local fn = vim.fn

local function ensure_python_host()
	local data = fn.stdpath("data") -- e.g. ~/.local/share/nvim
	local state = fn.stdpath("state") -- e.g. ~/.local/state/nvim
	local venv = data .. "/python-venv"
	local py = venv .. "/bin/python"
	local stamp = state .. "/python_host_last_update"

	local function notify(msg, lvl)
		vim.notify(msg, lvl or vim.log.levels.INFO)
	end
	local function exists(f)
		return fn.filereadable(f) == 1
	end
	local function makedirs(p)
		fn.mkdir(p, "p")
	end

	local function sys_python()
		if fn.executable("python3") == 1 then
			return "python3"
		end
		if fn.executable("python") == 1 then
			return "python"
		end
		return nil
	end

	local function run(cmd)
		local out = fn.system(cmd)
		local ok = (vim.v.shell_error == 0)
		return ok, out
	end

	makedirs(state)

	-- Step 1: create venv if missing
	if not exists(py) then
		local sp = sys_python()
		if not sp then
			notify("No system Python found to create Neovim host venv", vim.log.levels.ERROR)
			return
		end
		makedirs(venv)
		notify("Creating Neovim Python host venv at " .. venv .. "…")
		local ok = run({ sp, "-m", "venv", venv })
		if not exists(py) then
			notify("Failed to create venv at " .. venv, vim.log.levels.ERROR)
			return
		end
		notify("Installing pynvim into host venv…")
		run({ py, "-m", "pip", "install", "-U", "pip", "pynvim" })
		fn.writefile({ tostring(os.time()) }, stamp)
	end

	-- Always point Neovim to this Python
	vim.g.python3_host_prog = py

	-- Step 2: weekly auto-update of pip + pynvim
	local WEEK = 7 * 24 * 60 * 60
	local now = os.time()
	local last = 0
	if exists(stamp) then
		local lines = fn.readfile(stamp)
		if lines and lines[1] then
			last = tonumber(lines[1]) or 0
		end
	end
	if (now - last) > WEEK then
		notify("Updating Neovim Python host (pip, pynvim)…")
		run({ py, "-m", "pip", "install", "-U", "pip", "pynvim" })
		fn.writefile({ tostring(now) }, stamp)
	end
end

ensure_python_host()
