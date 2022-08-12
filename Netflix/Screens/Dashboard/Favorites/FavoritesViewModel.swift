//
//  FavoritesViewModel.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 29.07.2022.
//

import Foundation
import RxSwift
import RxCocoa

class FavoritesViewModel: ViewModel {
    
    struct Input {
        let isViewLoaded: Observable<Bool>
        let switchButtonTap: Observable<Void>
        let deleteFromFavorites: Observable<IndexPath>
        let movieCoverTap: Observable<IndexPath>
    }
    
    struct Output {
        let showingTrigger: Driver<Void>
        let showFavoriteMovies: Driver<[Movie]>
        let switchToComingSoon: Driver<Void>
        let isFavoritesEmpty: Driver<Bool>
        let showMovieDetails: Driver<Void>
        let error: Driver<String>
    }
    
    private let showFavoriteMoviesRelay = BehaviorRelay(value: [Movie]())
    private let isFavoritesEmptyRelay = BehaviorRelay<Bool>(value: true)
    private let errorRelay = PublishRelay<String>()
    
    private let coordinator: FavoritesCoordinator
    private let service: UserInfoProvider
    private let keychainUseCase: Keychain
    private var favoriteMovies = [Movie]()
    
    init(coordinator: FavoritesCoordinator,
         service: UserInfoProvider,
         keychainUseCase: Keychain) {
        self.coordinator = coordinator
        self.service = service
        self.keychainUseCase = keychainUseCase
    }
    
    func transform(_ input: Input) -> Output {
        let loadFavoriteMovies = input.isViewLoaded
            .flatMap { [service] _ -> Single<MoviesResultsResponse> in
                guard let user = try self.keychainUseCase.getUser()
                else {
                    return .never()
                }
                return service.getFavoriteMovies(for: user.session_id)
            }
            .asObservable().materialize()
            .do { [unowned self] materializedEvent in
                switch materializedEvent {
                case let .next(moviesResultsResponse):
                    self.favoriteMovies = moviesResultsResponse.results.map({ movie in
                        Movie(id: movie.id, imagePath: movie.poster_path, isFavorite: true)
                    })
                    self.showFavoriteMoviesRelay.accept(self.favoriteMovies)
                    if !self.favoriteMovies.isEmpty {
                        self.isFavoritesEmptyRelay.accept(false)
                    }
                case let .error(error):
                    self.errorRelay.accept(error.localizedDescription)
                case .completed:
                    break
                }
            }
            .map { _ in }
            .asDriver(onErrorJustReturn: ())
        
        let showFavoriteMovies = showFavoriteMoviesRelay.asDriver(onErrorJustReturn: [Movie]())

        let switchToComingSoon = input.switchButtonTap
            .do(onNext: { [coordinator] in
                coordinator.coordinateToComingSoon()
            })
            .asDriver(onErrorJustReturn: ())
                
        var dislikedMovieId = 0
                
        let deleteFromFavorites = input.deleteFromFavorites
            .flatMap { [service, keychainUseCase, showFavoriteMoviesRelay] movieIndex -> Single<AccountDetailsResponse> in
                guard let user = try keychainUseCase.getUser()
                else {
                    return .never()
                }
                dislikedMovieId = self.favoriteMovies[movieIndex.row].id
                self.favoriteMovies.remove(at: movieIndex.row)
                print(self.favoriteMovies)
                showFavoriteMoviesRelay.accept(self.favoriteMovies)
                return service.getAccountDetails(with: user.session_id)
            }
            .flatMap { [service, keychainUseCase] accountDetailsResponse -> Single<MarkAsFavoriteResponse> in
                guard let user = try keychainUseCase.getUser()
                else {
                    return .never()
                }
                return service.markAsFavorite(
                    for: accountDetailsResponse.id,
                    with: user.session_id,
                    mediaType: "movie",
                    mediaId: dislikedMovieId,
                    favorite: false
                )
            }
            .do(onError: { error in
                self.errorRelay.accept(error.localizedDescription)
            })
            .map { _ in }
            .asDriver(onErrorJustReturn: ())
                
        let isFavoritesEmpty = isFavoritesEmptyRelay.asDriver(onErrorJustReturn: true)
        
        let showMovieDetails = input.movieCoverTap
            .do(onNext: { index in
                self.coordinator.coordinateToMovieDetails(of: self.favoriteMovies[index.row].id)
            })
            .map { _ in }
            .asDriver(onErrorDriveWith: .never())
        
        let showingTrigger = Driver.merge(loadFavoriteMovies, showMovieDetails, deleteFromFavorites)
                    
        let error = errorRelay.asDriver(onErrorJustReturn: "Unknown error")
                    
        return Output(showingTrigger: showingTrigger,
                      showFavoriteMovies: showFavoriteMovies,
                      switchToComingSoon: switchToComingSoon,
                      isFavoritesEmpty: isFavoritesEmpty,
                      showMovieDetails: showMovieDetails,
                      error: error)
        }
}
