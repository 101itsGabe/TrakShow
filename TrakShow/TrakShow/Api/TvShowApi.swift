//
//  TvShowApi.swift
//  TrakShow
//
//  Created by Gabriel Mannheimer on 2/7/24.
//

import Foundation

struct Wrapper: Decodable{
    let tvShow: TVShow
}

struct TVShow : Decodable, Hashable{
    let id: Int
    let name: String
    let image_thumbnail_path: String?
}

struct SearchWrapper: Decodable{
    let total: String
    let page: Int
    let pages: Int
    let tv_shows: [TVShow]
    
}


class TvShowApi
{
    var baseShowUrl = "/api/show-details?q=:show"
    
    func performApiCall() async throws -> TVShow {
            let url = URL(string: "https://www.episodate.com/api/show-details?q=keeping-up-with-the-kardashians")!
            let (data, _) = try await URLSession.shared.data(from: url)
        let wrapper = try JSONDecoder().decode(Wrapper.self, from: data)
        let tvShow = wrapper.tvShow
        let id = tvShow.id
        let name = tvShow.name
        //print("TvShow: \(name) ID: \(id)")
            return wrapper.tvShow
    }
    
    func getShows(search: String) async throws -> [TVShow]{
        var shows: [TVShow] = []
        do{
            if(search == "")
            {
                let url = URL(string: "https://www.episodate.com/api/most-popular?page=1")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let jsonString = String(data: data, encoding: .utf8)
                print(jsonString ?? "No data received")
                let searchWrapper = try JSONDecoder().decode(SearchWrapper.self, from: data)
                
                let total = searchWrapper.total
                shows = searchWrapper.tv_shows
                for show in shows{
                    print(show.image_thumbnail_path)
                }
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
                let url = URL(string: "https://www.episodate.com/api/search?q=\(newSearch)&page=1")
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
