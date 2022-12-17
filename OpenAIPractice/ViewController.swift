//
//  ViewController.swift
//  TDXPractice
//
//  Created by Pulin on 2022/12/17.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    var answerDictionary: [Int: String] = [:] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                let indexPath = IndexPath(row: self.answerDictionary.count - 1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at:.bottom, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = UITableView.automaticDimension
    }

    @IBAction func pressedSendButton(_ sender: Any) {
        let question = questionTextField.text
        sendRequest(question: question)
        questionTextField.text = ""
    }
    
    func sendRequest( question: String? ) {
        let url = URL(string: "https://api.openai.com/v1/completions")
        var request = URLRequest(url: url!)
        request.setValue("application/json",
                         forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer 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",
                         forHTTPHeaderField: "Authorization")
        
        let openAIBody = OpenAIBody(model: "text-davinci-003",
                                    prompt: question ?? "")
        request.httpBody = try? JSONEncoder().encode( openAIBody )
        request.httpMethod = "post"
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let strongSelf = self else { return }
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            if let data {
                let decoder = JSONDecoder()
                do {
                    let decodedData = try decoder.decode( OpenAIAnswer.self, from: data)
                    print(decodedData)
                    for choice in decodedData.choices {
                        strongSelf.answerDictionary.updateValue(choice.text,
                                                                forKey: decodedData.created)
                        print(strongSelf.answerDictionary)
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.answerDictionary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        let lastAnswerTime: [Int] = self.answerDictionary.keys.sorted(by: { $0 < $1 })
        let answer = answerDictionary[lastAnswerTime[indexPath.row]]
        cell.setAnswerTextView(answer: answer)
        cell.layoutIfNeeded()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

