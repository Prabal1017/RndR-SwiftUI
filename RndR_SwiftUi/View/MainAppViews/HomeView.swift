import SwiftUI

struct HomeView: View {
    var recentlyView = ["bedroom", "kitchen", "livingroom", "dinningroom", "bathroom"]
    let cate = ["Bedroom", "Kitchen", "Living Room", "Dinning Room", "Bathroom"]

    var body: some View {
        ScrollView {
            VStack {
                Text("Recently Scanned")
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)

                // Using the subview SliderView
                SliderView(recentlyView: recentlyView)
                
                Text("Categories")
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                    .padding([.top, .bottom])
                
                // Categories view with images and names
                categoriesView(categories: getCategories())
            }
            .padding(.top)
        }
    }
    
    private func getCategories() -> [(imageName: String, categoryName: String)] {
        return [
            ("bedroom", "Bedroom"),
            ("kitchen", "Kitchen"),
            ("livingroom", "Living Room"),
            ("dinningroom", "Dinning Room"),
            ("bathroom", "Bathroom")
        ]
    }
}

struct categoriesView: View {
    var categories: [(imageName: String, categoryName: String)]
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(categories, id: \.categoryName) { category in
                NavigationLink(destination: CategorieItemView(roomType: category.categoryName, heroImage: category.imageName)) {
                    VStack {
                        Image(category.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 310)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding([.top, .leading, .trailing])
                        
                        Text(category.categoryName)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.bottom)
                    }
                    .frame(width: 350)
                    .background(.secondary)
                    .cornerRadius(10)
                }
            }
        }
    }
}


// Subview for the slider
struct SliderView: View {
    var recentlyView: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(recentlyView, id: \.self) { demo in
                    VStack {
                        ZStack(alignment: .bottomLeading) {
                            Image(demo)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 350)

                            VStack(alignment: .leading) {
                                Text("Title")
                                    .font(.headline)

                                Text("Subtitle")
                                    .font(.subheadline)
                            }
                            .frame(width: 150, alignment: .leading)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(10)
                            .padding([.leading, .bottom], 10)
                        }
                    }
                    .cornerRadius(10)
                    .scrollTargetLayout()
                    .scrollTransition { content, phase in
                        content.opacity(phase.isIdentity ? 1.0 : 0.0)
                            .scaleEffect(x: phase.isIdentity ? 1.0 : 0.3, y: phase.isIdentity ? 1.0 : 0.3)
                    }
                    .containerRelativeFrame(.horizontal)
                }
            }
        }
        .scrollTargetBehavior(.paging)
    }
}

#Preview {
    HomeView()
}
