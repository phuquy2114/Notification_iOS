//
//  NotificationModel.swift
//  Demo Notification
//
//  Created by Softone on 5/6/20.
//  Copyright © 2020 Softone. All rights reserved.
//

import Foundation

struct NotificationModel : Codable, Identifiable {
    let body: String
    let id: String
    
    init(body: String, id: String) {
        self.body = body
        self.id = id
    }
}
