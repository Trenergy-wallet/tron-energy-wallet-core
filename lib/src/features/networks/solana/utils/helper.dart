import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/solana/src/instructions/compute_budget/layouts/layouts/set_compute_unit_limit.dart';
import 'package:on_chain/solana/src/instructions/compute_budget/layouts/layouts/set_compute_unit_price.dart';
import 'package:on_chain/solana/src/instructions/compute_budget/program.dart';
import 'package:on_chain/solana/src/instructions/memo/layouts/memo.dart';
import 'package:on_chain/solana/src/instructions/memo/program.dart';
import 'package:on_chain/solana/src/models/transaction/instruction.dart';
import 'package:on_chain/solana/src/utils/utils.dart';
import 'package:tr_logger/tr_logger.dart';

/// Solana utilities
class SolanaHelper {
  /// Lamports => SOL
  static BigRational lamportsToSol(int lamports) => BigRational(
    BigInt.from(lamports),
    denominator: BigInt.from(SolanaUtils.lamportsPerSol),
  );

  /// Create compute budget heap frame size override instruction
  static TransactionInstruction createLimitInstruction(int units) {
    return ComputeBudgetProgram.setComputeUnitLimit(
      layout: ComputeBudgetSetComputeUnitLimitLayout(units: units),
    );
  }

  /// Create compute budget price instruction
  static TransactionInstruction createPriceInstruction(BigInt microLamports) {
    return ComputeBudgetProgram.setComputeUnitPrice(
      layout: ComputeBudgetSetComputeUnitPriceLayout(
        microLamports: microLamports,
      ),
    );
  }

  /// Create instruction to add Memo to tx. Limited to 100 symbols
  static TransactionInstruction createMemoInstruction(String message) {
    return MemoProgram(layout: MemoLayout(memo: message.maxLen(100)));
  }
}
