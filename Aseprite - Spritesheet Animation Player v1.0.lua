-- Aseprite Spritesheet Animation Player v1.0.0
-- Tested using Aseprite 1.3.15.5-x64 by Igara Studio (Steam build) on a Windows 10 device
-- Created by Syvalia >> https://github.com/syvalia/aseprite-spritesheet-animation-player/

-- REFERENCES -- 
local spritesheet
local dlg
local timer

-- CONFIGURATION  --
-- (Can be modified)
    local zoom = 5 -- Default zoom level at start up. Can be changed via the UI slider or mouse scroll wheel
    local collapsed = false -- Hides options by default
    local frame_X, frame_Y = 0,0 -- Set default area at top-left most of the spritesheet at start up. Can be changed via set start frame button in the UI
    local frame_width, frame_height = 16,16 -- Default frame size 
    local frame_count = 3 --Default number of animation frames at start up, change this if you want a different default value at start. Can be changed via frame count input field in the UI
    local animation_vertical = false -- If enabled, spritesheet frames play from top to bottom. Disabled by default to play from left to right
    local animation_speed = 8 -- Default speed of animation playback. Can be changed via animation speed input field
    local animation_loop = true -- Repeats animation forever until disabled. Enabled by default but can be toggled in the UI
    local animation_pingpong = false -- Repeats the animation back and forth if enabled. Disabled by default but can be toggled in the UI
-- (Do not modify)
    local animation_order = 1 
    local is_playing = false
    local frame_current = 0

-- FUNCTION: SHOW/HIDE OPTIONS -- 
local function toggle_options()
  collapsed = not collapsed
  local visible = not collapsed
  local ids = {
    "option_animation_label",
    "option_animation_loop",
    "option_animation_pingpong",
    "option_animation_vertical",
    "option_frame_count_label",
    "option_frame_count",
    "option_animation_speed_label",
    "option_animation_speed",
    "option_zoom_label",
    "option_zoom",
  }

  for _, id in ipairs(ids) do
    dlg:modify{ id=id, visible=visible }
  end

  dlg:modify{
    id="collapse_toggle", 
    text = collapsed and "Show Options" or "Hide Options"
  }
end
-----------------------------------------------------------------------
-- FUNCTION: SET START FRAME FROM SELECTION --
-----------------------------------------------------------------------
local function get_start_frame()
  spritesheet = app.activeSprite
  if not spritesheet then
    app.alert("Make sure an active document is open in Aseprite first!")
    return
  end

  local frame_selection = spritesheet.selection
  if frame_selection.isEmpty then
    app.alert("Make a selection using the marquee tool!")
    return
  end

  local bounds = frame_selection.bounds
  frame_X, frame_Y, frame_width, frame_height = bounds.x, bounds.y, bounds.width, bounds.height
  dlg:repaint()
end
-----------------------------------------------------------------------
-- FUNCTION: UPDATE --
-----------------------------------------------------------------------
local function stop_animation()
  if timer then timer:stop() end
  if dlg then dlg:modify{ id="play", text="Play" } end
  is_playing = false
  frame_current = 0
  animation_order = 1
end

local function update_frame()
  frame_current = frame_current + animation_order

  if frame_current > frame_count - 1 then
    frame_current = 0
  elseif frame_current < 0 then
    frame_current = frame_count - 1
  end

end

local function update_loop()
  frame_current = frame_current + animation_order
  if animation_pingpong then
    if frame_current >= frame_count - 1 then
      animation_order = -1
    elseif frame_current <= 0 then
      if animation_loop then
        animation_order = 1
      else
        stop_animation()
      end
    end
    return
  end

  if frame_current >= frame_count then
    if animation_loop then
      frame_current = 0
    else
      frame_current = frame_count - 1
      stop_animation()
    end
  elseif frame_current < 0 then
    if animation_loop then
      frame_current = frame_count - 1
    else
      frame_current = 0
      stop_animation()
    end
  end
end

local function play_animation()
  if timer and timer.isRunning then return end

  timer = Timer{
    interval = 1.0 / animation_speed,
    ontick = function()
      -- Stop animation if Aseprite document is closed
      if not app.activeSprite then
        stop_animation()
        return
      end

      animation_loop = dlg.data["option_animation_loop"]
      animation_pingpong = dlg.data["option_animation_pingpong"]
      animation_vertical = dlg.data["option_animation_vertical"]

      update_loop()

      dlg:repaint()
    end
  }

  timer:start()
  dlg:modify{ id="play", text="Stop" }
  is_playing = true
