import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientInstance {
  static final SupabaseClient _client = SupabaseClient(
    'https://faoaccqijwrgblcewkur.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZhb2FjY3FpandyZ2JsY2V3a3VyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTc1MzM4OTYsImV4cCI6MjAzMzEwOTg5Nn0.S4gGDdAdFyVSD7YKHUrCbL0Go5vrA8gcdQySEagjmwQ',
  );

  static SupabaseClient get client => _client;
}
