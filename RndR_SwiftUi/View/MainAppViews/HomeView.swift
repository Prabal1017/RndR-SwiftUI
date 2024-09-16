import SwiftUI

struct HomeView: View {
    var recentlyView = ["bedroom", "kitchen", "livingroom", "dinningroom", "bathroom"]
    let cate = ["Bedroom", "Kitchen", "Living Room", "Dinning Room", "Bathroom"]
    
    @State private var isShowingAddRoomView = false
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Recent scans")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                
                // Using the subview SliderView
                SliderView(recentlyView: recentlyView)
                
                HStack {
                    Text("Rooms")
                        .font(.title.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button {
                        isShowingAddRoomView = true
                    } label: {
                        Image(systemName: "plus")
                            .imageScale(.large)
                            .frame(height: 44)
                    }
                }
                .padding([.horizontal, .top])
                
                // Categories view with images and names
                categoriesView(categories: getCategories())
            }
            .padding(.top)
            .sheet(isPresented: $isShowingAddRoomView) {
                AddRoomView(isShowingAddRoomView: $isShowingAddRoomView)
            }
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
//    var recentlyView: [String]
    var categories: [(imageName: String, categoryName: String)]
    let columns = Array(repeating: GridItem(.flexible(),spacing: 20), count: 2)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(categories, id: \.categoryName) { category in
                NavigationLink(destination: CategorieItemView(roomType: category.categoryName, heroImage: category.imageName)){
                    ZStack(alignment: .bottom){
                        Image(category.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .greatestFiniteMagnitude)
                            .cornerRadius(8)
                            .draggable(category.imageName)
                        HStack {
                            VStack(alignment: .leading) {
                                Text(category.categoryName)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding([.top,.bottom,],8)
                            }
                        }
                        .frame(maxWidth: .greatestFiniteMagnitude)
                        .background(
                            Material.ultraThinMaterial
                        )
                    }
                }
                .cornerRadius(10)
            }
        }
        .padding(.horizontal)
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
                        ZStack(alignment: .bottom) {
                            Image(demo)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .greatestFiniteMagnitude)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("BedRoom One")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Text("Subtitle")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                
                                Button {
                                    // Action (view with LiDAR)
                                } label: {
                                    Text("View")
                                        .frame(width: 80, height: 36)
                                        .foregroundColor(.white)
                                        .background(Color.white.opacity(0.4))
                                        .fontWeight(.bold)
                                        .cornerRadius(20)
                                }
                            }
                            .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
                            .padding()
                            .background(
                                Material.ultraThinMaterial
                            )
                        }
                    }
                    .cornerRadius(10)
                    .padding(.horizontal)
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
