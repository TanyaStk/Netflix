//
//  ComingSoonViewModel.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 02.08.2022.
//

import Foundation
import RxSwift
import RxCocoa

class ComingSoonViewModel: ViewModel {
    
    struct Input {
        let isViewLoaded: Observable<Bool>
        let searchQuery: Observable<String>
        let cancelSearching: Observable<Void>
        let upcomingMovieCoverTap: Observable<IndexPath>
        let searchingResultsMovieCoverTap: Observable<IndexPath>
    }

    struct Output {
        let loadMovies: Observable<Void>
        let showUpcomingMovies: Driver<[Movie]>
        let showSearchingResults: Driver<[Movie]>
        let showUpcomingMovieDetails: Driver<Void>
        let showSearchingMovieDetails: Driver<Void>
        let isHiddenUpcoming: Driver<Bool>
        let error: Driver<String>
    }

    private let upcomingMoviesSubject = PublishSubject<[Movie]>()
    private let searchingResultsSubject = PublishSubject<[Movie]>()
    private let isHiddenUpcomingBehaviorRelay = BehaviorRelay(value: false)
    private let errorRelay = PublishRelay<String>()

    private let coordinator: ComingSoonCoordinator
    private let service: MoviesProvider
    private var upcomingMovies = [Movie]()
    private var searchingResults = [Movie]()

    init(coordinator: ComingSoonCoordinator, service: MoviesProvider) {
        self.coordinator = coordinator
        self.service = service
    }

    func transform(_ input: Input) -> Output {
        let loadUpcomingMovies = Observable
            .merge(input.isViewLoaded, input.cancelSearching.map { _ in true })
            .flatMap { [service] _ in
                service.getUpcoming()
            }
            .asObservable().materialize()
            .do { [unowned self] materializedEvent in
                switch materializedEvent {
                case let .next(moviesResultsResponse):
                    self.isHiddenUpcomingBehaviorRelay.accept(false)
                    self.upcomingMovies = moviesResultsResponse.results.map { movie in
                        Movie(id: movie.id, imagePath: movie.poster_path, isFavorite: false)
                    }
                    self.upcomingMoviesSubject.onNext(self.upcomingMovies)
                case let .error(error):
                    self.errorRelay.accept(error.localizedDescription)
                case .completed:
                    break
                }
            }
            .map { _ in }
            .asDriver(onErrorJustReturn: ())
        
        let showUpcomingMovies = upcomingMoviesSubject.asDriver(onErrorJustReturn: [Movie]())
        
        let loadSearchResults = input.searchQuery
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .flatMap { [service] query in
                service.search(for: query)
            }
            .asObservable().materialize()
            .do { [unowned self] materializedEvent in
                switch materializedEvent {
                case let .next(searchingResultsResponse):
                    self.isHiddenUpcomingBehaviorRelay.accept(true)
                    self.searchingResults = searchingResultsResponse.results.map { movie in
                        Movie(id: movie.id, imagePath: movie.poster_path, isFavorite: false)
                    }
                    self.searchingResultsSubject.onNext(self.searchingResults)
                case let .error(error):
                    self.errorRelay.accept(error.localizedDescription)
                case .completed:
                    break
                }
            }
            .map { _ in }
            .asDriver(onErrorJustReturn: ())
        
        let showSearchingResults = searchingResultsSubject.asDriver(onErrorJustReturn: [Movie]())
        
        let loadMovies = Observable.merge(loadUpcomingMovies.asObservable(),
                                          loadSearchResults.asObservable())
        
        let showUpcomingMovieDetails = input.upcomingMovieCoverTap
            .do(onNext: { index in
                self.coordinator.coordinateToMovieDetails(of: self.upcomingMovies[index.item].id)
            })
            .map { _ in }
            .asDriver(onErrorDriveWith: .never())
        
        let showSearchingMovieDetails = input.searchingResultsMovieCoverTap
            .do(onNext: { index in
                self.coordinator.coordinateToMovieDetails(of: self.searchingResults[index.item].id)
            })
            .map { _ in }
            .asDriver(onErrorDriveWith: .never())
        
        let isHiddenUpcoming = isHiddenUpcomingBehaviorRelay.asDriver()

        let error = errorRelay.asDriver(onErrorJustReturn: "Unknown error")

        return Output(loadMovies: loadMovies,
                      showUpcomingMovies: showUpcomingMovies,
                      showSearchingResults: showSearchingResults,
                      showUpcomingMovieDetails: showUpcomingMovieDetails,
                      showSearchingMovieDetails: showSearchingMovieDetails,
                      isHiddenUpcoming: isHiddenUpcoming,
                      error: error)
    }
}
