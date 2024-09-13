import SwiftUI

// Main HomeView using SliderView as a subview
struct HomeView: View {
    var recentlyView = ["demoImage", "demoImage", "demoImage", "demoImage", "demoImage"]

    var body: some View {
        ScrollView {
            VStack {
                Text("Recently Scanned")
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)

                // Using the subview SliderView
                SliderView(recentlyView: recentlyView)
                
                Text("Categories")
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                    .padding([.top, .bottom])
                
                //catagories view
                categoriesView(recentlyView: recentlyView)
            }
            .padding(.top)
            
        }
    }
}

// catagories view
struct categoriesView: View {
    var recentlyView: [String]
    
    var body: some View {
        VStack(spacing: 10){
            ForEach(recentlyView, id: \.self) { demo in
                NavigationLink(destination: CategorieItemView()){
                    VStack{
                        Image(demo)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 310)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding([.top, .leading, .trailing])
                        
                        Text("Home")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.bottom)
                    }
                    .frame(width: 350)
                    .background(.secondary)
                    .cornerRadius(10)
                }
            }
        }
    }
}

// Subview for the slider
struct SliderView: View {
    var recentlyView: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(recentlyView, id: \.self) { demo in
                    VStack {
                        ZStack(alignment: .bottomLeading) {
                            Image(demo)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 350)

                            VStack(alignment: .leading) {
                                Text("Title")
                                    .font(.headline)

                                Text("Subtitle")
                                    .font(.subheadline)
                            }
                            .frame(width: 150, alignment: .leading)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(10)
                            .padding([.leading, .bottom], 10)
                        }
                    }
                    .cornerRadius(10)
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

#Preview {
    HomeView()
}
