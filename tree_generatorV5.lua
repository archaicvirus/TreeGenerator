-- title:   Tree Generator
-- author:  ArchaicVirus
-- desc:    Procedural tree generator
-- site:    https://github.com/archaicvirus
-- license: MIT License
-- version: 3
-- script:  lua


UI_CORNER = 224
UI_CURSOR = 271
UI_BG = 8
UI_FG = 9
UI_TEXT_BG = 0
UI_TEXT_FG = 4
UI_SHADOW = 0
UI_ARROW = 240
UI_BUTTON = 241
UI_BUTTON2 = 242
ui = {}

--tic80 wiki
function pal(c0, c1)
  if not c0 and not c1 then
    for i = 0, 15 do
      poke4(0x3FF0 * 2 + i, i)
    end
  elseif type(c0) == 'table' then
    for i = 1, #c0, 2 do
      poke4(0x3FF0*2 + c0[i], c0[i + 1])
    end
  else
    poke4(0x3FF0*2 + c0, c1)
  end
end

function ui.draw_panel(x, y, w, h, bg, fg, label, shadow)
  bg, fg = bg or UI_BG, fg or UI_FG
  local text_width = print(label, 0, -10, 0, false, 1, true)
  if text_width > w + 7 then w = text_width + 7 end
  rect(x + 2, y + 2, w - 4, h - 4, bg) -- background fill
  if label then
    pal(1, fg)
    pal(8, fg)
    spr(UI_CORNER, x, y, 0)
    spr(UI_CORNER, x + w - 8, y, 0, 1, 1)
    pal()
    pal(1, fg)
    pal(8, bg)
    spr(UI_CORNER, x + w - 8, y + h - 8, 0, 1, 3)
    spr(UI_CORNER, x, y + h - 8, 0, 1, 2)
    pal()
    rect(x, y + 6, w, 3, fg) -- header lower-fill
    rect(x + 2, y + h - 3, w - 4, 1, fg) -- bottom footer fill
    rect(x + 6, y + 2, w - 12, 4, fg)--header fill
    prints(label, x + w/2 - text_width/2, y + 2, 0, 4) -- header text
  else
    pal(1, fg)
    spr(UI_CORNER, x + w - 8, y + h - 8, {0, 8}, 1, 3)
    spr(UI_CORNER, x, y + h - 8, {0, 8}, 1, 2)
    spr(UI_CORNER, x, y, {0, 8})
    spr(UI_CORNER, x + w - 8, y, {0, 8}, 1, 1)
    pal()
  end
  rect(x + 6, y, w - 12, 2, fg) -- top border
  rect(x, y + 6, 2, h - 12, fg) -- left border
  rect(x + w - 2, y + 6, 2, h - 12, fg) -- right border
  rect(x + 6, y + h - 2, w - 12, 2, fg) -- bottom border
  if shadow then
    line(x + 4, y + h, x + w - 3, y + h, shadow) -- shadow
    line(x + w - 2, y + h - 1, x + w, y + h - 3, shadow)-- shadow
    line(x + w, y + 4, x + w, y + h - 4, shadow)-- shadow
  end
end

function ui.draw_button(x, y, flip, id, color, shadow_color, hover_color)
  color, shadow_color, hover_color = color or 12, shadow_color or 0, hover_color or 11
  local _mouse, _box, ck, p = {x = cursor.x, y = cursor.y}, {x = x, y = y, w = 8, h = 8}, 1, {4, color, 2, shadow_color, 12, color}
  local hov = hovered(_mouse, _box)
  if hov and not cursor.l then
    p = {2, shadow_color, 12, hover_color, 4, hover_color}
  elseif hov and cursor.l then
    p = {2, hover_color, 12, hover_color, 4, hover_color}
    ck = {1, 4}
  end
  pal(p)
  spr(id, x, y, ck, 1, flip)
  pal()
  if hov and cursor.l and not cursor.ll then return true end
  return false
end

vec2 = {}
vec2_mt = {}
vec2_mt.__index = vec2_mt

function vec2_mt:__add( v )
  return vec2(self.x + v.x, self.y + v.y)
end

function vec2_mt:__sub( v )
  return vec2(self.x - v.x, self.y - v.y)
end

function vec2_mt:__mul( v )
  trace('v = ' .. tostring(v))
  if type(v) == "table"
  then return vec2(self.x * v.x, self.y * v.y)
  else return vec2(self.x * v, self.y * v) end
end

function vec2_mt:__div( v )
  if type(v) == "table"
  then return vec2(self.x / v.x, self.y / v.y)
  else return vec2(self.x / v, self.y / v) end
end

function vec2_mt:__unm()
  return vec2(-self.x, -self.y)
end

function vec2_mt:dot( v )
  return self.x * v.x + self.y * v.y
end

function vec2_mt:length()
  return math.sqrt(self.x * self.x + self.y * self.y)
end

function vec2_mt:normalize()
  local length = self:length()
  if length == 0 then
    return vec2(0, 0)
  end
  return vec2(self.x / length, self.y / length)
end

function vec2_mt:rotate(angle)
  local cs = math.cos(angle)
  local sn = math.sin(angle)
  return vec2(self.x * cs - self.y * sn, self.x * sn + self.y * cs)
end
  
function vec2_mt:div()
  return self.x / self.y
end

function vec2_mt:min(v)
  if type(v) == "table"
  then return vec2(math.min(self.x, v.x), math.min(self.y, v.y))
  else return math.min(self.x, self.y) end
end

function vec2_mt:max(v)
  if type(v) == "table"
  then return vec2(math.max(self.x, v.x), math.max(self.y, v.y))
  else return math.max(self.x, self.y) end
end

function vec2_mt:abs()
  return vec2(math.abs(self.x), math.abs(self.y))
end

function vec2_mt:mix(v, n)
  return self * n + v * math.max(0, 1 - n)
end

function vec2_mt:__tostring()
  return ("(%g | %g)"):format(self:tuple())
end

function vec2_mt:tuple()
  return self.x, self.y
end
  
setmetatable(vec2, {__call = function(V, x, y )
    return setmetatable({x = x or 0, y = y or x or 0}, vec2_mt)
  end})

tree = {}
tick = 0
floor = math.floor
tx, ty = 120, 120

cursor = {
  x = 8,
  y = 8,
  id = 352,
  lx = 8,
  ly = 8,
  sx = 0,
  sy = 0,
  lsx = 0,
  lsy = 0,
  l = false,
  ll = false,
  m = false,
  lm = false,
  r = false,
  lr = false,
  prog = false,
  hold_time = 0,
  drag = false,
}

