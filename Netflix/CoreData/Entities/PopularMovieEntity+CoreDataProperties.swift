//
//  PopularMovieEntity+CoreDataProperties.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 17.08.2022.
//
//

import Foundation
import CoreData


extension PopularMovieEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PopularMovieEntity> {
        return NSFetchRequest<PopularMovieEntity>(entityName: "PopularMovieEntity")
    }

    @NSManaged public var movies: NSSet?

}

// MARK: Generated accessors for movies
extension PopularMovieEntity {

    @objc(addMoviesObject:)
    @NSManaged public func addToMovies(_ value: MovieEntity)

    @objc(removeMoviesObject:)
    @NSManaged public func removeFromMovies(_ value: MovieEntity)

    @objc(addMovies:)
    @NSManaged public func addToMovies(_ values: NSSet)

    @objc(removeMovies:)
    @NSManaged public func removeFromMovies(_ values: NSSet)

}

extension PopularMovieEntity : Identifiable {

}
