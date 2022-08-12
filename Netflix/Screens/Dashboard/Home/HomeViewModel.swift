//
//  HomeViewModel.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 25.07.2022.
//

import Foundation
import RxSwift
import RxCocoa

class HomeViewModel: ViewModel {
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let profileButtonTap: Observable<Void>
        let likeButtonTap: Observable<Void>
        let playButtonTap: Observable<Void>
        let movieCoverTap: Observable<IndexPath>
        let loadNextPage: Observable<(cell: UICollectionViewCell, at: IndexPath)>
    }
    
    struct Output {
        let openProfile: Driver<Void>
        let addLatestToFavorites: Driver<Void>
        let isLatestMovieFavorite: Driver<Bool>
        let loadMovies: Driver<Void>
        let showLatestMovie: Driver<LatestMovie>
        let loadVideoKey: Driver<Void>
        let videoKey: Driver<String>
        let showPopularMovies: Driver<[Movie]>
        let showMovieDetails: Driver<Void>
        let error: Driver<String>
    }
    
    private let showLatestMovieRelay = BehaviorRelay<LatestMovie>(value: LatestMovie(
        adult: false, genres: [], id: 0, imagePath: "", title: "", isFavorite: false)
    )
    private let showPopularMoviesRelay = BehaviorRelay<[Movie]>(value: [Movie]())
    private let isLatestFavoriteBehaviorRelay = BehaviorRelay(value: false)
    private let movieVideoKeyRelay = BehaviorRelay(value: "")
    private let errorRelay = PublishRelay<String>()
    
    private let coordinator: HomeCoordinator
    private let movieService: MoviesProvider
    private let userService: UserInfoProvider
    private let keychainUseCase: Keychain

    private var popularMoviesPage = 1
    private var popularMovies = [Movie]()
    private var latestMovieId = 0
    
    init(coordinator: HomeCoordinator,
         movieService: MoviesProvider,
         userService: UserInfoProvider,
         keychainUseCase: Keychain) {
        self.coordinator = coordinator
        self.movieService = movieService
        self.userService = userService
        self.keychainUseCase = keychainUseCase
    }
    
    func transform(_ input: Input) -> Output {
        let openProfile = input.profileButtonTap
            .do(onNext: { [weak self] _ in
                self?.coordinator.coordinateToProfile()
            })
            .asDriver(onErrorDriveWith: .never())
                
        let addToFavorites = input.likeButtonTap
            .flatMapLatest { [userService, keychainUseCase] _ -> Single<AccountDetailsResponse> in
                guard let user = try keychainUseCase.getUser()
                else {
                    return .never()
                }
                return userService.getAccountDetails(with: user.session_id)
            }
            .flatMap { [userService, keychainUseCase, latestMovieId, isLatestFavoriteBehaviorRelay] accountDetailsResponse -> Single<MarkAsFavoriteResponse> in
                isLatestFavoriteBehaviorRelay.accept(!(isLatestFavoriteBehaviorRelay.value))
                guard let user = try keychainUseCase.getUser()
                else {
                    return .never()
                }
                return userService.markAsFavorite(
                    for: accountDetailsResponse.id,
                    with: user.session_id,
                    mediaType: "movie",
                    mediaId: latestMovieId,
                    favorite: isLatestFavoriteBehaviorRelay.value
                )
            }
            .do(onError: { error in
                self.errorRelay.accept(error.localizedDescription)
            })
            .map { _ in }
            .asDriver(onErrorJustReturn: ())
                    
        let isLatestMovieFavorite = isLatestFavoriteBehaviorRelay.asDriver(onErrorJustReturn: false)
                    
        let loadLatestMovie = movieService.getLatest()
            .do { getLatestResponse in
                let latestMovie = LatestMovie(
                    adult: getLatestResponse.adult,
                    genres: getLatestResponse.genres.map({ genre in
                        genre.name
                    }),
                    id: getLatestResponse.id,
                    imagePath: getLatestResponse.poster_path,
                    title: getLatestResponse.title,
                    isFavorite: false)
                self.latestMovieId = getLatestResponse.id
                self.showLatestMovieRelay.accept(latestMovie)
            } onError: { [errorRelay] error in
                errorRelay.accept(error.localizedDescription)
            }
            .map { _ in }
            .asObservable()
        
        let loadVideoKey = input.playButtonTap
            .flatMapLatest { _ -> Driver<Void> in
                return self.getVideoKey()
            }
            .do(onError: { [weak self] error in
                self?.errorRelay.accept(error.localizedDescription)
            })
            .map { _ in }
            .asDriver(onErrorJustReturn: ())

        let loadFirstPagePopularMovies = self.loadPopularMovies(on: 1)
                
        let loadNextPage = input.loadNextPage
            .flatMapLatest { (_, indexPath) -> Observable<Void> in
                if !self.popularMovies.isEmpty &&
                    self.popularMovies[indexPath.row].id ==
                    self.popularMovies[self.popularMovies.count - 2].id {
                    return self.loadPopularMovies(on: self.popularMoviesPage)
                } else {
                    return Observable.just(())
                }
            }
                
        let loadMovies = Observable
                .zip(loadLatestMovie, loadFirstPagePopularMovies, loadNextPage)
                .map { _ in }
                .asDriver(onErrorJustReturn: ())
        
        let showLatestMovie = showLatestMovieRelay
            .asDriver(onErrorJustReturn: LatestMovie(
                adult: false, genres: [], id: 0, imagePath: "", title: "", isFavorite: false)
            )
        
        let showPopularMovies =  showPopularMoviesRelay
            .asDriver(onErrorJustReturn: [Movie]())
        
        let showMovieDetails = input.movieCoverTap
            .do(onNext: { [coordinator] index in
                coordinator.coordinateToMovieDetails(of: self.popularMovies[index.row].id)
            })
            .map { _ in }
            .asDriver(onErrorDriveWith: .never())
        
        let videoKey = movieVideoKeyRelay.skip(1).asDriver(onErrorJustReturn: "")
        let error = errorRelay.asDriver(onErrorJustReturn: "Unknown error")
        
        return Output(openProfile: openProfile,
                      addLatestToFavorites: addToFavorites,
                      isLatestMovieFavorite: isLatestMovieFavorite,
                      loadMovies: loadMovies,
                      showLatestMovie: showLatestMovie,
                      loadVideoKey: loadVideoKey,
                      videoKey: videoKey,
                      showPopularMovies: showPopularMovies,
                      showMovieDetails: showMovieDetails,
                      error: error)
    }
    
    private func getVideoKey() -> Driver<Void> {
        return movieService.getVideos(for: self.latestMovieId)
            .do(onSuccess: { getVideosResponse in
                guard let videoKey = getVideosResponse.results.first?.key else {
                    self.movieVideoKeyRelay.accept("")
                    return
                }
                self.movieVideoKeyRelay.accept(videoKey)
            }, onError: { error in
                self.errorRelay.accept(error.localizedDescription)
            })
            .map { _ in }
            .asDriver(onErrorJustReturn: ())
    }
    
    private func loadPopularMovies(on page: Int) -> Observable<Void> {
       return self.movieService.getPopular(page: self.popularMoviesPage)
            .asObservable()
            .flatMap { moviesResultsResponse -> Observable<Void> in
                let transformedResults = moviesResultsResponse.results.map({ response in
                    Movie(id: response.id,
                          imagePath: response.poster_path,
                          isFavorite: false)
                })
                self.popularMovies += transformedResults

                if moviesResultsResponse.page < moviesResultsResponse.total_pages {
                    self.popularMoviesPage += 1
                } else {
                    self.popularMoviesPage = 1
                }
                
                return Observable.from(moviesResultsResponse.results)
                    .flatMap { movieResponse -> Driver<Void> in
                        guard let user = try self.keychainUseCase.getUser()
                        else {
                            return .never()
                        }
                        return self.getStatus(for: user.session_id, movieId: movieResponse.id)
                    }
            }
            .do(onError: { [errorRelay] error in
                errorRelay.accept(error.localizedDescription)
            })
            .asObservable()
    }

    private func getStatus(for userId: String, movieId: Int) -> Driver<Void> {
        return userService.isFavorite(for: userId, movieId: movieId)
            .do {  [showPopularMoviesRelay] response in
                guard let movieIndex = self.popularMovies.firstIndex(where: {$0.id == response.id})
                else {
                    return
                }
                var updatedMovie = self.popularMovies[movieIndex]
                updatedMovie.markAs(favorite: response.favorite)
                self.popularMovies[movieIndex] = updatedMovie
                showPopularMoviesRelay.accept(self.popularMovies)
            }
            .map { _ in }
            .asDriver(onErrorJustReturn: ())
    }
}