tree_settings = {
  --left page
  {name = 'Trunk Width', val = 5, min = 1, max = 24, step = 1, update = function() update_trunk_width() end},
  {name = 'Trunk Height', val = 38, min = 16, max = 80, step = 1, update = function() update_trunk_height() end},
  {name = 'Step Height', val = 8, min = 1, max = 8, step = 1},
  {name = 'Shift/Step', val = 1, min = 0, max = 8, step = 1},
  {name = 'Sprite ID', val = 0, min = 0, max = 15, step = 1, update = function(self) tree.id = self.val end},
  {name = 'Branch Length', val = 12, min = 8, max = 32, step = 1},
  {name = 'Branch Width', val = 3, min = 2, max = 8, step = 1},
  {name = 'Br. Thickness', val = 2, min = 1, max = 8, step = 1},
  {name = 'Branch Height', val = 4, min = 1, max = 16, step = 1},
  {name = 'Branch Shift', val = 8, min = 1, max = 8, step = 1},
  {name = 'Total Branches', val = 5, min = 0, max = 16, step = 1},
  {name = 'Branch Deviation', val = 16, min = 1, max = 16, step = 1},
  {name = 'Leaf Density', val = 1.0, min = 0, max = 1.0, step = 0.05},
  {name = 'Leaf Cull Dist', val = 2, min = 0, max = 10, step = 1},
  {name = 'Leaf Fill Radius', val = 12, min = 4, max = 24, step = 1},
  {name = 'Leaf Fill Count', val = 65, min = 0, max = 150, step = 5},
  {name = 'Vine count', val = 2, min = 0, max = 10, step = 1},

  --right page
  {name = 'Fruit ID', val = 33, min = 32, max = 47, step = 1},
  {name = 'Fruit Density', val = 0.15, min = 0, max = 1.0, step = 0.05},
  {name = 'Save Width', val = 40, min = 1, max = 128, step = 1},
  {name = 'Save Height', val = 60, min = 1, max = 128, step = 1},
  {name = 'Save X', val = 102, min = 0, max = 239, step = 1},
  {name = 'Save Y', val = 60, min = 0, max = 125, step = 1},
  {name = 'Save ID', val = 256, min = 0, max = 511, step = 1},
  {name = 'BG Color', val = 8, min = 0, max = 15, step = 1},
}

function copyScreenToSprite(startX, startY, width, height, spriteStart)
  local spriteWidth = 8
  local spriteHeight = 8
  local spriteLineBytes = spriteWidth / 2  -- Number of bytes in a sprite line
  local screenLineBytes = 240 / 2  -- Number of bytes in a screen line
  local spritesPerRow = 16  -- Number of sprites per row in sprite RAM

  -- Calculate the number of full and partial sprites to copy
  local numSpritesX = math.ceil(width / spriteWidth)
  local numSpritesY = math.ceil(height / spriteHeight)
  local partialSpriteWidth = width % spriteWidth
  local partialSpriteHeight = height % spriteHeight

  for spriteY = 0, numSpritesY - 1 do
      for spriteX = 0, numSpritesX - 1 do
          local numLines = spriteHeight
          if spriteY == numSpritesY - 1 and partialSpriteHeight > 0 then
              numLines = partialSpriteHeight
          end
          for spriteLine = 0, numLines - 1 do
              -- Calculate the number of bytes to copy for this line
              local copyBytes = spriteLineBytes
              if spriteX == numSpritesX - 1 and partialSpriteWidth > 0 then
                  copyBytes = math.ceil(partialSpriteWidth / 2)
              end

              -- Calculate addresses in screen and sprite RAM
              local screenAddr = 0x0000 + ((startY + spriteY * spriteHeight + spriteLine) * screenLineBytes) + math.floor((startX + spriteX * spriteWidth) / 2)
              local spriteIndex = spriteStart + spriteY * spritesPerRow + spriteX
              local spriteAddr = 0x4000 + (spriteIndex * 32) + spriteLine * spriteLineBytes

              -- Copy the line of the sprite
              memcpy(spriteAddr, screenAddr, copyBytes)
          end
      end
  end
end

function save_tree()
  local t = tree_settings
  local save_width, save_height, save_x, save_y, save_id = t[20].val, t[21].val, t[22].val, t[23].val, t[24].val
  local x, y, w, h = save_x, save_y, save_width, save_height 
  --startX, startY, width, height, spriteStart
  copyScreenToSprite(x, y, w, h, save_id)
  --trace('x: ' .. x .. ' y: ' .. y .. ' w: ' .. w .. ' h: ' .. h)
  sync(0,0,true)
end

function clamp(val, min, max)
  return math.max(min, math.min(val, max))
end

function draw_cable(p1, p2, color, sag)
  -- calculate the length and midpoint of the cable
  local dx = p2.x - p1.x
  local dy = p2.y - p1.y
  local length = math.sqrt(dx * dx + dy * dy)
  local midpoint = { x = (p1.x + p2.x) / 2, y = (p1.y + p2.y) / 2 }

  -- calculate the height of the sag
  local sag_height = math.max(length / 8, sag)

  -- draw the cable
  for x = 0, length do
    local y = math.sin(x / length * math.pi) * sag_height
    local px = p1.x + dx * x / length + 0.5
    local py = p1.y + dy * x / length + y + 0.5
    if x > 0 then
      local px_prev = p1.x + dx * (x - 1) / length + 0.5
      local py_prev = p1.y + dy * (x - 1) / length + math.sin((x - 1) / length * math.pi) * sag_height + 0.5
      line(px_prev, py_prev, px, py, color)
    else
      pix(px, py, color)
    end
  end
end

function remap(n, a, b, c, d)
  return c + (n - a) * (d - c) / (b - a)
end

function prints(txt, x, y, bg, fg, shadow_offset)
  bg, fg = bg or 0, fg or 4
  shadow_offset = shadow_offset or {x = 1, y = 0}
  print(txt, x + shadow_offset.x, y + shadow_offset.y, bg, false, 1, true)
  print(txt, x, y, fg, false, 1, true)
end

function text_width(txt)
  return print(txt, 0, -10, 0, false, 1, true)
end

function hovered(_mouse, _box)
  local mx, my, bx, by, bw, bh = _mouse.x, _mouse.y, _box.x, _box.y, _box.w, _box.h
  return mx >= bx and mx < bx + bw and my >= by and my < by + bh
end

function update_cursor_state()
  local x, y, l, m, r, sx, sy = mouse()
  --update hold state for left and right click
  if l and cursor.l and not cursor.held_left and not cursor.r then
    cursor.held_left = true
  end

  if r and cursor.r and not cursor.held_right and not cursor.l then
    cursor.held_right = true
  end

  if cursor.held_left or cursor.held_right then
    cursor.hold_time = cursor.hold_time + 1
  end

  if not l and cursor.held_left then
    cursor.held_left = false
    cursor.hold_time = 0
  end

  if not r and cursor.held_right then
    cursor.held_right = false
    cursor.hold_time = 0
  end

  cursor.lx, cursor.ly, cursor.ll, cursor.lm, cursor.lr, cursor.lsx, cursor.lsy = cursor.x, cursor.y, cursor.l, cursor.m, cursor.r, cursor.sx, cursor.sy
  cursor.x, cursor.y, cursor.l, cursor.m, cursor.r, cursor.sx, cursor.sy = x, y, l, m, r, sx, sy
