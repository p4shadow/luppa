import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task.dart';
import 'package:smooth_app/background/background_task_add_other_price.dart';
import 'package:smooth_app/background/background_task_image.dart';
import 'package:smooth_app/background/background_task_price.dart';
import 'package:smooth_app/background/background_task_queue.dart';
import 'package:smooth_app/background/background_task_upload.dart';
import 'package:smooth_app/background/operation_type.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/crop_parameters.dart';
import 'package:smooth_app/query/product_query.dart';

// TODO(monsieurtanuki): use transient file, in order to have instant access to proof image?
/// Background task about adding a product price.
class BackgroundTaskAddPrice extends BackgroundTaskPrice {
  BackgroundTaskAddPrice._({
    required super.processName,
    required super.uniqueId,
    required super.stamp,
    // proof display
    required this.fullPath,
    required this.rotationDegrees,
    required this.cropX1,
    required this.cropY1,
    required this.cropX2,
    required this.cropY2,
    required this.proofType,
    required this.eraserCoordinates,
    required this.displaySnackbar,
    // single
    required super.date,
    required super.currency,
    required super.locationOSMId,
    required super.locationOSMType,
    // multi
    required super.barcodes,
    required super.categories,
    required super.origins,
    required super.labels,
    required super.pricePers,
    required super.pricesAreDiscounted,
    required super.prices,
    required super.pricesWithoutDiscount,
  });

  BackgroundTaskAddPrice.fromJson(super.json)
    : fullPath = json[_jsonTagImagePath] as String,
      rotationDegrees = json[_jsonTagRotation] as int? ?? 0,
      cropX1 = json[_jsonTagX1] as int? ?? 0,
      cropY1 = json[_jsonTagY1] as int? ?? 0,
      cropX2 = json[_jsonTagX2] as int? ?? 0,
      cropY2 = json[_jsonTagY2] as int? ?? 0,
      proofType = ProofType.fromOffTag(json[_jsonTagProofType] as String)!,
      eraserCoordinates = BackgroundTaskPrice.fromJsonListDouble(
        json[_jsonTagEraserCoordinates],
      ),
      displaySnackbar = json[_jsonTagDisplaySnackbar] as bool? ?? true,
      super.fromJson();

  static const String _jsonTagImagePath = 'imagePath';
  static const String _jsonTagRotation = 'rotation';
  static const String _jsonTagX1 = 'x1';
  static const String _jsonTagY1 = 'y1';
  static const String _jsonTagX2 = 'x2';
  static const String _jsonTagY2 = 'y2';
  static const String _jsonTagProofType = 'proofType';
  static const String _jsonTagEraserCoordinates = 'eraserCoordinates';
  static const String _jsonTagDisplaySnackbar = 'displaySnackbar';

  static const OperationType _operationType = OperationType.addPrice;

