//import SwiftUI
//
//struct HomeView: View {
//    @StateObject private var viewModel = HomeViewViewModel()
//    @StateObject private var roomViewModel = RoomPlanViewViewModel()
//    @State private var isShowingAddRoomView = false
//
//    var body: some View {
//        ScrollView {
//            VStack {
//                Text("Recent scans")
//                    .font(.largeTitle.bold())
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.leading, 20)
//
//                SliderView(viewModel: roomViewModel)
//
//                HStack {
//                    Text("Rooms")
//                        .font(.title.bold())
//                        .frame(maxWidth: .infinity, alignment: .leading)
//
//                    Button {
//                        isShowingAddRoomView = true
//                    } label: {
//                        Image(systemName: "plus")
//                            .imageScale(.large)
//                            .frame(height: 44)
//                    }
//                }
//                .padding([.horizontal, .top])
//
//                categoriesView(categories: viewModel.categories)
//            }
//            .padding(.top)
//            .sheet(isPresented: $isShowingAddRoomView) {
//                AddRoomView(isShowingAddRoomView: $isShowingAddRoomView, viewModel: roomViewModel)
//                    .presentationDetents([.medium])
//            }
//        }
//        .background(
//            Image("appBackground") // Replace with your image name
//                .resizable()
//                .scaledToFill()
//                .edgesIgnoringSafeArea(.all)
//        )
//        .onAppear {
//            viewModel.fetchCategories()
//            roomViewModel.fetchCategoryNames()
//            roomViewModel.fetchRecentRooms()
//        }
//        .refreshable {
//            viewModel.fetchCategories()
//            roomViewModel.fetchCategoryNames()
////            roomViewModel.fetchRecentRooms()
//            //reset the local storage to have new users recent rooms
//            roomViewModel.handleUserChange()
//        }
//    }
//}
//
//
//#Preview {
//    HomeView()
//}

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewViewModel()
    @StateObject private var roomViewModel = RoomPlanViewViewModel()
    @State private var isShowingAddRoomView = false
    @State private var showNavbarTitle = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {

                    VStack {
                        Text("Recent scans")
                            .font(.title.bold())
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
                        AddRoomView(
                            isShowingAddRoomView: $isShowingAddRoomView,
                            viewModel: roomViewModel
                        )
                        .presentationDetents([.medium])
                    }
                }
                .padding(.top)
            }
//            .background(
//                Image("appBackground")  // Replace with your image name
//                    .resizable()
//                    .scaledToFill()
//                    .edgesIgnoringSafeArea(.all)
//            )
            .onAppear {
                viewModel.fetchCategories()
                roomViewModel.fetchCategoryNames()
                roomViewModel.fetchRecentRooms()
            }
            .refreshable {
                viewModel.fetchCategories()
                roomViewModel.fetchCategoryNames()
                roomViewModel.handleUserChange()
            }
            .navigationTitle("Home")  // Conditional title
            .navigationBarTitleDisplayMode(.automatic)
        }
    }
}

#Preview {
    HomeView()
}

// PreferenceKey to track scroll offset
struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
