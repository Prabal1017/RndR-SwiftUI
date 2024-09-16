import SwiftUI
import SDWebImageSwiftUI

struct CategorieItemView: View {
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @StateObject private var viewModel = CategoryViewViewModel()
    
    var roomType: String
    @State private var isLoading = true
    var heroImage: String
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 0) {
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
                        .padding(.top, 30)
                        .background(LinearGradient(colors: [.clear, .black.opacity(1)], startPoint: .top, endPoint: .bottom))
                        .offset(y: -85)
                    
                    if isLoading {
                        ProgressView("Fetching Rooms...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1, anchor: .center)
                            .padding()
                            .offset(y: -50)
                    } else {
                        if viewModel.rooms.isEmpty {
                            Text("No rooms added")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading)
                                .offset(y: -55)
                        } else {
                            LazyVGrid(columns: layout, spacing: 20) {
                                ForEach(viewModel.rooms) { room in
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
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .offset(y: -55)
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchRooms(for: roomType) { success in
                isLoading = !success
            }
        }
        .preferredColorScheme(.dark)
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
