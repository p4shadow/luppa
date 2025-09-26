import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/query/product_query.dart';

// ignore: avoid_classes_with_only_static_members
class UserFeedbackHelper {
  static String getFeedbackFormLink() {
    final String languageCode = ProductQuery.getLanguage().code;
    // if (languageCode == 'en') {
    //   return 'https://formulario';
    // } else if (languageCode == 'de') {
    //   return 'https://formulario';
    // } else if (languageCode == 'es') {
    //   return 'https://formulario';
    // } else if (languageCode == 'fr') {
    //   return 'https://formulario';
    // } else if (languageCode == 'it') {
    //   return 'https://formulario';
    // } else {
    //   return 'https://formulario';
    // }
    return 'https://luppa.ar/formulario';
  }
}
