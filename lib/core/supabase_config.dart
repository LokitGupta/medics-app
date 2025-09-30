import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://yekuhglffaqcytjeborh.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlla3VoZ2xmZmFxY3l0amVib3JoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg3MDc2NTksImV4cCI6MjA3NDI4MzY1OX0.bU3VMHo4bMZzTRZLywJPp7l3E9Pj51_5PMwRU09OhIE';

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
