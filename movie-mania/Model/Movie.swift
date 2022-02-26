//
//  Movie.swift
//  movie-mania
//
//  Created by harshdeep.s on 25/02/22.
//

import Foundation
import CoreData

enum DecoderConfigurationError: Error {
  case missingManagedObjectContext
}

extension CodingUserInfoKey {
  static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}

class Movie: NSManagedObject, Decodable {
    enum CodingKeys: CodingKey {
        case id, title, poster_path, vote_average, popularity, overview, release_date
    }
    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
              throw DecoderConfigurationError.missingManagedObjectContext
            }

            self.init(context: context)

            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(Int64.self, forKey: .id)
            self.title = try container.decode(String.self, forKey: .title)
            self.poster_path = try container.decode(String.self, forKey: .poster_path)
            self.vote_average = try container.decode(Float.self, forKey: .vote_average)
            self.popularity = try container.decode(Double.self, forKey: .popularity)
            self.overview = try container.decode(String.self, forKey: .overview)
            self.release_date = try container.decode(String.self, forKey: .release_date)
    }
    
}
