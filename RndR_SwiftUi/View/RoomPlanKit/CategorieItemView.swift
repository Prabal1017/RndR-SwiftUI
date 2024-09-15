//import SwiftUI
//
//struct CategorieItemView: View {
//    // Define a grid layout with two columns
//    let layout = [
//        GridItem(.flexible()), // Flexible column
//        GridItem(.flexible())  // Another flexible column
//    ]
//
//    var recentlyView = ["demoImage", "demoImage1", "demoImage2"]
//
//    var body: some View {
//        VStack{
//            // Display header image
//            Image("demoImage")
//                .resizable()
//                .scaledToFill()
//                .ignoresSafeArea()
//
//            // Title
//            Text("Scans")
//                .font(.title3)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.leading)
//                .padding(.top, -30)
//
//            // LazyVGrid with 2 columns
//            LazyVGrid(columns: layout, spacing: 20) {
//                ForEach(recentlyView, id: \.self) { demo in
//                    VStack{
//                        Image(demo)
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 170, height: 200) // Adjust size as needed
//                            .clipShape(RoundedRectangle(cornerRadius: 10))
//
//                        Text("Title")
//                            .font(.subheadline)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                    }
//                }
//            }
//            .padding(.horizontal)
//        }
//    }
//}
//
//#Preview {
//    CategorieItemView()
//}


import SwiftUI
import FirebaseFirestore
import SDWebImageSwiftUI

struct CategorieItemView: View {
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var rooms: [Room] = []
    
    var body: some View {
        VStack {
            Image("demoImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            Text("Scans")
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
                .padding(.top, -30)
            
            LazyVGrid(columns: layout, spacing: 20) {
                ForEach(rooms) { room in
                    NavigationLink(destination: ARViewDisplay(modelUrl: room.modelUrl)) {
                        VStack {
                            WebImage(url: URL(string: room.imageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 170, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            Text(room.roomName)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            fetchRooms()
        }
    }
    
    func fetchRooms() {
        let db = Firestore.firestore()
        db.collection("rooms/").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching rooms: \(error.localizedDescription)")
            } else {
                rooms = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    return Room(
                        id: document.documentID,
                        roomName: data["roomName"] as? String ?? "",
                        roomType: data["roomType"] as? String ?? "",
                        imageUrl: data["imageUrl"] as? String ?? "",
                        image: UIImage(), // Placeholder
                        modelUrl: data["modelUrl"] as? String ?? ""
                    )
                } ?? []
                print("Successfully fetched \(rooms.count) rooms")
                print("rooms - \(rooms)")
            }
        }
    }
}
