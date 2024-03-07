//
//  TvShowApi.swift
//  TrakShow
//
//  Created by Gabriel Mannheimer on 2/7/24.
//

import Foundation

struct Wrapper: Decodable{
    let tvShow: TVShowSelected
}

struct TVShow : Decodable, Hashable{
    let id: Int
    let name: String
    let image_thumbnail_path: String?
    //let episodes: [Episode]
}

struct SearchWrapper: Decodable{
    let total: String
    let page: Int
    let pages: Int
    let tv_shows: [TVShow]
    
}

struct TVShowSelected: Decodable{
    let id: Int
    let name: String
    let description: String
    let image_thumbnail_path: String
    let rating: String
    let episodes: [Episode]
}

struct Episode: Decodable, Hashable {
    let season: Int
    let episode: Int
    let name: String
}

struct MazeStart: Decodable{
    let tvShowMaze: TVShowMaze
}

struct TVShowMaze: Decodable{
    let score: String?
    let show: Show?
}

struct Show: Decodable, Hashable {
    let id: Int?
    let name: String?
}

struct rating: Decodable{
    let average: Double
}


class TvShowApi
{
    var baseShowUrl = "/api/show-details?q=:show"
    var baseSearchUrl2 = "/search/shows?q=:query"
    
    func tvmazeapi(search: String) async throws {
        var url = URL(string: "https://api.tvmaze.com/search/shows?q=haikyu")
        let (data, _) = try await URLSession.shared.data(from: url!)
        let jsonString = String(data: data, encoding: .utf8)
        print("right before json string")
        print(jsonString ?? "Nah")
        print("\n\n\n\n")
        let showWrapper = try JSONDecoder().decode([MazeStart].self, from: data)
        print(showWrapper.count)
        for showShit in showWrapper{
            print(showShit.tvShowMaze.show?.name ?? "Nah")
        }
        
        //pt2.
        
    }
    
    func performApiCall(id: Any?) async throws -> TVShowSelected {
        var url = URL(string: "")
        if let stringID = id as? String {
            var newSearch = ""
            for curchar in stringID{
                if curchar == " "{
                    newSearch += "-"
                }
                else if curchar.isLetter {
                    newSearch += curchar.lowercased()
                }
            }
            //print(newSearch)
            url = URL(string: "https://www.episodate.com/api/show-details?q=\(newSearch)")!
        }
        else if let intID = id as? Int {
            url = URL(string: "https://www.episodate.com/api/show-details?q=\(intID)")!
        }
            let (data, _) = try await URLSession.shared.data(from: url!)
            let wrapper = try JSONDecoder().decode(Wrapper.self, from: data)
            //let jsonString = String(data: data, encoding: .utf8)
            //print(jsonString ?? "No data received")
            
            return wrapper.tvShow
        }
    
    func getShows(search: String, page: Int) async throws -> [TVShow]{
        var shows: [TVShow] = []
        //print(page)
        do{
            if(search == "")
            {
                let url = URL(string: "https://www.episodate.com/api/most-popular?page=\(page)")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let jsonString = String(data: data, encoding: .utf8)
                //print(jsonString ?? "No data received")
                let searchWrapper = try JSONDecoder().decode(SearchWrapper.self, from: data)
                
                let total = searchWrapper.total
                shows = searchWrapper.tv_shows
            }
            else
            {
                var newSearch = ""
                for curchar in search{
                    if curchar == " "{
                        newSearch += "-"
                    }
                    else{
                        newSearch += curchar.lowercased()
                    }
                }
                //print(newSearch)
                let url = URL(string: "https://www.episodate.com/api/search?q=\(newSearch)&page=\(page)")
                if let realUrl = url{
                    let (data, _) = try await URLSession.shared.data(from: realUrl)
                    let searchWrapper = try JSONDecoder().decode(SearchWrapper.self, from: data)
                    shows = searchWrapper.tv_shows
                }
            }
        }
        catch{
            print("in error")
            print(String(describing: error))
        }
        
        return shows
    }
}
