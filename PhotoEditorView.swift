//
//  PhotoEditorView.swift
//  UrbanPhotoLab
//
//  Created by Andriyanto Halim on 26/10/24.
//

import SwiftUI

struct PhotoEditorView: View {
    @StateObject private var viewModel = PhotoEditorViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if let image = viewModel.filteredImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                } else {
                    Text("Select a Photo")
                        .font(.title)
                        .foregroundColor(.gray)
                        .frame(height: 300)
                }
                
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(FilterType.allCases, id: \.self) { filterType in
                            Button(action: {
                                viewModel.applyFilter(type: filterType)
                            }) {
                                Text(filterType.rawValue)
                                    .padding()
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                }
                
                Button("Save Photo") {
                    viewModel.saveImage()
                }
                .padding()
                .disabled(viewModel.filteredImage == nil)
            }
            .padding()
            .navigationBarTitle("Photo Editor")
            .navigationBarItems(trailing: Button("Select Photo") {
                viewModel.showPhotoPicker = true
            })
            .sheet(isPresented: $viewModel.showPhotoPicker) {
                PhotoPicker { image in
                    viewModel.loadImage(image)
                }
            }
            .alert(isPresented: $viewModel.showSaveAlert) {
                Alert(
                    title: Text("Save Photo"),
                    message: Text(viewModel.saveMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoEditorView()
    }
}

