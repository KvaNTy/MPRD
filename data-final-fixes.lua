local function generate_description(recipe, results)
	local output = {'', {"recipe-description.mprd-caption"}, " "}

	for _, product in pairs(results) do
		if product.localised_name then
			table.insert(output, ", ")
			table.insert(output, product.localised_name)
		else
			local product_key = ""
			if product.type ~= nil then
				if product.type == "item" then product_key = "item-name." .. product.name
				elseif product.type == "fluid" then product_key = "fluid-name." .. product.name end
				table.insert(output, ", ")
				table.insert(output, {product_key})
			else
				local product_type = ""
				local product_name = ""
				for i, value in pairs(product) do
					if type(value) == "string" then
						if value == "item" or value == "fluid" then product_type = value
						else product_name = value end
					end
				end
				if product_type == "item" and product_name ~= "" then product_key = "item-name." .. product_name
				elseif product_type == "fluid" and product_name ~= "" then product_key = "fluid-name." .. product_name end
				table.insert(output, ", ")
				table.insert(output, {product_key})
			end
		end
	end

	table.remove(output, 4) -- To deal with first comma
	if recipe.localised_description ~= nil then -- Preserve existing description
		table.insert(output, 2, recipe.localised_description)
		table.insert(output, 3, "\n\n")
	elseif recipe.description ~= nil then
		table.insert(output, 2, {recipe.description})
		table.insert(output, 3, "\n\n")
	end
	--table.insert(output, "\n")

	return output
end

local function get_results(recipe)
	if recipe.results ~= nil then return recipe.results end
	if recipe.normal ~= nil and recipe.normal.results ~= nil then return recipe.normal.results end
end

for _, recipe in pairs(data.raw["recipe"]) do
	if recipe.results ~= nil or (recipe.normal ~= nil and recipe.normal.results ~= nil) then
		local results = get_results(recipe)
		if results ~= nil and #results > 1 then -- Only for multi-product recipes
			recipe.localised_description = generate_description(recipe, results)
		end
	end
end
