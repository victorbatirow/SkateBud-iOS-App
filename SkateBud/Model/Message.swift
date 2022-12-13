//
//  Message.swift
//  SkateBud
//
//  Created by Victor on 2022-11-02.
//

import Foundation

class Message {
    var id: String
    var from: String
    var to: String
    var date: Double
    var text: String
    var imageUrl: String
    var height: Double
    var width: Double
    var videoUrl: String
    
    init(id: String, from: String, to: String, date: Double, text: String, imageUrl: String, height: Double, width: Double, videoUrl: String)  {
        self.id = id
        self.from = from
        self.to = to
        self.date = date
        self.text = text
        self.imageUrl = imageUrl
        self.height = height
        self.width = width
        self.videoUrl = videoUrl
    }
    
    // keyId: the id of the message
    static func transformMessage(dict: [String: Any], keyId: String) -> Message? {
        guard let from = dict["from"] as? String,
              let to = dict["to"] as? String,
              let date = dict["date"] as? Double else {
                  return nil
              }
        
//        var text = dict["text"] as? String
//        text = (text == nil) ? "" : text
        // Simplified to:
        var text = (dict["text"] as? String) == nil ? "" : (dict["text"]! as! String)
        var imageUrl = (dict["imageUrl"] as? String) == nil ? "" : (dict["imageUrl"]! as! String)
        var height = (dict["height"] as? Double) == nil ? 0 : (dict["height"]! as! Double)
        var width = (dict["width"] as? Double) == nil ? 0 : (dict["width"]! as! Double)
        var videoUrl = (dict["videoUrl"] as? String) == nil ? "" : (dict["videoUrl"]! as! String)
        
        let message = Message(id: keyId, from: from, to: to, date: date, text: text, imageUrl: imageUrl, height: height, width: width, videoUrl: videoUrl)
        return message
    }
    
    static func hash(forMembers members: [String]) -> String {
        let hash = members[0].hashString ^ members[1].hashString
        let memberHash = String(hash)
        return memberHash
    }
}
