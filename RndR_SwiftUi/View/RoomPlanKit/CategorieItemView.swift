import SwiftUI

struct CategorieItemView: View {
    // Define a grid layout with two columns
    let layout = [
        GridItem(.flexible()), // Flexible column
        GridItem(.flexible())  // Another flexible column
    ]
    
    var recentlyView = ["demoImage", "demoImage1", "demoImage2"]
    
    var body: some View {
        VStack{
            // Display header image
            Image("demoImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // Title
            Text("Scans")
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
                .padding(.top, -30)
            
            // LazyVGrid with 2 columns
            LazyVGrid(columns: layout, spacing: 20) {
                ForEach(recentlyView, id: \.self) { demo in
                    VStack{
                        Image(demo)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 170, height: 200) // Adjust size as needed
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        Text("Title")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    CategorieItemView()
}
