//
//  ContentView.swift
//  PushAPI
//
//  Created by DunkeyyFong on 26/12/2023.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct ContentView: View {
    
    @State private var title = ""
    @State private var image: UIImage?
    @State private var imageUrl = ""
    @State private var desc = ""
    @State private var isImagePickerPresented = false
    
    //Alert pushing success
    @State private var showingPushing = false
    @State private var alertMessage: String? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Title", text: $title)
                    .padding()
                    .border(Color.gray, width: 0.5)
                
                HStack {
                    
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 70, height: 70)
                            .cornerRadius(20)
                            .padding()
                    } else {
                        Image("")
                            .resizable()
                            .background(Color.gray)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 70, height: 70)
                            .cornerRadius(20)
                            .padding()
                    }
                    
                    Button {
                        isImagePickerPresented.toggle()
                    } label: {
                        Text("Select Image")
                    }
                    .sheet(isPresented: $isImagePickerPresented) {
                        ImagePicker(selectedImage: $image)
                    }
                }
                .padding()
                
                TextField("Image URL", text: $imageUrl)
                    .padding()
                    .border(Color.gray, width: 0.5)
                
                TextField("Description", text: $desc)
                    .padding()
                    .border(Color.gray, width: 0.5)
                
                Button {
                    pushData()
                    showingPushing = true
                } label: {
                    Text("Push")
                        .foregroundColor(.white)
                        .padding()
                }
                .background(Color.blue)
                .padding()
                .alert(isPresented: $showingPushing) {
                    Alert(title: Text("Notification"), message: Text(alertMessage ?? ""), dismissButton: .default(Text("OK")))
                }

            }
            .navigationTitle("API")
            .padding()
        }
    }
    
    func pushData() {
//        guard let imageData = image?.jpegData(compressionQuality: 0.5) else {
//
//            #if DEBUG
//            print("Error converting image to data")
////            alertMessage = "Error converting image to data"
//            #endif
//
//            return
//        }
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("test/\(UUID().uuidString).png")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
//        _ = imageRef.putData(//imageData, metadata: metadata) { _, error in
//            if let error = error {
//                print("Error uploading image: \(error.localizedDescription)")
//                alertMessage = "Error uploading image: \(error.localizedDescription)"
//                return
//            }
//
//            imageRef.downloadURL { url, error in
//                guard let imageUrl = url?.absoluteString else {
//                    print("Error getting image URL: \(error?.localizedDescription ?? "Unknown error")")
//                    alertMessage = "Error getting image URL: \(error?.localizedDescription ?? "Unknown error")"
//                    return
//                }
                
                let db = Firestore.firestore()
                let data: [String: Any] = [
                    "title": title,
                    "desc": desc,
                    "imagePath": imageRef.fullPath,
                    "imageUrl": imageUrl
                ]
                
                db.collection("build").addDocument(data: data) { error in
                    if let error = error {
                        print("Error adding document: \(error)")
                        alertMessage = "Error adding document: \(error)"
                    } else {
                        print("Document adding: \(data)")
                        alertMessage = "Document adding: \(data)"
                        
                        //Clear value in TextField
//                        title = ""
//                        desc = ""
                    }
                }
//            }
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
