// MARK: - Machine Tiers Data
let MACHINE_TIERS: [String: [MachineTier]] = [
    "assembling": [
        MachineTier(id: "assembling-1", name: "Assembling Machine 1", category: "assembling", speed: 0.5, iconAsset: "assembling_machine_1", moduleSlots: 0),
        MachineTier(id: "assembling-2", name: "Assembling Machine 2", category: "assembling", speed: 0.75, iconAsset: "assembling_machine_2", moduleSlots: 2),
        MachineTier(id: "assembling-3", name: "Assembling Machine 3", category: "assembling", speed: 1.25, iconAsset: "assembling_machine_3", moduleSlots: 4)
    ],
    "smelting": [
        MachineTier(id: "stone-furnace", name: "Stone Furnace", category: "smelting", speed: 1.0, iconAsset: "stone_furnace", moduleSlots: 0),
        MachineTier(id: "steel-furnace", name: "Steel Furnace", category: "smelting", speed: 2.0, iconAsset: "steel_furnace", moduleSlots: 0),
        MachineTier(id: "electric-furnace", name: "Electric Furnace", category: "smelting", speed: 2.0, iconAsset: "electric_furnace", moduleSlots: 2)
    ],
    "chemistry": [
        MachineTier(id: "chemical-plant", name: "Chemical Plant", category: "chemistry", speed: 1.0, iconAsset: "chemical_plant", moduleSlots: 3)
    ],
    "casting": [
        MachineTier(id: "foundry", name: "Foundry", category: "casting", speed: 1.0, iconAsset: "foundry", moduleSlots: 4)
    ],
    "cryogenic": [
        MachineTier(id: "cryogenic-plant", name: "Cryogenic Plant", category: "cryogenic", speed: 1.0, iconAsset: "cryogenic_plant", moduleSlots: 4)
    ],
    "biochamber": [
        MachineTier(id: "biochamber", name: "Biochamber", category: "biochamber", speed: 1.0, iconAsset: "biochamber", moduleSlots: 4)
    ],
    "electromagnetic": [
        MachineTier(id: "electromagnetic-plant", name: "Electromagnetic Plant", category: "electromagnetic", speed: 1.0, iconAsset: "electromagnetic_plant", moduleSlots: 5)
    ],
    "crushing": [
        MachineTier(id: "crusher", name: "Crusher", category: "crushing", speed: 1.0, iconAsset: "crusher", moduleSlots: 2)
    ],
    "recycling": [
        MachineTier(id: "recycler", name: "Recycler", category: "recycling", speed: 1.0, iconAsset: "recycler", moduleSlots: 4)
    ],
    "space-manufacturing": [
        MachineTier(id: "space-platform", name: "Space Platform", category: "space-manufacturing", speed: 1.0, iconAsset: "space_platform_foundation", moduleSlots: 0)
    ],
    "centrifuging": [
        MachineTier(id: "centrifuge", name: "Centrifuge", category: "centrifuging", speed: 1.0, iconAsset: "centrifuge", moduleSlots: 2)
    ],
    "rocket-building": [
        MachineTier(id: "rocket-silo", name: "Rocket Silo", category: "rocket-building", speed: 1.0, iconAsset: "rocket_part", moduleSlots: 4)
    ],
    "mining": [
        MachineTier(id: "burner-mining-drill", name: "Burner Mining Drill", category: "mining", speed: 0.25, iconAsset: "burner_mining_drill", moduleSlots: 0),
        MachineTier(id: "electric-mining-drill", name: "Electric Mining Drill", category: "mining", speed: 0.5, iconAsset: "electric_mining_drill", moduleSlots: 3),
        MachineTier(id: "big-mining-drill", name: "Big Mining Drill", category: "mining", speed: 2.0, iconAsset: "big_mining_drill", moduleSlots: 4)
    ],
    "quality": [
        MachineTier(id: "quality-module", name: "Quality Module", category: "quality", speed: 1.0, iconAsset: "quality_module", moduleSlots: 0)
    ]
]
