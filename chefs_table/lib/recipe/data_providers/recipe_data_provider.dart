import 'dart:convert';
import 'dart:developer';
import 'package:chefs_table/recipe/models/recipeUpdateDto.dart';

import '../../review/models/review.dart';

import '../models/recipe.dart';
import 'package:http/http.dart' as http;

class RecipeDataProvider {
  static const String _baseUrl = "http://10.0.2.2:3001/recipes";
  final String jwtToken =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6IkRvbWluaWsiLCJzdWIiOjIsInJvbGVzIjpbImNoZWYiXSwiaWF0IjoxNjg1MDM1NDg2LCJleHAiOjE2ODUwMzkwODZ9.1fgVHnX08i08tTEEEeQK16smXwnR_n2xqLag5TA9f4A";
  late Map<String, String> header;
  RecipeDataProvider() {
    header = <String, String>{
      "Content-Type": "application/json",
      "Authorization": "Bearer $jwtToken"
    };
  }

  Future<Recipe> create(Recipe recipe) async {
    final http.Response response = await http.post(Uri.parse(_baseUrl),
        headers: header,
        body: jsonEncode({
          "title": recipe.title,
          "ingredients": recipe.ingredients,
          "procedure": recipe.procedure,
          "photo": recipe.photo,
          "time": recipe.time
        }));
    if (response.statusCode == 201) {
      return Recipe.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.body);
    }
  }

  Future<Recipe> update(int id, RecipeUpdateDto update) async {
    // final updateUser = {};
    // // if (title != null) {
    // //   updateUser[title] = title;
    // // }
    // // if (procedure != null) {
    // //   updateUser[procedure] = procedure;
    // // }
    // // if (ingredients != null) {
    // //   updateUser[ingredients] = ingredients;
    // // }
    // // if (photo != null) {
    // //   updateUser[photo] = photo;
    // // }
    String updatableJson = jsonEncode(<String, dynamic>{
      "title": update.title,
      "ingredients": update.ingredients,
      "procedure": update.procedure,
      "photo": update.photo,
      "time": update.time
    });
    print("from dp${inspect(updatableJson)}");
    final response = await http.patch(Uri.parse("$_baseUrl/$id"),
        headers: header, body: updatableJson);

    if ((response.statusCode / 100).floor() == 2) {
      return Recipe.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          (jsonDecode(response.body) as Map<String, dynamic>)["message"]);
    }
  }

  Future<Recipe> fetch(int id) async {
    final response = await http.get(Uri.parse("$_baseUrl/$id"));

    if (response.statusCode == 200) {
      return Recipe.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Fetching Recipe by id failed");
    }
  }

  Future<List<Recipe>> fetchAll() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      final recipes = jsonDecode(response.body) as List;
      return recipes.map((c) => Recipe.fromJson(c)).toList();
    } else {
      throw Exception("Could not fetch recipes");
    }
  }

  Future<void> delete(int id) async {
    final response =
        await http.delete(Uri.parse("$_baseUrl/$id"), headers: header);
    print("$_baseUrl/$id");
    print(response.statusCode);
    if (response.statusCode != 200) {
      throw Exception(
          (jsonDecode(response.body) as Map<String, dynamic>)["message"]);
    }
  }

  Future<List<Review>> getReviews(int id) async {
    final response = await http.get(Uri.parse("$_baseUrl/$id/reviews"));

    if (response.statusCode == 200) {
      final reviews = jsonDecode(response.body) as List;
      return reviews.map((c) => Review.fromJson(c)).toList();
    } else {
      throw Exception("Fetching Reviews by id failed");
    }
  }
}
