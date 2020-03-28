//
//  ViewController.swift
//  Flashcards
//
//  Created by Chewy nguyen on 2/20/20.
//  Copyright © 2020 Chieu Anh Nguyen. All rights reserved.
//

import UIKit

struct Flashcard {
    var Question: String
    var Answer: String
}

class ViewController: UIViewController {

    @IBOutlet weak var backLabel: UILabel!
    @IBOutlet weak var frontLabel: UILabel!
    @IBOutlet weak var card: UIView!
    
    // Array to hold our flashcards
    var flashcards = [Flashcard] ()
    var currentIndex = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        card.layer.cornerRadius = 20
        card.layer.shadowRadius = 10
        card.layer.shadowOpacity = 0.5
        
        frontLabel.layer.cornerRadius = 20
        frontLabel.clipsToBounds = true
        backLabel.layer.cornerRadius = 20
        backLabel.clipsToBounds = true

        readSavedFlashcards()
        
        if flashcards.count == 0  {
            updateFlashcard(question: "what is my name", answer: "chewy")
        }else{
        updateLabels()
        updateNextPrevButtons()
        }
        
    }
    func deleteCurrentFlashcard(){
        flashcards.remove(at: currentIndex)
        
        if currentIndex>flashcards.count - 1{
        currentIndex = flashcards.count - 1
        }
        updateNextPrevButtons()
        updateLabels()
        saveAllFlashcardsToDisk()
    }
    @IBAction func didTapOnDelete(_ sender: Any) {
        if currentIndex < 0 {
               currentIndex = 0
        }
        if currentIndex == 0{
            let alert = UIAlertController(title: "Delete Disabled" , message: "You cannot delete this flashcard", preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                   alert.addAction(cancelAction)
        }
        else{
       let alert = UIAlertController(title: "Delete Flashcard", message: "Are you sure you want to delete this flashcard?", preferredStyle:.actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive)
        { action in
            self.deleteCurrentFlashcard()
        }
        alert.addAction(deleteAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
    
        present(alert, animated: true, completion: nil)
        
        }
    }
    @IBAction func didTapOnPrev(_ sender: Any) {
        animateCardOut()
        currentIndex = currentIndex - 1
    
        if currentIndex <= -1 {
            currentIndex = 0
        }

        //updateLabels()
        updateNextPrevButtons()
    }
    
    @IBAction func didTapOnNext(_ sender: Any) {
        animateCardOut()
        currentIndex = currentIndex + 1
        
        // check if we're out of range
        if currentIndex > flashcards.count - 1 {
            currentIndex = flashcards.count - 1
        }
        
       // updateLabels()
        updateNextPrevButtons()
    }
    
    
    func updateLabels() {
        // get currrent flashcard
        let currentFlashcard = flashcards[currentIndex]
        // update labels
        frontLabel.text = currentFlashcard.Question
        backLabel.text = currentFlashcard.Answer
    }
    
   func animateCardIn() {
    card.transform = CGAffineTransform.identity.translatedBy(x: 300, y: 0.0)
    UIView.animate(withDuration: 0.3, animations: {
        self.card.transform = CGAffineTransform.identity
    })
    }
    
    func animateCardOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.card.transform = CGAffineTransform.identity.translatedBy(x: -300, y: 0.0)
        }, completion: {finished in
            self.updateLabels()
            self.animateCardIn()
            
            
        }  )
    }
    
    @IBOutlet weak var prevButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBAction func didTapOnFlashcard(_ sender: Any) {
        flipFlashcard()
    }
    func flipFlashcard(){
        UIView.transition(with: card, duration: 0.3, options: .transitionFlipFromRight, animations: {
            
            if self.frontLabel.isHidden {
                self.frontLabel.isHidden = false
            }
                
            else {
                self.frontLabel.isHidden = true

            }
        })
        

    }
    
    
    func updateFlashcard(question: String, answer: String) {
        let flashcard = Flashcard(Question: question, Answer: answer)
        backLabel.text = flashcard.Answer
        frontLabel.text = flashcard.Question
        frontLabel.isHidden = false
        flashcards.append(flashcard)
        
        //logging on console
        print("We now have \(flashcards.count) new flashcards")
        // update current index
        print("Our Current index is \(flashcards.count-1)")
        
        //update buttons
        updateNextPrevButtons()
        updateLabels()
        saveAllFlashcardsToDisk()
    }
    
    func updateNextPrevButtons() {
        // disable next button if at end
        
        if currentIndex == flashcards.count - 1 {
            nextButton.isEnabled = false
        } else{
           nextButton.isEnabled = true
        }
        
        if currentIndex == 0 {
            prevButton.isEnabled = false
        } else {
            prevButton.isEnabled = true
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let creationController = navigationController.topViewController as! CreationViewController
        creationController.flashcardsController = self
    }
    
    func saveAllFlashcardsToDisk() {
        
    print("Flashcards saved to UserDefault")
        let dictionaryArray = flashcards.map { (card) -> [String: String] in
            return ["question":card.Question, "answer": card.Answer]
    }
        UserDefaults.standard.set(dictionaryArray, forKey: "flashcards")
}
    //read dictionary from disc if any
    func readSavedFlashcards() {
        if let dictionaryArray = UserDefaults.standard.array(forKey: "flashcards") as?  [[String:String]]{
        // in here we know for sure we have a dictionary array
            let savedCards = dictionaryArray.map { Dictionary -> Flashcard in
                return Flashcard (Question:Dictionary["question"]!,Answer:Dictionary["answer"]!)
           }
                //put all these cards in our flashcards array
                flashcards.append(contentsOf: savedCards)}
    }
}


