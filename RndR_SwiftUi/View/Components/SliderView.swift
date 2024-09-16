import SwiftUI

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
