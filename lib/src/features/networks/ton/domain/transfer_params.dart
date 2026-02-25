import 'package:tron_energy_wallet_core/tron_energy_wallet_core.dart';

/// TransferParamsTON
class TransferParamsTON extends TransferParams {
  /// TransferParamsTON
  ///
  /// [to] - address to send to
  /// [amount] - number of coins to send
  /// [message] - optional message to add to the transaction
  /// [coinInfo] - jetton info. Required for jetton transfers
  const TransferParamsTON({
    required super.to,
    required super.from,
    required super.amount,
    required super.tokenWalletType,
    this.coinInfo = JettonInfoTON.empty,
    super.message,
  }) : assert(
         tokenWalletType == TokenWalletType.master ||
             coinInfo != JettonInfoTON.empty,
         'coinInfo is required for jettons',
       ),
       super(appBlockchain: AppBlockchain.ton);

  /// Info about coin on TON
  final JettonInfoTON coinInfo;
}

/// Info about coin on TON
class JettonInfoTON {
  /// Info about coin on TON
  const JettonInfoTON({
    required this.id,
    required this.name,
    required this.shortName,
    required this.icon,
    required this.decimal,
    required this.contractAddress,
    required this.childWalletAddress,
  });

  /// ID
  final int id;

  /// Token name
  final String name;

  /// ShortName
  final String shortName;

  /// Icon
  final String icon;

  /// Token decimal
  final int decimal;

  /// Jetton address
  final String childWalletAddress;

  /// Token contract
  final String contractAddress;

  /// Dummy
  ///
  /// Use it for TON transfer
  static const empty = JettonInfoTON(
    id: CoreConsts.invalidIntValue,
    name: '',
    shortName: '',
    icon: '',
    decimal: CoreConsts.invalidIntValue,
    contractAddress: '',
    childWalletAddress: '',
  );
}
