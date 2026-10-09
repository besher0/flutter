import 'package:get_it/get_it.dart';
import '../common/constant/configuration/bunny_url_routes.dart';
import '../common/constant/configuration/url_routes.dart';
import '../storage/prefs_repository.dart';

enum ServerName { master, bunny }

Uri getBaseUriForSpecificServer(ServerName serverName) {
  switch (serverName) {
    case ServerName.master:
      return MasterUrlRoutes.baseUri;
    case ServerName.bunny:
      return BunnyUrlRoutes.baseUri;
  }
}

/// Request path on [serverName]; backend routes are versioned (/v2).
String apiPathFor(ServerName serverName, String endpoint) {
  switch (serverName) {
    case ServerName.master:
      return MasterUrlRoutes.apiPath(endpoint);
    case ServerName.bunny:
      return endpoint;
  }
}

String? getServerToken(ServerName serverName) {
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  switch (serverName) {
    case ServerName.master:
      return prefsRepository.token;
    case ServerName.bunny:
      return null;
  }
}
