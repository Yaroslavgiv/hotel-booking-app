import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hotel_booking_app/core/config/app_config.dart';
import 'package:hotel_booking_app/core/security/token_storage.dart';

class GraphQLApiClient {
  GraphQLApiClient(TokenStorage tokenStorage)
    : notifier = ValueNotifier<GraphQLClient>(
        GraphQLClient(
          link: Link.from(<Link>[
            AuthLink(
              getToken: () async {
                final String? token = await tokenStorage.read();
                return token == null ? null : 'Bearer $token';
              },
            ),
            HttpLink(AppConfig.graphQLEndpoint),
          ]),
          cache: GraphQLCache(),
        ),
      );

  final ValueNotifier<GraphQLClient> notifier;
  GraphQLClient get client => notifier.value;
}