  final String fullPath;
  final int rotationDegrees;
  final int cropX1;
  final int cropY1;
  final int cropX2;
  final int cropY2;
  final ProofType proofType;
  final List<double>? eraserCoordinates;
  final bool displaySnackbar;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = super.toJson();
    result[_jsonTagImagePath] = fullPath;
    result[_jsonTagRotation] = rotationDegrees;
    result[_jsonTagX1] = cropX1;
    result[_jsonTagY1] = cropY1;
    result[_jsonTagX2] = cropX2;
    result[_jsonTagY2] = cropY2;
    result[_jsonTagProofType] = proofType.offTag;
    result[_jsonTagEraserCoordinates] = eraserCoordinates;
    result[_jsonTagDisplaySnackbar] = displaySnackbar;
    return result;
  }

  /// Adds the background task about uploading a product image.
  static Future<void> addTask({
    required final BuildContext context,
    required final CropParameters cropObject,
    required final ProofType proofType,
    required final DateTime date,
    required final Currency currency,
    required final int locationOSMId,
    required final LocationOSMType locationOSMType,
    required final List<String> barcodes,
    required final List<String> categories,
    required final List<List<String>> origins,
    required final List<List<String>> labels,
    required final List<String> pricePers,
    required final List<bool> pricesAreDiscounted,
    required final List<double> prices,
    required final List<double?> pricesWithoutDiscount,
    required final bool displaySnackbar,
  }) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final String uniqueId = await _operationType.getNewKey(localDatabase);
    final BackgroundTask task = _getNewTask(
      uniqueId: uniqueId,
      cropObject: cropObject,
      proofType: proofType,
      date: date,
      currency: currency,
      locationOSMId: locationOSMId,
      locationOSMType: locationOSMType,
      barcodes: barcodes,
      categories: categories,
      origins: origins,
      labels: labels,
      pricePers: pricePers,
      pricesAreDiscounted: pricesAreDiscounted,
      prices: prices,
      pricesWithoutDiscount: pricesWithoutDiscount,
      displaySnackbar: displaySnackbar,
    );
    if (!context.mounted) {
      return;
    }
    await task.addToManager(
      localDatabase,
      context: context,
      queue: BackgroundTaskQueue.slow,
    );
  }

  /// Returns a new background task about changing a product.
  static BackgroundTaskAddPrice _getNewTask({
    required final String uniqueId,
    required final CropParameters cropObject,
    required final ProofType proofType,
    required final DateTime date,
    required final Currency currency,
    required final int locationOSMId,
    required final LocationOSMType locationOSMType,
    required final List<String> barcodes,
    required final List<String> categories,
    required final List<List<String>> origins,
    required final List<List<String>> labels,
    required final List<String> pricePers,
    required final List<bool> pricesAreDiscounted,
    required final List<double> prices,
    required final List<double?> pricesWithoutDiscount,
    required final bool displaySnackbar,
  }) => BackgroundTaskAddPrice._(
    uniqueId: uniqueId,
    processName: _operationType.processName,
    fullPath: cropObject.fullFile!.path,
    rotationDegrees: cropObject.rotation,
    cropX1: cropObject.x1,
    cropY1: cropObject.y1,
    cropX2: cropObject.x2,
    cropY2: cropObject.y2,
    proofType: proofType,
    date: date,
    currency: currency,
    locationOSMId: locationOSMId,
    locationOSMType: locationOSMType,
    eraserCoordinates: cropObject.eraserCoordinates,
    barcodes: barcodes,
    categories: categories,
    origins: origins,
    labels: labels,
    pricePers: pricePers,
    pricesAreDiscounted: pricesAreDiscounted,
    prices: prices,
    pricesWithoutDiscount: pricesWithoutDiscount,
    stamp: BackgroundTaskPrice.getStamp(
      date: date,
      locationOSMId: locationOSMId,
      locationOSMType: locationOSMType,
    ),
    displaySnackbar: displaySnackbar,
  );

  @override
  (String, AlignmentGeometry)? getFloatingMessage(
    final AppLocalizations appLocalizations,
  ) => displaySnackbar ? super.getFloatingMessage(appLocalizations) : null;

  @override
  Future<void> postExecute(
    final LocalDatabase localDatabase,
    final bool success,
  ) async {
    await super.postExecute(localDatabase, success);
    try {
      (await BackgroundTaskUpload.getFile(fullPath)).deleteSync();
    } catch (e) {
      // not likely, but let's not spoil the task for that either.
    }
    try {
      (await BackgroundTaskUpload.getFile(
        await BackgroundTaskImage.getCroppedPath(fullPath),
      )).deleteSync();
    } catch (e) {
      // possible, but let's not spoil the task for that either.
    }
  }

  @override
  Future<void> execute(final LocalDatabase localDatabase) async {
    final String? path = await BackgroundTaskImage.cropIfNeeded(
      fullPath: fullPath,
      rotationDegrees: rotationDegrees,
      cropX1: cropX1,
      cropY1: cropY1,
      cropX2: cropX2,
      cropY2: cropY2,
      compressQuality: 80,
      forceCompression: true,
      eraserCoordinates: eraserCoordinates,
    );
    if (path == null) {
      // TODO(monsieurtanuki): maybe something more refined when we dismiss the picture, like alerting the user, though it's not supposed to happen anymore from upstream.
      return;
    }

    final String bearerToken = await getBearerToken(localDatabase);

    // proof upload
    final Uri initialImageUri = Uri.parse(path);
    final MediaType initialMediaType = HttpHelper().imagineMediaType(
      initialImageUri.path,
    )!;
    final MaybeError<Proof> uploadProof = await OpenPricesAPIClient.uploadProof(
      createProofParameters: CreateProofParameters(proofType)
        ..date = date
        ..currency = currency
        ..locationOSMId = locationOSMId
        ..locationOSMType = locationOSMType
        ..readyForPriceTagValidation = proofType == ProofType.priceTag,
      imageUri: initialImageUri,
      mediaType: initialMediaType,
      bearerToken: bearerToken,
      uriHelper: ProductQuery.uriPricesHelper,
    );
    if (uploadProof.isError) {
      throw Exception('Could not upload proof: ${uploadProof.error}');
    }

    await BackgroundTaskAddOtherPrice.addTask(
      context: null,
      localDatabase: localDatabase,
      proofId: uploadProof.value.id,
      date: date,
      currency: currency,
      locationOSMId: locationOSMId,
      locationOSMType: locationOSMType,
      barcodes: barcodes,
      categories: categories,
      origins: origins,
      labels: labels,
      pricePers: pricePers,
      pricesAreDiscounted: pricesAreDiscounted,
      prices: prices,
      pricesWithoutDiscount: pricesWithoutDiscount,
    );
  }
}
