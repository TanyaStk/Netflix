//
//  UpcomingEntity+CoreDataProperties.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 18.08.2022.
//
//

import Foundation
import CoreData

extension UpcomingEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UpcomingEntity> {
        return NSFetchRequest<UpcomingEntity>(entityName: "UpcomingEntity")
    }

    @NSManaged public var id: Int64

}

extension UpcomingEntity: Identifiable {

}
