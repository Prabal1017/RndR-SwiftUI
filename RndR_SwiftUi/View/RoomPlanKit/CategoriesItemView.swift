import SwiftUI
import SDWebImageSwiftUI

struct CategorieItemView: View {
    let layout = Array(repeating: GridItem(.flexible(), spacing: 28), count: 2)
    
    @StateObject private var viewModel = CategoryViewViewModel()
    
    var roomType: String
    @State private var isLoading = true
    var heroImage: String
    
    @State private var showDeleteAlert = false
    @State private var roomToDelete: Room?
    
    @State private var showDeletedMessage = false
    
    //    //back button on top
    //    @Environment(\.presentationMode) var presentationMode
    //
    //    var btnBack : some View { Button(action: {
    //        self.presentationMode.wrappedValue.dismiss()
    //    }) {
    //        HStack{
    //            Image(systemName: "arrow.left")
    //        }
    //    }
    //    }
    //
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 0) {
                    if showDeletedMessage {
                        HStack {
                            Text("Room deleted successfully!")
                                .foregroundColor(.white)
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .offset(y: 0)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .transition(.move(edge: .top))
                        .zIndex(1)
                    }
                    
                    ScrollViewHeader {
                        WebImage(url: URL(string: heroImage))
                            .resizable()
                            .scaledToFill()
                    }
                    .frame(height: 250) // Adjust the height as needed
                    
                    Text("\(roomType) Scans")
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .padding([.top, .bottom], 30)
                        .background(LinearGradient(colors: [.clear, .black.opacity(0.8), .black, .black], startPoint: .top, endPoint: .bottom))
                        .offset(y: -100)
                    
                    if isLoading {
                        ProgressView("Fetching Rooms...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1, anchor: .center)
                            .padding()
                            .offset(y: -70)
                    } else {
                        if viewModel.rooms.isEmpty {
                            VStack{
                                Image("noScans")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 150,height: 150)
                                Text("No models added yet.")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .padding()
                            }
                        } else {
                            // Corrected grid layout
                            LazyVGrid(columns: layout, spacing: 20) {
                                ForEach(viewModel.rooms) { room in
                                    VStack {
                                        if let modelURL = URL(string: room.modelUrl) {
                                            NavigationLink(destination: FileDetailView(fileName: room.roomName, modelURL: modelURL)) {
                                                ZStack(alignment: .bottom){
                                                    WebImage(url: URL(string: room.imageUrl))
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: geo.size.width / 2 - 20, height: 200) // Adjust size for grid
                                                    
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
                                            .contextMenu {
                                                Button(role: .destructive){
                                                    roomToDelete = room
                                                    showDeleteAlert = true
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                        .tint(Color.red)
                                                }
                                            }
                                        } else {
                                            // Handle invalid URL case
                                            Text("Invalid model URL")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .offset(y: -100)
                        }
                    }
                }
            }
            .animation(.easeInOut, value: showDeletedMessage)
        }
        .navigationTitle("\(roomType)")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            viewModel.fetchRooms(for: roomType) { success in
                isLoading = !success
            }
        }
        .onAppear {
            viewModel.fetchRooms(for: roomType) { success in
                isLoading = !success
            }
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete Room"),
                message: Text("Are you sure you want to delete this room?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let roomToDelete = roomToDelete {
                        viewModel.deleteRoom(roomToDelete) { success in
                            if success {
                                print("Room deleted successfully.")
                                showDeletedMessage = true // Show the deleted message
                                // Hide the deleted message after 2 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showDeletedMessage = false
                                }
                                viewModel.fetchRooms(for: roomType) { _ in } // Refresh the view
                            } else {
                                print("Failed to delete room.")
                            }
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
        //        .navigationBarBackButtonHidden(true)
        //        .navigationBarItems(leading: btnBack)
        //        .preferredColorScheme(.dark)
    }
}




public struct ScrollViewHeader<Content: View>: View {
    
    public init(
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
    }
    
    private let content: () -> Content
    
    public var body: some View {
        GeometryReader { geo in
            content().stretchable(in: geo)
        }
    }
}

private extension View {
    
    @ViewBuilder
    func stretchable(in geo: GeometryProxy) -> some View {
        let width = geo.size.width
        let height = geo.size.height
        let minY = geo.frame(in: .global).minY
        let useStandard = minY <= 0
        self.frame(width: width, height: height + (useStandard ? 0 : minY))
            .offset(y: useStandard ? 0 : -minY)
    }
}

