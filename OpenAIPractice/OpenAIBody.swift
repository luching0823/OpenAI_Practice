//
//  OpenAIBody.swift
//  TDXPractice
//
//  Created by Pulin on 2022/12/17.
//

import Foundation

struct OpenAIBody: Encodable {
    var model: String
    var prompt: String
    var temperature = 0.7
    var max_tokens = 256
    var top_p = 1
    var frequency_penalty = 0
    var presence_penalty = 0
}


