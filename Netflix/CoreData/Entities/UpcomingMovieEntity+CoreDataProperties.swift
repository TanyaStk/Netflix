//
//  UpcomingMovieEntity+CoreDataProperties.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 17.08.2022.
//
//

import Foundation
import CoreData


extension UpcomingMovieEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UpcomingMovieEntity> {
        return NSFetchRequest<UpcomingMovieEntity>(entityName: "UpcomingMovieEntity")
    }

    @NSManaged public var movies: NSSet?

}

// MARK: Generated accessors for movies
extension UpcomingMovieEntity {

    @objc(addMoviesObject:)
    @NSManaged public func addToMovies(_ value: MovieEntity)

    @objc(removeMoviesObject:)
    @NSManaged public func removeFromMovies(_ value: MovieEntity)

    @objc(addMovies:)
    @NSManaged public func addToMovies(_ values: NSSet)

    @objc(removeMovies:)
    @NSManaged public func removeFromMovies(_ values: NSSet)

}

extension UpcomingMovieEntity : Identifiable {

}
