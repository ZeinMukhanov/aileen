//
//  ViewController.swift
//  AI.leen
//
//  Created by Tarlan Askaruly on 27.10.2021.
//

// MARK: -Library for UI elements
import UIKit
// MARK: -Library for a button with built-in speech recognition
import SpeechRecognizerButton
// MARK: -OpenAI API client for Swift programming language
import OpenAI
// MARK: -Native library for synthesizing sound from words
import AVFoundation

// MARK: -Establishing OpenAI API client
let apiKey: String = "API-KEY"
let client = Client(apiKey: apiKey)

class ViewController: UIViewController {

  // MARK: -User interface elements
  @IBOutlet weak var recordButton: SFButton!
  @IBOutlet weak var waveAnimation: SFWaveformView!
  @IBOutlet weak var chatTableView: UITableView!
  
  // MARK: -Object that will be used to synthesize sound
  let synth = AVSpeechSynthesizer()
  // MARK: -Object for representing string as utterance
  var myUtterance = AVSpeechUtterance(string: "")
  
  // MARK: -Internal variable array for storing messages
  private var messages = [Message(isUserMessage: false, content: "I am ready for your service!")]
  // MARK: -Internal variable for storing whole conversation as a string. It will be sent to OpenAI API.
  private var prompt = "The following is a conversation with a medical AI assistant named AIleen. She was created as part of a CPE term project done by three NYUAD students (Zein, Tarlan, Gulsim). Her purpose is to help students with their health related questions. She is very helpful when it comes to answering questions about your medical complications.\n"
  // MARK: -Internal variable array for storing the words to detect question sentences.
  private var questionWords = ["who", "where", "what", "when", "why", "which", "how", "how many", "how much", "how long", "how far", "how often", "do", "does", "are", "is", "can", "should", "could", "would", "will", "did"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // MARK: -Methods necessary for proper function of table view
    chatTableView.delegate = self
    chatTableView.dataSource = self
    chatTableView.separatorStyle = .none
    
    // MARK: -Design
    recordButton.waveformView = waveAnimation
    recordButton.selectedColor = .red
    waveAnimation.waveColor = .darkGray
    
    
    recordButton.resultHandler = {
      
      // MARK: -Condition for checking if the text was recognized from user's speech
      if var recordedMessage = $1?.bestTranscription.formattedString {
        
        // MARK: -If the question word is found in a speech, add the question mark at the bottom
        for questionWord in self.questionWords {
          if recordedMessage.lowercased().starts(with: questionWord) {
            recordedMessage += "?"
            break
          }
        }
        // MARK: -Add the user message to the dialogue
        self.messages.append(Message(isUserMessage: true, content: recordedMessage))
        self.prompt.append("\nHuman: " + recordedMessage + "\nAI:")
        
        // MARK: -Update the dialogue interface so that it shows the last message
        DispatchQueue.main.async {
          self.chatTableView.reloadData()
        }
        
        // MARK: -Call the function scrolling the dialogue to the bottom
        self.scrollToBottom()
        
        // MARK: -Call method from an earlier object
        client.completions(engine: .davinci,
                           prompt: self.prompt,
                           sampling: .temperature(0.9),
                           numberOfTokens: ...150,
                           numberOfCompletions: 1,
                           stop: ["\n", " Human:", " AI:"],
                           presencePenalty: 0.6,
                           frequencyPenalty: 0.0,
                           bestOf: 1) { result in
            guard case .success(let completions) = result else { fatalError("\(result)") }
          
            var response = ""
            for choice in completions.flatMap(\.choices) {
              response += choice.text
            }
          
            // MARK: -Add the AI message to the dialogue
            self.messages.append(Message(isUserMessage: false, content: response))
            self.prompt.append(" " + response)
            DispatchQueue.main.async {
              // MARK: -Call the function to synthesize speech
              self.textToSpeech(txt: response)
              self.chatTableView.reloadData()
            }
            self.scrollToBottom()
        }
        
        
      }
      
    }
    
    
  }
  // MARK: -Internal function for scrolling the dialogue to the bottom
  private func scrollToBottom(){
      DispatchQueue.main.async {
          let indexPath = IndexPath(row: self.messages.count-1, section: 0)
          self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
      }
  }
  // MARK: -Internal function for synthesizing speech from text
  private func textToSpeech(txt: String) {
    myUtterance = AVSpeechUtterance(string: txt)
    myUtterance.rate = 0.42
    synth.speak(myUtterance)
  }

}

// MARK: -Methods for displaying messages in a list (table view)
extension ViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.cellIdentifier, for: indexPath) as! ChatCell
    cell.setupCell(message: messages[indexPath.row])
    cell.selectionStyle = .none
    return cell
  }
  
  
}
