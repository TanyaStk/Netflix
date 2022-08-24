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
        let loadMovies: Driver<Void>
        let openProfile: Driver<Void>
        let addLatestToFavorites: Driver<Void>
        let isLatestMovieFavorite: Driver<Bool>
        let showLatestMovie: Driver<LatestMovie>
        let loadVideoKey: Driver<Void>
        let videoKey: Driver<String>
        let showPopularMovies: Driver<[Movie]>
        let showMovieDetails: Driver<Void>
        let error: Driver<String>
    }
    
    private let showLatestMovieRelay = BehaviorRelay<LatestMovie>(value: LatestMovie())
    private let showPopularMoviesRelay = BehaviorRelay<[Movie]>(value: [Movie]())
    private let isLatestFavoriteBehaviorRelay = BehaviorRelay(value: false)
    private let movieVideoKeyRelay = BehaviorRelay(value: "")
    private let errorRelay = PublishRelay<String>()
    
    private let coordinator: HomeCoordinator
    private let moviesProvider: MoviesProviderProtocol
    private let userInfoProvider: UserInfoProvider
    private let keychainUseCase: KeychainProtocol
    
    private var favoriteMovies = [Int]()
    private var popularMoviesPage = 1
    private var popularMovies = [Movie]()
    private var latestMovieId = 0
    
    init(coordinator: HomeCoordinator,
         moviesProvider: MoviesProviderProtocol,
         userInfoProvider: UserInfoProvider,
         keychainUseCase: KeychainProtocol) {
        self.coordinator = coordinator
        self.moviesProvider = moviesProvider
        self.userInfoProvider = userInfoProvider
        self.keychainUseCase = keychainUseCase
    }
    
    func transform(_ input: Input) -> Output {
        let openProfile = input.profileButtonTap
            .do(onNext: { [weak self] _ in
                self?.coordinator.coordinateToProfile()
            })
            .asDriver(onErrorDriveWith: .never())
                
        let loadFavorites = input.viewDidLoad
                .flatMap { [userInfoProvider] _ -> Single<MoviesResultsResponse> in
                    guard let user = try self.keychainUseCase.getUser()
                    else {
                        return .never()
                    }
                    return userInfoProvider.getFavoriteMovies(for: user.session_id)
                }.asObservable().materialize()
            .do { [unowned self] materializedEvent in
                switch materializedEvent {
                case let .next(moviesResultsResponse):
                    self.favoriteMovies = moviesResultsResponse.results.map({ movie in
                        movie.id
                    })
                case let .error(error):
                    self.errorRelay.accept(error.localizedDescription)
                case .completed:
                    break
                }
            }
            .map { _ in }
            .asObservable()
                
        let addToFavorites = input.likeButtonTap
            .flatMapLatest { [userInfoProvider, keychainUseCase] _ -> Single<AccountDetailsResponse> in
                guard let user = try keychainUseCase.getUser()
                else {
                    return .never()
                }
                return userInfoProvider.getAccountDetails(with: user.session_id)
            }
            .flatMap { [userInfoProvider, keychainUseCase, latestMovieId] accountDetailsResponse -> Single<MarkAsFavoriteResponse> in
                self.isLatestFavoriteBehaviorRelay.accept(!(self.isLatestFavoriteBehaviorRelay.value))
                guard let user = try keychainUseCase.getUser()
                else {
                    return .never()
                }
                return userInfoProvider.markAsFavorite(
                    for: accountDetailsResponse.id,
                    with: user.session_id,
                    mediaType: "movie",
                    mediaId: latestMovieId,
                    favorite: self.isLatestFavoriteBehaviorRelay.value
                )
            }
            .do(onError: { error in
                self.errorRelay.accept(error.localizedDescription)
            })
            .map { _ in }
            .asDriver(onErrorJustReturn: ())
                    
        let isLatestMovieFavorite = isLatestFavoriteBehaviorRelay.asDriver(onErrorJustReturn: false)
                    
        let loadLatestMovie = moviesProvider.getLatest()
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
        
        let loadFirstPageOfPopularMovies = self.loadPopularMovies(on: 1)
                
        let loadNextPageOfPopularMovies = input.loadNextPage
            .flatMapLatest { (_, indexPath) -> Observable<Void> in
                if !self.popularMovies.isEmpty &&
                    self.popularMovies[indexPath.item].id ==
                    self.popularMovies[self.popularMovies.count - 2].id {
                    return self.loadPopularMovies(on: self.popularMoviesPage)
                } else {
                    return Observable.just(())
                }
            }
        
        let loadVideoKey = input.playButtonTap
            .flatMapLatest { _ -> Driver<Void> in
                return self.getVideoKey()
            }
            .do(onError: { [weak self] error in
                self?.errorRelay.accept(error.localizedDescription)
            })
            .map { _ in }
            .asDriver(onErrorJustReturn: ())
                
        let loadPopularAndLatest = Observable
            .merge(loadFirstPageOfPopularMovies,
                    loadLatestMovie,
                    loadNextPageOfPopularMovies)
        
        let loadMovies = Observable
                .concat(loadFavorites, loadPopularAndLatest)
                .map { _ in }
                .asDriver(onErrorJustReturn: ())
        
        let showLatestMovie = showLatestMovieRelay
            .asDriver(onErrorJustReturn: LatestMovie())
        
        let showPopularMovies = showPopularMoviesRelay
            .asDriver(onErrorJustReturn: [])
        
        let showMovieDetails = input.movieCoverTap
            .do(onNext: { [coordinator] index in
                coordinator.coordinateToMovieDetails(of: self.popularMovies[index.row].id)
            })
            .map { _ in }
            .asDriver(onErrorDriveWith: .never())
        
        let videoKey = movieVideoKeyRelay.skip(1).asDriver(onErrorJustReturn: "")
        let error = errorRelay.asDriver(onErrorJustReturn: "Unknown error")
        
        return Output(loadMovies: loadMovies,
                      openProfile: openProfile,
                      addLatestToFavorites: addToFavorites,
                      isLatestMovieFavorite: isLatestMovieFavorite,
                      showLatestMovie: showLatestMovie,
                      loadVideoKey: loadVideoKey,
                      videoKey: videoKey,
                      showPopularMovies: showPopularMovies,
                      showMovieDetails: showMovieDetails,
                      error: error)
    }
    
    private func getVideoKey() -> Driver<Void> {
        return moviesProvider.getVideos(for: self.latestMovieId)
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
        return self.moviesProvider.getPopular(page: page)
            .do { moviesResultsResponse in
                let transformedResults = moviesResultsResponse.results.map({ response -> Movie in
                    let isFavoriteStatus = self.favoriteMovies.contains(response.id)
                    return Movie(id: response.id,
                                 imagePath: response.poster_path,
                                 isFavorite: isFavoriteStatus)
                })
                self.popularMovies += transformedResults
                self.showPopularMoviesRelay.accept(self.popularMovies)
                
                if moviesResultsResponse.page < moviesResultsResponse.total_pages {
                    self.popularMoviesPage += 1
                } else {
                    self.popularMoviesPage = 1
                }
            }
            onError: { [errorRelay] error in
                errorRelay.accept(error.localizedDescription)
            }
            .map {_ in }
            .asObservable()
    }
}
