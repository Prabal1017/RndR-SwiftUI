//import SwiftUI
//
//struct HomeView: View {
//    @StateObject private var viewModel = HomeViewViewModel()
//    @StateObject private var roomViewModel = RoomPlanViewViewModel()
//    @State private var isShowingAddRoomView = false
//    @State private var showNavbarTitle = false
//
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack {
//
//                    VStack {
//                        Text("Recent scans")
//                            .font(.title.bold())
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .padding(.leading, 20)
//
//                        
//                        SliderView(viewModel: roomViewModel)
//
//                        HStack {
//                            Text("Rooms")
//                                .font(.title.bold())
//                                .frame(maxWidth: .infinity, alignment: .leading)
//
//                            Button {
//                                isShowingAddRoomView = true
//                            } label: {
//                                Image(systemName: "plus")
//                                    .imageScale(.large)
//                                    .frame(height: 44)
//                            }
//                        }
//                        .padding([.horizontal, .top])
//
//                        categoriesView(categories: viewModel.categories)
//                    }
//                    .padding(.top)
//                    .sheet(isPresented: $isShowingAddRoomView) {
//                        AddRoomView(
//                            isShowingAddRoomView: $isShowingAddRoomView,
//                            viewModel: roomViewModel
//                        )
//                        .presentationDetents([.medium])
//                    }
//                }
//                .padding(.top)
//            }
////            .background(
////                Image("appBackground")  // Replace with your image name
////                    .resizable()
////                    .scaledToFill()
////                    .edgesIgnoringSafeArea(.all)
////            )
//            .onAppear {
//                viewModel.fetchCategories()
//                roomViewModel.fetchCategoryNames()
//                roomViewModel.fetchRecentRooms()
//            }
//            .refreshable {
//                viewModel.fetchCategories()
//                roomViewModel.fetchCategoryNames()
//                roomViewModel.handleUserChange()
//            }
//            .navigationTitle("Home")  // Conditional title
//            .navigationBarTitleDisplayMode(.automatic)
//        }
//    }
//}
//
//#Preview {
//    HomeView()
//}
//
//// PreferenceKey to track scroll offset
//struct ScrollOffsetKey: PreferenceKey {
//    static var defaultValue: CGFloat = 0
//
//    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
//        value = nextValue()
//    }
//}



//import SwiftUI
//
//struct HomeView: View {
//    @StateObject private var viewModel = HomeViewViewModel()
//    @StateObject private var roomViewModel = RoomPlanViewViewModel()
//    @State private var isShowingAddRoomView = false
//    @State private var showNavbarTitle = false
//    
//    // State for search text
//    @State private var searchText: String = ""
//    
//    // Filtered rooms based on search query
//    var filteredRooms: [Room] {
//        if searchText.isEmpty {
//            return []
//        } else {
//            return viewModel.allRooms.filter { room in
//                room.roomName.lowercased().contains(searchText.lowercased()) ||
//                room.roomType.lowercased().contains(searchText.lowercased())
//            }
//        }
//    }
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                // Search Bar
//                TextField("Search rooms by name or type", text: $searchText)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding(.horizontal)
//                    .padding(.top, 10)
//                
//                ScrollView {
//                    VStack {
//                        VStack {
//                            Text("Recent scans")
//                                .font(.title.bold())
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .padding(.leading, 20)
//                            
//                            SliderView(viewModel: roomViewModel)
//
//                            HStack {
//                                Text("Rooms")
//                                    .font(.title.bold())
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//
//                                Button {
//                                    isShowingAddRoomView = true
//                                } label: {
//                                    Image(systemName: "plus")
//                                        .imageScale(.large)
//                                        .frame(height: 44)
//                                }
//                            }
//                            .padding([.horizontal, .top])
//                            
//                            // Show the list only if there is search text
//                            if !searchText.isEmpty {
//                                // Display filtered rooms in a list
//                                List(filteredRooms) { room in
//                                    VStack(alignment: .leading) {
//                                        Text(room.roomName)
//                                            .font(.headline)
//                                        Text(room.roomType)
//                                            .font(.subheadline)
//                                    }
//                                    .padding()
//                                }
//                                .listStyle(InsetGroupedListStyle())
//                                .frame(height: 300) // Adjust height as needed
//                            } else {
//                                // Optionally, you can show a message when no search has been made
//                                Text("No rooms to display")
//                                    .foregroundColor(.gray)
//                                    .frame(maxWidth: .infinity, alignment: .center)
//                                    .padding()
//                            }
//                            
//                            categoriesView(categories: viewModel.categories)
//                        }
//                        .padding(.top)
//                        .sheet(isPresented: $isShowingAddRoomView) {
//                            AddRoomView(
//                                isShowingAddRoomView: $isShowingAddRoomView,
//                                viewModel: roomViewModel
//                            )
//                            .presentationDetents([.medium])
//                        }
//                    }
//                    .padding(.top)
//                }
//                .onAppear {
//                    viewModel.fetchCategories()
//                    roomViewModel.fetchCategoryNames()
//                    roomViewModel.fetchRecentRooms()
//                }
//                .refreshable {
//                    viewModel.fetchCategories()
//                    roomViewModel.fetchCategoryNames()
//                    roomViewModel.handleUserChange()
//                }
//                .navigationTitle("Home")
//                .navigationBarTitleDisplayMode(.automatic)
//            }
//        }
//    }
//}
//
//#Preview {
//    HomeView()
//}

///working search
//import SwiftUI
//import SDWebImageSwiftUI // Make sure to import SDWebImageSwiftUI for WebImage
//
//struct HomeView: View {
//    @StateObject private var viewModel = HomeViewViewModel()
//    @StateObject private var roomViewModel = RoomPlanViewViewModel()
//    @State private var isShowingAddRoomView = false
//    
//    // State for search text
//    @State private var searchText: String = ""
//    
//    // Filtered rooms based on search query
//    var filteredRooms: [Room] {
//        if searchText.isEmpty {
//            return []
//        } else {
//            return viewModel.allRooms.filter { room in
//                let matchesName = room.roomName.lowercased().contains(searchText.lowercased())
//                let matchesType = room.roomType.lowercased().contains(searchText.lowercased())
//                return matchesName || matchesType
//            }
//        }
//    }
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                ScrollView {
//                    VStack {
//                        if searchText.isEmpty {
//                            // Normal home view elements when search text is empty
//                            Text("Recent scans")
//                                .font(.title.bold())
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .padding(.leading, 20)
//
//                            SliderView(viewModel: roomViewModel)
//
//                            HStack {
//                                Text("Rooms")
//                                    .font(.title.bold())
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//
//                                Button {
//                                    isShowingAddRoomView = true
//                                } label: {
//                                    Image(systemName: "plus")
//                                        .imageScale(.large)
//                                        .frame(height: 44)
//                                }
//                            }
//                            .padding([.horizontal, .top])
//
//                            categoriesView(categories: viewModel.categories)
//                        } else {
//                            // Display filtered rooms in a grid when there is search text
//                            let layout = Array(repeating: GridItem(.flexible()), count: 2) // 2 columns
//                            LazyVGrid(columns: layout, spacing: 30) {
//                                ForEach(filteredRooms) { room in
//                                    VStack {
//                                        if let modelURL = URL(string: room.modelUrl) {
//                                            NavigationLink(destination: FileDetailView(fileName: room.roomName, modelURL: modelURL)) {
//                                                WebImage(url: URL(string: room.imageUrl))
//                                                    .resizable()
//                                                    .scaledToFill()
//                                                    .frame(width: (UIScreen.main.bounds.width / 2) - 30, height: 200) // Adjust size for grid
//                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
//                                            }
//                                            .contextMenu {
//                                                Button(action: {
//                                                    // Your delete logic
//                                                    // roomToDelete = room
//                                                    // showDeleteAlert = true
//                                                }) {
//                                                    Label("Delete", systemImage: "trash")
//                                                        .tint(Color.red)
//                                                }
//                                            }
//                                        } else {
//                                            // Handle invalid URL case
//                                            Text("Invalid model URL")
//                                                .foregroundColor(.red)
//                                        }
//                                        
//                                        Text(room.roomName)
//                                            .font(.subheadline)
//                                            .frame(maxWidth: .infinity, alignment: .leading)
//                                            .foregroundColor(.secondary)
//                                    }
//                                }
//                            }
//                            .padding(.horizontal)
//                        }
//                    }
//                    .padding(.top)
//                    .sheet(isPresented: $isShowingAddRoomView) {
//                        AddRoomView(
//                            isShowingAddRoomView: $isShowingAddRoomView,
//                            viewModel: roomViewModel
//                        )
//                        .presentationDetents([.medium])
//                    }
//                }
//                .onAppear {
//                    viewModel.fetchCategories()
//                    roomViewModel.fetchCategoryNames()
//                    roomViewModel.fetchRecentRooms()
//                }
//                .refreshable {
//                    viewModel.fetchCategories()
//                    roomViewModel.fetchCategoryNames()
//                    roomViewModel.handleUserChange()
//                }
//                .navigationTitle("Home")
//                .navigationBarTitleDisplayMode(.automatic)
//                .searchable(text: $searchText, prompt: "Search rooms by name or type") // Searchable modifier
//            }
//        }
//    }
//}
//
//#Preview {
//    HomeView()
//}




import SwiftUI
import SDWebImageSwiftUI // Make sure to import SDWebImageSwiftUI for WebImage

struct HomeView: View {
    @StateObject private var viewModel = HomeViewViewModel()
    @StateObject private var roomViewModel = RoomPlanViewViewModel()
    @State private var isShowingAddRoomView = false
    
    // State for search text
    @State private var searchText: String = ""
    
    // Filtered rooms based on search query
    var filteredRooms: [Room] {
        if searchText.isEmpty {
            return []
        } else {
            return viewModel.allRooms.filter { room in
                let matchesName = room.roomName.lowercased().contains(searchText.lowercased())
                let matchesType = room.roomType.lowercased().contains(searchText.lowercased())
                return matchesName || matchesType
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack {
                        if searchText.isEmpty {
                            // Normal home view elements when search text is empty
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
                        } else {
                            // Display filtered rooms in a grid when there is search text
                            let layout = Array(repeating: GridItem(.flexible()), count: 2) // 2 columns
                            LazyVGrid(columns: layout, spacing: 30) {
                                ForEach(filteredRooms) { room in
                                    VStack {
                                        ZStack(alignment: .topLeading) {
                                            if let modelURL = URL(string: room.modelUrl) {
                                                NavigationLink(destination: FileDetailView(fileName: room.roomName, modelURL: modelURL)) {
                                                    WebImage(url: URL(string: room.imageUrl))
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: (UIScreen.main.bounds.width / 2) - 30, height: 200) // Adjust size for grid
                                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                                }
//                                                .contextMenu {
//                                                    Button(action: {
//                                                        // Your delete logic
//                                                        // roomToDelete = room
//                                                        // showDeleteAlert = true
//                                                    }) {
//                                                        Label("Delete", systemImage: "trash")
//                                                            .tint(Color.red)
//                                                    }
//                                                }

                                                // Tag for room type
                                                Text(room.roomType)
                                                    .font(.caption)
                                                    .padding(5)
                                                    .background(Color.blue)
                                                    .foregroundColor(.primary)
                                                    .cornerRadius(5)
                                                    .padding([.top, .leading], 10)
                                            } else {
                                                // Handle invalid URL case
                                                Text("Invalid model URL")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                        
                                        Text(room.roomName)
                                            .font(.subheadline)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
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
                .navigationTitle("Home")
                .navigationBarTitleDisplayMode(.automatic)
                .searchable(text: $searchText, prompt: "Search rooms by name or type") // Searchable modifier
            }
        }
    }
}
//
//#Preview {
//    HomeView()
//}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View{
        Group{
            HomeView()
                .environment(\.locale, Locale.init(identifier: "en"))
            
            HomeView()
                .environment(\.locale, Locale.init(identifier: "es"))
        }
    }
}
