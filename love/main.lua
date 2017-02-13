local character

function love.load()
  --debug
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  
  --load character
  character = {}
  character.image_name = "res/vulture.jpeg"
  character.image = love.graphics.newImage(character.image_name)
  character.pose_number = 7
  
  character.total_width = character.image:getWidth()
  character.total_height = character.image:getHeight()
  
  character.pose_height = character.image:getHeight()
  character.pose_width = character.image:getWidth() / character.pose_number
  
  character.sequence = {}
  
  character.pose_index = 0
  
  refresh_rate = .07
  
  for i=0, character.pose_number-1 do
    character.sequence[i] = love.graphics.newQuad(i*character.pose_width, 0, character.pose_width, character.pose_height, character.total_width, character.total_height)
  end
  character.current_pose = character.sequence[character.pose_index]
  
  --get the size of the window to move the character
  width, height = love.graphics.getDimensions( )
  character.posx = -character.pose_width
end

--keep delta time
dtotal = 0
flip = 1
function love.update(dt)
  dtotal = dtotal + dt
  --change sequence every refresh time
  if dtotal > refresh_rate then
    if love.keyboard.isDown("right") then
      if flip == 1 then
        character.pose_index = (character.pose_index + 1) % character.pose_number
        character.current_pose = character.sequence[character.pose_index]
        dtotal = 0
        --move along the axis
        character.posx = character.posx + flip * character.pose_width/character.pose_number
      else
        --in case of flip don't change position
        flip = 1
        character.posx = character.posx - character.pose_width
      end
    end 
    if love.keyboard.isDown("left") then
      if flip == -1 then
        character.pose_index = (character.pose_index + 1) % character.pose_number
        character.current_pose = character.sequence[character.pose_index]
        dtotal = 0
        --move along the axis
        character.posx = character.posx + flip * character.pose_width/character.pose_number
      else
        --in case of flip don't change position
        flip = -1
        character.posx = character.posx + character.pose_width
      end
    end
    --if we go out of the scren continue
    if  character.posx > width + character.pose_width then
      character.posx = -character.pose_width
    elseif character.posx < -character.pose_width then
      character.posx = width + character.pose_width
    end
  end
end

function love.draw()
  --draw the image in the center
	love.graphics.draw(character.image, character.current_pose, character.posx, height/2-character.pose_height/2, 0,flip,1)
end
