RoachHook.Helpers = {}

RoachHook.Helpers.MouseInBox = function(x, y, w, h)
    local mouseX, mouseY = gui.MousePos()
    return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h
end
RoachHook.Helpers.GetPlayerListID = function(plr)
    local id = 0

    for k,v in ipairs(player.GetAll()) do
        if(v == LocalPlayer()) then continue end
        id = id + 1
        if(v == plr) then return id end
    end
    return id
end
RoachHook.Helpers.GenerateRotatedArrow = function(x, y, scale, ang)
    local ang1 = Angle(0, ang, 0):Forward() * scale
    local ang2 = Angle(0, ang + 120, 0):Forward() * (scale - 1)
    local ang3 = Angle(0, ang - 120, 0):Forward() * (scale - 1)

    local p0 = {x = x, y = y}
    local poly = {
        {x = p0.x + ang1.x, y = p0.y + ang1.y},
        {x = p0.x + ang2.x, y = p0.y + ang2.y},
        {x = p0.x + ang3.x, y = p0.y + ang3.y},
    }
    return poly
end
RoachHook.Helpers.DrawOutlinedPoly = function(poly)
    local last = nil
    for k,v in pairs(poly) do
        if(last) then
            surface.DrawLine(last.x, last.y, v.x, v.y)
            last = v
        else
            last = v
        end
    end
    surface.DrawLine(last.x, last.y, poly[1].x, poly[1].y)
end