end

function draw_ui()
  local col = tree_settings[25].val
  ui.draw_panel(0, 0, 240, 136, col, 9, false)
  prints('Tree Generator', 120 - text_width('Tree Generator')/2, 3)
  --left set of ui buttons
  for i = 1, 17 do
    local v = tree_settings[i]
    local x, y = 4, 15 + (i-1) * 7
    prints(v.name, x, y)
    --x, y, flip, id, color, shadow_color, hover_color
    if ui.draw_button(62, y - 1, 1, UI_ARROW, 9, 0, 10) then
      v.val = clamp(v.val - v.step, v.min, v.max)
      if v.update then v:update() end
      --generate_tree()
    end
    if ui.draw_button(81, y - 1, 0, UI_ARROW, 9, 0, 10) then
      v.val = clamp(v.val + v.step, v.min, v.max)
      if v.update then v:update() end
      --generate_tree()
    end
    prints(v.val, 76 - floor(text_width(v.val)/2), y)
  end
  --right set of ui buttons
  for i = 18, #tree_settings do
    local v = tree_settings[i]
    local x, y = 165, 15 + (i-18) * 7
    prints(v.name, x, y)
    --x, y, flip, id, color, shadow_color, hover_color
    if ui.draw_button(x + 50, y - 1, 1, UI_ARROW, 9, 0, 10) then
      v.val = clamp(v.val - v.step, v.min, v.max)
      if v.update then v:update() end
      --generate_tree()
    end
    if ui.draw_button(x + 65, y - 1, 0, UI_ARROW, 9, 0, 10) then
      v.val = clamp(v.val + v.step, v.min, v.max)
      if v.update then v:update() end
      --generate_tree()
    end
    prints(v.val, x + 62 - floor(text_width(v.val)/2), y)
  end


  --Re-genrate tree button
  if ui.draw_button(3, 3, 0, UI_BUTTON, 12, 0, 11) then
    local width, height, step, rotation, id = table.unpack(tree_settings)
    tree = generate_tree(tx, ty, width.val, height.val, step.val, rotation.val, id.val)
  end

end

