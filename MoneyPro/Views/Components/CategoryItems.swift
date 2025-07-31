import SwiftUI

// MARK: - Category Bar Item
struct CategoryBarItem: View {
    let item: CategoryPercentage
    let geometry: GeometryProxy
    let categoryCount: Int
    let index: Int
    let isSelected: Bool
    let selectedCategory: String?
    let onTap: () -> Void
    
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(limeColorForIndex)
            .frame(
                width: (geometry.size.width - CGFloat(categoryCount - 1) * 5) * item.percentage,
                height: 30
            )
            .animation(.easeInOut(duration: 0.3), value: item.percentage)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? Colors.primaryColor : Color.clear, lineWidth: 0)
            )
            .opacity(selectedCategory == nil ? 1.0 : (isSelected ? 1.0 : 0.3))
            .onTapGesture(perform: onTap)
    }
    
    private var limeColorForIndex: Color {
        switch index {
        case 0: return Colors.limeGreen
        case 1: return Colors.limeGreen2
        case 2: return Colors.limeGreen3
        case 3: return Colors.limeGreen4
        case 4: return Colors.limeGreen5
        case 5: return Colors.limeGreen6
        case 6: return Colors.limeGreen7
        case 7: return Colors.limeGreen8
        default: return Colors.limeGreen
        }
    }
}

// MARK: - Category List Item
struct CategoryListItem: View {
    let item: CategoryPercentage
    let index: Int
    let isSelected: Bool
    let selectedCategory: String?
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            CategoryColorIndicator(category: item.category, index: index)
            CategoryNameText(name: item.category)
            CategoryPercentageText(percentage: item.percentage)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Colors.primaryBackground)
        .cornerRadius(8)
        .opacity(selectedCategory == nil ? 1.0 : (isSelected ? 1.0 : 0.3))
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Supporting Components
private struct CategoryColorIndicator: View {
    let category: String
    let index: Int
    
    var body: some View {
        Rectangle()
            .fill(limeColorForIndex)
            .frame(width: 12, height: 12)
            .cornerRadius(4)
    }
    
    private var limeColorForIndex: Color {
        switch index {
        case 0: return Colors.limeGreen
        case 1: return Colors.limeGreen2
        case 2: return Colors.limeGreen3
        case 3: return Colors.limeGreen4
        case 4: return Colors.limeGreen5
        case 5: return Colors.limeGreen6
        case 6: return Colors.limeGreen7
        case 7: return Colors.limeGreen8
        default: return Colors.limeGreen
        }
    }
}

private struct CategoryNameText: View {
    let name: String
    
    var body: some View {
        Text(name)
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundColor(Colors.primaryText)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
    }
}

private struct CategoryPercentageText: View {
    let percentage: Double
    
    var body: some View {
        Text("\(Int(percentage * 100))%")
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundColor(Colors.secondaryText)
            .lineLimit(1)
    }
}