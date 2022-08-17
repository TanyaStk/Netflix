//
//  LatestMovieEntity+CoreDataProperties.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 17.08.2022.
//
//

import Foundation
import CoreData

extension LatestMovieEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LatestMovieEntity> {
        return NSFetchRequest<LatestMovieEntity>(entityName: "LatestMovieEntity")
    }

    @NSManaged public var genres: [String]?
    @NSManaged public var id: Int64
    @NSManaged public var posterPath: String?
    @NSManaged public var title: String?

}

extension LatestMovieEntity: Identifiable {

}
