//
//  ViewController.swift
//  movie Searcher
//
//  Created by Mac on 18/12/24.
//

import UIKit
import SafariServices
//UI
// Network request
//tap a cell to see info about movie
// custom ell

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    @IBOutlet var field: UITextField!
    
    
    var movies = [Movie]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.register(MovieTableViewCell.nib(), forCellReuseIdentifier: MovieTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        field.delegate = self
    }
    //Field
    
    func textFieldShouldReturn( textField: UITextField) -> Bool{
        searchMovies()
        return true
    }
    func searchMovies(){
        field.resignFirstResponder()
        guard let text = field.text, !text.isEmpty else {
            return
        }
         let query = text.replacingOccurrences(of: " ", with: "%20")
        movies.removeAll()
        URLSession.shared.dataTask(with: URL(string: "https://www.omdbapi.com/?apikey=3aea79ac&s=\(query)&type=movie")!,
                                   completionHandler: {data, response, error in
            guard let data = data, error == nil else{
                return
            }
            
            // convert
            var result: MovieResult?
            do {
                result = try JSONDecoder().decode(MovieResult.self, from: data)
            }
            catch {
                print("error")
            }
            
            guard let finalResult = result else {
                return
            }
            // update movie array
            let newMovies = finalResult.Search
            self.movies.append(contentsOf: newMovies)
            
            // refresh table
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        }).resume()
    }
        // Table
        func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return movies.count
            
        }
        func tableView( _ tableView: UITableView, cellForRowAt indexpath: IndexPath) ->  UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier, for: indexpath) as! MovieTableViewCell
            cell.configure(with: movies[indexpath.row])
            return cell
        }
        func tableView( tableView: UITableView, didSelectRowAt indexPath: IndexPath){
            tableView.deselectRow(at: indexPath, animated: true)
            
            //show movie details
            let url = "https://www.imdb.com/title/\(movies[indexPath.row].imdbID)/"
            let vc = SFSafariViewController(url: URL(string: url)!)
            present(vc, animated: true)
        }
    func tableView(_tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 120
    }
        
    }
    
    struct MovieResult: Codable{
        let Search: [Movie]
    }
    struct Movie: Codable {
        let Title: String
        let Year: String
        let imdbID: String
        let _Type: String
        let Poster: String
        
        private enum CodingKeys: String, CodingKey {
            case Title, Year, imdbID, _Type = "Type", Poster
        }
    }
