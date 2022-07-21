//
//  ViewModel.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 21.07.2022.
//

import Foundation

protocol ViewModel {
    
    associatedtype Input
    associatedtype Output
    
    func transform(_ input: Input) -> Output
}
