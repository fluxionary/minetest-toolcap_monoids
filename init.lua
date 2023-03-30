toolcap_monoids = fmod.create()

toolcap_monoids.full_punch = item_monoids.make_monoid("full_punch", {
	predicate = function(toolstack)
		local toolcaps = toolstack:get_definition().tool_capabilities
		return toolcaps and toolcaps.full_punch_interval
	end,
	get_default = function(toolstack)
		return toolstack:get_definition().tool_capabilities.full_punch_interval
	end,
	fold = function(values, default_full_punch_interval)
		local full_punch_interval = default_full_punch_interval
		for _, multiplier in pairs(values) do
			full_punch_interval = full_punch_interval * multiplier
		end
		return full_punch_interval
	end,
	apply = function(full_punch_interval, toolstack)
		local tool_capabilities = toolstack:get_tool_capabilities()
		tool_capabilities.full_punch_interval = full_punch_interval
		local meta = toolstack:get_meta()
		meta:set_tool_capabilities(tool_capabilities)
	end,
})

toolcap_monoids.dig_speed = item_monoids.make_monoid("dig_speed", {
	predicate = function(toolstack)
		local toolcaps = toolstack:get_definition().tool_capabilities
		return toolcaps and toolcaps.groupcaps
	end,
	get_default = function(toolstack)
		local toolcaps = toolstack:get_definition().tool_capabilities
		local dig_speeds = {}
		for group, groupcaps in pairs(toolcaps.groupcaps) do
			dig_speeds[group] = groupcaps.times
		end
		return dig_speeds
	end,
	apply = function(dig_speeds, toolstack)
		local tool_capabilities = table.copy(toolstack:get_tool_capabilities())
		for group in pairs(tool_capabilities.groupcaps) do
			if not dig_speeds[group] then
				tool_capabilities.groupcaps[group] = nil
			end
		end
		for group, times in pairs(dig_speeds) do
			if not tool_capabilities.groupcaps[group] then
				tool_capabilities.groupcaps[group] = {}
			end
			tool_capabilities.groupcaps[group].times = times
		end
		item_monoids.chat_send_all("[DEBUG] @1", dump(dig_speeds))
		item_monoids.chat_send_all("[DEBUG] @1", dump(tool_capabilities))
		local meta = toolstack:get_meta()
		meta:set_tool_capabilities(tool_capabilities)
	end,
	fold = function(values, default_dig_speeds)
		local dig_speeds = table.copy(default_dig_speeds)
		for _, multiplier in pairs(values) do
			if multiplier == "disable" then
				return {}
			elseif type(multiplier) == "number" then
				for _, times in pairs(dig_speeds) do
					for i = 1, #times do
						times[i] = times[i] * multiplier
					end
				end
			elseif type(multiplier) == "table" then
				for group, group_multiplier in pairs(multiplier) do
					if group_multiplier == "disable" then
						dig_speeds[group] = nil
					else
						local times = dig_speeds[group]
						if times then
							for i = 1, #times do
								times[i] = times[i] * group_multiplier
							end
						end
					end
				end
			end
		end
		return dig_speeds
	end,
})

toolcap_monoids.durability = item_monoids.make_monoid("durability", {
	predicate = function(toolstack)
		local toolcaps = toolstack:get_definition().tool_capabilities
		return toolcaps and (toolcaps.groupcaps or toolcaps.punch_attack_uses)
	end,
	get_default = function(toolstack)
		local toolcaps = toolstack:get_definition().tool_capabilities
		local uses = {}
		for group, groupcaps in pairs(toolcaps.groupcaps) do
			uses[group] = groupcaps.uses
		end
		uses.punch_attack = toolcaps.punch_attack_uses
		return uses
	end,
	fold = function(values, default_uses)
		local uses = table.copy(default_uses)
		for _, multiplier in pairs(values) do
			if type(multiplier) == "number" then
				for group, value in pairs(uses) do
					uses[group] = value * multiplier
				end
			elseif type(multiplier) == "table" then
				for group, group_multiplier in pairs(multiplier) do
					local current_uses = uses[group]
					if current_uses then
						uses[group] = current_uses * group_multiplier
					end
				end
			end
		end
		return uses
	end,
	apply = function(uses, toolstack)
		local tool_capabilities = toolstack:get_tool_capabilities()
		for group, value in pairs(uses) do
			if group == "punch_attack" then
				tool_capabilities.punch_attack_uses = value
			else
				tool_capabilities.groupcaps[group].uses = value
			end
		end
		local meta = toolstack:get_meta()
		meta:set_tool_capabilities(tool_capabilities)
	end,
})

toolcap_monoids.damage = item_monoids.make_monoid("damage", {
	predicate = function(toolstack)
		return toolstack:get_definition().tool_capabilities
	end,
	get_default = function(toolstack)
		local toolcaps = toolstack:get_definition().tool_capabilities
		return toolcaps.damage_groups or {}
	end,
	fold = function(values, default_damage_groups)
		local damage_groups = table.copy(default_damage_groups)
		for _, additional_damage in pairs(values) do
			if additional_damage == "disable" then
				return {}
			else
				for group, damage in pairs(additional_damage) do
					if damage == "disable" then
						damage_groups[group] = "disabled"
					elseif damage_groups[group] ~= "disabled" then
						local total_damage = (damage_groups[group] or 0) + damage
						if total_damage == 0 then
							damage_groups[group] = nil
						else
							damage_groups[group] = total_damage
						end
					end
				end
			end
		end
		for group, value in pairs(damage_groups) do
			if value == "disabled" then
				damage_groups[group] = nil
			end
		end
		return damage_groups
	end,
	apply = function(damage_groups, toolstack)
		local tool_capabilities = toolstack:get_tool_capabilities()
		tool_capabilities.damage_groups = damage_groups
		local meta = toolstack:get_meta()
		meta:set_tool_capabilities(tool_capabilities)
	end,
})
