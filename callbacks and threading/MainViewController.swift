//
//  MainViewController.swift
//  callbacks and threading
//
//  Created by uday on 8/17/17.
//  Copyright © 2017 uday. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var names = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        getUsers { (success, response, error) in
            if success {
                guard let names = response as? [String] else {return}
                self.names = names
                self.tableView.reloadData()
            }
        }
        
    }
    func getUsers(completion: @escaping (Bool,Any?,Error?) -> Void) {
        
        DispatchQueue.global().asyncAfter(deadline: .now()) {
            
            guard let path = Bundle.main.path(forResource: "someJSON", ofType: "txt") else {return}
            let url = URL(fileURLWithPath: path)
            do{
                let data = try Data(contentsOf: url)
                let json = try JSONSerialization.jsonObject(with:data , options: .mutableContainers)
                //            print(json)
                guard let array = json as? [[String:Any]] else {return}
                var names = [String]()
                for user in array{
                    guard let name = user["name"] as? String else {continue}
                    names.append(name)
                }
                DispatchQueue.main.async {
                    completion(true, names, nil)
                }
                
                
            }catch{
                DispatchQueue.main.async {
                    completion(false, nil, error)
                }
            }
            
        }
    }
}

extension MainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = names[indexPath.row]
        return cell
    }
}