function generate_tree()
  --generate the main trunk
  tree = {}
  local t = tree_settings
  local tw, th, sh, ss, sid = t[1], t[2], t[3], t[4], t[5]
  local bl, bw, bt, bh, bs, nb, bd, lc, vn = t[6], t[7], t[8], t[9], t[10], t[11], t[12], t[14], t[17]
  local rad, count = t[15], t[16].val
  tree.id = sid.val
  local x, y = tx, ty
  tree.trunk = {{x1 = x, y1 = y, x2 = x + tw.val, y2 = y}}
  local i, last_height = 2, y
  while last_height > y - th.val do
    last_height = clamp(last_height - sh.val, y - th.val, y)
    local x1, x2 = tree.trunk[i-1].x1, tree.trunk[i-1].x2
    local shift = floor(math.random(-ss.val, ss.val))
    tree.trunk[i] = {x1 = x1 + shift, y1 = last_height, x2 = x2 + shift, y2 = last_height}
    i = i + 1
  end
  
  --generate the branches
  tree.branches = {}
  for i = 1, nb.val do
    tree.branches[i] = {}
    tree.branches[i].wood = generate_branch(i)
    tree.branches[i].leaves = generate_leaves(tree.branches[i].wood)
    tree.branches[i].fruit = generate_fruit(tree.branches[i].wood)
  end

    --generate top leaves fill
    tree.fleaves = {[1] = {}, [2] = {}}
    local sx, sy = tree.trunk[#tree.trunk].x1 + t[1].val/2 - 4, ty - t[2].val - rad.val
    for i = 1, count do
      --local x, y = floor(sx + math.sin(math.random(-10, 10)*100)), floor(sy + math.cos(math.random(-10, 10)*100))
      --circb(x, y, 6, 2)
      if math.random() < 0.5 then
        local side = math.random() > 0.5
        local angle = math.random() * 2 * math.pi -- Random angle in radians
        local distance = math.sqrt(math.random()) * rad.val -- Random distance within the radius
        local x = sx + distance * math.cos(angle)
        local y = sy + distance * math.sin(angle)
        table.insert(side and tree.fleaves[1] or tree.fleaves[2], {x = x, y = y, id = floor(math.random(2))})
      end
    end
    --generate hanging vines
    tree.vines = {}
    for i = 1, vn.val do
      table.insert(tree.vines, generate_vine())
    end
  return tree
end

function generate_leaves(branch)
  local leaves = {[1] = {}, [2] = {}}
  local leaf_density = tree_settings[13].val
  for i = #branch, 1, -1 do
    local step = 1
    if branch[i].x1 and math.random() < leaf_density then
      local xv = branch[i].x1 - 4
      local yv = branch[i].y1 - 4
      --local x = clamp(xv, tx + tw.val/2 - 16, tx + tw.val/2 + 16)
      --local y = clamp(yv, ty - th.val, ty)
      local side = math.random() > 0.5
      table.insert(side and leaves[1] or leaves[2], {x = xv, y = yv, id = floor(math.random(2))})
    end
    if branch[i].x1 and math.random() < leaf_density then
      local xv = branch[i].x2 - 4
      local yv = branch[i].y2 - 4
      local side = math.random() > 0.5
      table.insert(side and leaves[1] or leaves[2], {x = xv, y = yv, id = floor(math.random(2))})
    end
    step = step + 1
  end
  return leaves
end

function generate_fruit(branch)
  local t = tree_settings
  local fruit_id, fruit_count = t[18].val, t[19].val
  local fruit = {[1] = {}, [2] = {}}
  for i = #branch, 1, -1 do
    local step = 1
    if branch[i].x1 and math.random() < fruit_count then
      local xv = branch[i].x1 - 4
      local yv = branch[i].y1 - 4
      --local x = clamp(xv, tx + tw.val/2 - 16, tx + tw.val/2 + 16)
      --local y = clamp(yv, ty - th.val, ty)
      local side = math.random() > 0.5
      table.insert(side and fruit[1] or fruit[2], {x = xv, y = yv, id = floor(math.random(2))})
    end
    if branch[i].x1 and math.random() < fruit_count then
      local xv = branch[i].x2 - 4
      local yv = branch[i].y2 - 4
      local side = math.random() > 0.5
      table.insert(side and fruit[1] or fruit[2], {x = xv, y = yv, id = floor(math.random(2))})
    end
    step = step + 1
  end
  return fruit
end

function generate_branch(n)
  local t = tree_settings
  local tw, th, sh, ss, id = t[1], t[2], t[3], t[4], t[5]
  local bl, bw, bt, bh, bs, nb, bd, lc = t[6], t[7], t[8], t[9], t[10], t[11], t[12], t[14]
  local voff = clamp(n*(floor(math.random(-bd.val,bd.val))), -2, 12)
  local dir = n%2 == 0
  --find vertical trunk segment to attach branch
  local max_height = ty - th.val
  local index = math.ceil(remap(bh.val, 1, 16, 1, #tree.trunk - 1))
  local x1 = dir and tree.trunk[index + 1].x2 or tree.trunk[index + 1].x1
  local y1 = clamp(tree.trunk[index+1].y1 - voff, max_height, ty)
  local x2 = dir and tree.trunk[index].x2 or tree.trunk[index].x1
  local y2 = clamp(y1 + bt.val, max_height, ty)
  local x, y = tx, ty
  local branch = {{x1 = x1, y1 = y1, x2 = x2, y2 = y2}}
  local i, last_x = 2, not dir and x or x + tw.val
  if dir then
    while last_x < x + bl.val + tw.val do
      last_x = clamp(last_x + bw.val, x, x + bl.val + tw.val)
      local shift = floor(math.random(bs.val))
      local x1, x2, y1, y2 = last_x, last_x, branch[i-1].y1 - shift, branch[i-1].y2 - shift
      --x1 = floor(clamp(x1, tx + tw.val/2 - 20, tx + tw.val/2 + 20))
      --y1 = floor(clamp(y1, ty - th.val, ty))
      --x2 = floor(clamp(x2, tx + tw.val/2 - 20, tx + tw.val/2 + 20))
      --y2 = floor(clamp(y2, ty - th.val, ty))
      branch[i] = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
      i = i + 1
    end
  else
    while last_x > x - bl.val do
      last_x = clamp(last_x - bw.val, x - bl.val, x)
      local shift = floor(math.random(bs.val))
      local x1, x2, y1, y2 = last_x, last_x, branch[i-1].y1 - shift, branch[i-1].y2 - shift
      --x1 = floor(clamp(x1, tx + tw.val/2 - 20, tx + tw.val/2 + 20))
      --y1 = floor(clamp(y1, ty - th.val, ty))
      --x2 = floor(clamp(x2, tx + tw.val/2 - 20, tx + tw.val/2 + 20))
      --y2 = floor(clamp(y2, ty - th.val, ty))
      branch[i] = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
      i = i + 1
    end
  end
  return branch
end

function generate_vine()
  local vine = {}
  local branch1, branch2 = math.ceil(math.random(#tree.branches)), math.ceil(math.random(#tree.branches))
  local p1, p2 = tree.branches[branch1].wood[math.ceil(math.random(#tree.branches[branch1].wood))], tree.branches[branch2].wood[math.ceil(math.random(#tree.branches[branch2].wood))]
  return {x1 = p1.x1, y1 = p1.y1, x2 = p2.x2, y2 = p2.y2, color = 7 - floor(math.random(2)), sag = floor(math.random(10, 20))}
end

function update_trunk_width()
  local trunk_width = tree_settings[1].val
  for i = 1, #tree.trunk do
    local old_width = tree.trunk[i].x2 - tree.trunk[i].x1
    tree.trunk[i].x1 = tree.trunk[i].x1 + floor(old_width/2) - floor(trunk_width/2)
    tree.trunk[i].x2 = tree.trunk[i].x1 + trunk_width
  end
end

function update_trunk_height(old_height)
  local last_index = #tree.trunk
  local old_height = ty - tree.trunk[last_index].y1
  local new_height = tree_settings[2].val
  local step = tree_settings[3].val
  local ss = tree_settings[4].val
  local segment_height = tree.trunk[last_index - 1].y1 - tree.trunk[last_index].y1
  --if we're taller now
  if old_height < new_height then
    if segment_height < step then
      --raise current line
      tree.trunk[last_index].y1 = tree.trunk[last_index].y1 - 1
      tree.trunk[last_index].y2 = tree.trunk[last_index].y2 - 1
    else
      --add additional segment
      local shift = floor(math.random(-ss, ss))
      table.insert(tree.trunk, {x1 = tree.trunk[last_index].x1 + shift, y1 = tree.trunk[last_index].y1 - 1, x2 = tree.trunk[last_index].x2 + shift, y2 = tree.trunk[last_index].y2 - 1})      
    end
  else
    --we're shorter now
    if segment_height > 1 then
      --reduce top segment
      tree.trunk[last_index].y1 = tree.trunk[last_index].y1 + 1
      tree.trunk[last_index].y2 = tree.trunk[last_index].y2 + 1
    else
    --or delete segment if h == 0
      table.remove(tree.trunk, last_index)
    end
  end
end

function mesh_fill(lines, id)
  id = id or 0
  local u = 8 * (id % 16)
  local v = 8 * floor(id / 16)
  for i = 1, #lines - 1 do
    --line(floor(tree.trunk[i].x1), floor(tree.trunk[i].y1), floor(tree.trunk[i+1].x1), floor(tree.trunk[i+1].y1), i%2 == 0 and 2 or 9)
    --line(floor(tree.trunk[i].x2), floor(tree.trunk[i].y2), floor(tree.trunk[i+1].x2), floor(tree.trunk[i+1].y2), i%2 == 0 and 2 or 9)
        -- Draw bottom triangle
        ttri(
          lines[i+0].x1, lines[i+0].y1,
          lines[i+0].x2, lines[i+0].y2,
          lines[i+1].x1, lines[i+1].y1,
          u, v+8, u+8, v+8, u, v, 0, 1
        )
    
        -- Draw top triangle
        ttri(
          lines[i+0].x2, lines[i+0].y2,
          lines[i+1].x1, lines[i+1].y1,
          lines[i+1].x2, lines[i+1].y2,
          u+8, v+8, u, v, u+8, v, 0, 1
        )
  end
end

function draw_tree()
  local t = tree_settings
  local tw, th, sh, ss, sid = t[1].val, t[2].val, t[3].val, t[4].val, t[5].val
  local bl, bw, bt, bh, bs, nb, bd, ld, leaf_cull_distance = t[6].val, t[7].val, t[8].val, t[9].val, t[10].val, t[11].val, t[12].val, t[13], t[14].val
  local fruit_id = t[18].val
  --draw background leaves first
  for k, v in ipairs(tree.branches) do
    --leaves
    for i, j in ipairs(v.leaves[1]) do
      if i <= leaf_cull_distance then
        spr(16 + j.id, j.x, j.y, 1, 1)
      end
    end
    --fruits
    for i, j in ipairs(v.fruit[1]) do
      --if i <= leaf_cull_distance then
        spr(fruit_id, j.x, j.y, 1, 1)
      --end
    end
  end
  
  for k, v in ipairs(tree.fleaves[1]) do
    spr(16 + v.id, v.x, v.y, 1, 1)
  end
  
  --draw main trunk
  mesh_fill(tree.trunk, tree.id)
  
  --draw all branches
  for i = 1, #tree.branches do
    mesh_fill(tree.branches[i].wood, tree.id)
  end
  
  for k, v in ipairs(tree.vines) do
    draw_cable({x = v.x1, y = v.y1}, {x = v.x2, y = v.y2}, v.color, v.sag)
  end
  --draw foreground leaves last
  for k, v in ipairs(tree.branches) do
    for i, j in ipairs(v.leaves[2]) do
      if i <= leaf_cull_distance then
        spr(16 + j.id, j.x, j.y, 1, 1)
      end
    end
        --fruits
        for i, j in ipairs(v.fruit[2]) do
          --if i <= leaf_cull_distance then
            spr(fruit_id, j.x, j.y, 1, 1)
          --end
        end
        for i, j in ipairs(v.fruit[1]) do
          --if i <= leaf_cull_distance then
            spr(fruit_id, j.x, j.y, 1, 1)
          --end
        end
  end

  for k, v in ipairs(tree.fleaves[2]) do
    spr(16 + v.id, v.x, v.y, 1, 1)
  end

end

tree = generate_tree()

function TIC()
  cls(8)
  --cursor
  poke(0x3FFB, UI_CURSOR)
  --border
  poke(0x03FF8, 8)
  update_cursor_state()
  draw_ui()
  draw_tree()
  if keyp(20) then
    save_tree()
  end
    --save button
    prints('Save ->', 198, 4)
    if ui.draw_button(225, 3, 0, UI_BUTTON2, 12, 0, 11) then
      trace('saving tree')
      save_tree()
    end
  local t = tree_settings
  local save_width, save_height, save_x, save_y, save_id = t[20].val, t[21].val, t[22].val, t[23].val, t[24].val
  local x, y, w, h = save_x, save_y, save_width, save_height 
  rectb(x-1, y-1, w+2, h+2, 2)
  tick = tick + 1
end

-- <TILES>
-- 000:bbbbcb0000bcb00c00bbc000b00cbc0000bbcbbc0bbcb0cbbbbbc00cbbcb000b
-- 001:0bbbb0b0bbb0bbbbbbbbb0bb0b0bbbbb0bbbbbb0bbb0b0bbbb0bb0bb0bbb0bb0
-- 002:3333323233333233333333233333333233333232333332333333322333333322
-- 003:1122331111322311112223111122331111322311112223111122331111322311
-- 004:1333323113323221133233211333323113333321133233211333322113323231
-- 005:11bcbb1111bbdc1111bcbd1111bbcb1111bcbc1111bbcb1111bccb1111bcdc11
-- 006:eeeeeffeeefeefefeeeeeeefeeeeeeffeeeeeeeeeeeeeffeeeeeeeefefeeefef
-- 007:4344e44e4344e4e43444e4ee3444e4e443344eee3444444e3444e4e43344e4ee
-- 008:1111111111111111111111111111111111111111111111111111111111111111
-- 009:1111111111111111111111111111111111111111111111111111111111111111
-- 010:1111111111111111111111111111111111111111111111111111111111111111
-- 011:1111111111111111111111111111111111111111111111111111111111111111
-- 012:1111111111111111111111111111111111111111111111111111111111111111
-- 013:1111111111111111111111111111111111111111111111111111111111111111
-- 014:1111111111111111111111111111111111111111111111111111111111111111
-- 015:1111111111111111111111111111111111111111111111111111111111111111
-- 016:1111111111656561165656565567676516767676177777771177777111111111
-- 017:1111111111656561165656565567676516767676177777771177777111111111
-- 018:1111111111577671156567675656567615757555156567671156557111111111
-- 019:1111111112443411232343414242424132343432232323211222221111111111
-- 020:1111111111422321143432324343432314242444143432321143442111111111
-- 021:1111111112443411232343414242424132323232222222211222221111111111
-- 032:1b111111bdb111111b1111111111111111111111111111111111111111111111
-- 033:111157b111177b3b117171b1171b751111b3b171111b11611151111711171111
-- 034:7761111771771176611b117111b6b671117b11711b611b71b7b1b7b11b711b11
-- 035:117111111117111111132111112222111122b211111221111111111111111111
-- 036:1167711111111711111176111167111111173111113333111133431111133111
-- 037:1111111111111111111111111111111111111111111111111111111111111111
-- 048:1111111111656561165656565567676516767676177777771177777111111111
-- 049:1111111111577671156567675656567615757555156567671156557111111111
-- 050:1111111116565611656565615676765567676761777777711777771111111111
-- 051:1111111111111111111111111111111111111111111111111111111111111111
-- 052:1111111111111111111111111111111111111111111111111111111111111111
-- 053:1111111111111111111111111111111111111111111111111111111111111111
-- 064:1b111111bdb111111b1111111111111111111111111111111111111111111111
-- 065:111157b111177b3b117171b1171b751111b3b171111b11611151111711171111
-- 066:1111111111111111111111111111111111111111111111111111111111111111
-- 067:1111111111111111111111111111111111111111111111111111111111111111
-- 068:1111111111111111111111111111111111111111111111111111111111111111
-- 069:1111111111111111111111111111111111111111111111111111111111111111
-- 224:0011110001111100111888001188880011888800118888000000000000000000
-- 240:1111111111141111111c4111111cc411111cc211111c21111112111111111111
-- 241:1111111111111111114441111400c4111c0c0c111cc00c1112ccc21111222111
-- 242:144444414cc0ccc4ccc00cccccc000ccccc00cccccc0cccc2cccccc212222221
-- </TILES>

-- <SPRITES>
-- 000:8888888888888888888888888888888888888888888888888888888888888888
-- 001:8888888888888888888888888888888588888888888888888888888888888888
-- 002:8885656786565656656575755675656767675655777777788777778888888885
-- 003:6788888876888888558888886788888878888888857767885656767865656768
-- 004:8888888888888888888888888888888888888888888888888888888888888888
-- 015:b0000000bb000000bbc00000bde0000000000000000000000000000000000000
-- 016:8888888888885776888565678856577688856567885656568885757588856567
-- 017:8888888878888888678888887688888867888865768886565557556765656676
-- 018:8885776788565656866565656556767665675776565665656765565676767575
-- 019:5757555856567678656557565765657757767656656767655656765775755556
-- 020:8888888888888888857767886756767876756768676755585556767876755778
-- 032:8888565588888888888888878888887888885776888565678856565688857575
-- 033:565657777575757705656765b75655567bc78565678658577688785655888585
-- 034:7777656577765656776767655676767665676777575557775676777765577777
-- 035:6567676556557567565776776565676756565676657575557565676777565577
-- 036:5776676877775558767676785667578865668888765588886767888877788888
-- 048:8885656788885655888888888888888088888885888888568888856588885757
-- 049:67888058788888b5888888088888888b77678880567678886567688857555887
-- 050:888880cb888800bc55880bc08855bcb08857b555077b3bb07878bbc08b750cbb
-- 051:00880777b8bb0558c0055888b55c888858b88888b8088888cc888888bc888888
-- 052:7768888886888888868888888688888886888888868888888688888886888888
-- 064:8885655688565655888575758885656788885655888888888888888888888888
-- 065:5676788865578888558888886757767875656767565656768575755585656767
-- 066:b3b07bcb8b806c0c588bb700878bcb06888bbcb08880bb0c8880bc008880cb00
-- 067:c888888888888888888888888888888868888888688888866888888668888886
-- 068:6888888868888888688888886888888868888888888888888888888888888888
-- 080:8888888888888888888888888888888888888888888888888888888888888888
-- 081:885655788888bcb8888880cb888888cc8888888c888888878888888888888887
-- 082:8800bcb8880bc0c88857b008b77b3bb87877bb080b753bc8b3bb70088b756c08
-- 083:8688888686888868868888688868886888688688888666888888888888888888
-- 084:8888888888888888888888888888888888888888888888888888888888888888
-- 096:8888888888888888888888888888888888888888888888888888888888888888
-- 097:8888888888888888888888888888888888888888888888888888888888888888
-- 098:53bb77c8870b60b858bbb7c887bcb0b888bbbb08880bc0c8880bb00888b0cc08
-- 099:8888888888888888888888888888888888888888888888888888888888888888
-- 100:8888888888888888888888888888888888888888888888888888888888888888
-- 112:8888888888888888888888888888888800000000000000000000000000000000
-- 113:8888888888888888888888888888888800000000000000000000000000000000
-- 114:880bbbc8880bc0b888bbb0c888bcb0b800000000000000000000000000000000
-- 115:8888888888888888888888888888888800000000000000000000000000000000
-- 116:8888888888888888888888888888888800000000000000000000000000000000
-- </SPRITES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <SCREEN>
-- 000:889999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999988
-- 001:899999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999998
-- 002:999888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888999
-- 003:998888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888444088888888888888844088888888888888888888840888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 004:9988888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888408404084408440884088844044088440404044084440840840408888888888888888888888888888888888888888888888888888440888888888888888888408888bb0bbb88888899
-- 005:99888ccc8888888888888888888888888888888888888888888888888888888888888888888888888888888888888840844084040404088404040404040404044088440840840404408888888888888888888888888888888888888888888888888888408844084040844088888884088bbb00bbb8888899
-- 006:9988c00cc888888888888888888888888888888888888888888888888888888888888888888888888888888888888840840884408440888404044084040440840884040840840404088888888888888888888888888888888888888888888888888888840884404040404088444088408bbb000bb8888899
-- 007:9988c0c0c888888888888888888888888888888888888888888888888888888888888888888888888888888888888840840888440844088844084404040844040884440884084084088888888888888888888888888888888888888888888888888888884040404040440888888884088bbb00bbb8888899
-- 008:9988cc00c888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888440844408408844088888840888bbb0bbbb8888899
-- 009:99880ccc0888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888bbbbbbbb8888899
-- 010:9988800088888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888bbbbbb88888899
-- 011:998888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 012:998888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 013:998888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 014:998888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 015:998844408888888888884088884040408840840840888888888888888888888888988888884440888888988888888888888888888888888888888888888888888888888888888888888888888888888888888444088888888408408884440440888888888888888888888888888988844084408889888899
-- 016:998884084040404044084040884040888440444044088888888888888888888889988888884088888888998888888888888888888888888888888888888888888888888888888888888888888888888888888408840404040884440888408404088888888888888888888888889988888408840889988899
-- 017:998884084408404040404408884040404040840840408888888888888888888899988888884408888888999888888888888888888888888888888888888888888888888888888888888888888888888888888440844084040408408888408404088888888888888888888888899988884088408889998899
-- 018:998884084088404040404408884440404040840840408888888888888888888809988888888840888888990888888888888888888888888888888888888888888888888888888888888888888888888888888408840884040408408888408404088888888888888888888888809988888408840889908899
-- 019:998884084088844040404040884440408440884040408888888888888888888880988888884408888888908888888888888888888888888888888888888888888888888888888888888888888888888888888408840888440408840884440440888888888888888888888888880988844084408889088899
-- 020:998888888888888888888888888888888888888888888888888888888888888888088888888888888888088888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888088888888888880888899
-- 021:998888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 022:998844408888888888884088884040888840888840888408888888888888888888988888440844408888988888888888888888888888888888888888888888888888888888888888888888888888888888888444088888888408408884408888888888888408408888888888888984408884084440888899
-- 023:998884084040404044084040884040844088844044084440888888888888888889988888884040408888998888888888888888888888888888888888888888888888888888888888888888888888888888888408840404040884440884040844044088440884440404088888889940408844084089988899
-- 024:998884084408404040404408884440404040404040408408888888888888888899988888840844408888999888888888888888888888888888888888888888888888888888888888888888888888888888888440844084040408408884040404040404408408408404088888899940408884084409998899
-- 025:998884084088404040404408884040440840444040408408888888888888888809988888884040408888990888888888888888888888888888888888888888888888888888888888888888888888888888888408840884040408408884040440840408840408408844088888809940408884088840908899
-- 026:998884084088844040404040884040844040884040408840888888888888888880988888440844408888908888888888888888888888888888888888888888888888888888888888888888888888888888888408840888440408840884408844040404408408840884088888880944084044404409088899
-- 027:998888888888888888888888888888888888840888888888888888888888888888088888888888888888088888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888840888888888088888888888880888899
-- 028:998888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 029:998884408408888888888840408888408888408884088888888888888888888888988888884440888888988888888888888888888888888888888888888888888888888888888888888888888888888888888844088888888888888404040884084084088888888888888888888988840408440889888899
-- 030:998840884440844044088840408440888440440844408888888888888888888889988888884040888888998888888888888888888888888888888888888888888888888888888888888888888888888888888408844084040844088404088844044404408888888888888888889988840404040889988899
-- 031:998884088408404040408844404040404040404084088888888888888888888899988888884440888888999888888888888888888888888888888888888888888888888888888888888888888888888888888840884404040404088404040404084084040888888888888888899988844404040889998899
-- 032:998888408408440840408840404408404440404084088888888888888888888809988888884040888888990888888888888888888888888888888888888888888888888888888888888888888888888888888884040404040440888444040404084084040888888888888888809988888404040889908899
-- 033:998844088840844044088840408440408840404088408888888888888888888880988888884440888888908888888888888888888888888888888888888888888888888888888888888888888888888888888440844408408844088444040844088404040888888888888888880988888404408889088899
-- 034:998888888888888840888888888888888408888888888888888888888888888888088888888888888888088888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888088888888888880888899
-- 035:998888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 036:998884404088408840840888888440840888888888888888888888888888888888988888888408888888988888888888888888888888888888888888888888888888888888888888888888888888888888888844088888888888888404088884088884088840888888888888888988884408440889888899
-- 037:998840884408888408444088404088444084404408888888888888888888888889988888884408888888998888888888888888888888888888888888888888888888888888888888888888888888888888888408844084040844088404084408884404408444088888888888889988840884040889988899
-- 038:998884084040404440840884088408840840404040888888888888888888888899988888888408888888999888888888888888888888888888888888888888888888888888888888888888888888888888888840884404040404088444040404040404040840888888888888899988844404040889998899
-- 039:998888404040408408840840888840840844084040888888888888888888888809988888888408888888990888888888888888888888888888888888888888888888888888888888888888888888888888888884040404040440888404044084044404040840888888888888809988840404040889908899
-- 040:998844084040408408884088884408884084404408888888888888888888888880988888884440888888908888888888888888888888888888888888888888888888888888888888888888888888888888888440844408408844088404084404088404040884088888888888880988844404408889088899
-- 041:998888888888888888888888888888888888884088888888888888888888888888088888888888888888088888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888884088888888888888888888888088888888888880888899
-- 042:998888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 043:998884408888888840840888888844404408888888888888888888888888888888988888888440888888988888888888888888888888888888888888888888888888888888888888888888888888888888888844088888888888888404088888888888888888888888888888888988408844044089888899
-- 044:998840884408404088444084408884084040888888888888888888888888888889988888884040888888998888888888888888888888888888888888888888888888888888888888888888888888888888888408844084040844088404088888888888888888888888888888889984408404088409988899
-- 045:998884084040440840840840408884084040888888888888888888888888888899988888884040888888999888888888888888888888888888888888888888888888888888888888888888888888888888888840884404040404088840888888888888888888888888888888899988408404084089998899
-- 046:998888404040408840840844088884084040888888888888888888888888888809988888884040888888990888888888888888888888888888888888888888888888888888888888888888888888888888888884040404040440888404088888888888888888888888888888809988408404040889908899
-- 047:998844084408408840884084408844404408888888888888888888888888888880988888884408888888908888888888888888888888888888888888888888888888888888888888888888888888888888888440844408408844088404088888888888888888888888888888880984440440844409088899
-- 048:998888884088888888888888888888888888888888888888888888888888888888088888888888888888088888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888088888888888880888899
-- 049:998888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 050:998844088888888888888888408888408888888888888884084088888888888888988888840844088888988888888888888888888888888888888888888888888888888888888888888888888888888888888844088888888888888404088888888888888888888888888888888988884408440889888899
-- 051:998840404040440844088440440888408884404408844044404408888888888889988888440888408888998888888888888888888888888888888888888888888888888888888888888888888888888888888408844084040844088404088888888888888888888888888888889988840884040889988899
-- 052:998844084408844040404088404088408840404040404084084040888888888899988888840884088888999888888888888888888888888888888888888888888888888888888888888888888888888888888840884404040404088840888888888888888888888888888888899988844404040889998899
-- 053:998840404088404040404088404088408844084040444084084040888888888809988888840840888888990888888888888888888888888888888888888888888888888888888888888888888888888888888884040404040440888840888888888888888888888888888888809988840404040889908899
-- 054:998844084088444040408440404088444084404040884088404040888888888880988888444044408888908888888888888888888888888888888888888888888888888888888888888888888888888888888440844408408844088840888888888888888888888888888888880988844404408889088899
-- 055:998888888888888888888888888888888888888888840888888888888888888888088888888888888888088888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888088888888888880888899
-- 056:998888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 057:998844088888888888888888408888404040884084084088888888888888888888988888884408888888988888888888888888888888888888888888888888888888888888888888888888888888888888888844088888888888888444044088888888888888888888888888888984408444084409888899
-- 058:998840404040440844088440440888404088844044404408888888888888888889988888888840888888998888888888888888888888888888888888888888888888888888888888888888888888888888888408844084040844088840840408888888888888888888888888889988840408840889988899
-- 059:998844084408844040404088404088404040404084084040888888888888888899988888888408888888999888888888888888888888888888888888885776788888888888888888888888888888888888888840884404040404088840840408888888888888888888888888899988408440844409998899
-- 060:998840404088404040404088404088444040404084084040888888888888888809988888888840888888990888888888888888888888888888888888856567678888888888888888888888888888888888888884040404040440888840840408888888888888888888888888809984088884040409908899
-- 061:998844084088444040408440404088444040844088404040888888888888888880988888884408888888908888888888888888888888888888888886565656768888888888888888888888888888888888888440844408408844088444044088888888888888888888888888880984440440844409088899
-- 062:998888888888888888888888888888888888888888888888888888888888888888088888888888888888088888888888888888888888888888888865657575558888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888088888888888880888899
-- 063:998888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888556756567678888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 064:998844088888888844404088408888408888888888888888888888888888888888988888884408888888988888888888888888888888888888888867675655788888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 065:998840404040888884084408888440404044088440844084408888888888888889988888888840888888998888888888888888888888888888888877777778857767888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 066:998844084408888884084040404088440840404040440844088888888888888899988888888408888888999888888888888888888888888888888887777788565676788888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 067:998840404088888884084040404088440840404408884088408888888888888809988888884088888888990888888888888888888888888888888888888885656567688888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 068:998844084088408884084040408440404040408440440844088888888888888880988888884440888888908888888888888888888888888888888888857767575755588888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 069:998888888888888888888888888888888888888888888888888888888888888888088888888888888888088888888888888888888857767888888888565656565676788888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 070:998888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888565676788888886656565656557568577678888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 071:998844088888888888888888408888404088884088884088840888888888888888988888884040888888988888888888888888885657767688888865567676576565776756767888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 072:998840404040440844088440440888404084408884404408444088888888888889988888884040888888998888888888888888888565676788886565675776577676567675676888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 073:998844084408844040404088404088444040404040404040840888888888888899988888884440888888999888888888888888885656567688865656566565656767656767555888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 074:998840404088404040404088404088404044084044404040840888888888888809988888888840888888990888888888888888888575755557556767655656565676575556767888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 075:998844084088444040408440404088404084404088404040884088888888888880988888888840888888908888888888888888888565676565667676767575757555567675577888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 076:998888888888888888888888888888888888888884088888888888888888888888088888888888888888088888888888888888888856555656577777776565656767655776676888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 077:998888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888887575757777765656565575677777555888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 078:998844088888888888888888408888844040884088408408888888888888888888988888884440888888988888888888888888888888870565676577676765565776777676767888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 079:99884040404044084408844044088840884408888408444088888888888888888998888888404088888899888888888888888888888878b756555656767676656567675667578888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 080:998844084408844040404088404088840840404044408408888888888888888899988888884440888888999888888888888888888857767bc7856565676777565656766566888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 081:998840404088404040404088404088884040404084088408888888888888888809988888884040888888990888888888888888888565676786585757555777657575557655888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 082:998844084088444040408440404088440840404084088840888888888888888880988888884440888888908888888888888888885656567688785656767777756567676767888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 083:998888888888888888888888888888888888888888888888888888888888888888088888888888888888088888888888888888888575755588858565577777775655777778888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 084:9988888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888885656767888058888880cb008807777768888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 085:99884440888884088888440888440888888888888888884088888888888888888898888888444088888898888888888888888888885655788888b5888800bcb8bb05588688888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 086:998884088408444044088408884040404044084408844044088440844088888889988888884088888888998888888888888888888888888888880855880bc0c00558888688888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 087:998884084040840884408408884408440884404040408840404040440888888899988888884408888888999888888888888888888888808888888b8855bcb0b55c88888688888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 088:99888408404084084040840888404040884040404040884040440888408888880998888888884088888899088888888888888888888885776788808857b55558b888888688888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 089:9988840884088840444044408844084088444040408440404084404408888888809888888844088888889088888888888888888888885656767888077b3bb0b80888888688888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 090:99888888888888888888888888888888888888888888888888888888888888888808888888888888888808888888888888888888888565656768887878bbc0cc8888888688888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 091:99888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888885757575558878b750cbbbc8888888688888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 092:9988440888888888888888884088884408888888884088888408408888888888889888888408844088889888888888888888888885655656767888b3b07bcbc88888886888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 093:99884040404044084408844044088840408440404088440844408884084408888998888844084088888899888888888888888888565655655788888b806c0c888888886888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 094:9988440844088440404040884040884040404040404084408408404040404088999888888408444088889998888888888888888885757555888888588bb700888888886888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 095:9988404040884040404040884040884040440840404040408408404040404088099888888408404088889908888888888888888885656767577678878bcb06888888886888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 096:9988440840884440404084404040884408844084084044408840408408404088809888884440444088889088888888888888888888565575656767888bbcb0688888886888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 097:99888888888888888888888888888888888888888888888888888888888888888808888888888888888808888888888888888888888888565656768880bb0c688888868888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 098:99888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888857575558880bc00688888868888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 099:99884088888888888840884408888888888888408408888888888888888888888898888840888844088898888888888888888888888888856567678880cb00688888868888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 100:99884088844044088408884040844044088440884440404088888888888888888998888440888404088899888888888888888888888888885655788800bcb8868888868888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 101:998840884040844044408840404040404044084084084040888888888888888899988888408884040888999888888888888888888888888888bcb8880bc0c8868888688888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 102:99884088440840408408884040440840408840408408844088888888888888880998888840888404088899088888888888888888888888888880cb8857b008868888688888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 103:99884440844044408408884408844040404408408840884088888888888888888098888444040440888890888888888888888888888888888888ccb77b3bb8886888688888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 104:998888888888888888888888888888888888888888888408888888888888888888088888888888888888088888888888888888888888888888888c7877bb08886886888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 105:99888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888870b753bc8888666888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 106:9988408888888888884088844088884408440888440840888884088888888888889888888844088888889888888888888888888888888888888888b3bb7008888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 107:99884088844044088408884088404084088408884040888440444088888888888998888888884088888899888888888888888888888888888888878b756c08888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 108:998840884040844044408840884040840884088840404044088408888888888899988888888408888888999888888888888888888888888888888853bb77c8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 109:9988408844084040840888408840408408840888404040884084088888888888099888888840888888889908888888888888888888888888888888870b60b8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 110:998844408440444084088884408440444044408844084044088840888888888880988888884440888888908888888888888888888888888888888858bbb7c8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 111:998888888888888888888888888888888888888888888888888888888888888888088888888888888888088888888888888888888888888888888887bcb0b8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 112:998888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888bbbb08888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 113:9988408888888888884088444040440844088844088888884040888888888888889888888408440888889888888888888888888888888888888888880bc0c8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 114:9988408884404408840888408888840884088840404408844088404084408888899888884408884088889988888888888888888888888888888888880bb008888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 115:998840884040844044408844084084088408884440844040404040404408888899988888840884088888999888888888888888888888888888888888b0cc08888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 116:9988408844084040840888408840840884088844084040404040404088408888099888888408408888889908888888888888888888888888888888880bbbc8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 117:9988444084404440840888408840444044408840404440844040844044088888809888884440444088889088888888888888888888888888888888880bc0b8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 118:998888888888888888888888888888888888888888888888888888888888888888088888888888888888088888888888888888888888888888888888bbb0c8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 119:998888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888bcb0b8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 120:998840888888888888408844404044084408888440888888888888840888888888988888844044408888988888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 121:998840888440440884088840888884088408884088840840404408444088888889988888408840888888998888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 122:998840884040844044408844084084088408884088404040404040840888888899988888444044088888999888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 123:998840884408404084088840884084088408884088404040404040840888888809988888404088408888990888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 124:998844408440444084088840884044404440888440840884404040884088888880988888444044088888908888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 125:998888888888888888888888888888888888888888888888888888888888888888088888888888888888088888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 126:998888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 127:998840404088888888888888888888888888840888888888888888888888888888988888884408888888988888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 128:998840408844088440888440840840404408444088888888888888888888888889988888888840888888998888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 129:998840404040404040884088404040404040840888888888888888888888888899988888888408888888999888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 130:998840404040404408884088404040404040840888888888888888888888888809988888884088888888990888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 131:998884084040408440888440840884404040884088888888888888888888888880988888884440888888908888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 132:998888888888888888888888888888888888888888888888888888888888888888088888888888888888088888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888899
-- 133:999888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888999
-- 134:899999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999998
-- 135:889999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999988
-- </SCREEN>

-- <PALETTE>
-- 000:1010105d245db13e50ef9157ffff6daee65061be3c047f5005344c185dc95999f6e6eaf2b6baba8d8d9d7150042c2404
-- </PALETTE>

