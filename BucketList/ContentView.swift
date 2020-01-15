//
//  ContentView.swift
//  BucketList
//
//  Created by Jules Lee on 1/14/20.
//  Copyright © 2020 Jules Lee. All rights reserved.
//

import SwiftUI
import MapKit
import LocalAuthentication

struct ContentView: View {
    
    enum Alerta  {
        
        var bool: Bool {
            return self == .none ? false : true
        }
        
        case placeDetails, authenticationError, none
    }
    
    @State private var selectedPlace: MKPointAnnotation?
    @State private var showingPlaceDetails = false
    @State private var isUnlocked = false
    @State private var showingEditScreen = false
    @State private var alertMode: Alerta = .none {
        didSet {
            onAlert = alertMode == .none ? false : true
        }
    }
    @State private var onAlert = Alerta.none.bool
    @State private var centerCoordinate = CLLocationCoordinate2D()
    @State private var locations = [CodableMKPointAnnotation]()
    
    var body: some View {
        Group {
            if isUnlocked {
                MapContentView()
            } else {
                Button("Unlock Places") {
                    self.authenticate()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
        }
        .onAppear(perform: isUnlocked ? loadData : authenticate)
        .alert(isPresented: $onAlert) {
            if alertMode == .placeDetails {
                return Alert(title: Text(selectedPlace?.title ?? "Unknown"), message: Text(selectedPlace?.subtitle ?? "Missing place information."), primaryButton: .default(Text("OK")), secondaryButton: .default(Text("Edit")) {
                    // edit this place
                    self.showingEditScreen = true
                })
            } else if alertMode == .authenticationError {
                return Alert(title: Text("Error"), message: Text("Cannot authenticate"), dismissButton: .default(Text("Okay")) {
                    self.alertMode = .none
                    })
            }
            return Alert(title: Text("Nothing"))
        }
        .sheet(isPresented: $showingEditScreen, onDismiss: saveData) {
            if self.selectedPlace != nil {
                EditView(placemark: self.selectedPlace!)
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func loadData() {
        let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")

        do {
            let data = try Data(contentsOf: filename)
            locations = try JSONDecoder().decode([CodableMKPointAnnotation].self, from: data)
        } catch {
            print("Unable to load saved data.")
        }
    }
    
    func saveData() {
        do {
            let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")
            let data = try JSONEncoder().encode(self.locations)
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Unable to save data.")
        }
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "We need to unlock your data."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                DispatchQueue.main.async {
                    if success {
                        // authenticated successfully
                        self.isUnlocked = true
                    } else {
                        // there was a problem
                        self.alertMode = .none
                    }
                }
            }
        } else {
            // no biometrics
            self.alertMode = .none
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
