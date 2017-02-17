local lg = love.graphics
local character
local config = {refresh_rate=.07}
--keep delta time
local dtotal = 0

function filter_white( x, y, r, g, b, a )
   if r>170 and g>170 and b>170 then
     a = 0
   else
     r=x*255
     g=y%255
     b=x*y%255
   end
   return r,g,b,a
end


function pixel_erode( seuil, image, x, y )
  local erode
  for xi=x-1, x+1 do
    for yi= y-1, y+1 do
      if yi > 0 and yi < image:getHeight() and xi > 0 and xi < image:getWidth() then
        local r, g, b = image:getPixel( xi , yi )
        if r < seuil or g < seuil or b <seuil then
           return true
        end
      end
    end
  end
  return false
end

function erosion( image )
  local x
  local y
  local eroded_image = love.image.newImageData(image:getWidth(),image:getHeight())
  for x = 1, image:getWidth()-1 do
      for y = 1, image:getHeight()-1 do
          -- Pixel coordinates range from 0 to image width - 1 / height - 1.
          --if 

          if pixel_erode(120, image, x,y) then
            local r, g, b = image:getPixel( x , y )
            eroded_image:setPixel( x, y, r, g, b,255)
          end
      end
  end
  return eroded_image
end

function newCharacter(image_path,pose_count)
  --load character
  character = {}
  local imgData = love.image.newImageData(image_path)
  
  character.image = lg.newImage(erosion(imgData))
  --character.image:refresh()
  
  character.pose_count = pose_count
  
  character.total_width = character.image:getWidth()/4
  character.total_height = character.image:getHeight()/4
  
  character.pose_height = character.total_height
  character.pose_width = character.total_width / character.pose_count
  
  character.sequence = {}
  
  character.pose_index = 0
  
  for i=0, character.pose_count-1 do
    character.sequence[i] = lg.newQuad(i*character.pose_width, 0, character.pose_width, character.pose_height, character.total_width, character.total_height)
  end
  character.current_pose = character.sequence[character.pose_index]
  return character
end

local function move(character,direction)
  if direction == "up" then
    character.posy = character.posy - character.pose_height/40
    if character.flipx == 1 then
      direction = "right"
    else
      direction = "left"
    end
  elseif direction == "down" then
    character.posy = character.posy + character.pose_height/40
    if character.flipx == 1 then
      direction = "right"
    else
      direction = "left"
    end
  end
  
  if direction == "right" then
    if character.flipx == 1 then
      character.pose_index = (character.pose_index + 1) % character.pose_count
      character.current_pose = character.sequence[character.pose_index]
      --move along the axis
      character.posx = character.posx + character.flipx * character.pose_width/character.pose_count
    else
      --in case of flip don't change position
      character.flipx = 1
      character.posx = character.posx - character.pose_width
    end
  elseif direction == "left" then
    if character.flipx == -1 then
      character.pose_index = (character.pose_index + 1) % character.pose_count
      character.current_pose = character.sequence[character.pose_index]
      --move along the axis
      character.posx = character.posx + character.flipx * character.pose_width/character.pose_count
    else
      --in case of flip don't change position
      character.flipx = -1
      character.posx = character.posx + character.pose_width
    end
  end
end

local function draw(character)
	lg.draw(character.image, character.current_pose, character.posx, character.posy, 0,character.flipx,1,character.flipx*character.pose_width/2,character.pose_height/2)
end

function love.load()
  --debug
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  character = newCharacter("res/bonh.jpg",4)
  --get the size of the window to move the character
  config.width, config.height = lg.getDimensions( )
  character.flipx = 1
  character.posx = config.width/2
  character.posy = config.height/2
end

local dir
--local help = ""

function love.touchpressed(id, x, y, dx, dy)
    local cx = x
    local cy = y
    cx = character.posx - cx
    cy = character.posy - cy
    --todo fix hard coded values
    if cy > 100 then
        dir = "up"
    elseif cy < -100 then
        dir = "down"
    elseif cx > 10 then
        dir = "left"
    elseif cx < 10 then
        dir = "right"
    end
    if cx > 10 and character.flipx > 0 then
	dir = "left"
    elseif cx < 10 and character.flipx < 0 then
	dir = "right"
    end
    --help = {"x", cx, "\ny", cy}
end

function love.touchmoved(id, x, y, dx, dy)
    local cx = x
    local cy = y
    cx = character.posx - cx
    cy = character.posy - cy
    --todo fix hard coded values
    if cy > 100 then
        dir = "up"
    elseif cy < -100 then
        dir = "down"
    elseif cx > 10 then
        dir = "left"
    elseif cx < 10 then
        dir = "right"
    end
    if cx > 10 and character.flipx > 0 then
	dir = "left"
    elseif cx < 10 and character.flipx < 0 then
	dir = "right"
    end
    --help = {"x", cx, "\ny", cy}
end

function love.touchreleased()
    dir = nil
end

function love.keypressed( key )
    if key == "right" then
      dir = "right"
    elseif key == "left" then
      dir = "left"
    elseif key == "up" then
      dir = "up"
    elseif key == "down" then
      dir="down"
    end
end
 
function love.keyreleased( key )
    if key == "right" or key == "left" or key == "up" or key == "down" then
      dir=nil
    end
end

function love.update(dt)
  dtotal = dtotal + dt
  --change sequence every refresh time
  if dtotal > config.refresh_rate then
    if dir then
      move(character, dir)
      dtotal = 0
    end
    --if we go out of the scren continue
    if  character.posx > config.width + character.pose_width - character.flipx * character.pose_width/2 then
      character.posx = 0
    elseif character.posx < -character.pose_width/2 then
      character.posx = config.width + character.pose_width
    end
    --if we go out of the scren continue
    if  character.posy > config.height - character.pose_height/2 then
      character.posy = config.height - character.pose_height/2
    elseif character.posy < character.pose_height/2 then
      character.posy = character.pose_height/2
    end
  end
end

function love.draw()
  draw(character)

  --lg.print(help,20,200,0,4,4)
end
