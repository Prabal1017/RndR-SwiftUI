import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewViewModel()
    @State private var isShowingAddRoomView = false

    var body: some View {
        ScrollView {
            VStack {
                Text("Recent scans")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                
                // Using the subview SliderView
                SliderView(recentlyView: ["bedroom", "kitchen", "livingroom", "dinningroom", "bathroom"])
                
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
                categoriesView(categories: viewModel.categories)
            }
            .padding(.top)
            .sheet(isPresented: $isShowingAddRoomView) {
                AddRoomView(isShowingAddRoomView: $isShowingAddRoomView)
            }
        }
        .onAppear {
            viewModel.fetchCategories()
        }
    }
}

#Preview {
    HomeView()
}
