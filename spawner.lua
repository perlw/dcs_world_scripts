local groupCounter = 0
function spawnPlane(args)
  local spawnZone = trigger.misc.getZone(args.zone)
  local spawnPos = {}
  spawnPos.x = spawnZone.point.x + math.random(-spawnZone.radius, spawnZone.radius)
  spawnPos.z = spawnZone.point.z + math.random(-spawnZone.radius, spawnZone.radius)

  local aircraftData = {
    ["modulation"] = 0,
    ["tasks"] = {
    },
    ["task"] = "CAS",
    ["uncontrolled"] = false,
    ["route"] = {
      ["points"] = {
        [1] = {
          ["alt"] = 2000,
          ["type"] = "Turning Point",
          ["action"] = "Turning Point",
          ["alt_type"] = "RADIO",
          ["formation_template"] = "",
          ["ETA"] = 0,
          ["y"] = spawnPos.z,
          ["x"] = spawnPos.x,
          ["speed"] = 400,
          ["ETA_locked"] = true,
          ["task"] = {
            ["id"] = "ComboTask",
            ["params"] = {
              ["tasks"] = {
                [1] = {
                  ["id"] = "Orbit",
                  ["params"] = {
                    ["pattern"] = "Circle",
                  },
                },
              },
            },
          },
          ["speed_locked"] = false,
        },
      },
    },
    ["groupId"] = groupCounter,
    ["hidden"] = false,
    ["units"] = {
      [1] = {
        ["alt"] = 2000,
        ["heading"] = 0,
        ["livery_id"] = nil,
        ["type"] = args.plane,
        ["psi"] = 0,
        ["onboard_num"] = "10",
        ["parking"] = 19,
        ["y"] = spawnPos.z,
        ["x"] = spawnPos.x,
        ["name"] = "Spawner-" .. groupCounter .. "1",
        ["payload"] = {
          ["pylons"] = {
          },
          ["fuel"] = "9400",
          ["flare"] = 96,
          ["chaff"] = 96,
          ["gun"] = 100,
        },
        ["speed"] = 400,
        ["unitId"] =  math.random(9999, 99999),
        ["alt_type"] = "RADIO",
        ["skill"] = "High",
      },
    },
    ["y"] = spawnPos.z,
    ["x"] = spawnPos.x,
    ["name"] = "Spawner-" .. args.plane .. "-" .. groupCounter,
    ["communication"] = true,
    ["start_time"] = 0,
    ["frequency"] = 124,
  }

  groupCounter = groupCounter + 1
  coalition.addGroup(country.id.RUSSIA, Group.Category.AIRPLANE, aircraftData)
  trigger.action.outText("Spawned: " .. aircraftData["name"] .. "/" .. aircraftData["units"][1]["type"], 1)
end

function registerSpawner(plane, zone)
  trigger.action.outText("Booting Spawner Script -=- " .. plane, 1)

  -- Radio Commands
  function addSpawnerRadioCommand(unit, plane, zone)
    local group = unit:getGroup()
    if group == nil then
      return
    end

    local gid = group:getID()
    trigger.action.outText("Spawner: Adding " .. plane .. " to " .. unit:getName(), 1)

    missionCommands.addCommandForGroup(gid, "Spawn " .. plane, nil, spawnPlane, { plane = plane, zone = zone })
  end

  function eventHandler(event)
    if event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT then
      if event.initiator == nil then
        return
      end

      local initiatorName = event.initiator:getName()
      addSpawnerRadioCommand(Unit.getByName(initiatorName), plane, zone)
    end
  end
  mist.addEventHandler(eventHandler)

  -- If any players loaded before mission start
  for k, v in pairs(mist.DBs.humansByName) do
    local unit = Unit.getByName(k)
    if unit and unit.isActive then
      addSpawnerRadioCommand(unit, plane, zone)
    end
  end
end
