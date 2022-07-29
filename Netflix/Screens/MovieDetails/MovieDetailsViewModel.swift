//
//  MovieDetailsViewModel.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 28.07.2022.
//

import Foundation
import RxSwift
import RxCocoa

class MovieDetailsViewModel: ViewModel {
    struct Input {
        let isViewLoaded: Observable<Bool>
        let backButtonTap: Observable<Void>
        let likeButtonTap: Observable<Void>
    }
    
    struct Output {
        let movieDetails: Driver<MovieDetailsResponse>
        let dismissDetails: Driver<Void>
        let addToFavorites: Driver<Void>
        let isFavorite: Driver<Bool>
        let error: Driver<String>
    }
    
    private let isFavoriteBehaviorRelay = BehaviorRelay(value: false)
    private let errorRelay = PublishRelay<String>()
    
    private let coordinator: MovieDetailsCoordinator
    private let service: MoviesProvider
    private let movieId: Int
    
    init(coordinator: MovieDetailsCoordinator,
         service: MoviesProvider,
         movieId: Int) {
        self.coordinator = coordinator
        self.service = service
        self.movieId = movieId
    }
    
    func transform(_ input: Input) -> Output {
        let movieDetails = input.isViewLoaded
            .flatMap { [unowned self] _ in
                self.service.getDetails(movieId: String(self.movieId))
            }
            .do(onError: { [weak self] error in
                self?.errorRelay.accept(error.localizedDescription)
            })
            .asDriver(onErrorJustReturn: MovieDetailsResponse(id: 0,
                                                              overview: "",
                                                              poster_path: "",
                                                              release_date: "",
                                                              runtime: 0,
                                                              title: "",
                                                              vote_average: 0))
        let dismissDetails = input.backButtonTap
            .do { [weak self] _ in
                self?.coordinator.dismiss()
            }
            .asDriver(onErrorJustReturn: ())
        
        let addToFavorites = input.likeButtonTap
            .do(onNext: { [weak self] _ in
                print("Like me")
                self?.isFavoriteBehaviorRelay.accept(!(self?.isFavoriteBehaviorRelay.value ?? false))
            })
            .asDriver(onErrorDriveWith: .never())
                    
        let isFavorite = isFavoriteBehaviorRelay.asDriver(onErrorJustReturn: false)
        
        let error = errorRelay.asDriver(onErrorJustReturn: "Unknown error")
        
        return Output(movieDetails: movieDetails,
                      dismissDetails: dismissDetails,
                      addToFavorites: addToFavorites,
                      isFavorite: isFavorite,
                      error: error)
    }
}
