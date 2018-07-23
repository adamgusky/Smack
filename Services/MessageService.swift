//
//  MessageService.swift
//  Smack
//
//  Created by Adam Gusky on 7/16/18.
//  Copyright © 2018 Adam Gusky. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class MessageService {
    
    static let instance = MessageService()
    
    private init() {
        
    }
    
    var channels = [Channel]()
    var messages = [Message]()
    var unreadChannels = [String]()
    var selectedChannel : Channel?
    
    func findAllChannel(completion: @escaping CompletionHandler) {
        Alamofire.request(URL_GET_CHANNELS, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: BEARER_HEADER).responseJSON { (response) in
            
            if response.result.isSuccess {
                print("Number of channels is \(self.channels.count)")
                guard let data = response.data else { return }
                let json = try! JSON(data: data).array
                for item in json! {
                        let name = item["name"].stringValue
                        let description = item["description"].stringValue
                        let id = item["_id"].stringValue
                        let channel = Channel(channelTitle: name, channelDescription: description, id: id)
                        self.channels.append(channel)
                }
                NotificationCenter.default.post(name: NOTIF_CHANNELS_LOADED, object: nil)
                completion(true)
            } else {
                completion(false)
                debugPrint(response.result.error as Any)
            }
        }
    }
    
    func findAllMessagesForChannel(channelId: String, completion: @escaping CompletionHandler) {
        Alamofire.request("\(URL_GET_MESSAGES)\(channelId)" , method: .get, parameters: nil, encoding: JSONEncoding.default, headers: BEARER_HEADER).responseJSON { (response) in
            
            if response.result.error == nil {
                self.clearMessages()
                guard let data = response.data else { return }
                let json = try! JSON(data: data).array
                for item in json! {
                    print("Found a message! ")
                    let messageBody = item["messageBody"].stringValue
                    let channelId = item["channelId"].stringValue
                    let id = item["_id"].stringValue
                    let userName = item["userName"].stringValue
                    let userAvatar = item["userAvatar"].stringValue
                    let userAvatarColor = item["userAvatarColor"].stringValue
                    let timeStamp = item["timeStamp"].stringValue
                    
                    let message = Message(message: messageBody, userName: userName, channelId: channelId, userAvatar: userAvatar, userAvatarColor: userAvatarColor, id: id, timeStamp: timeStamp)
                    self.messages.append(message)
                }
                completion(true)
            } else {
                debugPrint(response.result.error as Any)
                completion(false)
            }
        }
    }
    
    func clearMessages() {
        messages.removeAll()
    }
    
    func clearChannels() {
        channels.removeAll()
    }
    
}
