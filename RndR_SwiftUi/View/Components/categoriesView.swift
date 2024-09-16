import SwiftUI

struct categoriesView: View {
    var categories: [Category]
    let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
    @StateObject private var viewModel = HomeViewViewModel()
    
    @State private var showAlert = false
    @State private var selectedCategory: Category?

    // Define the restricted category names
    let restrictedCategories = ["Bedroom", "Kitchen", "Living Room", "Dinning Room", "Bathroom"]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(categories, id: \.categoryName) { category in
                NavigationLink(destination: CategorieItemView(roomType: category.categoryName, heroImage: category.categoryImage)) {
                    ZStack(alignment: .bottom) {
                        AsyncImage(url: URL(string: category.categoryImage)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 170, height: 120)
                                    .cornerRadius(8)
                            case .failure:
                                Image(systemName: "photo.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .greatestFiniteMagnitude)
                                    .cornerRadius(8)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text(category.categoryName)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding([.top, .bottom], 8)
                            }
                        }
                        .frame(maxWidth: .greatestFiniteMagnitude)
                        .background(
                            Material.ultraThinMaterial
                        )
                    }
                }
                .cornerRadius(10)
                .contextMenu {
                    if !restrictedCategories.contains(category.categoryName) {
                        Button(role: .destructive) {
                            selectedCategory = category
                            showAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Delete Category"),
                message: Text("Are you sure you want to delete this category?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let category = selectedCategory {
                        viewModel.deleteCategory(category)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}
