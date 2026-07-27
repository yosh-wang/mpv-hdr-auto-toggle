-- ============================================================================
-- toggleHDR.lua
-- 功能：根据视频类型自动切换 Windows HDR 模式
-- 依赖：HDRCmd.exe (来自 HDRTray 工具)
-- ============================================================================

require "mp.msg"

local config = {
    hdr_cmd_path = "D:\\HDRTray\\HDRCmd.exe",
    enabled = true
}

local config_file = mp.find_config_file("script-opts/toggleHDR.conf")
if config_file then
    local file = io.open(config_file, "r")
    if file then
        for line in file:lines() do
            line = line:gsub("#.*", ""):gsub("^%s+", ""):gsub("%s+$", "")
            if line ~= "" then
                local key, value = line:match("^([^=]+)=(.*)$")
                if key and value then
                    key = key:gsub("^%s+", ""):gsub("%s+$", "")
                    value = value:gsub("^%s+", ""):gsub("%s+$", "")
                    if key == "enabled" then
                        config.enabled = value ~= "no" and value ~= "false"
                    elseif key == "hdr_cmd_path" then
                        config.hdr_cmd_path = value
                    end
                end
            end
        end
        file:close()
    end
end

if not config.enabled then
    mp.msg.info("toggleHDR: disabled in config")
    return
end

local HDR_CMD = config.hdr_cmd_path

local function hdr_status()
    local result = mp.command_native({
        name = "subprocess",
        args = {HDR_CMD, "status"},
        capture_stdout = true,
        playback_only = false
    })
    return result.stdout and result.stdout:match("%s*on%s*") and true or false
end

local function hdr_set(on)
    local result = mp.command_native({
        name = "subprocess",
        args = {HDR_CMD, on and "on" or "off"},
        playback_only = false,
        detach = true,
        capture_stderr = true
    })

    if result.error then
        mp.msg.warn("toggleHDR: failed to execute " .. HDR_CMD .. ": " .. result.error)
    elseif result.status ~= 0 then
        mp.msg.warn("toggleHDR: HDRCmd.exe returned non-zero exit code: " .. result.status)
        if result.stderr then
            mp.msg.warn("toggleHDR: stderr: " .. result.stderr)
        end
    end
end

local initial_hdr_state = hdr_status()
local hdr_was_toggled = false

mp.msg.info("toggleHDR: initial_hdr_state = " .. tostring(initial_hdr_state))

local function restore_hdr()
    if hdr_was_toggled then
        mp.msg.info("toggleHDR: restoring HDR to " .. tostring(initial_hdr_state))
        hdr_set(initial_hdr_state)
        hdr_was_toggled = false
    end
end

mp.register_event("end-file", function()
    local playlist_pos = mp.get_property_number("playlist-pos-1", 0)
    local playlist_count = mp.get_property_number("playlist-count", 0)
    if playlist_pos < playlist_count then
        return
    end
    mp.msg.info("toggleHDR: end-file triggered")
    restore_hdr()
end)

mp.register_event("shutdown", function()
    mp.msg.info("toggleHDR: shutdown triggered")
    restore_hdr()
end)

mp.observe_property("video-params", "native", function(_, params)
    if not params or not params.primaries or not params.gamma then
        return
    end

    local is_hdr_video = params.primaries == "bt.2020" and (params.gamma == "pq" or params.gamma == "hlg")
    local current_hdr_state = hdr_status()

    if initial_hdr_state then
        if is_hdr_video then
            return
        else
            if current_hdr_state then
                mp.msg.info("toggleHDR: SDR video on HDR display, turning HDR off")
                hdr_set(false)
                hdr_was_toggled = true
            end
        end
    else
        if is_hdr_video then
            if not current_hdr_state then
                mp.msg.info("toggleHDR: HDR video on SDR display, turning HDR on")
                hdr_set(true)
                hdr_was_toggled = true
            end
        else
            return
        end
    end
end)