end
-----------------------------------------------------------------------
-- DIALOG: CANVAS --
-----------------------------------------------------------------------
local function create_viewport()
  dlg = Dialog("Spritesheet Animation Player")

  dlg:canvas{
    id = "viewport",
    width = 32 * zoom,
    height = 32 * zoom,
    hexpand = true,
    vexpand = true,
    onpaint = function(ev)
      local gc = ev.context
      spritesheet = app.activeSprite

      -- Stop if Aseprite document is closed
      if not spritesheet then
        stop_animation()
        return
      end

      local dst_width = frame_width * zoom
      local dst_height = frame_height * zoom
      local center_x = (gc.width - dst_width) / 2
      local center_y = (gc.height - dst_height) / 2

      local srcRect
      if animation_vertical then
        srcRect = Rectangle(
          frame_X,
          frame_Y + frame_height * frame_current,
          frame_width,
          frame_height
        )
      else
        srcRect = Rectangle(
          frame_X + frame_width * frame_current,
          frame_Y,
          frame_width,
          frame_height
        )
      end

      local dstRect = Rectangle(center_x, center_y, dst_width, dst_height)

      -- Draw image only if Aseprite document is open
      if spritesheet then
        gc:drawImage(Image(spritesheet), srcRect, dstRect)
      end
    end,

    onwheel = function(ev)
      zoom = math.min(50, math.max(1, zoom + ev.deltaY))
      dlg:modify{id="option_zoom", value = zoom}
      dlg:repaint()
    end
  }
  -----------------------------------------------------------------------
  -- PLAYBACK CONTROLS --
  -----------------------------------------------------------------------
  :button{
    id = "playback_set",
    text = "Set start frame",
    onclick = function(ev) 
        get_start_frame() 
    end
  }
  :button{
    id = "previous",
    text = "|<",
    onclick = function(ev)
      animation_order = -1
      update_frame()
      dlg:repaint()
    end
  }
  :button{
    id = "play",
    text = "Play",
    onclick = function(ev)
      if is_playing then stop_animation() else play_animation() end
    end
  }
  :button{
    id = "next",
    text = ">|",
    onclick = function(ev)
      animation_order = 1
      update_frame()
      dlg:repaint()
    end
  }
  :button{
    id = "collapse_toggle",
    text = "Hide Options",
    onclick = function(ev) 
        toggle_options() 
    end
  }
  -----------------------------------------------------------------------
  -- OPTIONS --
  -----------------------------------------------------------------------
  :label{id="option_animation_label", text="Animation Playback:"}
  :check{
    id="option_animation_loop",
    text="Loop",
    selected=animation_loop,
    onchange = function(ev) 
        animation_loop = dlg.data["option_animation_loop"] 
    end
  }
  :check{
    id="option_animation_pingpong",
    text="Ping-Pong",
    selected=animation_pingpong,
    onchange = function(ev) 
        animation_pingpong = dlg.data["option_animation_pingpong"] 
    end
  }
  :check{
    id="option_animation_vertical",
    text="Vertical",
    selected=animation_vertical,
    onchange = function(ev) 
        animation_vertical = dlg.data["option_animation_vertical"] 
    end
  }

  :label{id="option_frame_count_label", text="Frame Count"}
  :number{
    id="option_frame_count",
    text="3",
    onchange = function(ev)
        frame_count = dlg.data["option_frame_count"]
      end
  }

  :label{id="option_animation_speed_label", text="Animation Speed"}
  :slider{
    id="option_animation_speed",
    min=1, max=120, value=8,
    onchange = function(ev)
      animation_speed = dlg.data["option_animation_speed"]
      if timer and is_playing then
        timer:stop()
        timer.interval = 1.0 / animation_speed
        timer:start()
      end
    end
  }

  :label{id="option_zoom_label", text="Zoom (or use mouse scroll wheel)"}
  :slider{
    id="option_zoom",
    min=1, max=50, value=5,
    onchange = function(ev)
      zoom = dlg.data["option_zoom"]
      dlg:repaint()
    end
  }

  dlg:show{wait=false}

  -- Stop when Aseprite document is closed
  app.events:on('sitechange', function()
    if not app.activeSprite then
      stop_animation()
      dlg:modify{ id="play", enabled=false }
    else
      dlg:modify{ id="play", enabled=true }
    end
    dlg:repaint()
  end)
end

-- Checks if Aseprite document is open before running script
if not app.activeSprite then
  app.alert("No file found. Open an image in Aseprite first!")
  return
end

create_viewport()

