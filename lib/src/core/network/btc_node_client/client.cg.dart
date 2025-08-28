import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:tron_energy_wallet_core/src/models/dto/btc_node/account_utxo.cg.dart';
import 'package:tron_energy_wallet_core/src/models/dto/btc_node/transaction.cg.dart';

part 'gen/client.cg.g.dart';

/// RestClient
@RestApi()
abstract interface class BtcNodeClient {
  /// RestClient
  factory BtcNodeClient(Dio dio) = _BtcNodeClient;

  /// Get utxos for address
  @GET('/premium-http/{blockBook}/{apiToken}/api/v1/utxo/{address}')
  Future<List<AppUtxoDtoV1>> fetchUtxosV1({
    @Path('address') required String address,
    @Path('blockBook') required String blockBook,
    @Path('apiToken') required String apiToken,
    @Query('confirmed') bool? confirmed,
  });

  /// Get utxos for address
  @GET('/premium-http/{blockBook}/{apiToken}/api/v2/utxo/{address}')
  Future<List<AppUtxoDtoV2>> fetchUtxosV2({
    @Path('address') required String address,
    @Path('blockBook') required String blockBook,
    @Path('apiToken') required String apiToken,
    @Query('confirmed') bool? confirmed,
  });

  /// Tx info
  @GET('/premium-http/{blockBook}/{apiToken}/api/v2/tx/{txId}')
  Future<TransactionBtcNodeDto> fetchTransaction({
    @Path('txId') required String txId,
    @Path('blockBook') required String blockBook,
    @Path('apiToken') required String apiToken,
  });
}
