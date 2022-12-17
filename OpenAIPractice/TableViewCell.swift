//
//  TableViewCell.swift
//  TDXPractice
//
//  Created by Pulin on 2022/12/17.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var answerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setAnswerTextView( answer: String? = "" ) {
        answerLabel.text = answer
        print(answer)
        self.layoutIfNeeded()
    }
}
