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
        let upcomingMovieCoverTap: Observable<IndexPath>
        let searchingResultsMovieCoverTap: Observable<IndexPath>
    }

    struct Output {
        let loadMovies: Driver<Void>
        let showUpcomingMovies: Driver<[Movie]>
        let showSearchingResults: Driver<[Movie]>
        let showUpcomingMovieDetails: Driver<Void>
        let showSearchingMovieDetails: Driver<Void>
        let isHiddenUpcoming: Driver<Bool>
        let error: Driver<String>
    }

    private let upcomingMoviesRelay = BehaviorRelay<[Movie]>(value: [Movie]())
    private let searchingResultsRelay = BehaviorRelay<[Movie]>(value: [Movie]())
    private let isHiddenUpcomingBehaviorRelay = BehaviorRelay(value: false)
    private let errorRelay = PublishRelay<String>()

    private let coordinator: ComingSoonCoordinator
    private let moviesProvider: MoviesProviderProtocol
    private let userService: UserInfoProvider
    private let keychainUseCase: KeychainProtocol
   
    private var favoriteMovies = [Int]()
    private var upcomingMovies = [Movie]()
    private var upcomingPage = 1
    private var searchingResults = [Movie]()

    init(coordinator: ComingSoonCoordinator,
         moviesProvider: MoviesProviderProtocol,
         userService: UserInfoProvider,
         keychainUseCase: KeychainProtocol) {
        self.coordinator = coordinator
        self.moviesProvider = moviesProvider
        self.userService = userService
        self.keychainUseCase = keychainUseCase
    }

    func transform(_ input: Input) -> Output {
        let loadFavorites = input.isViewLoaded
            .flatMap { [userService] _ -> Single<MoviesResultsResponse> in
                guard let user = try self.keychainUseCase.getUser()
                else {
                    return .never()
                }
                return userService.getFavoriteMovies(for: user.session_id)
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

        let loadFirstPageOfUpcomingMovies = Observable
            .merge(input.isViewLoaded, input.cancelSearching.map { _ in true })
            .flatMap { _ -> Observable<Void> in
                self.searchingResults = []
                self.searchingResultsRelay.accept(self.searchingResults)
                self.upcomingPage = 1
                return self.loadUpcoming(on: self.upcomingPage)
            }
        
        let loadNextPageOfUpcomingMovies = input.loadUpcomingNextPage
            .flatMapFirst { (_, indexPath) -> Observable<Void> in
                if !self.upcomingMovies.isEmpty &&
                    self.upcomingMovies[indexPath.item].id ==
                    self.upcomingMovies[self.upcomingMovies.count - 3].id {
                    return self.loadUpcoming(on: self.upcomingPage)
                } else {
                    return .just(())
                }
            }
                                        
        let loadSearchResults = input.searchQuery
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .flatMapLatest { [moviesProvider] query in
                moviesProvider.search(for: query, on: 1)
            }
            .asObservable().materialize()
            .do { [unowned self] materializedEvent in
                switch materializedEvent {
                case let .next(searchingResultsResponse):
                    self.isHiddenUpcomingBehaviorRelay.accept(true)
                    let transformedResults = searchingResultsResponse.results.map({ response -> Movie in
                        let isFavoriteStatus = self.favoriteMovies.contains(response.id)
                        return Movie(id: response.id,
                                     imagePath: response.poster_path,
                                     isFavorite: isFavoriteStatus)
                    })
                    self.searchingResults = transformedResults
                    self.searchingResultsRelay.accept(self.searchingResults)
                case let .error(error):
                    self.errorRelay.accept(error.localizedDescription)
                case .completed:
                    break
                }
            }
            .map { _ in }
            .asDriver(onErrorJustReturn: ())
        
        let showSearchingResults = searchingResultsRelay.asDriver(onErrorJustReturn: [Movie]())
        
        let loadUpcomingAndSearchResults = Observable
            .merge(loadFirstPageOfUpcomingMovies,
                   loadNextPageOfUpcomingMovies,
                   loadSearchResults.asObservable())
        
        let loadMovies = Observable
            .concat(loadFavorites, loadUpcomingAndSearchResults)
            .map { _ in }
            .asDriver(onErrorJustReturn: ())
        
        let showUpcomingMovies = upcomingMoviesRelay.asDriver(onErrorJustReturn: [Movie]())
        
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
    
    private func loadUpcoming(on page: Int) -> Observable<Void> {
        return self.moviesProvider.getUpcoming(page: page)
            .do { moviesResultsResponse in
                let transformedResults = moviesResultsResponse.results.map({ response -> Movie in
                    let isFavoriteStatus = self.favoriteMovies.contains(response.id)
                    return Movie(id: response.id,
                                 imagePath: response.poster_path,
                                 isFavorite: isFavoriteStatus)
                })
                self.upcomingMovies += transformedResults
                self.upcomingMoviesRelay.accept(self.upcomingMovies)
                self.isHiddenUpcomingBehaviorRelay.accept(false)
                
                if moviesResultsResponse.page < moviesResultsResponse.total_pages {
                    self.upcomingPage += 1
                } else {
                    self.upcomingPage = 1
                }
            }
            onError: { [errorRelay] error in
                errorRelay.accept(error.localizedDescription)
            }
            .map {_ in }
            .asObservable()
    }
}
