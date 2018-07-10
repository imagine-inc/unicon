//
//  SingleChatViewController.swift
//  unicon
//
//  Created by Imajin Kawabe on 2018/07/09.
//  Copyright © 2018年 Imajin Kawabe. All rights reserved.
//

import UIKit
import MessageKit

class SingleChatViewController: MessagesViewController {

    var messageList: [MockMessage] = []
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.hex(hex: "FF5E62", alpha: 1.0)
        
        DispatchQueue.main.async {
            // messageListにメッセージの配列をいれて
            self.messageList = self.getMessages()
            // messagesCollectionViewをリロードして
            self.messagesCollectionView.reloadData()
            // 一番下までスクロールする
            self.messagesCollectionView.scrollToBottom()
        }
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        messageInputBar.delegate = self
        messageInputBar.sendButton.tintColor = UIColor.lightGray
        
        scrollsToBottomOnKeybordBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        
        messagesCollectionView.backgroundColor = UIColor.hex(hex: "FFFCF2", alpha: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func getMessages() -> [MockMessage] {
        return [
            createMessage(text: "あ"),
            createMessage(text: "い"),
            createMessage(text: "う"),
            createMessage(text: "え"),
            createMessage(text: "お"),
            createMessage(text: "か"),
            createMessage(text: "き"),
            createMessage(text: "く"),
            createMessage(text: "け"),
            createMessage(text: "こ"),
            createMessage(text: "さ"),
            createMessage(text: "し"),
            createMessage(text: "すせそたちつてとなにぬね\nのはひふへほまみむめもやゆよらりるれろわをん"),
        ]
    }
    
    func createMessage(text: String) -> MockMessage {
        let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont(name: "Hiragino Sans", size: 18)!, .foregroundColor: UIColor.black])
        return MockMessage(attributedText: attributedText, sender: otherSender(), messageId: UUID().uuidString, date: Date())
    }
}

extension SingleChatViewController: MessagesDataSource {
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    
    func currentSender() -> Sender {
        return Sender(id: "123", displayName: "自分")
    }
    
    func otherSender() -> Sender {
        return Sender(id: "456", displayName: "サンプル")
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    // メッセージの上に文字を表示
//    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        if indexPath.section % 3 == 0 {
//            return NSAttributedString(
//                string: MessageKitDateFormatter.shared.string(from: message.sentDate),
//                attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 10),
//                             NSAttributedStringKey.foregroundColor: UIColor.darkGray]
//            )
//        }
//        return nil
//    }
    
    // メッセージの上に文字を表示（名前）
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    // メッセージの下に文字を表示（日付）
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
}

// メッセージのdelegate
extension SingleChatViewController: MessagesDisplayDelegate {
    
    // メッセージの色を変更（デフォルトは自分：白、相手：黒）
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    // メッセージの背景色を変更している（デフォルトは自分：赤、相手：グレー）
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ?
            UIColor.hex(hex: "FF5E62", alpha: 1.0) :
            UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    // メッセージの枠にしっぽを付ける
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    // アイコンをセット
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // message.sender.displayNameとかで送信者の名前を取得できるので
        // そこからイニシャルを生成するとよい
        let avatar = Avatar(initials: "人")
        avatarView.set(avatar: avatar)
    }
}


// 各ラベルの高さを設定（デフォルト0なので必須）
extension SingleChatViewController: MessagesLayoutDelegate {
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 { return 10 }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
}

extension SingleChatViewController: MessageCellDelegate {
    // メッセージをタップした時の挙動
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
}

extension SingleChatViewController: MessageInputBarDelegate {
    // メッセージ送信ボタンをタップした時の挙動
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            if let image = component as? UIImage {
                
                let imageMessage = MockMessage(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messageList.append(imageMessage)
                messagesCollectionView.insertSections([messageList.count - 1])
                
            } else if let text = component as? String {
                
                let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont(name: "Hiragino Sans", size: 18)!, .foregroundColor: UIColor.white])
                let message = MockMessage(attributedText: attributedText, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messageList.append(message)
                messagesCollectionView.insertSections([messageList.count - 1])
            }
        }
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
}
