import SwiftUI

struct SliderView: View {
    @ObservedObject var viewModel: RoomPlanViewViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                // Check if recentRooms is empty
                if viewModel.recentRooms.isEmpty {
                    NavigationLink(destination: RoomScanningView()){
                        VStack {
                            ZStack(alignment: .bottom) {
                                Image("recentDemo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .greatestFiniteMagnitude)

                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Start scanning today!")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        
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
                        .containerRelativeFrame(.horizontal)
                    }
                } else {
                    // Show the recent rooms when data is available
                    ForEach(viewModel.recentRooms, id: \.id) { recentRoom in
                        VStack {
                            ZStack(alignment: .bottom) {
                                AsyncImage(url: URL(string: recentRoom.imageUrl)) { phase in
                                    switch phase {
                                    case .empty:
                                        SkeletonLoader()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    case .failure:
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: .greatestFiniteMagnitude)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(height: 250)
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(recentRoom.roomName)
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        
                                        Text(recentRoom.roomType)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                    }
                                    Spacer()
                                    
                                    if let validURL = URL(string: recentRoom.modelUrl) {
                                        NavigationLink(destination: FileDetailView(fileName: recentRoom.roomName, modelURL: validURL)) {
                                            Text("View")
                                                .frame(width: 80, height: 36)
                                                .foregroundColor(.white)
                                                .background(Color.white.opacity(0.4))
                                                .fontWeight(.bold)
                                                .cornerRadius(20)
                                        }
                                    } else {
                                        Text("Invalid URL")
                                            .foregroundColor(.red)
                                            .font(.subheadline)
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
                        .containerRelativeFrame(.horizontal)
                        .scrollTransition { content, phase in
                            content.opacity(phase.isIdentity ? 1.0 : 0.0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.8)
                        }
                    }
                }
            }
            .frame(maxHeight: 250)
        }
        .scrollTargetBehavior(.paging)
    }
}
