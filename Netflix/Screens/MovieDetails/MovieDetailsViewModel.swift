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
        let playButtonTap: Observable<Void>
    }
    
    struct Output {
        let movieDetails: Driver<MovieDetails>
        let loadFavoriteStatus: Driver<Void>
        let dismissDetails: Driver<Void>
        let addToFavorites: Driver<Void>
        let isFavorite: Driver<Bool>
        let loadVideoKey: Driver<Void>
        let videoKey: Driver<String>
        let error: Driver<String>
    }
    
    private let isFavoriteBehaviorRelay = BehaviorRelay(value: false)
    private let movieVideoKeyRelay = BehaviorRelay(value: "")
    private let errorRelay = PublishRelay<String>()
    
    private let coordinator: MovieDetailsCoordinator
    private let movieService: MoviesProvider
    private let userService: UserInfoProvider
    private let keychainUseCase: Keychain
    private let movieId: Int
    
    private var hasVideo = false
    
    init(coordinator: MovieDetailsCoordinator,
         movieService: MoviesProvider,
         userService: UserInfoProvider,
         keychainUseCase: Keychain,
         movieId: Int) {
        self.coordinator = coordinator
        self.movieService = movieService
        self.userService = userService
        self.keychainUseCase = keychainUseCase
        self.movieId = movieId
    }
    
    func transform(_ input: Input) -> Output {
        let movieDetails = input.isViewLoaded
            .flatMapLatest { [movieService] _ in
                movieService.getDetails(movieId: self.movieId).map { movie -> MovieDetails in
                    return MovieDetails(id: movie.id,
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
                
        let loadFavoriteStatus = input.isViewLoaded
            .flatMapLatest { _ -> Driver<Void> in
                guard let user = try self.keychainUseCase.getUser()
                else {
                    return .never()
                }
                return self.getStatus(for: user.session_id, movieId: self.movieId)
            }
            .do(onError: { [weak self] error in
                self?.errorRelay.accept(error.localizedDescription)
            })
            .map { _ in }
            .asDriver(onErrorJustReturn: ())
                
        let loadVideoKey = input.playButtonTap
            .flatMapLatest { _ -> Driver<Void> in
                self.getVideoKey()
            }
            .do(onError: { [weak self] error in
                self?.errorRelay.accept(error.localizedDescription)
            })
            .map { _ in }
            .asDriver(onErrorJustReturn: ())
        
        let dismissDetails = input.backButtonTap
            .do { [weak self] _ in
                self?.coordinator.dismiss()
            }
            .asDriver(onErrorJustReturn: ())
        
        let addToFavorites = input.likeButtonTap
            .flatMapLatest { [userService, keychainUseCase] _ -> Single<AccountDetailsResponse> in
                guard let user = try keychainUseCase.getUser()
                else {
                    return .never()
                }
                return userService.getAccountDetails(with: user.session_id)
            }
            .flatMap { [userService, keychainUseCase, movieId, isFavoriteBehaviorRelay] accountDetailsResponse -> Single<MarkAsFavoriteResponse> in
                isFavoriteBehaviorRelay.accept(!(isFavoriteBehaviorRelay.value))
                guard let user = try keychainUseCase.getUser()
                else {
                    return .never()
                }
                return userService.markAsFavorite(
                    for: accountDetailsResponse.id,
                    with: user.session_id,
                    mediaType: "movie",
                    mediaId: movieId,
                    favorite: isFavoriteBehaviorRelay.value
                )
            }
            .do(onError: { error in
                self.errorRelay.accept(error.localizedDescription)
            })
            .map { _ in }
            .asDriver(onErrorJustReturn: ())

        let isFavorite = isFavoriteBehaviorRelay.asDriver(onErrorJustReturn: false)
        let videoKey = movieVideoKeyRelay.asDriver(onErrorJustReturn: "")
        let error = errorRelay.asDriver(onErrorJustReturn: "Unknown error")
        
        return Output(movieDetails: movieDetails,
                      loadFavoriteStatus: loadFavoriteStatus,
                      dismissDetails: dismissDetails,
                      addToFavorites: addToFavorites,
                      isFavorite: isFavorite,
                      loadVideoKey: loadVideoKey,
                      videoKey: videoKey,
                      error: error)
    }
    
    private func getVideoKey() -> Driver<Void> {
        return movieService.getVideos(for: self.movieId)
            .do(onSuccess: { getVideosResponse in
                guard let videoKey = getVideosResponse.results.first?.key else {
                    return
                }
                self.movieVideoKeyRelay.accept(videoKey)
            }, onError: { error in
                self.errorRelay.accept(error.localizedDescription)
            })
            .map { _ in }
            .asDriver(onErrorJustReturn: ())
    }
    
    private func getStatus(for userId: String, movieId: Int) -> Driver<Void> {
        return userService.isFavorite(for: userId, movieId: movieId)
            .do {  [isFavoriteBehaviorRelay] response in
                isFavoriteBehaviorRelay.accept(response.favorite)
            }
            .map { _ in }
            .asDriver(onErrorJustReturn: ())
    }
}
