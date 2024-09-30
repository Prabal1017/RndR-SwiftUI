//
//  3DModelView.swift
//  RndR_SwiftUi
//
//  Created by Piyush saini on 30/09/24.
//

import SwiftUI
import RealityKit
import ARKit

struct ARModelView: View {
    var usdzURL: URL // URL to your .usdz model file

    var body: some View {
        ZStack {
            ARViewContainer(usdzURL: usdzURL)
                .edgesIgnoringSafeArea(.all) // Use the full screen for AR view
            
            // Optionally, add UI elements like a button to close or interact
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        // Add your action (e.g., close AR view)
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                    .padding()
                }
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    var usdzURL: URL

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // Load the USDZ model into the ARView
        do {
            let modelEntity = try Entity.load(contentsOf: usdzURL)
            let anchorEntity = AnchorEntity(plane: .horizontal)
            anchorEntity.addChild(modelEntity)

            // Add the anchor to the ARView scene
            arView.scene.addAnchor(anchorEntity)
        } catch {
            print("Failed to load model: \(error.localizedDescription)")
        }

        // Configure AR session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical] // Detect planes for placing the model
        arView.session.run(config)

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // Update the view when needed
    }
}

struct ARModelView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide a sample model URL for preview
        let url = Bundle.main.url(forResource: "sample", withExtension: "usdz")!
        ARModelView(usdzURL: url)
    }
}
