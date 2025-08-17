// MARK: - Icon Components
struct IconOrMonogram: View {
    var item: String
    var size: CGFloat = Constants.iconSize
    
    var body: some View {
        Group {
            if let assetName = ICON_ASSETS[item] {
                Image(assetName)
                    .renderingMode(.original)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                Monogram(item: item, size: size)
            }
        }
        .frame(width: size, height: size)
        .contentShape(Rectangle())
    }
}

struct ItemBadge: View {
    var item: String
    
    var body: some View {
        IconOrMonogram(item: item, size: Constants.iconSize)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.blue.opacity(0.35))
            )
            .frame(width: Constants.iconSize, height: Constants.iconSize)
    }
}

struct Monogram: View {
    var item: String
    var size: CGFloat = Constants.iconSize
    
    var body: some View {
        let initials = item.split(separator: " ")
            .compactMap { $0.first }
            .prefix(2)
        
        Text(String(initials))
            .font(.caption)
            .bold()
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.blue.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.blue.opacity(0.35))
            )
    }
}
