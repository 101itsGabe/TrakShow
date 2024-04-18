//
//  TvShowApi.swift
//  TrakShow
//
//  Created by Gabriel Mannheimer on 2/7/24.
//

import Foundation



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


struct TVShowMaze: Decodable{
    let score: Double?
    let show: Show?
    let image: MazeImage?
}

struct Show: Decodable, Hashable {
    let id: Int?
    let url: String?
    let name: String?
    let image: MazeImage?
    let summary: String?
}

struct MazeImage: Decodable, Hashable{
    let original: String?
    let medium: String?
}

struct MazeEpisode: Decodable, Hashable{
    let name: String?
    let season: Int?
    let number: Int?
}



class TvShowApi
{
    var baseShowUrl = "/api/show-details?q=:show"
    var baseSearchUrl2 = "/search/shows?q=:query"
    
    func tvmazeapi(search: String) async throws -> [Show]{
        var shows: [Show] = []
        var url = URL(string: "https://api.tvmaze.com/search/shows?q=\(search)")
        let (data, _) = try await URLSession.shared.data(from: url!)
        let jsonString = String(data: data, encoding: .utf8)
        //print("right before json string")
        //print(jsonString ?? "Nah")
        /*
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        if let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]) {
                if let prettyJsonString = String(data: prettyJsonData, encoding: .utf8) {
                    print(prettyJsonString)
                    print("\n\n")
                }
            }
         */
        print("\n\n\n\n")
        do{
            let showWrapper = try JSONDecoder().decode([TVShowMaze].self, from: data)
            for show in showWrapper{
                //print(show)
                if let show2 = show.show{
                    //print("Show id: \(show2.id) ")
                    shows.append(show2)
                }
            }
        }
        catch{
        print(String(describing: error))
        }
        return shows
    }
    
    
    func tvmazesingleShow(id: Int) async throws -> Show{
        print("dejavu")
        var curShow: Show
        print(id)
        var url = URL(string: "https://api.tvmaze.com/shows/\(id)")
        let (data, _) = try await URLSession.shared.data(from: url!)
        let jsonString = String(data: data, encoding: .utf8)
        //print(jsonString)
        /*
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        if let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]) {
                if let prettyJsonString = String(data: prettyJsonData, encoding: .utf8) {
                    print(prettyJsonString)
                    print("\n\n")
                }
            }
         */
        do{
            //print("in the deep")
            let showWrapper = try JSONDecoder().decode(Show.self, from: data)
            //print("after the deep")
            curShow = showWrapper
            //print(curShow.name)
        }
        return curShow
    }
    
    func tvmazepisodes(id: Int) async throws ->[MazeEpisode]{
        var eps: [MazeEpisode] = []
        var url = URL(string: "https://api.tvmaze.com/shows/\(id)/episodes")
        let (data, _) = try await URLSession.shared.data(from: url!)
        let jsonString = String(data: data, encoding: .utf8)
        
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        if let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]) {
                if let prettyJsonString = String(data: prettyJsonData, encoding: .utf8) {
                    //print(prettyJsonString)
                    //print("\n\n")
                }
            }
        
        do{
            let epWrapper = try JSONDecoder().decode([MazeEpisode].self, from: data)
            for ep in epWrapper{
                //print("Season: \(ep.season) Ep: \(ep.number) \(ep.name)")
                eps.append(ep)
            }
        }
        
        return eps
        
    }
    
}
