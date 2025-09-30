import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/supabase_config.dart';
import '../models/article.dart';

class ArticleNotifier extends StateNotifier<AsyncValue<List<Article>>> {
  ArticleNotifier() : super(const AsyncValue.loading()) {
    loadArticles();
  }

  final _client = SupabaseConfig.client;

  Future<void> loadArticles() async {
    try {
      final response = await _client
          .from('articles')
          .select()
          .order('published_at', ascending: false);

      final articles = (response as List)
          .map((json) => Article.fromJson(json))
          .toList();

      state = AsyncValue.data(articles);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<List<Article>> searchArticles(String query) async {
    try {
      final response = await _client
          .from('articles')
          .select()
          .or(
            'title.ilike.%$query%,content.ilike.%$query%,category.ilike.%$query%',
          )
          .order('published_at', ascending: false);

      return (response as List).map((json) => Article.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search articles: $e');
    }
  }
}

final articleProvider =
    StateNotifierProvider<ArticleNotifier, AsyncValue<List<Article>>>((ref) {
      return ArticleNotifier();
    });
