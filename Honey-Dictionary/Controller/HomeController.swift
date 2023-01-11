//
//  ViewController.swift
//  Honey-Dictionary
//
//  Created by Halil YAŞ on 4.01.2023.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class HomeController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var segmentCategory: UISegmentedControl!
    @IBOutlet weak var ideasTableView: UITableView!
    
    private var ideas = [Idea]()
    
    private var CollectionRef : CollectionReference!
    private var ideasListener : ListenerRegistration!
    
    private var selectedCategory = Categories.Funny.rawValue
    
    private var listenerHandler : AuthStateDidChangeListenerHandle?
    
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ideasTableView.delegate = self
        ideasTableView.dataSource = self
        
        CollectionRef = Firestore.firestore().collection(IDEAS_REF)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkUser()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if ideasListener != nil {
            ideasListener.remove()
        }
    }
    
    //MARK: - API
    
    func checkUser() {
        
        listenerHandler = Auth.auth().addStateDidChangeListener({ auth, user in
            
            if user == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true,completion: nil)
            } else {
                self.setListener()
            }
            
        })
    }
    
    //MARK: - Actions
    
    @IBAction func clickedSegment(_ sender: Any) {
        
        switch segmentCategory.selectedSegmentIndex {
        case 0 :
            selectedCategory = Categories.Funny.rawValue
        case 1 :
            selectedCategory = Categories.Absurd.rawValue
        case 2 :
            selectedCategory = Categories.Agenda.rawValue
        case 3 :
            selectedCategory = Categories.Popular.rawValue
        default :
            selectedCategory = Categories.Funny.rawValue
        }
        ideasListener.remove()
        setListener()
        
    }
    
    @IBAction func clickedLogOut(_ sender: Any) {
        
        let firebaseAuth = Auth.auth()
        
        do {
            
            try firebaseAuth.signOut()
            
        } catch let error as NSError {
            debugPrint("DEBUG: Error while loggining Out \(error.localizedDescription)")
        }
    }
    
    
    //MARK: - Helpers
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "homeToComment" {
            
            if let vc = segue.destination as? CommentController {
                
                if let selectedIdea = sender as? Idea {
                    vc.selectedIdea = selectedIdea
                }
            }
        }
    }
    
    func setListener() {
        
        if selectedCategory == Categories.Popular.rawValue {
            
            ideasListener = CollectionRef
                .order(by: LIKE_NUMBER, descending: true)
                .addSnapshotListener { snapshot, error in
                
                if let error = error {
                    debugPrint("DEBUG: getDocuments Error \(error.localizedDescription)")
                } else {
                    
                    self.ideas.removeAll()
                    self.ideas = Idea.getIdeas(snapshot: snapshot,dailyPost: true)
                    self.ideasTableView.reloadData()
                }
            }
            
        } else {
            
            ideasListener = CollectionRef.whereField(CATEGORY, isEqualTo: selectedCategory)
                .order(by: UPLOAD_DATE, descending: true)
                .addSnapshotListener { snapshot, error in
                
                if let error = error {
                    debugPrint("DEBUG: getDocuments Error \(error.localizedDescription)")
                } else {
                    
                    self.ideas.removeAll()
                    self.ideas = Idea.getIdeas(snapshot: snapshot)
                    self.ideasTableView.reloadData()
                }
            }
        }
    }
    
    func deleteComment(collectionRef : CollectionReference,deleteRecordNumber : Int = 100, completion : @escaping(Error?) -> ()) {
        
        collectionRef.limit(to: deleteRecordNumber).getDocuments { snapshot, error in
            
            guard let snapshot = snapshot else {
                completion(error)
                return
            }
            
            guard snapshot.count > 0 else {
                completion(nil)
                return
            }
            
            let batch = collectionRef.firestore.batch()
            snapshot.documents.forEach { batch.deleteDocument($0.reference) }
            
            batch.commit { batchError in
                
                if let error = batchError {
                    completion(error)
                } else {
                    self.deleteComment(collectionRef: collectionRef,deleteRecordNumber: deleteRecordNumber ,completion: completion)
                }
            }
        }
    }
}

//MARK: - UITableViewDataSource

extension HomeController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ideas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as? HomeCell {
            
            cell.configureUI(idea: ideas[indexPath.row],delegate: self)
            return cell
        }
        
        return UITableViewCell()
        
    }
}

//MARK: - UITableViewDelegate

extension HomeController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "homeToComment", sender: ideas[indexPath.row])
    }
}

//MARK: - HomeCellDelegate

extension HomeController : HomeCellDelegate {
    func handleOptions(idea: Idea) {
        
        let alert = UIAlertController(title: "Delete", message: "Do you want to delete your post?", preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: "Delete", style: .default) { action in
            // Delete Post
            
            let commentCollRef = Firestore.firestore().collection(IDEAS_REF).document(idea.documentId).collection(COMMENTS_REF)
            
            let likeCollRef = Firestore.firestore().collection(IDEAS_REF).document(idea.documentId).collection(LIKE_REF)
            
            self.deleteComment(collectionRef: likeCollRef) { error in
                
                if let error = error {
                    debugPrint("DEBUG: Error while deleting like of the your post \(error.localizedDescription)")
                } else {
                    
                    self.deleteComment(collectionRef: commentCollRef) { error in
                        
                        if let error = error {
                            debugPrint("DEBUG: Error while deleting comment of the your post \(error.localizedDescription)")
                        } else {
                            
                            Firestore.firestore().collection(IDEAS_REF).document(idea.documentId).delete { error in
                                
                                if let error = error {
                                    debugPrint("DEBUG: Error while deleting your post \(error.localizedDescription)")
                                } else {
                                    alert.dismiss(animated: true,completion: nil)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel,handler: nil)
        
        alert.addAction(delete)
        alert.addAction(cancel)
        present(alert, animated: true,completion: nil)
    }
}

