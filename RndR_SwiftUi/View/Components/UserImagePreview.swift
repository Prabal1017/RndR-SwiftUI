import SwiftUI
import SDWebImageSwiftUI

struct UserImagePreview: View {
    
    @Binding var showingImagePreview: Bool
    var profileImageUrl: String
    
    
    var body: some View {
        ZStack {
            if let url = URL(string: profileImageUrl) {
                WebImage(url: url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .frame(width: 300, height: 300)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            withAnimation{
                showingImagePreview = false
            }
        }
    }
}

#Preview {
    UserImagePreview(showingImagePreview: .constant(true), profileImageUrl: "https://via.placeholder.com/150")
}
