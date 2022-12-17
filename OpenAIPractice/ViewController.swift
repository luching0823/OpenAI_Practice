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
    @IBOutlet weak var bottomView: UIView!
    
    var answerDictionary: [Int: String] = [:] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                let indexPath = IndexPath(row: self.answerDictionary.count - 1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at:.bottom, animated: true)
            }
        }
    }
    
    var keyBoardHeight: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /* 監聽 鍵盤顯示/隱藏 事件 */
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    // 點擊空白時讓鍵盤消失
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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

extension ViewController {
    @objc func keyboardWillShow(note: NSNotification) {
            
        let userInfo = note.userInfo!
        /* 取得鍵盤尺寸 */
        let keyboard = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        self.keyBoardHeight = keyboard.height
            
        var react = self.bottomView.frame
        react.origin.y -= self.keyBoardHeight
        self.bottomView.frame = react
    }
         
        @objc func keyboardWillHide(note: NSNotification) {
            /* 鍵盤隱藏時將畫面下移回原樣 */
            let keyboardAnimationDetail = note.userInfo as! [String: AnyObject]
            self.bottomView.frame.origin.y += self.keyBoardHeight
        }
}
