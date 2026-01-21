/**
 * ContentView.swift
 * 
 * Main view for the iOS application using SwiftUI.
 * This demonstrates a simple mobile app with modern iOS design.
 */

import SwiftUI

/**
 * ContentView - The primary view of the application
 */
struct ContentView: View {
    // State variable to track the counter
    @State private var counter = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Title
                Text("Hello, iOS!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                // Subtitle
                Text("Welcome to Swift Mobile Development")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Spacer()
                    .frame(height: 32)
                
                // Counter display
                Text("Counter: \(counter)")
                    .font(.title)
                    .fontWeight(.semibold)
                
                // Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        counter += 1
                    }) {
                        Text("Increment")
                            .frame(maxWidth: 200)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        counter = 0
                    }) {
                        Text("Reset")
                            .frame(maxWidth: 200)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("My iOS App")
        }
    }
}

/**
 * Preview Provider - Shows the UI in Xcode preview canvas
 */
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
