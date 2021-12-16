//
//  Message.swift
//  AI.leen
//
//  Created by Tarlan Askaruly on 28.10.2021.
//

import Foundation

// Struct for representing message.
// isUserMessage propertry marks whether the message is from user
// content property is responsible for carrying the content of a message

struct Message {
  var isUserMessage: Bool
  var content: String
  
  init(isUserMessage: Bool, content: String) {
    self.isUserMessage = isUserMessage
    self.content = content
  }
}
