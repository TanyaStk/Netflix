//
//  GetVideosResponse.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 10.08.2022.
//

import Foundation

struct GetVideosResponse: Codable {
    let id: Int
    let results: [GetVideosResult]
}

struct GetVideosResult: Codable {
    let key: String
}
