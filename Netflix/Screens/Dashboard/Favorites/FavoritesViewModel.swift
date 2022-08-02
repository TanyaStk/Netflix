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
        let showingTrigger: Observable<Void>
        let showFavoriteMovies: Driver<[Movie]>
        let switchToComingSoon: Driver<Void>
        let isFavoritesEmpty: Driver<Bool>
        let showMovieDetails: Driver<Void>
        let error: Driver<String>
    }
    
    private let showFavoriteMoviesSubject = PublishSubject<[Movie]>()
    private let isFavoritesEmptyRelay = BehaviorRelay<Bool>(value: true)
    private let errorRelay = PublishRelay<String>()
    
    private let coordinator: FavoritesCoordinator
    private let service: UserInfoProvider
    private let keychainUseCase: KeychainUseCase
    private var favoriteMovies = [Movie]()
    
    init(coordinator: FavoritesCoordinator,
         service: UserInfoProvider,
         keychainUseCase: KeychainUseCase) {
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
            .asObservable()
            .materialize()
            .do { [unowned self] materializedEvent in
                switch materializedEvent {
                case let .next(moviesResultsResponse):
                    self.favoriteMovies = moviesResultsResponse.results.map({ movie in
                        Movie(id: movie.id, imagePath: movie.poster_path, isFavorite: true)
                    })
                    self.showFavoriteMoviesSubject.onNext(self.favoriteMovies)
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
        
        let showFavoriteMovies = showFavoriteMoviesSubject.asDriver(onErrorJustReturn: [Movie]())

        let switchToComingSoon = input.switchButtonTap
            .do(onNext: { [coordinator] in
                coordinator.coordinateToComingSoon()
            })
            .asDriver(onErrorJustReturn: ())
                
        let deleteFromFavorites = input.deleteFromFavorites
            .flatMap { [service] movieIndex -> Single<MarkAsFavoriteResponse> in
                guard let user = try self.keychainUseCase.getUser()
                else {
                    return .never()
                }
                let dislikedMovieId = self.favoriteMovies[movieIndex.row].id
                self.favoriteMovies.remove(at: movieIndex.row)
                self.showFavoriteMoviesSubject.onNext(self.favoriteMovies)
                return service.markAsFavorite(for: user.session_id,
                                              mediaType: "movie",
                                              mediaId: dislikedMovieId,
                                              favorite: false)
            }
            .do(onError: { error in
                self.errorRelay.accept(error.localizedDescription)
            })
            .map { _ in }
            .asDriver(onErrorJustReturn: ())
                
        let isFavoritesEmpty = isFavoritesEmptyRelay.asDriver(onErrorJustReturn: true)
        
        let showMovieDetails = input.movieCoverTap
            .do(onNext: { [weak self] index in
                self?.coordinator.coordinateToMovieDetails(of: self?.favoriteMovies[index.item].id ?? 0)
            })
            .map { _ in }
            .asDriver(onErrorDriveWith: .never())
        
        let showingTrigger = Observable.merge(loadFavoriteMovies.asObservable(),
                                              deleteFromFavorites.asObservable(),
                                              showMovieDetails.asObservable())
                    
        let error = errorRelay.asDriver(onErrorJustReturn: "Unknown error")
                    
        return Output(showingTrigger: showingTrigger,
                      showFavoriteMovies: showFavoriteMovies,
                      switchToComingSoon: switchToComingSoon,
                      isFavoritesEmpty: isFavoritesEmpty,
                      showMovieDetails: showMovieDetails,
                      error: error)
        }
}
