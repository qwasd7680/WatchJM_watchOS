//
//  Album.swift
//  WatchJM
//
//  Created by 周敬博 on 2025/8/17.
//

import Foundation

struct Album: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let aid: String
    var cover: String = ""
    var tags: [String] = []
    var url: URL? = nil
    var page_count: Int = 0
    var likes: Int = 0
    var views: Int = 0
    var method: String? = nil

    enum CodingKeys: String, CodingKey {
        case id, title, aid, cover, tags, url
        case page_count, likes, views, method
    }

    init(
        id: UUID = UUID(),
        title: String,
        aid: String,
        cover: String = "",
        tags: [String] = [],
        url: URL? = nil,
        page_count: Int = 0,
        likes: Int = 0,
        views: Int = 0,
        method: String? = nil
    ) {
        self.id = id
        self.title = title
        self.aid = aid
        self.cover = cover
        self.tags = tags
        self.url = url
        self.page_count = page_count
        self.likes = likes
        self.views = views
        self.method = method
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.title = try container.decode(String.self, forKey: .title)
        self.aid = try container.decode(String.self, forKey: .aid)
        self.cover = try container.decodeIfPresent(String.self, forKey: .cover) ?? ""
        self.tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        self.url = try container.decodeIfPresent(URL.self, forKey: .url)
        self.method = try container.decodeIfPresent(String.self, forKey: .method)
        self.page_count = try Album.decodeIntOrString(container: container, key: .page_count)
        self.likes = try Album.decodeIntOrString(container: container, key: .likes)
        self.views = try Album.decodeIntOrString(container: container, key: .views)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(aid, forKey: .aid)
        try container.encode(cover, forKey: .cover)
        try container.encode(tags, forKey: .tags)
        try container.encodeIfPresent(url, forKey: .url)
        try container.encode(page_count, forKey: .page_count)
        try container.encode(likes, forKey: .likes)
        try container.encode(views, forKey: .views)
        try container.encodeIfPresent(method, forKey: .method)
    }

    private static func decodeIntOrString(
        container: KeyedDecodingContainer<CodingKeys>,
        key: CodingKeys
    ) throws -> Int {
        if let intVal = try? container.decode(Int.self, forKey: key) {
            return intVal
        }
        if let strVal = try? container.decode(String.self, forKey: key) {
            return Int(strVal) ?? 0
        }
        return 0
    }
}
