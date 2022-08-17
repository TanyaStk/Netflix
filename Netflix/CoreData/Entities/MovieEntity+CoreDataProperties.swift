//
//  MovieEntity+CoreDataProperties.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 17.08.2022.
//
//

import Foundation
import CoreData

extension MovieEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MovieEntity> {
        return NSFetchRequest<MovieEntity>(entityName: "MovieEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var overview: String?
    @NSManaged public var posterPath: String?
    @NSManaged public var releaseData: String?
    @NSManaged public var runtime: Int64
    @NSManaged public var title: String?
    @NSManaged public var voteAverage: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var inFavorite: FavoriteMovieEntity?
    @NSManaged public var inPopular: PopularMovieEntity?
    @NSManaged public var inUpcoming: UpcomingMovieEntity?

}

extension MovieEntity: Identifiable {

}
