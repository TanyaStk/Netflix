//
//  FavoriteEntity+CoreDataProperties.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 18.08.2022.
//
//

import Foundation
import CoreData

extension FavoriteEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteEntity> {
        return NSFetchRequest<FavoriteEntity>(entityName: "FavoriteEntity")
    }

    @NSManaged public var id: Int64

}

extension FavoriteEntity: Identifiable {

}
