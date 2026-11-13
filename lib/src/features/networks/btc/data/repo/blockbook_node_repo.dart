import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart' show RPCError;
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// [BTCNodeRepo] over a Blockbook node (Bitcoin, Litecoin)
///
/// The node provider comes from outside, as in the other network services:
/// `BlockbookProvider(BlockbookHTTPProvider(url: ..., client: ...,
/// getAuthorization: ...))`. Long-lived, owned by the caller: the repo never
/// closes it
final class BlockbookNodeRepo implements BTCNodeRepo {
  /// [BTCNodeRepo] over a Blockbook node
  const BlockbookNodeRepo({required this.rpc});

  /// Node provider
  final BlockbookProvider rpc;

  @override
  Future<List<AppUtxo>> fetchUtxosV1({
    required String address,
    bool? confirmed,
  }) => _request(
    BlockbookRequestUtxosV1(address: address, confirmed: confirmed),
  );

  @override
  Future<List<AppUtxo>> fetchUtxosV2({
    required String address,
    bool? confirmed,
  }) => _request(
    BlockbookRequestUtxosV2(address: address, confirmed: confirmed),
  );

  @override
  Future<TransactionBtcNode> fetchTransaction({
    required String txId,
  }) => _request(BlockbookRequestTransaction(txId: txId));

  /// THROWS only [AppExceptionWithCode], so that the caller gets an error
  /// code whatever went wrong:
  ///
  /// - no response (timeout, connection) - `connectionTimeout`
  /// - the node answered with an error status - `rpcError`
  /// - a successful response that is not the model (not a JSON, another
  ///   shape, a missing or malformed field) - `checkedFromJsonException`
  /// - an [AppExceptionWithCode] of the injected client - as is
  /// - any other exception of the client - `rpcError`
  Future<RESULT> _request<RESULT, RESPONSE>(
    BlockbookRequest<RESULT, RESPONSE> request,
  ) async {
    try {
      return await rpc.request(request);
    } on AppExceptionWithCode {
      rethrow;
    } on TimeoutException catch (e, st) {
      throw _connectionError(request, e, st);
    } on http.ClientException catch (e, st) {
      throw _connectionError(request, e, st);
    } on RPCError catch (e, st) {
      final statusCode = e.statusCode;
      // With a successful status the provider throws only when it can't
      // decode the body to the type the request expects
      if (statusCode == null || (statusCode >= 200 && statusCode < 300)) {
        throw _unexpectedResponse(request, e.message, st);
      }
      throw AppRpcException(
        message: '${request.path}: $statusCode ${e.message}',
        stackTrace: st,
      );
    } on CheckedFromJsonException catch (e, st) {
      throw _unexpectedResponse(request, e, st);
    } on FormatException catch (e, st) {
      // A number of the model that is not a number
      throw _unexpectedResponse(request, e, st);
    } on Exception catch (e, st) {
      throw AppRpcException(message: '${request.path}: $e', stackTrace: st);
      // A response of an unexpected shape fails the casts and the null
      // checks of the DTOs: that is a node answer, an error with a code
      // ignore: avoid_catching_errors
    } on TypeError catch (e, st) {
      throw _unexpectedResponse(request, e, st);
    }
  }

  AppRpcException _connectionError(
    BlockbookRequest<dynamic, dynamic> request,
    Object error,
    StackTrace stackTrace,
  ) => AppRpcException(
    message: '${request.path}: $error',
    code: ExceptionCode.connectionTimeout,
    stackTrace: stackTrace,
  );

  AppRpcException _unexpectedResponse(
    BlockbookRequest<dynamic, dynamic> request,
    Object error,
    StackTrace stackTrace,
  ) => AppRpcException(
    message: '${request.path}: unexpected response: $error',
    code: ExceptionCode.checkedFromJsonException,
    stackTrace: stackTrace,
  );
}
