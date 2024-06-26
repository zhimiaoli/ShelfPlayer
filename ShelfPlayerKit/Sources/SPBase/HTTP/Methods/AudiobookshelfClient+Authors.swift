//
//  AudiobookshelfClient+Authors.swift
//  Audiobooks
//
//  Created by Rasmus Krämer on 04.10.23.
//

import Foundation

// MARK: Search

public extension AudiobookshelfClient {
    func getAuthors(libraryId: String) async throws -> [Author] {
        let response = try await request(ClientRequest<AuthorsResponse>(path: "api/libraries/\(libraryId)/authors", method: "GET"))
        return response.authors.map(Author.convertFromAudiobookshelf)
    }
    
    func getAuthor(authorId: String) async throws -> Author {
        let response = try await request(ClientRequest<AudiobookshelfItem>(path: "api/authors/\(authorId)", method: "GET"))
        return Author.convertFromAudiobookshelf(item: response)
    }
    
    func getAuthorId(name: String, libraryId: String) async throws -> String {
        let response = try? await request(ClientRequest<SearchResponse>(path: "api/libraries/\(libraryId)/search", method: "GET", query: [
            URLQueryItem(name: "q", value: name),
            URLQueryItem(name: "limit", value: "1"),
        ]))
        
        if let id = response?.authors?.first?.id {
            return id
        }
        
        throw AudiobookshelfClientError.missing
    }
    
    func getAuthorData(authorId: String, libraryId: String) async throws -> (Author, [Audiobook], [Series]) {
        let response = try await request(ClientRequest<AudiobookshelfItem>(path: "api/authors/\(authorId)", method: "GET", query: [
            URLQueryItem(name: "library", value: libraryId),
            URLQueryItem(name: "include", value: "items,series"),
        ]))
        
        let author = Author.convertFromAudiobookshelf(item: response)
        let audiobooks = (response.libraryItems ?? []).compactMap(Audiobook.convertFromAudiobookshelf)
        let series = (response.series ?? []).map(Series.convertFromAudiobookshelf)
        
        return (author, audiobooks, series)
    }
}
