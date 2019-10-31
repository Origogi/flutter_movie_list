import 'dart:convert';

import 'package:flutter_list/network/cache.dart';
import 'package:flutter_list/network/data.dart';
import 'package:http/http.dart' as http;

class MovieDBApi {
  static final _KEY = '2bafb8eb9137df7d37ed1fe043ad7596';

  static final _URL_GENRE_LIST =
      "https://api.themoviedb.org/3/genre/movie/list";

  static String moviesForGenreURL(int genreId, int page) {
    return 'https://api.themoviedb.org/3/discover/movie?api_key=$_KEY'
        '&language=ko-KR'
        '&sort_by=popularity.desc'
        '&page=$page'
        '&with_genres=$genreId';
  }

  static String movieDetailsUrl(int movieId) {
    return 'https://api.themoviedb.org/3/movie/'
        '$movieId'
        '?api_key=$_KEY&append_to_response=credits,'
        'images'
        '&language=ko-KR';
  }

  static String moviePlayNowUrl() {
    return 'https://api.themoviedb.org/3/movie/now_playing'
        '?api_key=$_KEY'
        '&language=ko-KR'
        '&page=1/';
  }

  static String getGenresUrl() {
    return 'https://api.themoviedb.org/3/genre/movie/list'
        '?api_key=$_KEY'
        '&language=ko-KR';
  }

  static String movieSearchUrl(String query) {
    return 'https://api.themoviedb.org/3/search/movie'
        '?query=$query'
        '&language=ko-KR'
        '&api_key=$_KEY';
  }

  static Future<Movie> getDetailMovie(int id) async {
    if (CacheData.getMovieCache(id) != null) {
      return CacheData.getMovieCache(id);
    }

    http.Response response =
        await http.get(Uri.encodeFull(movieDetailsUrl(id)), headers: {
      "Content-type": "application/json",
    });
    Map responseMap = jsonDecode(response.body);
    var movie = Movie.fromJson(responseMap);

    CacheData.setMovieCache(movie);

    return movie;
  }

  static Future<List<Movie>> getDetailMovies(List<int> IDs) async {
    List<Movie> movies = [];

    for (int id in IDs) {
      if (CacheData.getMovieCache(id) != null) {
        movies.add(CacheData.getMovieCache(id));
        continue;
      }

      http.Response response =
          await http.get(Uri.encodeFull(movieDetailsUrl(id)), headers: {
        "Content-type": "application/json",
      });
      Map responseMap = jsonDecode(response.body);
      var movie = Movie.fromJson(responseMap);
      movies.add(movie);
    }
    return movies;
  }

  static Future<List<Movie>> getRelatedGenreMovies(int id) async {
    http.Response response =
        await http.get(Uri.encodeFull(moviesForGenreURL(id, 1)), headers: {
      "Content-type": "application/json",
    });
    Map responseMap = jsonDecode(response.body);
    var apiResponse = MovieDBApiResponse.fromJson(responseMap);

    return apiResponse.results;
  }

  static Future<List<Movie>> getPlayNow() async {
    http.Response response =
        await http.get(Uri.encodeFull(moviePlayNowUrl()), headers: {
      "Content-type": "application/json",
    });
    Map responseMap = jsonDecode(response.body);
    var apiResponse = MovieDBApiResponse.fromJson(responseMap);

    return apiResponse.results;
  }

  static Future<List<Movie>> searchMovies(String query) async {
    print(query);
    http.Response response =
        await http.get(Uri.encodeFull(movieSearchUrl(query)), headers: {
      "Content-type": "application/json",
    });

    print('hello :' + response.statusCode.toString());
    Map responseMap = jsonDecode(response.body);
    var apiResponse = MovieDBApiResponse.fromJson(responseMap);

    return apiResponse.results;
  }

  static Future<Map<int, String>> getGenres() async {
    if (CacheData.getGanreCache() != null &&
        CacheData.getGanreCache().isNotEmpty) {
      return CacheData.getGanreCache();
    }

    http.Response response =
        await http.get(Uri.encodeFull(getGenresUrl()), headers: {
      "Content-type": "application/json",
    });

    Map responseMap = jsonDecode(response.body);
    var apiResponse = GenresApiResponse.fromJson(responseMap);
    print(apiResponse.genresMap);

    CacheData.setGanreCache(apiResponse.genresMap);

    return apiResponse.genresMap;
  }
}
