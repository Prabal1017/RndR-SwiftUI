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
//                            if !filteredRooms.isEmpty {
//                                let layout = Array(repeating: GridItem(.flexible()), count: 2) // 2 columns
//                                LazyVGrid(columns: layout, spacing: 30) {
//                                    ForEach(filteredRooms) { room in
//                                        VStack {
//                                            ZStack(alignment: .topLeading) {
//                                                if let modelURL = URL(string: room.modelUrl) {
//                                                    NavigationLink(destination: FileDetailView(fileName: room.roomName, modelURL: modelURL)) {
//                                                        WebImage(url: URL(string: room.imageUrl))
//                                                            .resizable()
//                                                            .scaledToFill()
//                                                            .frame(width: (UIScreen.main.bounds.width / 2) - 30, height: 200) // Adjust size for grid
//                                                            .clipShape(RoundedRectangle(cornerRadius: 10))
//                                                    }
//
//                                                    // Tag for room type
//                                                    Text(room.roomType)
//                                                        .font(.caption)
//                                                        .padding(5)
//                                                        .background(Color.blue)
//                                                        .foregroundColor(.primary)
//                                                        .cornerRadius(5)
//                                                        .padding([.top, .leading], 10)
//                                                } else {
//                                                    // Handle invalid URL case
//                                                    Text("Invalid model URL")
//                                                        .foregroundColor(.red)
//                                                }
//                                            }
//
//                                            Text(room.roomName)
//                                                .font(.subheadline)
//                                                .frame(maxWidth: .infinity, alignment: .leading)
//                                                .foregroundColor(.secondary)
//                                        }
//                                    }
//                                }
//                                .padding(.horizontal)
//                            }else if filteredRooms.isEmpty{
//                                VStack(spacing: 10){
//                                    Spacer()
//
//                                    Image(systemName: "magnifyingglass")
//                                        .resizable()
//                                        .frame(width: 60, height: 60)
//                                        .foregroundColor(.secondary)
//                                        .padding(.bottom)
//
//                                    Text("No Results for '\(searchText)'")
//                                        .font(.title2)
//                                        .bold()
//                                        .foregroundColor(.primary)
//
//                                    Text("Check the spelling or try a different search")
//                                        .font(.subheadline)
//                                        .foregroundColor(.secondary)
//
//                                    Spacer()
//                                }
//                            }
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
//                    viewModel.fetchAllRoomsForCategories()
//                }
//                .navigationTitle("Home")
//                .navigationBarTitleDisplayMode(.automatic)
//                .searchable(text: $searchText, prompt: "Search rooms by name or type") // Searchable modifier
//            }
//        }
//    }
//}
////
////#Preview {
////    HomeView()
////}
//
//
//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View{
//        Group{
//            HomeView()
//                .environment(\.locale, Locale.init(identifier: "en"))
//
//            HomeView()
//                .environment(\.locale, Locale.init(identifier: "es"))
//        }
//    }
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
        GeometryReader { geo in
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
                                    .shadow(radius: 5)
                                
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
                                if !filteredRooms.isEmpty {
                                    let layout = Array(repeating: GridItem(.flexible()), count: 2) // 2 columns
                                    LazyVGrid(columns: layout, spacing: 30) {
                                        ForEach(filteredRooms) { room in
                                            VStack {
                                                ZStack(alignment: .topLeading) {
                                                    if let modelURL = URL(string: room.modelUrl) {
                                                        NavigationLink(destination: FileDetailView(fileName: room.roomName, modelURL: modelURL)) {
                                                            ZStack(alignment: .bottom){
                                                                WebImage(url: URL(string: room.imageUrl))
                                                                    .resizable()
                                                                    .scaledToFill()
                                                                    .frame(width: geo.size.width / 2 - 20, height: 200)
                                                                
                                                                Text(room.roomName)
                                                                    .font(.headline)
                                                                    .fontWeight(.semibold)
                                                                    .foregroundColor(.white)
                                                                    .padding([.top, .bottom], 10)
                                                                    .frame(maxWidth: .greatestFiniteMagnitude)
                                                                    .background(Material.ultraThinMaterial)
                                                                    .lineLimit(1)
                                                                    .minimumScaleFactor(0.6)
                                                            }
                                                            .cornerRadius(10)
                                                        }
                                                        
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
                                            }
                                            .shadow(radius: 5)
                                        }
                                    }
                                    .padding(.horizontal)
                                }else if filteredRooms.isEmpty{
                                    VStack(spacing: 10){
                                        Spacer()
                                        
                                        Image(systemName: "magnifyingglass")
                                            .resizable()
                                            .frame(width: 60, height: 60)
                                            .foregroundColor(.secondary)
                                            .padding(.bottom)
                                        
                                        Text("No Results for '\(searchText)'")
                                            .font(.title2)
                                            .bold()
                                            .foregroundColor(.primary)
                                        
                                        Text("Check the spelling or try a different search")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                    }
                                }
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
                        viewModel.fetchAllRoomsForCategories()
                    }
                    .navigationTitle("Home")
                    .navigationBarTitleDisplayMode(.automatic)
                    .searchable(text: $searchText, prompt: "Search rooms by name or type") // Searchable modifier
                }
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
