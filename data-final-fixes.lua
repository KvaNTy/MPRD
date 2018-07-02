local function get_products_of_type(results, target_type)
	local product_keys_list = {}
	for _, product in pairs(results) do
		local product_type = ""
		local product_name = ""
		local product_key = ""
		if product.type ~= nil then -- {type="item|fluid", name="product_name", ammount=int}
			if product.type == "item" and product.type == target_type then 
				product_key = "item-name." .. product.name
			elseif product.type == "fluid" and product.type == target_type then 
				product_key = "fluid-name." .. product.name
			end
		else
			for i, value in pairs(product) do -- {[1]="item|fluid", [2]="product_name", [3]=int}
				if type(value) == "string" then
					if value == "item" or value == "fluid" then product_type = value
					else product_name = value end
				end
			end
			if product_type == "item" and product_name ~= "" and product_type == target_type then 
				product_key = "item-name." .. product_name
			elseif product_type == "fluid" and product_name ~= "" and product_type == target_type then 
				product_key = "fluid-name." .. product_name
			end
		end
		if product_key ~= "" then table.insert(product_keys_list, product_key) end
	end
	return product_keys_list
end

local function generate_description(recipe, results)
	local new_description = {'', {"recipe-description.mprd-caption"}, " "}
	local items = get_products_of_type(results, "item")
	local fluids = get_products_of_type(results, "fluid")

	for _, item_key in pairs(items) do -- Items must be listed first
		table.insert(new_description, ", ")
		table.insert(new_description, {item_key})
	end
	for _, fluid_key in pairs(fluids) do
		table.insert(new_description, ", ")
		table.insert(new_description, {fluid_key})
	end

	table.remove(new_description, 4) -- Remove preemptive first comma
	if recipe.localised_description or recipe.description then -- Preserve existing description
		if recipe.localised_description then table.insert(new_description, 2, recipe.localised_description)
		else table.insert(new_description, 2, {recipe.description}) end
		table.insert(new_description, 3, "\n\n")
	end
	--table.insert(new_description, "\n") -- In case additional spacing is needed

	return new_description
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
