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
        let showLatestMovie: Driver<GetLatestResponse>
        let showPopularMovies: Driver<[MovieResponse]>
        let showMovieDetails: Driver<Void>
        let error: Driver<String>
    }
    
    private let showLatestMovieSubject = PublishSubject<GetLatestResponse>()
    private let showPopularMoviesSubject = PublishSubject<[MovieResponse]>()
    private let isFavoriteBehaviorRelay = BehaviorRelay(value: false)
    private let errorRelay = PublishRelay<String>()
    
    private let coordinator: HomeCoordinator
    private let service: MoviesProvider
    
    init(coordinator: HomeCoordinator, service: MoviesProvider) {
        self.coordinator = coordinator
        self.service = service
    }
    
    func transform(_ input: Input) -> Output {
        let openProfile = input.profileButtonTap
            .do(onNext: { [weak self] _ in
                self?.coordinator.coordinateToProfile()
            })
                .asDriver(onErrorDriveWith: .never())
                
        let addToFavorites = input.likeButtonTap
            .do(onNext: { [weak self] _ in
                print("Like me")
                self?.isFavoriteBehaviorRelay.accept(!(self?.isFavoriteBehaviorRelay.value ?? false))
            })
                .asDriver(onErrorDriveWith: .never())
                    
        let isFavorite = isFavoriteBehaviorRelay.asDriver(onErrorJustReturn: false)
                    
        let zippedRequests = Observable.zip(service.getLatest().asObservable(),
                                    service.getPopular().asObservable())
                    
        let loadMovies = input.isAppLoaded
            .flatMap { _ in zippedRequests.materialize() }
            .do { [unowned self] materializedEvent in
                switch materializedEvent {
                case let .next((getLatestResponse, moviesListResponse)):
                    self.showLatestMovieSubject.onNext(getLatestResponse)
                    self.showPopularMoviesSubject.onNext(moviesListResponse.results)
                case let .error(error):
                    self.errorRelay.accept(error.localizedDescription)
                case .completed:
                    break
                }
            }
            .map { _ in }
            .asDriver(onErrorJustReturn: ())
        
        let showLatestMovie = showLatestMovieSubject
            .asDriver(onErrorJustReturn: GetLatestResponse(id: 0, poster_path: "", title: ""))
        
        let showPopularMovies =  showPopularMoviesSubject
            .asDriver(onErrorJustReturn: [MovieResponse]())
        
        let showMovieDetails = input.movieCoverTap
            .do(onNext: { [weak self] _ in
                self?.coordinator.coordinateToMovieDetails()
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
