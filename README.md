<h1>Aseprite Script - Spritesheet Animation Player version 1.0 </h1>

This is an Aseprite script that creates a live preview of spritesheet animations of a full spritesheet image, personally intended for pixel artists who prefer to work on a spritesheet in full view (like me) rather than approach it using Aseprite's frame system.

This is a basic script useful for creating spritesheets for games that emulate the visuals of retro consoles which tend to have low number of frames for animations, so you can easily check if they animate cleanly without having to plug them inside your game engine.

- Tested using Aseprite 1.3.15.5-x64 by Igara Studio (Steam build) on a Windows 10 device
- Created by [Syvalia](https://syvalia.itch.io/)

## Installation

1. Download the script from this repository (Aseprite - Spritesheet Animation Player v1.0.lua) which is just a .lua script file used for Aseprite.
2. Open Aseprite and navigate to your scripts folder by going to File > Scripts > Open Scripts Folder
3. Move or copy the Aseprite - Spritesheet Animation Player v1.0 file into the scripts folder.
4. To make sure Aseprite detects the script, go to File > Scripts > Rescan Scripts Folder.
5. Once done, you can now run the script the same by going to File > Scripts and selecting Aseprite - Spritesheet Animation Player v1.0 from the options
6. As a recommendation, you can assign a custom keyboard shortcut so you can run the script seamlessly while editing.

## Usage

<div align="center">
  <img src="Spritesheet Animation Player.PNG" alt="Aseprite Spritesheet Animation Player screenshot">
</div>

This script basically allows you to preview a spritesheet's individual animations based on the frame size you set. By default, this is set to a 16x16 frame by default but can accommodate any sizes within a rectangular selection.

Animations are then played by offsetting the spritesheet from the left to right (or top to bottom if vertical) by the specified frame size based on the total frame count.

This script assumes that your spritesheet is divided evenly to play animations i.e. a 16x16 animation with 3 frames will offset 16px to the right (or bottom) until you reach the last (3rd frame).

If your spritesheet has uneven spacing between frames, the animation will not playback properly as the offset is fixed based on the specified frame's width (or height if vertical).

| Option  | Description                                  |
| ------- | -------------------------------------------- |
| Set start frame | Previews a rectangular area of the spritesheet based on Aseprite's selection using the marquee tool. Make sure you select the first frame of your animation. On startup, the script is set to a default 16x16 frame size located at the very top left of your spritesheet image.|
| < or > | Plays the next or previous frame based on the start frame selection size|
| Play / Stop | Starts or stops the animation based on the frame count |
| Loop | If enabled, the animation plays forever without stopping. If disabled, animations will automatically stop once it reaches the last frame|
| Ping Pong | If disabled, the animation loops back to the start. If enabled, it will loop in reverse when it reaches the last frame |
| Vertical |  This will play the animation from top to bottom instead of left to right. Enable only if your spritesheet is arranged vertically. |
| Show / Hide Options | Hides the additional options below if needed |
| Frame Count  | Set the total number of animation frames to loop through |
| Animation Speed  | Controls the speed of playback using the slider. |
| Zoom  | Allows you to zoom in or out of the frame using the slider or mouse scroll wheel button|

I generally use loop and ping pong enabled to preview low frame animations (such as in retro video games) where typically you have 3 unique frames, wherein the second frame is the idle frame which you repeat twice. Instead of having to repeat the idle frame in the spritesheet or having to go hardcode it to your game engine, you can preview it directly from Aseprite so you can edit it on the fly. To test the script, you can download any of my free character spritesheets on [Itch.io - Syvalia](https://syvalia.itch.io/)

## Known Bugs as of Version 1.0
- The window is resizable but reverts back to its default size if you press play/stop or use the show/hide options button
- If you make any changes to the spritesheet itself (ex. draw, change layer visibility, etc.) it will not reflect until you preview animation by playing or pressing the next/previous frame buttons.
- Running the script multiple times allows you to open multiple preview windows at the same time. Not really an intended feature and may introduce potential bugs or errors if used too much.

## Adjusting configurations
If you want to modify the value at start up (ideally if you already have a specific workflow), you can adjust the script's configuration variables directly at the top of the script using any code editor such as Visual Studio Code or even any text editor program. Notes are already included as in-line comments in the script.

<pre>
-- CONFIGURATION  --
-- (Can be modified)
local zoom = 5 -- Default zoom level at start up. Can be changed via the UI slider or mouse scroll wheel
  
local collapsed = false -- Hides options by default
  
local frame_X, frame_Y = 0, 0 -- Set default area at top-left most of the spritesheet at start up. Can be changed via set start frame button in the UI

local frame_width, frame_height = 16, 16 -- Default frame size 
  
local frame_count = 3 -- Default number of animation frames at start up, change this if you want a different default value at start. Can be changed via frame count input field in the UI

local animation_vertical = false -- If enabled, spritesheet frames play from top to bottom. Disabled by default to play from left to right

local animation_speed = 12 -- Default speed of animation playback. Can be changed via animation speed input field

local animation_loop = true -- Repeats animation forever until disabled. Enabled by default but can be toggled in the UI

local animation_pingpong = false -- Repeats the animation back and forth if enabled. Disabled by default but can be toggled in the UI
</pre>

**NOTE: I recommend atleast having gone through basic Lua scripting tutorials if you find the need to modify the code further**

## Credits
This script was directly inspired by [Aseprite SpriteSheet Preview by Canadian Boy](https://canadianboy.itch.io/aseprite-sprite-sheet-preview). This is just a basic version personally rewritten from scratch - mainly to learn how to do it while adding features for my own needs. The only unique feature as of writing is allowing you to preview the animation as a ping pong type loop.

