import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import '../../../shared/data/models/movies/results.dart';

import '../../../shared/data/models/movies/now_playing.dart';
import '../../../shared/data/models/movies/popular.dart';
import '../../../shared/data/models/movies/searched_movies.dart';
import '../../../shared/data/models/movies/top_rated.dart';
import '../../../shared/data/models/movies/upcoming.dart';
import '../../../shared/data/repo/movies_repo/movies_repository.dart';
import '../../../shared/web_services/errors/api_result.dart';
import '../../../shared/web_services/errors/network_exceptions.dart';
import 'movies_state.dart';

class MoviesCubit extends Cubit<MoviesState> {
  MoviesRepository? moviesRepository;

  MoviesCubit(
    this.moviesRepository,
  ) : super(MoviesStateIdle());
  List<Results>? nowPlayingMoviesList = [];
  List<Results>? topRatedMoviesList = [];
  List<Results>? popularMoviesList = [];
  List<Results>? upComingMoviesList = [];
  List<Results>? allCategories = [];
  List<Results>? searchedMovies = [];

  int? index = 0;

  Future<void> emitNowPlayingMovies() async {
    try {
      emit(MoviesStateLoading());

      ApiResult<NowPlayingMovieModel?> response =
          await moviesRepository!.getMoviesPlayingNow();
      response.when(success: (nowPlayingMovieModel) {
        nowPlayingMoviesList = nowPlayingMovieModel!.results!.cast<Results>();

        nowPlayingMoviesList!.forEach((element) {
          if (!allCategories!.contains(element)) {
            allCategories!.add(element);
          }
        });
        debugPrint('${allCategories!.length}');

        emit(MoviesStateSuccess(nowPlayingMovieModel.results));
      }, failure: (NetworkExceptions networkExceptions) {
        emit(MoviesStateError(networkExceptions));
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> emitTopRatedMovies() async {
    try {
      emit(MoviesStateLoading());
      ApiResult<TopRatedMovieModel?> response =
          await moviesRepository!.getMoviesTopRated();
      response.when(success: (topRatedMovies) {
        topRatedMoviesList = topRatedMovies!.results!.cast<Results>();

        topRatedMoviesList?.forEach((element) {
          if (!allCategories!.contains(element)) {
            allCategories!.add(element);
          }
        });
        debugPrint('${allCategories!.length}');

        emit(MoviesStateSuccess(topRatedMovies.results));
      }, failure: (NetworkExceptions networkExceptions) {
        emit(MoviesStateError(networkExceptions));
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> emitMoviesPopular() async {
    try {
      emit(MoviesStateLoading());
      ApiResult<PopularMovieModel?> response =
          await moviesRepository!.getMoviesPopular();
      response.when(success: (popularMovies) {
        popularMoviesList = popularMovies!.results!.cast<Results>();

        popularMoviesList!.forEach((element) {
          if (!allCategories!.contains(element)) {
            allCategories!.add(element);
          }
        });
        debugPrint('${allCategories!.length}');
        emit(MoviesStateSuccess(popularMovies.results));
      }, failure: (NetworkExceptions networkExceptions) {
        emit(MoviesStateError(networkExceptions));
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> emitMoviesUpComing() async {
    try {
      emit(MoviesStateLoading());
      ApiResult<UpcomingMovieModel?> response =
          await moviesRepository!.getMoviesUpComing();
      response.when(success: (upComingMovies) {
        upComingMoviesList = upComingMovies!.results!.cast<Results>();

        upComingMoviesList!.forEach((element) {
          if (!allCategories!.contains(element)) {
            allCategories!.add(element);
          }
        });
        debugPrint('${allCategories!.length}');
        emit(MoviesStateSuccess(upComingMovies.results));
      }, failure: (NetworkExceptions networkExceptions) {
        emit(MoviesStateError(networkExceptions));
      });
    } catch (e) {
      print(e.toString());
    }
  }

  bool isSearching = false;
  final searchTextController = TextEditingController();

  Future<void> emitSearchedMovies(String query) async {
    try {
      emit(MoviesStateLoading());

      query = query.toLowerCase();

      ApiResult<SearchedMovies?> response =
          await moviesRepository!.getSearchedMovies(query);
      response.when(success: (searchedMoviesList) {
        searchedMovies = searchedMoviesList?.results;

        debugPrint('${searchedMovies!.length}');

        emit(MoviesStateSuccess(searchedMovies));
      }, failure: (NetworkExceptions networkExceptions) {
        emit(MoviesStateError(networkExceptions));
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void _startSearch(BuildContext context) {
    ModalRoute.of(context)!
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));
    isSearching = true;
    emit(MoviesStateSearchingStarted());
  }

  void _stopSearching() {
    _clearSearch();
    isSearching = false;
    emit(MoviesStateSearchingStopped());
  }

  void _clearSearch() {
    searchTextController.clear();
  }
}
