//
//  OpenAIAnswer.swift
//  TDXPractice
//
//  Created by Pulin on 2022/12/17.
//

import Foundation

struct OpenAIAnswer: Codable {
  let id: String
  let object: String
  let created: Int
  let model: String
  let choices: [Choice]
  let usage: Usage
  
  struct Choice: Codable {
    let text: String
    let index: Int
    let logprobs: Int?
    let finish_reason: String
  }
  
  struct Usage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
  }
}
