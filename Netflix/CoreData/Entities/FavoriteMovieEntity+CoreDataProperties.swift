//
//  FavoriteMovieEntity+CoreDataProperties.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 17.08.2022.
//
//

import Foundation
import CoreData


extension FavoriteMovieEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteMovieEntity> {
        return NSFetchRequest<FavoriteMovieEntity>(entityName: "FavoriteMovieEntity")
    }

    @NSManaged public var movies: NSSet?

}

// MARK: Generated accessors for movies
extension FavoriteMovieEntity {

    @objc(addMoviesObject:)
    @NSManaged public func addToMovies(_ value: MovieEntity)

    @objc(removeMoviesObject:)
    @NSManaged public func removeFromMovies(_ value: MovieEntity)

    @objc(addMovies:)
    @NSManaged public func addToMovies(_ values: NSSet)

    @objc(removeMovies:)
    @NSManaged public func removeFromMovies(_ values: NSSet)

}

extension FavoriteMovieEntity : Identifiable {

}
