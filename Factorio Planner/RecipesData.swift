// MARK: - Recipes Data (complete list with alternatives)
let RECIPES: [Recipe] = [
    // Basic Resources
    Recipe(id: "iron-plate", name: "Iron Plate", category: "smelting", time: 3.2, inputs: ["Iron Ore": 1], outputs: ["Iron Plate": 1]),
    Recipe(id: "copper-plate", name: "Copper Plate", category: "smelting", time: 3.2, inputs: ["Copper Ore": 1], outputs: ["Copper Plate": 1]),
    Recipe(id: "steel-plate", name: "Steel Plate", category: "smelting", time: 16, inputs: ["Iron Plate": 5], outputs: ["Steel Plate": 1]),
    Recipe(id: "stone-brick", name: "Stone Brick", category: "smelting", time: 3.2, inputs: ["Stone": 2], outputs: ["Stone Brick": 1]),
    
    // Basic Components
    Recipe(id: "copper-cable", name: "Copper Cable", category: "assembling", time: 0.5, inputs: ["Copper Plate": 1], outputs: ["Copper Cable": 2]),
    Recipe(id: "iron-stick", name: "Iron Stick", category: "assembling", time: 0.5, inputs: ["Iron Plate": 1], outputs: ["Iron Stick": 2]),
    Recipe(id: "iron-gear-wheel", name: "Iron Gear Wheel", category: "assembling", time: 0.5, inputs: ["Iron Plate": 2], outputs: ["Iron Gear Wheel": 1]),
    Recipe(id: "pipe", name: "Pipe", category: "assembling", time: 0.5, inputs: ["Iron Plate": 1], outputs: ["Pipe": 1]),
    Recipe(id: "engine-unit", name: "Engine Unit", category: "assembling", time: 10, inputs: ["Steel Plate": 1, "Iron Gear Wheel": 1, "Pipe": 2], outputs: ["Engine Unit": 1]),
    Recipe(id: "electric-engine-unit", name: "Electric Engine Unit", category: "assembling", time: 10, inputs: ["Engine Unit": 1, "Electronic Circuit": 2, "Lubricant": 15], outputs: ["Electric Engine Unit": 1]),
    
    // Circuits
    Recipe(id: "electronic-circuit", name: "Electronic Circuit", category: "assembling", time: 0.5, inputs: ["Iron Plate": 1, "Copper Cable": 3], outputs: ["Electronic Circuit": 1]),
    Recipe(id: "advanced-circuit", name: "Advanced Circuit", category: "assembling", time: 6, inputs: ["Electronic Circuit": 2, "Plastic Bar": 2, "Copper Cable": 4], outputs: ["Advanced Circuit": 1]),
    Recipe(id: "processing-unit", name: "Processing Unit", category: "assembling", time: 10, inputs: ["Electronic Circuit": 20, "Advanced Circuit": 2, "Sulfuric Acid": 5], outputs: ["Processing Unit": 1]),
    
    // Science Packs (CORRECTED)
    Recipe(id: "automation-science-pack", name: "Automation Science Pack", category: "assembling", time: 5, inputs: ["Copper Plate": 1, "Iron Gear Wheel": 1], outputs: ["Automation Science Pack": 1]),
    Recipe(id: "logistic-science-pack", name: "Logistic Science Pack", category: "assembling", time: 6, inputs: ["Inserter": 1, "Transport Belt": 1], outputs: ["Logistic Science Pack": 1]),
    Recipe(id: "military-science-pack", name: "Military Science Pack", category: "assembling", time: 10, inputs: ["Piercing Rounds Magazine": 1, "Grenade": 1, "Wall": 2], outputs: ["Military Science Pack": 2]),
    Recipe(id: "chemical-science-pack", name: "Chemical Science Pack", category: "assembling", time: 24, inputs: ["Engine Unit": 2, "Advanced Circuit": 3, "Sulfur": 1], outputs: ["Chemical Science Pack": 2]),
    Recipe(id: "production-science-pack", name: "Production Science Pack", category: "assembling", time: 21, inputs: ["Electric Furnace": 1, "Productivity Module": 1, "Rail": 30], outputs: ["Production Science Pack": 3]),
    Recipe(id: "utility-science-pack", name: "Utility Science Pack", category: "assembling", time: 21, inputs: ["Low Density Structure": 3, "Processing Unit": 2, "Flying Robot Frame": 1], outputs: ["Utility Science Pack": 3]),
    
    // Space Age Science Packs (NEW)
    Recipe(id: "space-science-pack", name: "Space Science Pack", category: "space-manufacturing", time: 15, inputs: ["Asteroid Chunk": 1, "Empty Barrel": 1, "Processing Unit": 1], outputs: ["Space Science Pack": 5]),
    Recipe(id: "metallurgic-science-pack", name: "Metallurgic Science Pack", category: "assembling", time: 36, inputs: ["Tungsten Carbide": 3, "Tungsten Plate": 6, "Carbon": 1], outputs: ["Metallurgic Science Pack": 1]),
    Recipe(id: "electromagnetic-science-pack", name: "Electromagnetic Science Pack", category: "electromagnetic", time: 10, inputs: ["Supercapacitor": 1, "Holmium Plate": 1, "Accumulator": 1], outputs: ["Electromagnetic Science Pack": 1]),
    Recipe(id: "agricultural-science-pack", name: "Agricultural Science Pack", category: "biochamber", time: 6, inputs: ["Bioflux": 1, "Nutrients": 4, "Biter Egg": 1], outputs: ["Agricultural Science Pack": 2]),
    Recipe(id: "cryogenic-science-pack", name: "Cryogenic Science Pack", category: "cryogenic", time: 30, inputs: ["Lithium Plate": 3, "Fusion Power Cell": 1, "Ice": 6], outputs: ["Cryogenic Science Pack": 1]),
    Recipe(id: "promethium-science-pack", name: "Promethium Science Pack", category: "assembling", time: 10, inputs: ["Processing Unit": 3, "Promethium Asteroid Chunk": 2, "Biter Egg": 1], outputs: ["Promethium Science Pack": 10]),
    
    // Transport
    Recipe(id: "transport-belt", name: "Transport Belt", category: "assembling", time: 0.5, inputs: ["Iron Plate": 1, "Iron Gear Wheel": 1], outputs: ["Transport Belt": 2]),
    Recipe(id: "inserter", name: "Inserter", category: "assembling", time: 0.5, inputs: ["Electronic Circuit": 1, "Iron Gear Wheel": 1, "Iron Plate": 1], outputs: ["Inserter": 1]),
    Recipe(id: "fast-inserter", name: "Fast Inserter", category: "assembling", time: 0.5, inputs: ["Electronic Circuit": 2, "Iron Plate": 2, "Inserter": 1], outputs: ["Fast Inserter": 1]),
    Recipe(id: "bulk-inserter", name: "Bulk Inserter", category: "assembling", time: 0.5, inputs: ["Electronic Circuit": 15, "Iron Gear Wheel": 15, "Fast Inserter": 1], outputs: ["Bulk Inserter": 1]),
    
    // Military
    Recipe(id: "piercing-rounds-magazine", name: "Piercing Rounds Magazine", category: "assembling", time: 3, inputs: ["Copper Plate": 5, "Steel Plate": 1, "Firearm Magazine": 1], outputs: ["Piercing Rounds Magazine": 1]),
    Recipe(id: "firearm-magazine", name: "Firearm Magazine", category: "assembling", time: 1, inputs: ["Iron Plate": 4], outputs: ["Firearm Magazine": 1]),
    Recipe(id: "grenade", name: "Grenade", category: "assembling", time: 8, inputs: ["Iron Plate": 5, "Coal": 10], outputs: ["Grenade": 1]),
    Recipe(id: "wall", name: "Wall", category: "assembling", time: 0.5, inputs: ["Stone Brick": 5], outputs: ["Wall": 1]),
    
    // Oil Processing
    Recipe(id: "basic-oil-processing", name: "Basic Oil Processing", category: "oil-refinery", time: 5, inputs: ["Crude Oil": 100], outputs: ["Petroleum Gas": 45]),
    Recipe(id: "advanced-oil-processing", name: "Advanced Oil Processing", category: "oil-refinery", time: 5, inputs: ["Crude Oil": 100, "Water": 50], outputs: ["Heavy Oil": 25, "Light Oil": 45, "Petroleum Gas": 55]),
    Recipe(id: "coal-liquefaction", name: "Coal Liquefaction", category: "oil-refinery", time: 5, inputs: ["Coal": 10, "Heavy Oil": 25, "Steam": 50], outputs: ["Heavy Oil": 90, "Light Oil": 20, "Petroleum Gas": 10]),
    Recipe(id: "heavy-oil-cracking", name: "Heavy Oil Cracking", category: "chemistry", time: 2, inputs: ["Heavy Oil": 40, "Water": 30], outputs: ["Light Oil": 30]),
    Recipe(id: "light-oil-cracking", name: "Light Oil Cracking", category: "chemistry", time: 2, inputs: ["Light Oil": 30, "Water": 30], outputs: ["Petroleum Gas": 20]),
    Recipe(id: "plastic-bar", name: "Plastic Bar", category: "chemistry", time: 1, inputs: ["Coal": 1, "Petroleum Gas": 20], outputs: ["Plastic Bar": 2]),
    Recipe(id: "sulfur", name: "Sulfur", category: "chemistry", time: 1, inputs: ["Water": 30, "Petroleum Gas": 30], outputs: ["Sulfur": 2]),
    Recipe(id: "sulfuric-acid", name: "Sulfuric Acid", category: "chemistry", time: 1, inputs: ["Iron Plate": 1, "Sulfur": 5, "Water": 100], outputs: ["Sulfuric Acid": 50]),
    Recipe(id: "lubricant", name: "Lubricant", category: "chemistry", time: 1, inputs: ["Heavy Oil": 10], outputs: ["Lubricant": 10]),
    Recipe(id: "battery", name: "Battery", category: "chemistry", time: 4, inputs: ["Iron Plate": 1, "Copper Plate": 1, "Sulfuric Acid": 20], outputs: ["Battery": 1]),
    
    // Alternative Fuel Processing (ALT recipes)
    Recipe(id: "solid-fuel-from-light-oil", name: "Solid Fuel (Light Oil)", category: "chemistry", time: 2, inputs: ["Light Oil": 10], outputs: ["Solid Fuel": 1]),
    Recipe(id: "solid-fuel-from-petroleum", name: "Solid Fuel (Petroleum)", category: "chemistry", time: 2, inputs: ["Petroleum Gas": 20], outputs: ["Solid Fuel": 1]),
    Recipe(id: "solid-fuel-from-heavy-oil", name: "Solid Fuel (Heavy Oil)", category: "chemistry", time: 2, inputs: ["Heavy Oil": 20], outputs: ["Solid Fuel": 1]),
    
    // Modules
    Recipe(id: "speed-module", name: "Speed Module", category: "assembling", time: 15, inputs: ["Advanced Circuit": 5, "Electronic Circuit": 5], outputs: ["Speed Module": 1]),
    Recipe(id: "speed-module-2", name: "Speed Module 2", category: "assembling", time: 30, inputs: ["Speed Module": 4, "Advanced Circuit": 5, "Processing Unit": 5], outputs: ["Speed Module 2": 1]),
    Recipe(id: "speed-module-3", name: "Speed Module 3", category: "assembling", time: 60, inputs: ["Speed Module 2": 4, "Advanced Circuit": 5, "Processing Unit": 5], outputs: ["Speed Module 3": 1]),
    Recipe(id: "productivity-module", name: "Productivity Module", category: "assembling", time: 15, inputs: ["Advanced Circuit": 5, "Electronic Circuit": 5], outputs: ["Productivity Module": 1]),
    Recipe(id: "productivity-module-2", name: "Productivity Module 2", category: "assembling", time: 30, inputs: ["Productivity Module": 4, "Advanced Circuit": 5, "Processing Unit": 5], outputs: ["Productivity Module 2": 1]),
    Recipe(id: "productivity-module-3", name: "Productivity Module 3", category: "assembling", time: 60, inputs: ["Productivity Module 2": 4, "Advanced Circuit": 5, "Processing Unit": 5], outputs: ["Productivity Module 3": 1]),
    Recipe(id: "efficiency-module", name: "Efficiency Module", category: "assembling", time: 15, inputs: ["Advanced Circuit": 5, "Electronic Circuit": 5], outputs: ["Efficiency Module": 1]),
    Recipe(id: "efficiency-module-2", name: "Efficiency Module 2", category: "assembling", time: 30, inputs: ["Efficiency Module": 4, "Advanced Circuit": 5, "Processing Unit": 5], outputs: ["Efficiency Module 2": 1]),
    Recipe(id: "efficiency-module-3", name: "Efficiency Module 3", category: "assembling", time: 60, inputs: ["Efficiency Module 2": 4, "Advanced Circuit": 5, "Processing Unit": 5], outputs: ["Efficiency Module 3": 1]),
    Recipe(id: "quality-module", name: "Quality Module", category: "assembling", time: 15, inputs: ["Electronic Circuit": 5, "Advanced Circuit": 5], outputs: ["Quality Module": 1]),
    Recipe(id: "quality-module-2", name: "Quality Module 2", category: "assembling", time: 30, inputs: ["Quality Module": 4, "Advanced Circuit": 5, "Processing Unit": 5], outputs: ["Quality Module 2": 1]),
    Recipe(id: "quality-module-3", name: "Quality Module 3", category: "assembling", time: 60, inputs: ["Quality Module 2": 4, "Advanced Circuit": 5, "Processing Unit": 5, "Superconductor": 1], outputs: ["Quality Module 3": 1]),
    
    // Rocket Components
    Recipe(id: "low-density-structure", name: "Low Density Structure", category: "assembling", time: 30, inputs: ["Steel Plate": 2, "Copper Plate": 20, "Plastic Bar": 5], outputs: ["Low Density Structure": 1]),
    Recipe(id: "rocket-fuel", name: "Rocket Fuel", category: "assembling", time: 30, inputs: ["Solid Fuel": 10, "Light Oil": 10], outputs: ["Rocket Fuel": 1]),
    Recipe(id: "rocket-control-unit", name: "Rocket Control Unit", category: "assembling", time: 30, inputs: ["Processing Unit": 1, "Speed Module": 1], outputs: ["Rocket Control Unit": 1]),
    Recipe(id: "rocket-part", name: "Rocket Part", category: "rocket-building", time: 3, inputs: ["Low Density Structure": 10, "Rocket Fuel": 10, "Rocket Control Unit": 10], outputs: ["Rocket Part": 1]),
    
    // Production Buildings
    Recipe(id: "electric-furnace", name: "Electric Furnace", category: "assembling", time: 5, inputs: ["Steel Plate": 10, "Advanced Circuit": 5, "Stone Brick": 10], outputs: ["Electric Furnace": 1]),
    Recipe(id: "oil-refinery", name: "Oil Refinery", category: "assembling", time: 8, inputs: ["Steel Plate": 15, "Iron Gear Wheel": 10, "Stone Brick": 10, "Electronic Circuit": 10, "Pipe": 10], outputs: ["Oil Refinery": 1]),
    Recipe(id: "chemical-plant", name: "Chemical Plant", category: "assembling", time: 5, inputs: ["Steel Plate": 5, "Iron Gear Wheel": 5, "Electronic Circuit": 5, "Pipe": 5], outputs: ["Chemical Plant": 1]),
    Recipe(id: "centrifuge", name: "Centrifuge", category: "assembling", time: 4, inputs: ["Concrete": 100, "Steel Plate": 50, "Advanced Circuit": 100, "Iron Gear Wheel": 100], outputs: ["Centrifuge": 1]),
    Recipe(id: "lab", name: "Lab", category: "assembling", time: 2, inputs: ["Electronic Circuit": 10, "Iron Gear Wheel": 10, "Transport Belt": 4], outputs: ["Lab": 1]),
    Recipe(id: "rail", name: "Rail", category: "assembling", time: 0.5, inputs: ["Stone": 1, "Iron Stick": 1, "Steel Plate": 1], outputs: ["Rail": 2]),
    Recipe(id: "flying-robot-frame", name: "Flying Robot Frame", category: "assembling", time: 20, inputs: ["Electric Engine Unit": 1, "Battery": 2, "Steel Plate": 1, "Electronic Circuit": 3], outputs: ["Flying Robot Frame": 1]),
    Recipe(id: "accumulator", name: "Accumulator", category: "assembling", time: 10, inputs: ["Iron Plate": 2, "Battery": 5], outputs: ["Accumulator": 1]),
    Recipe(id: "solar-panel", name: "Solar Panel", category: "assembling", time: 10, inputs: ["Steel Plate": 5, "Electronic Circuit": 15, "Copper Plate": 5], outputs: ["Solar Panel": 1]),
    
    // Concrete
    Recipe(id: "concrete", name: "Concrete", category: "assembling", time: 10, inputs: ["Stone Brick": 5, "Iron Ore": 1, "Water": 100], outputs: ["Concrete": 10]),
    Recipe(id: "hazard-concrete", name: "Hazard Concrete", category: "assembling", time: 0.25, inputs: ["Concrete": 10], outputs: ["Hazard Concrete": 10]),
    Recipe(id: "refined-concrete", name: "Refined Concrete", category: "assembling", time: 15, inputs: ["Concrete": 20, "Iron Stick": 8, "Steel Plate": 1, "Water": 100], outputs: ["Refined Concrete": 10]),
    
    // Nuclear
    Recipe(id: "uranium-processing", name: "Uranium Processing", category: "centrifuging", time: 12, inputs: ["Uranium Ore": 10], outputs: ["Uranium-235": 0.007, "Uranium-238": 0.993]),
    Recipe(id: "uranium-fuel-cell", name: "Uranium Fuel Cell", category: "assembling", time: 10, inputs: ["Iron Plate": 10, "Uranium-235": 1, "Uranium-238": 19], outputs: ["Uranium Fuel Cell": 10]),
    Recipe(id: "nuclear-fuel-reprocessing", name: "Nuclear Fuel Reprocessing", category: "centrifuging", time: 60, inputs: ["Used Up Uranium Fuel Cell": 5], outputs: ["Uranium-238": 3]),
    Recipe(id: "kovarex-enrichment-process", name: "Kovarex Enrichment Process", category: "centrifuging", time: 60, inputs: ["Uranium-235": 40, "Uranium-238": 5], outputs: ["Uranium-235": 41, "Uranium-238": 2]),
    
    // Alternative Molten Metal Recipes (ALT recipes from Foundry)
    Recipe(id: "molten-iron", name: "Molten Iron", category: "casting", time: 32, inputs: ["Iron Ore": 50, "Calcite": 1], outputs: ["Molten Iron": 500]),
    Recipe(id: "molten-copper", name: "Molten Copper", category: "casting", time: 32, inputs: ["Copper Ore": 50, "Calcite": 1], outputs: ["Molten Copper": 500]),
    Recipe(id: "molten-iron-from-lava", name: "Molten Iron from Lava", category: "casting", time: 16, inputs: ["Lava": 500, "Calcite": 2], outputs: ["Molten Iron": 250, "Stone": 10]),
    Recipe(id: "molten-copper-from-lava", name: "Molten Copper from Lava", category: "casting", time: 16, inputs: ["Lava": 500, "Calcite": 2], outputs: ["Molten Copper": 250, "Stone": 10]),
    Recipe(id: "iron-plate-from-molten", name: "Iron Plate (Molten)", category: "casting", time: 3.2, inputs: ["Molten Iron": 10], outputs: ["Iron Plate": 1]),
    Recipe(id: "copper-plate-from-molten", name: "Copper Plate (Molten)", category: "casting", time: 3.2, inputs: ["Molten Copper": 10], outputs: ["Copper Plate": 1]),
    Recipe(id: "steel-plate-from-molten", name: "Steel Plate (Molten)", category: "casting", time: 3.2, inputs: ["Molten Iron": 30], outputs: ["Steel Plate": 1]),
    Recipe(id: "concrete-from-molten", name: "Concrete (Foundry)", category: "casting", time: 10, inputs: ["Molten Iron": 20, "Water": 100, "Stone Brick": 5], outputs: ["Concrete": 10]),
    Recipe(id: "casting-copper-cable", name: "Casting Copper Cable", category: "casting", time: 0.5, inputs: ["Molten Copper": 5], outputs: ["Copper Cable": 2]),
    Recipe(id: "casting-iron-gear-wheel", name: "Casting Iron Gear Wheel", category: "casting", time: 0.5, inputs: ["Molten Iron": 10], outputs: ["Iron Gear Wheel": 1]),
    Recipe(id: "casting-iron-stick", name: "Casting Iron Stick", category: "casting", time: 0.5, inputs: ["Molten Iron": 5], outputs: ["Iron Stick": 2]),
    Recipe(id: "casting-low-density-structure", name: "Casting Low Density Structure", category: "casting", time: 15, inputs: ["Molten Copper": 200, "Molten Iron": 20, "Plastic Bar": 5], outputs: ["Low Density Structure": 1]),
    Recipe(id: "casting-pipe", name: "Casting Pipe", category: "casting", time: 0.5, inputs: ["Molten Iron": 10], outputs: ["Pipe": 1]),
    Recipe(id: "casting-pipe-to-ground", name: "Casting Pipe to Ground", category: "casting", time: 1, inputs: ["Molten Iron": 50, "Pipe": 2], outputs: ["Pipe to Ground": 2]),
    
    // Vulcanus-specific
    Recipe(id: "tungsten-plate", name: "Tungsten Plate", category: "smelting", time: 10, inputs: ["Tungsten Ore": 4, "Sulfuric Acid": 10], outputs: ["Tungsten Plate": 1]),
    Recipe(id: "tungsten-carbide", name: "Tungsten Carbide", category: "assembling", time: 2, inputs: ["Tungsten Plate": 2, "Carbon": 1], outputs: ["Tungsten Carbide": 1]),
    Recipe(id: "carbon", name: "Carbon", category: "chemistry", time: 1, inputs: ["Coal": 2, "Sulfuric Acid": 20], outputs: ["Carbon": 1]),
    Recipe(id: "carbon-fiber", name: "Carbon Fiber", category: "assembling", time: 4, inputs: ["Carbon": 4, "Plastic Bar": 2], outputs: ["Carbon Fiber": 1]),
    
    // Fulgora-specific (NEW)
    Recipe(id: "holmium-solution", name: "Holmium Solution", category: "chemistry", time: 1, inputs: ["Holmium Ore": 2, "Stone": 1, "Water": 10], outputs: ["Holmium Solution": 10]),
    Recipe(id: "holmium-plate", name: "Holmium Plate", category: "assembling", time: 1, inputs: ["Holmium Solution": 20], outputs: ["Holmium Plate": 1]),
    Recipe(id: "superconductor", name: "Superconductor", category: "electromagnetic", time: 5, inputs: ["Copper Plate": 2, "Plastic Bar": 1, "Holmium Plate": 1, "Light Oil": 5], outputs: ["Superconductor": 1]),
    Recipe(id: "supercapacitor", name: "Supercapacitor", category: "electromagnetic", time: 10, inputs: ["Battery": 2, "Electronic Circuit": 4, "Superconductor": 2, "Holmium Solution": 10], outputs: ["Supercapacitor": 1]),
    Recipe(id: "lightning-rod", name: "Lightning Rod", category: "assembling", time: 5, inputs: ["Copper Plate": 3, "Steel Plate": 8], outputs: ["Lightning Rod": 1]),
    Recipe(id: "lightning-collector", name: "Lightning Collector", category: "electromagnetic", time: 10, inputs: ["Lightning Rod": 2, "Accumulator": 1, "Superconductor": 4], outputs: ["Lightning Collector": 1]),
    Recipe(id: "scrap-recycling", name: "Scrap Recycling", category: "recycling", time: 0.2, inputs: ["Scrap": 1], outputs: ["Iron Gear Wheel": 0.2, "Concrete": 0.05, "Copper Cable": 0.03, "Steel Plate": 0.02, "Solid Fuel": 0.07, "Stone": 0.04, "Battery": 0.01, "Processing Unit": 0.002, "Low Density Structure": 0.001, "Ice": 0.05, "Holmium Ore": 0.01]),
    
    // Electromagnetic Plant exclusive recipes (NEW)
    Recipe(id: "electromagnetic-plant", name: "Electromagnetic Plant", category: "electromagnetic", time: 10, inputs: ["Steel Plate": 20, "Advanced Circuit": 10, "Holmium Plate": 20, "Processing Unit": 10], outputs: ["Electromagnetic Plant": 1]),
    Recipe(id: "tesla-turret", name: "Tesla Turret", category: "electromagnetic", time: 10, inputs: ["Steel Plate": 20, "Supercapacitor": 1, "Processing Unit": 10], outputs: ["Tesla Turret": 1]),
    Recipe(id: "tesla-ammo", name: "Tesla Ammo", category: "electromagnetic", time: 10, inputs: ["Supercapacitor": 1, "Steel Plate": 1], outputs: ["Tesla Ammo": 1]),
    
    // Space Platform
    Recipe(id: "space-platform-foundation", name: "Space Platform Foundation", category: "assembling", time: 10, inputs: ["Steel Plate": 20, "Low Density Structure": 10], outputs: ["Space Platform Foundation": 1]),
    Recipe(id: "asteroid-collector", name: "Asteroid Collector", category: "space-manufacturing", time: 10, inputs: ["Low Density Structure": 20, "Electric Engine Unit": 5, "Processing Unit": 5], outputs: ["Asteroid Collector": 1]),
    Recipe(id: "crusher", name: "Crusher", category: "space-manufacturing", time: 10, inputs: ["Steel Plate": 10, "Iron Gear Wheel": 5, "Electric Engine Unit": 2], outputs: ["Crusher": 1]),
    Recipe(id: "thruster", name: "Thruster", category: "space-manufacturing", time: 10, inputs: ["Steel Plate": 10, "Iron Gear Wheel": 10, "Pipe": 5], outputs: ["Thruster": 1]),
    Recipe(id: "cargo-bay", name: "Cargo Bay", category: "space-manufacturing", time: 10, inputs: ["Steel Plate": 20, "Low Density Structure": 5, "Processing Unit": 1], outputs: ["Cargo Bay": 1]),
    
    // Asteroid Crushing
    Recipe(id: "metallic-asteroid-crushing", name: "Metallic Asteroid Crushing", category: "crushing", time: 2, inputs: ["Metallic Asteroid": 1], outputs: ["Iron Ore": 20, "Copper Ore": 10, "Stone": 8]),
    Recipe(id: "carbonic-asteroid-crushing", name: "Carbonic Asteroid Crushing", category: "crushing", time: 2, inputs: ["Carbonic Asteroid": 1], outputs: ["Carbon": 10, "Sulfur": 4, "Water": 20]),
    Recipe(id: "oxide-asteroid-crushing", name: "Oxide Asteroid Crushing", category: "crushing", time: 2, inputs: ["Oxide Asteroid": 1], outputs: ["Ice": 10, "Calcite": 5, "Iron Ore": 5]),
    Recipe(id: "promethium-asteroid-crushing", name: "Promethium Asteroid Crushing", category: "crushing", time: 2, inputs: ["Promethium Asteroid": 1], outputs: ["Promethium Asteroid Chunk": 10]),
    
    // Advanced Asteroid Crushing (ALT recipes)
    Recipe(id: "advanced-metallic-asteroid-crushing", name: "Advanced Metallic Asteroid Crushing", category: "crushing", time: 5, inputs: ["Metallic Asteroid": 1], outputs: ["Iron Ore": 25, "Copper Ore": 12, "Stone": 10, "Holmium Ore": 1, "Tungsten Ore": 1]),
    Recipe(id: "advanced-carbonic-asteroid-crushing", name: "Advanced Carbonic Asteroid Crushing", category: "crushing", time: 5, inputs: ["Carbonic Asteroid": 1], outputs: ["Carbon": 12, "Sulfur": 5, "Water": 25]),
    Recipe(id: "advanced-oxide-asteroid-crushing", name: "Advanced Oxide Asteroid Crushing", category: "crushing", time: 5, inputs: ["Oxide Asteroid": 1], outputs: ["Ice": 12, "Calcite": 6, "Iron Ore": 6]),
    
    // Space Platform Processing
    Recipe(id: "asteroid-chunk-processing", name: "Asteroid Chunk Processing", category: "assembling", time: 1, inputs: ["Asteroid Chunk": 1], outputs: ["Iron Ore": 1, "Copper Ore": 1, "Stone": 1]),
    Recipe(id: "thruster-fuel", name: "Thruster Fuel", category: "chemistry", time: 10, inputs: ["Carbon": 2, "Water": 10], outputs: ["Thruster Fuel": 1]),
    Recipe(id: "thruster-oxidizer", name: "Thruster Oxidizer", category: "chemistry", time: 10, inputs: ["Water": 10, "Iron Ore": 2], outputs: ["Thruster Oxidizer": 1]),
    
    // Gleba / Biochamber Recipes
    Recipe(id: "nutrients", name: "Nutrients", category: "biochamber", time: 2, inputs: ["Spoilage": 10, "Water": 10], outputs: ["Nutrients": 20]),
    Recipe(id: "bioflux", name: "Bioflux", category: "biochamber", time: 4, inputs: ["Yumako Mash": 12, "Jellynut Paste": 12], outputs: ["Bioflux": 2]),
    Recipe(id: "jelly", name: "Jelly", category: "biochamber", time: 20, inputs: ["Jellynut Paste": 40, "Water": 20], outputs: ["Jelly": 20]),
    Recipe(id: "biter-egg", name: "Biter Egg", category: "biochamber", time: 10, inputs: ["Biter Egg Fragment": 10, "Nutrients": 20], outputs: ["Biter Egg": 1]),
    Recipe(id: "pentapod-egg", name: "Pentapod Egg", category: "biochamber", time: 15, inputs: ["Pentapod Egg Fragment": 10, "Nutrients": 30], outputs: ["Pentapod Egg": 1]),
    Recipe(id: "yumako-processing", name: "Yumako Processing", category: "biochamber", time: 1, inputs: ["Yumako": 2], outputs: ["Yumako Mash": 3]),
    Recipe(id: "jellynut-processing", name: "Jellynut Processing", category: "biochamber", time: 1, inputs: ["Jellynut": 2], outputs: ["Jellynut Paste": 3]),
    Recipe(id: "tree-seed-from-wood", name: "Tree Seed from Wood", category: "biochamber", time: 2, inputs: ["Wood": 10], outputs: ["Tree Seed": 1]),
    Recipe(id: "yumako-cultivation", name: "Yumako Cultivation", category: "biochamber", time: 60, inputs: ["Yumako Seed": 2, "Nutrients": 50, "Water": 50], outputs: ["Yumako": 30]),
    Recipe(id: "jellynut-cultivation", name: "Jellynut Cultivation", category: "biochamber", time: 60, inputs: ["Jellynut Seed": 2, "Nutrients": 50, "Water": 50], outputs: ["Jellynut": 20]),
    Recipe(id: "fish-breeding", name: "Fish Breeding", category: "biochamber", time: 180, inputs: ["Raw Fish": 2, "Nutrients": 100, "Water": 100], outputs: ["Raw Fish": 4]),
    
    // Biochamber Alternatives (ALT recipes)
    Recipe(id: "bioplastic", name: "Bioplastic", category: "biochamber", time: 5, inputs: ["Yumako Mash": 10, "Jellynut Paste": 10], outputs: ["Plastic Bar": 2]),
    Recipe(id: "biosulfur", name: "Biosulfur", category: "biochamber", time: 2, inputs: ["Yumako Mash": 5, "Bacteria": 5], outputs: ["Sulfur": 2]),
    Recipe(id: "biolubricant", name: "Biolubricant", category: "biochamber", time: 2, inputs: ["Jellynut Paste": 10], outputs: ["Lubricant": 10]),
    Recipe(id: "rocket-fuel-from-jelly", name: "Rocket Fuel from Jelly", category: "biochamber", time: 30, inputs: ["Jelly": 30], outputs: ["Rocket Fuel": 1]),
    Recipe(id: "iron-bacteria-cultivation", name: "Iron Bacteria Cultivation", category: "biochamber", time: 4, inputs: ["Iron Bacteria": 1, "Nutrients": 10], outputs: ["Iron Ore": 1]),
    Recipe(id: "copper-bacteria-cultivation", name: "Copper Bacteria Cultivation", category: "biochamber", time: 4, inputs: ["Copper Bacteria": 1, "Nutrients": 10], outputs: ["Copper Ore": 1]),
    
    // Aquilo / Cryogenic Recipes (NEW)
    Recipe(id: "ice-melting", name: "Ice Melting", category: "chemistry", time: 1, inputs: ["Ice": 1], outputs: ["Water": 10]),
    Recipe(id: "ammonia", name: "Ammonia", category: "chemistry", time: 2, inputs: ["Nitrogen": 50, "Hydrogen": 100], outputs: ["Ammonia": 20]),
    Recipe(id: "solid-fuel-from-ammonia", name: "Solid Fuel from Ammonia", category: "cryogenic", time: 2, inputs: ["Ammonia": 20], outputs: ["Solid Fuel": 1]),
    Recipe(id: "ammonia-rocket-fuel", name: "Ammonia Rocket Fuel", category: "cryogenic", time: 10, inputs: ["Ammonia": 40, "Iron Plate": 5, "Oxidizer": 20], outputs: ["Solid Rocket Fuel": 1]),
    Recipe(id: "lithium-plate", name: "Lithium Plate", category: "chemistry", time: 2, inputs: ["Lithium Ore": 1, "Sulfuric Acid": 10], outputs: ["Lithium Plate": 1]),
    Recipe(id: "fluorine", name: "Fluorine", category: "chemistry", time: 2, inputs: ["Fluorite": 2, "Sulfuric Acid": 30, "Steam": 50], outputs: ["Fluorine": 10]),
    Recipe(id: "fluoroketone-cold", name: "Fluoroketone (Cold)", category: "cryogenic", time: 5, inputs: ["Fluorine": 10, "Ammonia": 10, "Carbon": 1], outputs: ["Fluoroketone (Cold)": 20]),
    Recipe(id: "fluoroketone-hot", name: "Fluoroketone (Hot)", category: "chemistry", time: 5, inputs: ["Fluoroketone (Cold)": 20], outputs: ["Fluoroketone (Hot)": 20]),
    Recipe(id: "fusion-power-cell", name: "Fusion Power Cell", category: "assembling", time: 10, inputs: ["Lithium Plate": 1, "Deuterium": 50, "Tritium": 50], outputs: ["Fusion Power Cell": 1]),
    Recipe(id: "fusion-reactor", name: "Fusion Reactor", category: "assembling", time: 60, inputs: ["Processing Unit": 200, "Tungsten Plate": 50, "Superconductor": 50, "Lithium Plate": 50], outputs: ["Fusion Reactor": 1]),
    Recipe(id: "cryogenic-plant", name: "Cryogenic Plant", category: "cryogenic", time: 30, inputs: ["Steel Plate": 40, "Processing Unit": 20, "Concrete": 40, "Refined Concrete": 20], outputs: ["Cryogenic Plant": 1]),
    Recipe(id: "railgun-turret", name: "Railgun Turret", category: "assembling", time: 20, inputs: ["Steel Plate": 40, "Superconductor": 10, "Processing Unit": 20, "Tungsten Plate": 10], outputs: ["Railgun Turret": 1]),
    Recipe(id: "railgun-ammo", name: "Railgun Ammo", category: "assembling", time: 10, inputs: ["Steel Plate": 5, "Superconductor": 1, "Explosives": 1], outputs: ["Railgun Ammo": 10]),
    Recipe(id: "rocket-turret", name: "Rocket Turret", category: "assembling", time: 10, inputs: ["Steel Plate": 40, "Electronic Circuit": 30, "Iron Gear Wheel": 30], outputs: ["Rocket Turret": 1]),
    
    // Aquilo Advanced (NEW)
    Recipe(id: "quantum-processor", name: "Quantum Processor", category: "electromagnetic", time: 30, inputs: ["Processing Unit": 2, "Superconductor": 2, "Carbon Fiber": 1, "Tungsten Carbide": 1], outputs: ["Quantum Processor": 1]),
    Recipe(id: "mech-armor", name: "Mech Armor", category: "assembling", time: 60, inputs: ["Processing Unit": 200, "Steel Plate": 400, "Low Density Structure": 100, "Supercapacitor": 20, "Holmium Plate": 100], outputs: ["Mech Armor": 1]),
    Recipe(id: "personal-roboport-mk2", name: "Personal Roboport MK2", category: "assembling", time: 20, inputs: ["Personal Roboport": 5, "Processing Unit": 100, "Supercapacitor": 20], outputs: ["Personal Roboport MK2": 1]),
    Recipe(id: "personal-roboport", name: "Personal Roboport", category: "assembling", time: 10, inputs: ["Advanced Circuit": 10, "Iron Gear Wheel": 40, "Steel Plate": 20, "Battery": 45], outputs: ["Personal Roboport": 1]),
    
    // Utilities
    Recipe(id: "explosives", name: "Explosives", category: "chemistry", time: 4, inputs: ["Sulfur": 1, "Coal": 1, "Water": 10], outputs: ["Explosives": 2]),
    Recipe(id: "cliff-explosives", name: "Cliff Explosives", category: "assembling", time: 8, inputs: ["Explosives": 10, "Empty Barrel": 1, "Grenade": 1], outputs: ["Cliff Explosives": 1]),
    Recipe(id: "barrel", name: "Barrel", category: "assembling", time: 1, inputs: ["Steel Plate": 1], outputs: ["Empty Barrel": 1]),
    Recipe(id: "repair-pack", name: "Repair Pack", category: "assembling", time: 0.5, inputs: ["Electronic Circuit": 2, "Iron Gear Wheel": 2], outputs: ["Repair Pack": 1]),
    Recipe(id: "automation-core", name: "Automation Core", category: "assembling", time: 2, inputs: ["Iron Gear Wheel": 4, "Electronic Circuit": 2], outputs: ["Automation Core": 1]),
    Recipe(id: "logistic-robot", name: "Logistic Robot", category: "assembling", time: 0.5, inputs: ["Flying Robot Frame": 1, "Advanced Circuit": 2], outputs: ["Logistic Robot": 1]),
    Recipe(id: "construction-robot", name: "Construction Robot", category: "assembling", time: 0.5, inputs: ["Flying Robot Frame": 1, "Electronic Circuit": 2], outputs: ["Construction Robot": 1]),
    Recipe(id: "roboport", name: "Roboport", category: "assembling", time: 5, inputs: ["Steel Plate": 45, "Iron Gear Wheel": 45, "Advanced Circuit": 45], outputs: ["Roboport": 1]),
    Recipe(id: "beacon", name: "Beacon", category: "assembling", time: 15, inputs: ["Electronic Circuit": 20, "Advanced Circuit": 20, "Steel Plate": 10, "Copper Cable": 10], outputs: ["Beacon": 1]),
    Recipe(id: "heat-pipe", name: "Heat Pipe", category: "assembling", time: 1, inputs: ["Steel Plate": 10, "Copper Plate": 20], outputs: ["Heat Pipe": 1]),
    Recipe(id: "heat-exchanger", name: "Heat Exchanger", category: "assembling", time: 3, inputs: ["Steel Plate": 10, "Copper Plate": 100, "Pipe": 10], outputs: ["Heat Exchanger": 1]),
    Recipe(id: "steam-turbine", name: "Steam Turbine", category: "assembling", time: 3, inputs: ["Iron Gear Wheel": 50, "Copper Plate": 50, "Pipe": 20], outputs: ["Steam Turbine": 1]),
    Recipe(id: "nuclear-reactor", name: "Nuclear Reactor", category: "assembling", time: 8, inputs: ["Concrete": 500, "Steel Plate": 500, "Advanced Circuit": 500, "Copper Plate": 500], outputs: ["Nuclear Reactor": 1]),
    Recipe(id: "satellite", name: "Satellite", category: "assembling", time: 5, inputs: ["Low Density Structure": 100, "Solar Panel": 100, "Accumulator": 100, "Radar": 5, "Processing Unit": 100, "Rocket Fuel": 50], outputs: ["Satellite": 1]),
    Recipe(id: "radar", name: "Radar", category: "assembling", time: 0.5, inputs: ["Electronic Circuit": 5, "Iron Gear Wheel": 5, "Iron Plate": 10], outputs: ["Radar": 1]),
]
