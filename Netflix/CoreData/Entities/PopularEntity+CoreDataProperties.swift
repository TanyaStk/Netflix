//
//  PopularEntity+CoreDataProperties.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 18.08.2022.
//
//

import Foundation
import CoreData

extension PopularEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PopularEntity> {
        return NSFetchRequest<PopularEntity>(entityName: "PopularEntity")
    }

    @NSManaged public var id: Int64

}

extension PopularEntity: Identifiable {

}
