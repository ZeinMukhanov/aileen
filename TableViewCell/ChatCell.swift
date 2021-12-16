//
//  ChatCell.swift
//  AI.leen
//
//  Created by Tarlan Askaruly on 28.10.2021.
//

import UIKit

class ChatCell: UITableViewCell {

  static let cellIdentifier = "ChatCell"
  
  // MARK: -Interface elements
  @IBOutlet weak var ResponseMessageView: UIView!
  @IBOutlet weak var ResponseMessageText: UILabel!
  
  
  // MARK: -Default methods
  override func awakeFromNib() {
    super.awakeFromNib()
    
    // MARK: -Setting up layout of a cell
    ResponseMessageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
    ResponseMessageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
    setupView(ResponseMessageView)
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  // MARK: -Method for rounding the corners of a view
  private func setupView(_ customView: UIView) {
    customView.layer.cornerRadius = 5
  }
  
  func setupCell(message: Message) {
    if !message.isUserMessage {
      ResponseMessageText.textAlignment = .left
      ResponseMessageView.backgroundColor = .systemGray6
    }
    else {
      ResponseMessageText.textAlignment = .right
      ResponseMessageView.backgroundColor = .systemBlue
    }
    ResponseMessageText.text = message.content
  }

}
