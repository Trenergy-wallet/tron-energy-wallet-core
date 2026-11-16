import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// Service a [BlockbookProvider] sends its requests through
typedef BlockbookServiceProvider =
    IServiceProvider<BlockbookRequestDetails, BaseGRPCServiceRequestParams>;

/// Sends [BlockbookRequest]s to a Blockbook node (Bitcoin, Litecoin) through
/// the [service]
///
/// The same provider / service / request split as in bitcoin_base and
/// on_chain (blockchain_utils interfaces). bitcoin_base itself has no
/// Blockbook API, so the provider is ours
class BlockbookProvider
    extends IProvider<BlockbookServiceProvider, BlockbookRequestDetails> {
  /// Sends requests to a Blockbook node through the [service]
  BlockbookProvider(this.service);

  @override
  final BlockbookServiceProvider service;

  /// Unique identifier of a request
  int _id = 0;

  /// THROWS [RPCError] when the node answered with an error or the response
  /// can't be decoded, and whatever the [service] and
  /// [IServiceRequest.onResonse] throw
  @override
  Future<RESULT> request<RESULT, SERVICERESPONSE>(
    IServiceRequest<RESULT, SERVICERESPONSE, BlockbookRequestDetails> request, {
    Duration? timeout,
  }) async => request.onResonse(
    await requestDynamic<RESULT, SERVICERESPONSE>(request, timeout: timeout),
  );

  /// The response as it is received, not converted by the request
  ///
  /// THROWS [RPCError] when the node answered with an error or the response
  /// can't be decoded, and whatever the [service] throws
  @override
  Future<SERVICERESPONSE> requestDynamic<RESULT, SERVICERESPONSE>(
    IServiceRequest<RESULT, SERVICERESPONSE, BlockbookRequestDetails> request, {
    Duration? timeout,
  }) async {
    final params = request.buildRequest(_id++);
    final response = await service.doRequest(params, timeout: timeout);
    return params.toEncodingResponse<SERVICERESPONSE>(response);
  }
}
