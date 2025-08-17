// MARK: - Item mappings
let ITEM_TO_PRODUCERS: [String: [Recipe]] = {
    var mapping: [String: [Recipe]] = [:]
    for recipe in RECIPES {
        for (outputItem, _) in recipe.outputs {
            mapping[outputItem, default: []].append(recipe)
        }
    }
    return mapping
}()

let ITEM_TO_CONSUMERS: [String: [Recipe]] = {
    var mapping: [String: [Recipe]] = [:]
    for recipe in RECIPES {
        for (inputItem, _) in recipe.inputs {
            mapping[inputItem, default: []].append(recipe)
        }
    }
    return mapping
}()
