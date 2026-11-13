import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Parameters of a request to the Blockbook REST API
class BlockbookRequestDetails extends BaseServiceRequestParams {
  /// Parameters of a request to the Blockbook REST API
  ///
  /// [path] starts from the Blockbook root and carries the query
  const BlockbookRequestDetails({
    required super.requestID,
    required String super.path,
    required super.requestMethod,
    required super.responseEncoding,
    super.headers = const {},
    super.bodyBytes,
    super.bodyString,
  }) : super(network: BlockchainNetwork.bitcoinAndRelated);

  @override
  Uri encodeUrl(String url) => Uri.parse(
    '${url.endsWith('/') ? url.substring(0, url.length - 1) : url}$path',
  );

  @override
  Map<String, dynamic> toJson() => {
    'requestId': requestID,
    'type': requestMethod.name,
    'path': path,
    'body': bodyString ?? BytesUtils.tryToHexString(bodyBytes),
  };

  @override
  SerializationIdentifier get serializationIdentifier =>
      BlockchainNetwork.bitcoinAndRelated.identifier;

  @override
  List<CborObject?> get serializationItems => [
    CborMapValue.definite(
      headers.map((k, v) => MapEntry(CborStringValue(k), CborStringValue(v))),
    ),
    path?.toCbor(),
    requestMethod.value.toCbor(),
    responseEncoding.value.toCbor(),
    bodyBytes?.toCborBytes(),
    bodyString?.toCbor(),
    requestID.toCbor(),
  ];
}

/// Request to the Blockbook REST API, sent through a [BlockbookProvider]
abstract class BlockbookRequest<RESULT, RESPONSE>
    extends BaseServiceRequest<RESULT, RESPONSE, BlockbookRequestDetails> {
  /// Request to the Blockbook REST API
  const BlockbookRequest();

  /// Path from the Blockbook root, e.g. `/api/v2/tx/<txid>`
  String get path;

  /// Query parameters, null values are skipped
  Map<String, String?> get queryParameters => const {};

  @override
  RequestMethod get requestMethod => RequestMethod.get;

  @override
  BlockbookRequestDetails buildRequest(int requestID) {
    final query = {
      for (final MapEntry(:key, :value) in queryParameters.entries) key: ?value,
    };
    return BlockbookRequestDetails(
      requestID: requestID,
      path: query.isEmpty
          ? path
          : Uri(path: path, queryParameters: query).toString(),
      responseEncoding: ServiceReponseEncoding.fromType<RESPONSE>(),
      requestMethod: requestMethod,
    );
  }
}

/// UTXOs of the address, legacy API v1: includes the unconfirmed ones the
/// service looks for pending transactions in
class BlockbookRequestUtxosV1
    extends BlockbookRequest<List<AppUtxo>, List<Map<String, dynamic>>> {
  /// UTXOs of the address, API v1
  const BlockbookRequestUtxosV1({required this.address, this.confirmed});

  /// Wallet address
  final String address;

  /// Only confirmed UTXOs
  final bool? confirmed;

  @override
  String get path => '/api/v1/utxo/$address';

  @override
  Map<String, String?> get queryParameters => {
    'confirmed': confirmed?.toString(),
  };

  /// THROWS when the node sent a different model
  @override
  List<AppUtxo> onResonse(List<Map<String, dynamic>> result) => [
    for (final e in result) AppUtxoDtoV1.fromJson(e).toDomainOrThrow(),
  ];
}

/// UTXOs of the address, API v2
class BlockbookRequestUtxosV2
    extends BlockbookRequest<List<AppUtxo>, List<Map<String, dynamic>>> {
  /// UTXOs of the address, API v2
  const BlockbookRequestUtxosV2({required this.address, this.confirmed});

  /// Wallet address
  final String address;

  /// Only confirmed UTXOs
  final bool? confirmed;

  @override
  String get path => '/api/v2/utxo/$address';

  @override
  Map<String, String?> get queryParameters => {
    'confirmed': confirmed?.toString(),
  };

  /// THROWS when the node sent a different model
  @override
  List<AppUtxo> onResonse(List<Map<String, dynamic>> result) => [
    for (final e in result) AppUtxoDtoV2.fromJson(e).toDomainOrThrow(),
  ];
}

/// Transaction information, API v2
class BlockbookRequestTransaction
    extends BlockbookRequest<TransactionBtcNode, Map<String, dynamic>> {
  /// Transaction information, API v2
  const BlockbookRequestTransaction({required this.txId});

  /// Transaction id
  final String txId;

  @override
  String get path => '/api/v2/tx/$txId';

  /// THROWS when the node sent a different model
  @override
  TransactionBtcNode onResonse(Map<String, dynamic> result) =>
      TransactionBtcNodeDto.fromJson(result).toDomainOrThrow();
}
