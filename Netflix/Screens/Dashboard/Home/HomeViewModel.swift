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
        let profileButtonTap: Observable<Void>
        let likeButtonTap: Observable<Void>
        let isAppLoaded: Observable<Bool>
        let movieCoverTap: Observable<IndexPath>
    }
    
    struct Output {
        let openProfile: Driver<Void>
        let addLatestToFavorites: Driver<Void>
        let isLatestMovieFavorite: Driver<Bool>
        let loadMovies: Driver<Void>
        let showLatestMovie: Driver<LatestMovie>
        let showPopularMovies: Driver<[Movie]>
        let showMovieDetails: Driver<Void>
        let error: Driver<String>
    }
    
    private let showLatestMovieSubject = PublishSubject<LatestMovie>()
    private let showPopularMoviesSubject = PublishSubject<[Movie]>()
    private let isFavoriteBehaviorRelay = BehaviorRelay(value: false)
    private let errorRelay = PublishRelay<String>()
    
    private let coordinator: HomeCoordinator
    private let movieService: MoviesProvider
    private let userService: UserInfoProvider
    private let keychainUseCase: KeychainUseCase

    private var popularMovies = [Movie]()
    private var movieId = 0
    
    init(coordinator: HomeCoordinator,
         movieService: MoviesProvider,
         userService: UserInfoProvider,
         keychainUseCase: KeychainUseCase) {
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
                    
        let zippedRequests = Observable.zip(movieService.getLatest().asObservable(),
                                            movieService.getPopular().asObservable())
                    
        let loadMovies = input.isAppLoaded
            .flatMap { _ in zippedRequests.materialize() }
            .do { [unowned self] materializedEvent in
                switch materializedEvent {
                case let .next((getLatestResponse, moviesResultsResponse)):
                    let latestMovie = LatestMovie(id: getLatestResponse.id,
                                                  imagePath: getLatestResponse.poster_path,
                                                  title: getLatestResponse.title,
                                                  isFavorite: isFavoriteBehaviorRelay.value)
                    self.movieId = latestMovie.id
                    self.showLatestMovieSubject.onNext(latestMovie)
                    self.popularMovies = moviesResultsResponse.results.map({ movie in
                        Movie(id: movie.id, imagePath: movie.poster_path, isFavorite: false)
                    })
                    self.showPopularMoviesSubject.onNext(self.popularMovies)
                case let .error(error):
                    self.errorRelay.accept(error.localizedDescription)
                case .completed:
                    break
                }
            }
            .map { _ in }
            .asDriver(onErrorJustReturn: ())
        
        let showLatestMovie = showLatestMovieSubject
            .asDriver(onErrorJustReturn: LatestMovie(id: 0, imagePath: "", title: "", isFavorite: false))
        
        let showPopularMovies =  showPopularMoviesSubject
            .asDriver(onErrorJustReturn: [Movie]())
        
        let showMovieDetails = input.movieCoverTap
            .do(onNext: { [weak self] index in
                self?.coordinator.coordinateToMovieDetails(of: self?.popularMovies[index.item].id ?? 0)
            })
            .map { _ in }
            .asDriver(onErrorDriveWith: .never())
        
        let error = errorRelay.asDriver(onErrorJustReturn: "Unknown error")
        
        return Output(openProfile: openProfile,
                      addLatestToFavorites: addToFavorites,
                      isLatestMovieFavorite: isFavorite,
                      loadMovies: loadMovies,
                      showLatestMovie: showLatestMovie,
                      showPopularMovies: showPopularMovies,
                      showMovieDetails: showMovieDetails,
                      error: error)
    }
}
