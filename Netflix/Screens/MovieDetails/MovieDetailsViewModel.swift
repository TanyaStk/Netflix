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
        let movieDetails: Driver<MovieDetails>
        let dismissDetails: Driver<Void>
        let addToFavorites: Driver<Void>
        let isFavorite: Driver<Bool>
        let error: Driver<String>
    }
    
    private let isFavoriteBehaviorRelay = BehaviorRelay(value: false)
    private let errorRelay = PublishRelay<String>()
    
    private let coordinator: MovieDetailsCoordinator
    private let movieService: MoviesProvider
    private let userService: UserInfoProvider
    private let keychainUseCase: KeychainUseCase
    private let movieId: Int
    
    init(coordinator: MovieDetailsCoordinator,
         movieService: MoviesProvider,
         userService: UserInfoProvider,
         keychainUseCase: KeychainUseCase,
         movieId: Int) {
        self.coordinator = coordinator
        self.movieService = movieService
        self.userService = userService
        self.keychainUseCase = keychainUseCase
        self.movieId = movieId
    }
    
    func transform(_ input: Input) -> Output {
        let movieDetails = input.isViewLoaded
            .flatMap { [unowned self] _ in
                self.movieService.getDetails(movieId: String(self.movieId)).map { movie in
                    MovieDetails(id: movie.id,
                                 overview: movie.overview,
                                 imagePath: movie.poster_path,
                                 releaseDate: movie.release_date,
                                 runtime: movie.runtime,
                                 title: movie.title,
                                 voteAverage: movie.vote_average)
                }
            }
            .do(onError: { [weak self] error in
                self?.errorRelay.accept(error.localizedDescription)
            })
            .asDriver(onErrorJustReturn: MovieDetails(id: 0,
                                                      overview: "",
                                                      imagePath: "",
                                                      releaseDate: "",
                                                      runtime: 0,
                                                      title: "",
                                                      voteAverage: 0))
        let dismissDetails = input.backButtonTap
            .do { [weak self] _ in
                self?.coordinator.dismiss()
            }
            .asDriver(onErrorJustReturn: ())
        
        let addToFavorites = input.likeButtonTap
            .flatMap { [userService, movieId, isFavoriteBehaviorRelay] _ -> Single<MarkAsFavoriteResponse> in
                isFavoriteBehaviorRelay.accept(!(isFavoriteBehaviorRelay.value))
                guard let user = try self.keychainUseCase.getUser()
                else {
                    return .never()
                }
                return userService.markAsFavorite(for: user.session_id,
                                                  mediaType: "movie",
                                                  mediaId: movieId,
                                                  favorite: isFavoriteBehaviorRelay.value)
            }
            .do(onError: { error in
                self.errorRelay.accept(error.localizedDescription)
            })
            .map { _ in }
            .asDriver(onErrorJustReturn: ())

        let isFavorite = isFavoriteBehaviorRelay.asDriver(onErrorJustReturn: false)
        
        let error = errorRelay.asDriver(onErrorJustReturn: "Unknown error")
        
        return Output(movieDetails: movieDetails,
                      dismissDetails: dismissDetails,
                      addToFavorites: addToFavorites,
                      isFavorite: isFavorite,
                      error: error)
    }
}
