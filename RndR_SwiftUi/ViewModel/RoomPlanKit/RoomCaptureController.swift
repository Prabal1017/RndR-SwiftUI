//
//  RoomCaptureController.swift
//  ForReal Demo
//
//  Created by Vatsal Patel  on 8/17/24.
//

import Foundation
import RoomPlan
import Observation


@Observable
class RoomCaptureController: RoomCaptureViewDelegate, RoomCaptureSessionDelegate, ObservableObject {
    required init?(coder: NSCoder) {
        fatalError("Not needed.")
    }
    
    func encode(with coder: NSCoder) {
        fatalError("Not needed.")
    }
    
    var roomCaptureView: RoomCaptureView
    var showSaveButton = false
    var isScanning = false
    var showNameInputSheet = false
    var fileName = ""
    
    var sessionConfig: RoomCaptureSession.Configuration
    var finalResult: CapturedRoom?
    
    init() {
        roomCaptureView = RoomCaptureView(frame: CGRect(x: 0, y: 0, width: 42, height: 42))
        sessionConfig = RoomCaptureSession.Configuration()
        roomCaptureView.captureSession.delegate = self
        roomCaptureView.delegate = self
    }
    
    func startSession() {
        isScanning = true // Set scanning flag to true when session starts
        roomCaptureView.captureSession.run(configuration: sessionConfig)
    }
    
    func stopSession() {
        isScanning = false // Set scanning flag to false when session stops
        roomCaptureView.captureSession.stop()
    }
    
    
    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: Error?) -> Bool {
        return true
    }
    
    func captureView(didPresent processedResult: CapturedRoom, error: (Error)?) {
        if let error = error {
            print("Error in room capture: \(error.localizedDescription)")
            return
        }
        // Ensure the final result is set
        finalResult = processedResult
        print("Room capture complete, result set.")
    }
    
    private func categorizeRoomObjects(_ objects: [CapturedRoom.Object]) -> [String: [CapturedRoom.Object]] {
        var categorized = [String: [CapturedRoom.Object]]()
        
        for object in objects {
            let category: String
            switch object.category {
            case .refrigerator, .oven, .dishwasher, .washerDryer:
                category = "Appliance"
            case .table:
                category = "Table"
            case .bed:
                category = "Bed"
            case .chair, .sofa:
                category = "Seating"
            case .storage:
                category = "Storage"
            case .bathtub, .toilet:
                category = "Bathroom Fixture"
            case .sink:
                category = "Sink"
            case .television:
                category = "Television"
            default:
                category = "Other"
            }
            
            if categorized[category] == nil {
                categorized[category] = []
            }
            categorized[category]?.append(object)
        }
        
        return categorized
    }
    
    private func printCategorizedObjects(_ categorizedObjects: [String: [CapturedRoom.Object]]) {
        print("Categorized objects:")
        for (category, objects) in categorizedObjects {
            print("  \(category): \(objects.count) items")
            for object in objects {
                print("    - \(object.category): \(object.dimensions)")
            }
        }
    }
}


