//
//  UserEntity+CoreDataProperties.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 18.08.2022.
//
//

import Foundation
import CoreData

extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var username: String?

}

extension UserEntity: Identifiable {

}
