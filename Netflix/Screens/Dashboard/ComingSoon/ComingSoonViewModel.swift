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
        let movieCoverTap: Observable<IndexPath>
    }

    struct Output {
        let loadMovies: Observable<Void>
        let showUpcomingMovies: Driver<[Movie]>
        let showSearchingResults: Driver<[Movie]>
        let showMovieDetails: Driver<Void>
        let error: Driver<String>
    }

    private let upcomingMoviesSubject = PublishSubject<[Movie]>()
    private let searchingResultsSubject = PublishSubject<[Movie]>()
    private let errorRelay = PublishRelay<String>()

    private let coordinator: ComingSoonCoordinator
    private let service: MoviesProvider
    private var upcomingMovies = [Movie]()

    init(coordinator: ComingSoonCoordinator, service: MoviesProvider) {
        self.coordinator = coordinator
        self.service = service
    }

    func transform(_ input: Input) -> Output {
        let loadUpcomingMovies = input.isViewLoaded
            .flatMap { [service] _ in
                service.getUpcoming()
            }
            .asObservable().materialize()
            .do { [unowned self] materializedEvent in
                switch materializedEvent {
                case let .next(moviesResultsResponse):
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
                    let searchingResults = searchingResultsResponse.results.map { movie in
                        Movie(id: movie.id, imagePath: movie.poster_path, isFavorite: false)
                    }
                    self.searchingResultsSubject.onNext(searchingResults)
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
        
        let showMovieDetails = input.movieCoverTap
            .do(onNext: { index in
                self.coordinator.coordinateToMovieDetails(of: self.upcomingMovies[index.item].id)
            })
            .map { _ in }
            .asDriver(onErrorDriveWith: .never())

        let error = errorRelay.asDriver(onErrorJustReturn: "Unknown error")

        return Output(loadMovies: loadMovies,
                      showUpcomingMovies: showUpcomingMovies,
                      showSearchingResults: showSearchingResults,
                      showMovieDetails: showMovieDetails,
                      error: error)
    }
}
