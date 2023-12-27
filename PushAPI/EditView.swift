//
//  EditView.swift
//  PushAPI
//
//  Created by DunkeyyFong on 27/12/2023.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct DataFetched {
    let id: String
    let title: String
    let desc: String
    let imagePath: String
    let imageUrl: String
    let imageData: Data?
}

struct EditView: View {
    
    @ObservedObject var dataView = DataView()
    @State private var didFetchData = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(dataView.dataList, id: \.id) { dataItem in
                        NavigationLink(destination: EditDataView(dataItem: dataItem)) {
                            HStack {
                                //                        if let imageData = dataItem.imageData, let uiImage = UIImage(data: imageData) {
                                //                            Image(uiImage: uiImage)
                                //                                .resizable()
                                //                                .aspectRatio(contentMode: .fill)
                                //                                .frame(width: 60, height: 60)
                                //                                .cornerRadius(10)
                                //                        }
                                
                                Rectangle()
                                    .frame(width: 60, height: 60)
                                    .background(Color.gray)
                                    .cornerRadius(10)
                                
                                VStack {
                                    Text(dataItem.title)
                                        .bold()
                                        .font(.title3)
                                    Text(dataItem.desc)
                                        .font(.subheadline)
                                        .foregroundColor(Color.gray)
                                }
                                .padding()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dataView.fetchData()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    
                }
            }
            .onAppear {
                if !didFetchData {
                    dataView.fetchData()
                    didFetchData = true
                }
            }
        }
    }
}

struct EditDataView: View {
    
    let dataItem: DataFetched
    
    var body: some View {
        ScrollView {
            ZStack {
                
                Rectangle()
                    .fill(Color.brown)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        //                    if let imageData = dataItem.imageData, let uiImage = UIImage(data: imageData) {
                        //                        Image(uiImage: uiImage)
                        //                            .resizable()
                        //                            .aspectRatio(contentMode: .fill)
                        //                            .frame(width: 130, height: 130)
                        //                            .cornerRadius(25)
                        //                            .padding(.trailing, 20)
                        //                    }
                        
                        Rectangle()
                            .frame(width: 130, height: 130)
                            .background(Color.gray)
                            .cornerRadius(25)
                            .padding(.trailing, 20)
                        
                        VStack(alignment: .leading) {
                            Text(dataItem.title)
                                .font(.title)
                                .bold()
                                .padding(.bottom, 3)
                            Text("com.dunkeyyfong.test")
                                .font(.caption)
                                .foregroundColor(Color.gray)
                            
                            HStack {
                                Button {
                                    
                                } label: {
                                    HStack {
                                        Text("Edit")
                                            .font(.subheadline)
                                            .foregroundColor(Color.white)
                                    }
                                    .padding(10)
                                }
                                .background(Color.blue)
                                .cornerRadius(30)
                                
                                Button {
                                    
                                } label: {
                                    HStack {
                                        Text("Remove")
                                            .font(.subheadline)
                                            .foregroundColor(Color.white)
                                    }
                                    .padding(10)
                                }
                                .background(Color.red)
                                .cornerRadius(30)
                                
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    
                    Divider()
                        .background(Color.gray)
                        .padding()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Description")
                                .bold()
                                .font(.title)
                                .padding(.bottom, 5)
                            
                            Text(dataItem.desc)
                        }
                        .padding()
                        Spacer()
                    }
                    
                    Spacer()
                }
                .background(Color.white)
                .frame(height: 680)
            }
            .statusBar(hidden: false)
        }
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
            EditView()
    }
}

class DataView: ObservableObject {
    @Published var dataList: [DataFetched] = []
    
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    
    func fetchData() {
        db.collection("build").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            self.dataList = []
            
            for document in documents {
                if let data = document.data() as? [String: Any],
                   let title = data["title"] as? String,
                   let desc = data["desc"] as? String,
                   let imagePath = data["imagePath"] as? String,
                   let imageUrl = data["imageUrl"] as? String {
                    self.downloadImage(imagePath: imagePath) { imageData in
                        let newData = DataFetched(id: document.documentID, title: title, desc: desc, imagePath: imagePath, imageUrl: imageUrl, imageData: imageData)
                        self.dataList.append(newData)
                    }
                }
            }
        }
    }
    
    private func downloadImage(imagePath: String, completion: @escaping (Data?) -> Void) {
        let imageRef = storage.reference().child(imagePath)
        
        imageRef.getData(maxSize: Int64(5 * 1024 * 1024)) { data, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                completion(nil)
            } else {
                completion(data)
            }
        }
    }
}
