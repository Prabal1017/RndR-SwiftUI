import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewViewModel()
    @StateObject private var roomViewModel = RoomPlanViewViewModel()
    @State private var isShowingAddRoomView = false

    var body: some View {
        ScrollView {
            VStack {
                Text("Recent scans")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                
                SliderView(viewModel: roomViewModel)
                
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

                categoriesView(categories: viewModel.categories)
            }
            .padding(.top)
            .sheet(isPresented: $isShowingAddRoomView) {
                AddRoomView(isShowingAddRoomView: $isShowingAddRoomView, viewModel: roomViewModel)
                    .presentationDetents([.medium])
            }
        }
        .onAppear {
            viewModel.fetchCategories()
            roomViewModel.fetchCategoryNames()
            roomViewModel.fetchRecentRooms()
        }
        .refreshable {
            viewModel.fetchCategories()
            roomViewModel.fetchCategoryNames()
//            roomViewModel.fetchRecentRooms()
            //reset the local storage to have new users recent rooms
            roomViewModel.handleUserChange()
        }
    }
}


#Preview {
    HomeView()
}
