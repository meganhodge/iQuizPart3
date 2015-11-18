//
//  MasterViewController.swift
//  iQuiz Part 1
//
//  Created by Megan Hodge on 10/30/15.
//  Copyright © 2015 Megan Hodge. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import RealmSwift

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    
//    let realm = try! Realm() // from Realm documentation
//    let array = try! Realm().objects(Quiz).sorted("quizTitle")
    
    // variable to hold the different quizzes the user could select
    var quizOptions: [Quiz] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view, typically from a nib.
        
        
//        // Realm documentation code, gets the objects
//        dispatch_async(dispatch_queue_create("background", nil)) {
//            let locallyStoredQuizzes = self.realm.objects(Quiz) // locally stored quizzes
//            // if there are locally stored quizzes then we should grab them locally
//            // if there are not then we should get them from the URL
//            // locallyStoredQuizzes is an array of quizzes?
//            print(locallyStoredQuizzes)
//            //if locallyStoredQuizzes.isValid() {
//                //self.retrieveData()
//            //} else {
                self.retrieveData()
//            }
//        
//        dispatch_async(dispatch_get_main_queue()) {
//            self.tableView.reloadData()
//        }
            
        
        //}

        let settings = UIBarButtonItem(title: "Settings", style: .Plain, target: self, action: "didPressSettings:")
        self.navigationItem.rightBarButtonItem = settings
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        self.retrieveData()
    }

    
    func didPressSettings(sender: AnyObject) {
        let alert = UIAlertController(title: "Settings", message: "Settings go here", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                // sets quiz to the quiz that has been selected
                let quiz = quizOptions[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.quizSelected = quiz
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
                // sets the navigation top title to the quiz title
                controller.navigationController?.topViewController?.title = quiz.quizTitle
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizOptions.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = quizOptions[indexPath.row].quizTitle
        cell.detailTextLabel?.text = quizOptions[indexPath.row].quizDescription
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func retrieveData() {
        Alamofire.request(.GET, "https://tednewardsandbox.site44.com/questions.json").responseJSON {response in
            switch response.result {
                // .SUCCESS and .FAILURE come from Alamofire
            case .Success:
                if let data = response.result.value {
//                    let realm = try! Realm()
//                    realm.beginWrite()
                    let swiftyJson = JSON(data) // casts it to SwiftyJSON so that we can process it better
                    let swiftyJsonArray = swiftyJson.array
                    for eachQuiz in swiftyJsonArray! {
                        let quiz = Quiz()
                        quiz.quizTitle = eachQuiz["title"].stringValue
                        quiz.quizDescription = eachQuiz["desc"].stringValue
                        for eachQuestion in eachQuiz["questions"].array! {
                            let question = eachQuestion["text"].stringValue
                            let correctAnswer = eachQuestion["answer"].stringValue
                            let questionData = Question(question: question, answers: [], correctAnswer: correctAnswer)
                            for answerOption in eachQuestion["answers"].array! {
                                questionData.answers.append(answerOption.stringValue)
                            }
                            quiz.quizQuestions.append(questionData)
                        }
                        self.quizOptions.append(quiz)
//                        realm.create(Quiz.self, value: ["quizTitle" : quiz.quizTitle, "quizDescription" : quiz.quizDescription, "quizQuestions" : quiz.quizQuestions])
//                        try! realm.commitWrite()
                    }
                }
            case .Failure(let error):
                print(error)
            }
            // needs to load data so that it can be displayed because otherwise it sets up the tableview without the data? displays no cells
            self.tableView.reloadData()
        }
    }
}