local ignoredEntities = {
    ["env_skypaint"] = true,
    ["gmod_hands"] = true,
}
local cachedEntities = {
    ["spawned_money"] = true,
    ["money_printer"] = true,
}
local foundEntities = cachedEntities
RoachHook.Helpers.GetMapEntities = function()
    local entities = foundEntities
    local entts = ents.GetAll()
    for k=0, #entts do
        local v = entts[k]
        if(!v) then continue end
        
        local class = v:GetClass()
        if(v:IsWeapon()) then continue end
        if(v:IsNPC()) then continue end
        if(!v:IsScripted()) then continue end
        if(ignoredEntities[class]) then continue end

        entities[class] = true
    end
    foundEntities = entities

    local classes = {}
    for k,v in pairs(entities) do
        classes[#classes + 1] = k
    end

    return classes
end
RoachHook.Helpers.GetCorners = function(min, max)
    return {
        Vector(min.x, min.y, min.z),
        Vector(min.x, max.y, min.z),
        Vector(max.x, max.y, min.z),
        Vector(max.x, min.y, min.z),
        Vector(max.x, max.y, max.z),
        Vector(min.x, max.y, max.z),
        Vector(min.x, min.y, max.z),
        Vector(max.x, min.y, max.z)
    }
end
RoachHook.Helpers.GetRotatedAABB = function(entity, angle, pos)
    local mins, maxs = entity:GetCollisionBounds()
    local corners = RoachHook.Helpers.GetCorners(mins, maxs)
    local data = {minX = math.huge, maxX = 0, minY = math.huge, maxY = 0}

    for k=1, #corners do
        local rotatedCorner = corners[k]
        if(angle) then
            rotatedCorner:Rotate(angle)
        end
        local screenCorner = (pos + rotatedCorner):ToScreen()
        if(!screenCorner.visible) then return nil end
        
        local x, y = screenCorner.x, screenCorner.y
        
        if(x < data.minX) then data.minX = x end
        if(x > data.maxX) then data.maxX = x end
        if(y < data.minY) then data.minY = y end
        if(y > data.maxY) then data.maxY = y end
    end
   
    local bbox = {x = data.minX - 2, y = data.minY - 2, w = data.maxX - data.minX + 4, h = data.maxY - data.minY + 4}
    if((bbox.x + bbox.w < -2 && bbox.y + bbox.h < -2) || (bbox.y >= ScrW() + 2 && bbox.y > ScrH() + 2)) then
        bbox.x = -math.huge
        bbox.y = -math.huge
    end

    if(bbox.x + bbox.w <= 2 || bbox.y + bbox.h <= 2) then return nil end

    return bbox
end
RoachHook.Helpers.LerpColor = function(t, from, to)
    return Color(
        Lerp(t, from.r, to.r),
        Lerp(t, from.g, to.g),
        Lerp(t, from.b, to.b),
        Lerp(t, from.a, to.a)
    )
end
RoachHook.Helpers.GetKeysPressed = function()
    local keys = {}
    for key = KEY_NONE, MOUSE_LAST do
        if(key >= MOUSE_LEFT) then
            if(input.IsMouseDown(key)) then
                keys[#keys + 1] = key
            end
        else
            if(input.IsKeyDown(key)) then
                keys[#keys + 1] = key
            end
        end
    end

    return keys
end
local keysToggled = {}
RoachHook.Helpers.KeybindPressed = function(var)
    local key = RoachHook.Config[var]
    if(key == nil) then return end

    if(!key.key) then return false end
    if(!input.GetKeyName(key.key)) then return false end

    if(key.mode == "always on") then return true end
    if(key.mode == "hold" && !vgui.CursorVisible()) then
        if(key.key >= MOUSE_LEFT) then
            return input.IsMouseDown(key.key)
        else
          return input.IsKeyDown(key.key)
        end

        return false
    end

    if(!keysToggled[var]) then keysToggled[var] = {state = false, clicked = false} end
    if(vgui.CursorVisible()) then return keysToggled[var].state end

    local didPress = false
    if(key.key >= MOUSE_LEFT) then
        didPress = input.IsMouseDown(key.key)
    else
        didPress = input.IsKeyDown(key.key)
    end

    if(didPress) then
        if(!keysToggled[var].clicked) then
            keysToggled[var].state = !keysToggled[var].state

            keysToggled[var].clicked = true
        end
    else
        keysToggled[var].clicked = false
    end

    return keysToggled[var].state
end
RoachHook.Helpers.CopyColor = function(clr)
    return Color(clr.r, clr.g, clr.b, clr.a)
end
RoachHook.Helpers.BoneToHitbox = function(plr, bone)
  if(!LocalPlayer():Alive()) then return end
  for i=0, plr:GetHitBoxCount(0) do
      if(plr:GetHitBoxBone(i, 0) == bone) then
          return i
      end
  end
end
RoachHook.Helpers.GetMenuItemFromVar = function(var)
	for k,v in pairs(RoachHook.frame.Tabs) do
		for k,v in pairs(v[3]) do
			for k,v in pairs(v.items) do
				if(v.var == var) then
					return v
				end
			end
		end
	end
end
RoachHook.Helpers.CanHit = function(plr0, plr1, start, endpos, bone, angle, bIgnoreMultipoints)
    local trc0 = util.TraceLine({
      start = start,
      endpos = endpos,
      filter = {plr0, plr1},
      mask = MASK_SHOT
    })

    if(trc0.Fraction >= 1) then
        return trc0.Fraction, endpos
    end

    if(bIgnoreMultipoints) then return end

    local hitbox = RoachHook.Helpers.BoneToHitbox(plr1, bone)
    local hMins, hMaxs = plr1:GetHitBoxBounds(hitbox, 0)
    
    local corners = RoachHook.Helpers.GetCorners(hMins, hMaxs)

    for k = 1, #corners do
        local pos = corners[k]
        pos:Rotate(angle)

        local pos = pos + endpos
        
        local trc1 = util.TraceLine({
          start = start,
          endpos = pos,
          filter = plr0,
          mask = MASK_SHOT
        })
        
        if(trc1.Fraction >= 1) then
          return trc0.Fraction, pos
        end
    end

    return -1, endpos
end
local function signedArea(p, q, r)
    local cross = (q.y - p.y) * (r.x - q.x)
                - (q.x - p.x) * (r.y - q.y)
    return cross
end
  
local function isCCW(p, q, r) return signedArea(p, q, r) < 0 end

RoachHook.Helpers.GiftWrapping = function(points)
    local numPoints = #points
    if numPoints < 3 then return end
  
    local leftMostPointIndex = 1
    for i = 1, numPoints do
        if points[i].x < points[leftMostPointIndex].x then
            leftMostPointIndex = i
        end
    end
  
    local p = leftMostPointIndex
    local hull = {}
  
    repeat
        q = points[p + 1] and p + 1 or 1
        for i = 1, numPoints, 1 do
            if isCCW(points[p], points[i], points[q]) then q = i end
        end
  
        table.insert(hull, points[q])
        p = q
    until (p == leftMostPointIndex)
  
    return hull
end

local remove       = table.remove
local sqrt         = math.sqrt
local max          = math.max
local class = function(...)
  local klass = {}
  klass.__index = klass
  klass.__call = function(_,...) return klass:new(...) end
  function klass:new(...)
    local instance = setmetatable({}, klass)
    klass.__init(instance, ...)
    return instance
  end
  return setmetatable(klass,{__call = klass.__call})
end
local function quatCross(a, b, c)
  local p = (a + b + c) * (a + b - c) * (a - b + c) * (-a + b + c)
  return sqrt(p)
end
local function crossProduct(p1, p2, p3)
  local x1, x2 = p2.x - p1.x, p3.x - p2.x
  local y1, y2 = p2.y - p1.y, p3.y - p2.y
  return x1 * y2 - y1 * x2
end
local function isFlatAngle(p1, p2, p3)
  return (crossProduct(p1, p2, p3) == 0)
end
local Edge = class()
Edge.__eq = function(a, b) return (a.p1 == b.p1 and a.p2 == b.p2) end
Edge.__tostring = function(e)
  return (('Edge :\n  %s\n  %s'):format(tostring(e.p1), tostring(e.p2)))
end
function Edge:__init(p1, p2)
  self.p1, self.p2 = p1, p2
end
function Edge:same(otherEdge)
  return ((self.p1 == otherEdge.p1) and (self.p2 == otherEdge.p2))
      or ((self.p1 == otherEdge.p2) and (self.p2 == otherEdge.p1))
end
function Edge:length()
  return self.p1:dist(self.p2)
end
function Edge:getMidPoint()
  local x = self.p1.x + (self.p2.x - self.p1.x) / 2
  local y = self.p1.y + (self.p2.y - self.p1.y) / 2
  return x, y
end
local Point = class()
Point.__eq = function(a,b)  return (a.x == b.x and a.y == b.y) end
Point.__tostring = function(p)
  return ('Point (%s) x: %.2f y: %.2f'):format(p.id, p.x, p.y)
end
function Point:__init(x, y)
  self.x, self.y, self.id = x or 0, y or 0, '?'
end
function Point:dist2(p)
  local dx, dy = (self.x - p.x), (self.y - p.y)
  return dx * dx + dy * dy
end
function Point:dist(p)
  return sqrt(self:dist2(p))
end
function Point:isInCircle(cx, cy, r)
  local dx = (cx - self.x)
  local dy = (cy - self.y)
  return ((dx * dx + dy * dy) <= (r * r))
end
local Triangle = class()
Triangle.__tostring = function(t)
  return (('Triangle: \n  %s\n  %s\n  %s')
    :format(tostring(t.p1), tostring(t.p2), tostring(t.p3)))
end
function Triangle:__init(p1, p2, p3)
  assert(not isFlatAngle(p1, p2, p3), ("angle (p1, p2, p3) is flat:\n  %s\n  %s\n  %s")
    :format(tostring(p1), tostring(p2), tostring(p3)))
  self.p1, self.p2, self.p3 = p1, p2, p3
  self.e1, self.e2, self.e3 = Edge(p1, p2), Edge(p2, p3), Edge(p3, p1)
end
function Triangle:isCW()
  return (crossProduct(self.p1, self.p2, self.p3) < 0)
end
function Triangle:isCCW()
  return (crossProduct(self.p1, self.p2, self.p3) > 0)
end
function Triangle:getSidesLength()
  return self.e1:length(), self.e2:length(), self.e3:length()
end
function Triangle:getCenter()
  local x = (self.p1.x + self.p2.x + self.p3.x) / 3
  local y = (self.p1.y + self.p2.y + self.p3.y) / 3
  return x, y
end
function Triangle:getCircumCircle()
  local x, y = self:getCircumCenter()
  local r = self:getCircumRadius()
  return x, y, r
end
function Triangle:getCircumCenter()
  local p1, p2, p3 = self.p1, self.p2, self.p3
  local D =  ( p1.x * (p2.y - p3.y) +
               p2.x * (p3.y - p1.y) +
               p3.x * (p1.y - p2.y)) * 2
  local x = (( p1.x * p1.x + p1.y * p1.y) * (p2.y - p3.y) +
             ( p2.x * p2.x + p2.y * p2.y) * (p3.y - p1.y) +
             ( p3.x * p3.x + p3.y * p3.y) * (p1.y - p2.y))
  local y = (( p1.x * p1.x + p1.y * p1.y) * (p3.x - p2.x) +
             ( p2.x * p2.x + p2.y * p2.y) * (p1.x - p3.x) +
             ( p3.x * p3.x + p3.y * p3.y) * (p2.x - p1.x))
  return (x / D), (y / D)
end
function Triangle:getCircumRadius()
  local a, b, c = self:getSidesLength()
  return ((a * b * c) / quatCross(a, b, c))
end
function Triangle:getArea()
  local a, b, c = self:getSidesLength()
  return (quatCross(a, b, c) / 4)
end
function Triangle:inCircumCircle(p)
  return p:isInCircle(self:getCircumCircle())
end
local Delaunay = {
  Point            = Point,
  Edge             = Edge,
  Triangle         = Triangle,
	convexMultiplier = 1e3,
  _VERSION = "0.1"
}
function Delaunay.triangulate(...)
  local vertices = {...}
  local nvertices = #vertices
  assert(nvertices > 2, "Cannot triangulate, needs more than 3 vertices")
  if nvertices == 3 then
    return {Triangle(unpack(vertices))}
  end

  local trmax = nvertices * 4

  local minX, minY = vertices[1].x, vertices[1].y
  local maxX, maxY = minX, minY

  for i = 1, #vertices do
    local vertex = vertices[i]
    vertex.id = i
    if vertex.x < minX then minX = vertex.x end
    if vertex.y < minY then minY = vertex.y end
    if vertex.x > maxX then maxX = vertex.x end
    if vertex.y > maxY then maxY = vertex.y end
  end

	local convex_mult = Delaunay.convexMultiplier
  local dx, dy = (maxX - minX) * convex_mult, (maxY - minY) * convex_mult
  local deltaMax = max(dx, dy)
  local midx, midy = (minX + maxX) * 0.5, (minY + maxY) * 0.5

  local p1 = Point(midx - 2 * deltaMax, midy - deltaMax)
  local p2 = Point(midx, midy + 2 * deltaMax)
  local p3 = Point(midx + 2 * deltaMax, midy - deltaMax)
  p1.id, p2.id, p3.id = nvertices + 1, nvertices + 2, nvertices + 3
  vertices[p1.id] = p1
  vertices[p2.id] = p2
  vertices[p3.id] = p3

  local triangles = {}
  triangles[#triangles + 1] = Triangle(vertices[nvertices + 1],
                                       vertices[nvertices + 2],
                                       vertices[nvertices + 3]
                              )

  for i = 1, nvertices do
  
    local edges = {}
    local ntriangles = #triangles

    for j = #triangles, 1, -1 do
      local curTriangle = triangles[j]
      if curTriangle:inCircumCircle(vertices[i]) then
        edges[#edges + 1] = curTriangle.e1
        edges[#edges + 1] = curTriangle.e2
        edges[#edges + 1] = curTriangle.e3
        remove(triangles, j)
      end
    end

    for j = #edges - 1, 1, -1 do
      for k = #edges, j + 1, -1 do
        if edges[j] and edges[k] and edges[j]:same(edges[k]) then
          remove(edges, j)
          remove(edges, k-1)
        end
      end
    end

    for j = 1, #edges do
      local n = #triangles
      assert(n <= trmax, "Generated more than needed triangles")
      triangles[n + 1] = Triangle(edges[j].p1, edges[j].p2, vertices[i])
    end
   
  end

  for i = #triangles, 1, -1 do
    local triangle = triangles[i]
    if (triangle.p1.id > nvertices or 
        triangle.p2.id > nvertices or 
        triangle.p3.id > nvertices) then
      remove(triangles, i)
    end
  end

  for _ = 1,3 do remove(vertices) end

  return triangles

end

RoachHook.Helpers.DelaunayTriangulate = function(points)
    local pointsTable = {}
    for k=0, #points do
        local v = points[k]
        if(!v) then continue end
        
        pointsTable[#pointsTable + 1] = Point(v.x, v.y)
    end
    if(#points <= 3) then return points end

    return Delaunay.triangulate(unpack(points))
end
RoachHook.Helpers.Bezier = function(t, p0, p1, p2)
	return (1 - t)^2 * p0 + 2 * (1 - t) * t * p1 + t^2 * p2
end
RoachHook.Helpers.BezierVector = function(t, p0, p1, p2)
    return Vector(
        RoachHook.Helpers.Bezier(t, p0.x, p1.x, p2.x),
        RoachHook.Helpers.Bezier(t, p0.y, p1.y, p2.y),
        RoachHook.Helpers.Bezier(t, p0.z, p1.z, p2.z)
    )
end
RoachHook.Helpers.DrawRoundedBoxProper = function(rpx, x, y, w, h, clr)
    local points = {}

    // TOP LEFT
    for i=0, 100 do
        points[#points + 1] = RoachHook.Helpers.BezierVector(i / 100, Vector(x, y + rpx), Vector(x, y), Vector(x + rpx, y))
    end
    // TOP RIGHT
    for i=0, 100 do
        points[#points + 1] = RoachHook.Helpers.BezierVector(i / 100, Vector(x + w, y + rpx), Vector(x + w, y), Vector(x + w - rpx, y))
    end
    // BOTTOM LEFT
    for i=0, 100 do
        points[#points + 1] = RoachHook.Helpers.BezierVector(i / 100, Vector(x, y + h - rpx), Vector(x, y + h), Vector(x + rpx, y + h))
    end
    // BOTTOM RIGHT
    for i=0, 100 do
        points[#points + 1] = RoachHook.Helpers.BezierVector(i / 100, Vector(x + w, y + h - rpx), Vector(x + w, y + h), Vector(x + w - rpx, y + h))
    end

    for k,v in ipairs(points) do points[k] = {x = v.x, y = v.y} end

    local points = RoachHook.Helpers.GiftWrapping(points)
    surface.SetDrawColor(clr)
    draw.NoTexture()
    surface.DrawPoly(points)
end
RoachHook.Helpers.ClampText = function(text, maxChars)
    local str = ""

    for i=1, maxChars do
        str = str .. (text[i] || "")
    end

    return str
end
RoachHook.Helpers.FixMovement = function(cmd)
    local aaaaa = cmd:GetViewAngles().x > 89 || cmd:GetViewAngles().x < -89
    local move = Vector(cmd:GetForwardMove(), cmd:GetSideMove(), 0)
    local speed = math.sqrt(move.x * move.x + move.y * move.y)
    local ang = move:Angle()
    local yaw = math.rad(cmd:GetViewAngles().y - RoachHook.SilentAimbot.y + ang.y)
    cmd:SetForwardMove((math.cos(yaw) * speed) * ( aaaaa && -1 || 1 ))
    cmd:SetSideMove(math.sin(yaw) * speed)
end
RoachHook.Helpers.CanFire = function()
    local pLocal = LocalPlayer()
    if(!pLocal || !IsValid(pLocal)) then return false end
    local pWeapon = pLocal:GetActiveWeapon()
    if(!pWeapon || !IsValid(pWeapon)) then return false end
    if(!pWeapon.Clip1 || !pWeapon.GetMaxClip1) then return false end
    if(pWeapon:Clip1() <= 0 && pWeapon:GetMaxClip1() > 0) then return false end
    
    return pWeapon:GetNextPrimaryFire() <= RoachHook.ServerTime
end
RoachHook.Helpers.IsTraitor = function(plr)
    local TraitorGuns = {}
    for k, v in pairs(weapons.GetList()) do
        if(v.CanBuy) then
            for k,role in pairs(v.CanBuy) do
                if(role == ROLE_TRAITOR) then
                    TraitorGuns[v.ClassName] = true
                end
            end
        end
    end

    for k,v in pairs(plr:GetWeapons()) do
        if(TraitorGuns[v:GetClass()]) then
            return true
        end
    end
    return false
end

RoachHook.Helpers.TIME_TO_TICKS = function(dt)
    return 0.5 + (dt / engine.TickInterval())
end
RoachHook.Helpers.TICKS_TO_TIME = function(t)
    return engine.TickInterval() * t
end