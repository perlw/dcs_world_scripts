do

  trigger.action.outText("Booting Range Script", 1)

  local units = mist.makeUnitTable({'[blue][plane]', '[blue][helicopter]'})

  -- Strafe Pits
  StrafePits = {
    StrafePit1 = {
      active = false,
    },
    StrafePit2 = {
      active = false,
    },
    StrafePit3 = {
      active = false,
    },
  }

  function eventHandler(event)
    if event.id == world.event.S_EVENT_HIT and event.weapon then
      if event.target == nil then
        return
      end
      if event.initiator == nil then
        return
      end

      local targetName = event.target:getName()
      local shooterName = event.initiator:getName()

      local found = false
      local pit = nil
      for k, _ in pairs(StrafePits) do
        if targetName == k then
          pit = k
          found = true
          break
        end
      end

      if not found then
        return
      end

      if StrafePits[pit].unitName == shooterName then
        StrafePits[pit].hitCount = StrafePits[pit].hitCount + 1
      end
    end
  end

  mist.addEventHandler(eventHandler)

  function beginStrafeRun(args)
    local pit = args.strafePit
    local unitName = args.unitName

    local unit = Unit.getByName(unitName)
    if unit == nil then
      return
    end

    if StrafePits[pit].active then
      trigger.action.outText("This pit is already taken by " .. StrafePits[pit].playerName, 1)
      return
    end

    local rounds= 0
    local ammo = unit:getAmmo()
    for t = 1, #ammo do
      if ammo[t].desc.category == Weapon.Category.SHELL then
        rounds = rounds + ammo[t].count
      end
    end

    local playerName = unit:getPlayerName()
    StrafePits[pit].active = true
    StrafePits[pit].unitName = unitName
    StrafePits[pit].playerName = playerName
    StrafePits[pit].hitCount = 0
    StrafePits[pit].startAmmo = rounds
    trigger.action.outText(playerName  .. " has started a run on " .. pit, 1)
  end

  function endStrafeRun(args)
    local pit = args.strafePit
    local unitName = args.unitName

    local unit = Unit.getByName(unitName)
    if unit == nil then
      return
    end

    if not StrafePits[pit].active then
      return
    end

    if StrafePits[pit].active and not (StrafePits[pit].unitName == unitName) then
      trigger.action.outText("This pit is taken by " .. StrafePits[pit].playerName .. ", not you", 1)
      return
    end

    local roundsLeft = 0
    local ammo = unit:getAmmo()
    for t = 1, #ammo do
      if ammo[t].desc.category == Weapon.Category.SHELL then
        roundsLeft = roundsLeft + ammo[t].count
      end
    end

    local roundsUsed = StrafePits[pit].startAmmo - roundsLeft
    local accuracy = math.floor(((StrafePits[pit].hitCount / roundsUsed) * 100) + 0.5)
    StrafePits[pit].active = false
    trigger.action.outText(StrafePits[pit].playerName  .. " has ended a run on pit 1", 1)
    trigger.action.outText("Hit count: " .. StrafePits[pit].hitCount .. "\nAccuracy: " .. StrafePits[pit].hitCount .. "/" .. roundsUsed .. " (" .. accuracy .. "%)", 2)
  end

  -- Radio Commands
  RadioCommandTable = {}

  function addRadioCommand(unitName)
    local unit = Unit.getByName(unitName)
    if unit == nil then
      return
    end

    local group = unit:getGroup()
    if group == nil then
      return
    end

    local gid = group:getID()
    local radioName = tostring(gid) .. ":" .. unitName
    if RadioCommandTable[radioName] == nil then
      trigger.action.outText("Adding radio to " .. radioName, 1)

      local strafeSubMenu = missionCommands.addSubMenuForGroup(gid, "Strafe Pits", nil)
      missionCommands.addCommandForGroup(gid, "Begin run, Strafe Pit 1", strafeSubMenu, beginStrafeRun, { strafePit = "StrafePit1", unitName = unitName, })
      missionCommands.addCommandForGroup(gid, "End run, Strafe Pit 1", strafeSubMenu, endStrafeRun, { strafePit = "StrafePit1", unitName = unitName, })
      missionCommands.addCommandForGroup(gid, "Begin run, Strafe Pit 2", strafeSubMenu, beginStrafeRun, { strafePit = "StrafePit2", unitName = unitName, })
      missionCommands.addCommandForGroup(gid, "End run, Strafe Pit 2", strafeSubMenu, endStrafeRun, { strafePit = "StrafePit2", unitName = unitName, })
      missionCommands.addCommandForGroup(gid, "Begin run, Strafe Pit 3", strafeSubMenu, beginStrafeRun, { strafePit = "StrafePit3", unitName = unitName, })
      missionCommands.addCommandForGroup(gid, "End run, Strafe Pit 3", strafeSubMenu, endStrafeRun, { strafePit = "StrafePit3", unitName = unitName, })

      RadioCommandTable[radioName] = true
    end
  end

  function addRadioCommands(arg, time)
    for t = 1, #units do
      --if string.find(units[t], "Client") then
        addRadioCommand(units[t])
      --end
    end

    return time + 5
  end

  do
    timer.scheduleFunction(addRadioCommands, nil, timer.getTime() + 5)
  end

end
