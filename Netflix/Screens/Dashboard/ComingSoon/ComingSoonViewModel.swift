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
        let loadUpcomingNextPage: Observable<(cell: UICollectionViewCell, at: IndexPath)>
        let loadSearchingNextPage: Observable<(cell: UICollectionViewCell, at: IndexPath)>
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

    private let upcomingMoviesSubject = BehaviorRelay<[Movie]>(value: [Movie]())
    private let searchingResultsSubject = BehaviorRelay<[Movie]>(value: [Movie]())
    private let isHiddenUpcomingBehaviorRelay = BehaviorRelay(value: false)
    private let errorRelay = PublishRelay<String>()

    private let coordinator: ComingSoonCoordinator
    private let movieService: MoviesProvider
    private let userService: UserInfoProvider
    private let keychainUseCase: KeychainUseCase
    
    private var upcomingMovies = [Movie]()
    private var upcomingPage = 1
    private var searchingResults = [Movie]()
    private var searchingPage = 1

    init(coordinator: ComingSoonCoordinator,
         movieService: MoviesProvider,
         userService: UserInfoProvider,
         keychainUseCase: KeychainUseCase) {
        self.coordinator = coordinator
        self.movieService = movieService
        self.userService = userService
        self.keychainUseCase = keychainUseCase
    }

    func transform(_ input: Input) -> Output {
        let loadFirstPageOfUpcomingMovies = Observable
            .merge(input.isViewLoaded, input.cancelSearching.map { _ in true })
            .flatMap { _ in
                self.loadUpcoming(on: 1)
            }
        
        let loadNextPageOfUpcomingMovies = input.loadUpcomingNextPage
            .flatMapFirst {[upcomingMovies] (_, indexPath) -> Driver<Void> in
                print(indexPath.row)
                if !upcomingMovies.isEmpty &&
                    upcomingMovies[indexPath.row].id == upcomingMovies[upcomingMovies.count - 1].id {
                    return self.loadUpcoming(on: self.upcomingPage)
                } else {
                    return .just(())
                }
            }
        
        let showUpcomingMovies = upcomingMoviesSubject.asDriver(onErrorJustReturn: [Movie]())
        
        let loadSearchResults = input.searchQuery
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .flatMap { [movieService] query in
                movieService.search(for: query)
            }
            .asObservable().materialize()
            .do { [unowned self] materializedEvent in
                switch materializedEvent {
                case let .next(searchingResultsResponse):
                    self.isHiddenUpcomingBehaviorRelay.accept(true)
                    self.searchingResults = searchingResultsResponse.results.map { movie in
                        Movie(id: movie.id, imagePath: movie.poster_path, isFavorite: false)
                    }
                    self.searchingResultsSubject.accept(self.searchingResults)
                case let .error(error):
                    self.errorRelay.accept(error.localizedDescription)
                case .completed:
                    break
                }
            }
            .map { _ in }
            .asDriver(onErrorJustReturn: ())
        
        let showSearchingResults = searchingResultsSubject.asDriver(onErrorJustReturn: [Movie]())
        
        let loadMovies = Observable.merge(loadFirstPageOfUpcomingMovies.asObservable(),
                                          loadNextPageOfUpcomingMovies.asObservable(),
                                          loadSearchResults.asObservable())
        
        let showUpcomingMovieDetails = input.upcomingMovieCoverTap
            .do(onNext: { index in
                self.coordinator.coordinateToMovieDetails(of: self.upcomingMovies[index.row].id)
            })
            .map { _ in }
            .asDriver(onErrorDriveWith: .never())
        
        let showSearchingMovieDetails = input.searchingResultsMovieCoverTap
            .do(onNext: { index in
                self.coordinator.coordinateToMovieDetails(of: self.searchingResults[index.row].id)
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
    
    private func loadUpcoming(on page: Int) -> Observable<Void> {
        return self.movieService.getUpcoming(page: page)
            .asObservable()
            .flatMap { moviesResultsResponse -> Observable<Void> in
                let transformedResults = moviesResultsResponse.results.map({ response in
                    Movie(id: response.id,
                          imagePath: response.poster_path,
                          isFavorite: false)
                })
                self.upcomingMovies += transformedResults
                self.upcomingMoviesSubject.accept(self.upcomingMovies)
                
                if moviesResultsResponse.page < moviesResultsResponse.total_pages {
                    self.upcomingPage += 1
                } else {
                    self.upcomingPage = 1
                }
                
                return Observable.from(moviesResultsResponse.results)
                    .flatMap { movieResponse -> Driver<Void> in
                        guard let user = try self.keychainUseCase.getUser()
                        else {
                            return .never()
                        }
//                        return self.getStatus(for: user.session_id, movieId: movieResponse.id)
                    }
            }
            .do(onError: { [errorRelay] error in
                errorRelay.accept(error.localizedDescription)
            })
                .asObservable()
    }
}
