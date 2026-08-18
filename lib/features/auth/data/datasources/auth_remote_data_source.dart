import 'package:gql/ast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hotel_booking_app/core/network/graphql_api_client.dart';
import 'package:hotel_booking_app/features/auth/domain/entities/auth_session.dart';
import 'package:hotel_booking_app/features/auth/domain/entities/user.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._apiClient);

  final GraphQLApiClient _apiClient;

  static final DocumentNode _loginMutation = gql(r'''
    mutation Login($input: LoginInput!) {
      login(input: $input) {
        accessToken
        user { id name email role }
      }
    }
  ''');

  static final DocumentNode _registerMutation = gql(r'''
    mutation Register($input: RegisterInput!) {
      register(input: $input) {
        accessToken
        user { id name email role }
      }
    }
  ''');

  static final DocumentNode _meQuery = gql(r'''
    query Me {
      me { id name email role }
    }
  ''');

  Future<AuthSession> login({required String email, required String password}) {
    return _authenticate(
      document: _loginMutation,
      operationName: 'login',
      input: <String, dynamic>{'email': email, 'password': password},
    );
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _authenticate(
      document: _registerMutation,
      operationName: 'register',
      input: <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
      },
    );
  }

  Future<User> fetchCurrentUser() async {
    final QueryResult result = await _apiClient.client.query(
      QueryOptions(document: _meQuery, fetchPolicy: FetchPolicy.networkOnly),
    );
    _throwIfFailed(result);
    return _mapUser(result.data?['me'] as Map<String, dynamic>);
  }

  Future<AuthSession> _authenticate({
    required DocumentNode document,
    required String operationName,
    required Map<String, dynamic> input,
  }) async {
    final QueryResult result = await _apiClient.client.mutate(
      MutationOptions(
        document: document,
        variables: <String, dynamic>{'input': input},
      ),
    );
    _throwIfFailed(result);
    final Map<String, dynamic> payload =
        result.data?[operationName] as Map<String, dynamic>;
    return AuthSession(
      accessToken: payload['accessToken'] as String,
      user: _mapUser(payload['user'] as Map<String, dynamic>),
    );
  }

  void _throwIfFailed(QueryResult result) {
    if (result.hasException) {
      throw result.exception!;
    }
  }

  User _mapUser(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }
}
