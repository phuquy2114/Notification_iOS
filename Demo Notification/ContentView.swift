//
//  ContentView.swift
//  Demo Notification
//
//  Created by Softone on 5/6/20.
//  Copyright © 2020 Softone. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel : ShuffleViewModel = ShuffleViewModel()

    
    var body: some View {
        List(viewModel.listData) { value in
            VStack(alignment: .leading) {
                Text(value.id)
                Text(value.body)
            }
        }
    }
    
    func reloadData(){
        viewModel.shuffle()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class ShuffleViewModel : ObservableObject {
    @Published var listData: [NotificationModel] = []

    func shuffle() {
        updateData()
        listData.shuffle()
    }
    
    init() {
        updateData()
    }
    
    func updateData() {
        listData.removeAll();
        
        if let bodies: [String] = UserDefaults.standard.array(forKey: "body") as? [String] {
            for json in bodies {
                do {
                    let data = try JSONDecoder().decode(NotificationModel.self, from: Data(json.utf8))
                    listData.append(data)
                } catch { }
            }
        }
    }
}
