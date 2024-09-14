import SwiftUI

struct UnsupportedDeviceView: View {
    var body: some View {
        VStack {
            Text("Unsupported Device")
                .font(.title)
                .foregroundColor(.red)
                .padding()
            
            Text("This device does not support Lidar.")
                .padding()
        }
    }
}
#Preview {
    UnsupportedDeviceView()
}
